#!/bin/sh
# Rend site/loop-scene.html (jardin zen, décisions 0002/0003) en boucle vidéo
# 1920x1080 30 fps sans couture pour la diffusion (le stream recopie cette
# vidéo telle quelle : GOP 2 s et plafond 4 Mb/s obligatoires).
#
# Deux modes :
#   - simple (défaut)   : une scène (b par défaut, --scene a|b|c), boucle 60 s.
#   - --broadcast       : rotation 3 scènes de la décision 0003 —
#                         A (夕暮れ) → B (深夜) → C (黎明) → A, 210 s de tenue
#                         par scène, fondus croisés de 45 s, total 765 s.
#                         Chaque scène est d'abord rendue en base 60 s sans
#                         couture, puis tuilée à la longueur voulue : les
#                         animations du jardin (cascade, koi, pétales) sont à
#                         cycle court, une base 60 s répétée est visuellement
#                         identique à une capture pleine durée, pour 12x moins
#                         de frames à capturer (5580 au lieu de 22950).
#
# ATTENTION : nécessite un Chrome/Chromium local + node + ffmpeg. L'image
# radio-brain du cluster n'a PAS de Chrome : ce script se lance depuis une
# machine de travail, puis pousse le mp4 sur le PVC via ssh + kubectl (--deploy).
#
# Méthode de capture : les animations CSS sont mises en pause via la Web
# Animations API (document.getAnimations) et le temps est avancé image par
# image en fixant currentTime — rendu déterministe, aucune frame perdue.
# Couture par scène : on capture LOOP+FADE secondes, puis la fin (60→62 s) est
# fondue (xfade) dans le début (0→2 s) ; le point de bouclage retombe sur une
# frame identique à la frame d'entrée.
# Couture broadcast : le dernier fondu C→A (720→765 s) se fait vers la base A
# prise à la phase 15 s (765 mod 60), si bien qu'à 765 s la phase A vaut 60≡0 :
# le retour au début de la boucle est continu, animations comprises.
#
# Usage : render-loop.sh [sortie.mp4] [--scene a|b|c] [--broadcast] [--deploy]
set -eu

REPO=$(cd "$(dirname "$0")/../.." && pwd)
OUT=loop.mp4
DEPLOY=0
BROADCAST=0
SCENE=b
while [ $# -gt 0 ]; do
  case "$1" in
    --deploy) DEPLOY=1 ;;
    --broadcast) BROADCAST=1 ;;
    --scene) shift; SCENE=$1 ;;
    *) OUT=$1 ;;
  esac
  shift
done
case "$SCENE" in a|b|c) ;; *) echo "--scene doit être a, b ou c"; exit 1 ;; esac
case "$OUT" in /*) ;; *) OUT=$PWD/$OUT ;; esac

FPS=30
LOOP=60          # durée d'une base de scène en secondes
FADE=2           # secondes de fondu tête/queue pour masquer la couture de base
BASE_MS=600000   # offset : 10 min de "régime établi" (pétales etc. en vol)
WIDTH=1920
HEIGHT=1080
HOLD=210         # décision 0003 : tenue par scène
XFADE=45         # décision 0003 : durée des fondus croisés
# Timeline broadcast : A 0-210, fondu 210-255, B 255-465, fondu 465-510,
# C 510-720, fondu de bouclage C→A 720-765. 3x210 + 3x45 = 765 s.

CHROME=${CHROME_BIN:-}
if [ -z "$CHROME" ]; then
  for c in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then CHROME=$(command -v "$c"); break; fi
  done
fi
[ -n "$CHROME" ] || { echo "Chrome introuvable (définir CHROME_BIN)"; exit 1; }
command -v node >/dev/null || { echo "node requis"; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg requis"; exit 1; }

# /var/tmp (disque) plutôt que /tmp (tmpfs) : ~4 Go de PNG par scène
WORK=$(mktemp -d /var/tmp/render-loop.XXXXXX)
trap 'rm -rf "$WORK"' EXIT

TOTAL_FRAMES=$(( (LOOP + FADE) * FPS ))
MID_END=$(( LOOP * FPS ))
FADE_FRAMES=$(( FADE * FPS ))

echo "== puppeteer-core =="
npm install --prefix "$WORK" --no-audit --no-fund --loglevel=error puppeteer-core >/dev/null

cat > "$WORK/capture.cjs" <<'EOF'
const puppeteer = require("puppeteer-core");
const [,, pageUrl, outDir, framesStr, fpsStr, baseStr, chromePath, w, h] = process.argv;
const frames = +framesStr, fps = +fpsStr, base = +baseStr;
(async () => {
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ["--hide-scrollbars", "--force-device-scale-factor=1"],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: +w, height: +h, deviceScaleFactor: 1 });
  await page.goto(pageUrl, { waitUntil: "networkidle0" });
  await page.evaluate(() => {
    window.__anims = document.getAnimations();
    window.__anims.forEach((a) => a.pause());
  });
  for (let i = 0; i < frames; i++) {
    const t = base + (i * 1000) / fps;
    await page.evaluate(async (t) => {
      window.__anims.forEach((a) => { a.currentTime = t; });
      await new Promise(requestAnimationFrame);
    }, t);
    await page.screenshot({
      path: `${outDir}/f${String(i).padStart(5, "0")}.png`,
      optimizeForSpeed: true,
    });
    if (i % 300 === 0) console.log(`frame ${i}/${frames}`);
  }
  await browser.close();
})().catch((e) => { console.error(e); process.exit(1); });
EOF

# rend une scène en boucle 60 s sans couture
# $1 = scène (a|b|c)   $2 = mp4 de sortie   $3 = options d'encodage ffmpeg
render_base() {
  _scene=$1; _out=$2; _enc=$3
  rm -rf "$WORK/frames"; mkdir -p "$WORK/frames"
  echo "== scène $_scene : capture de $TOTAL_FRAMES frames à $FPS fps =="
  NODE_PATH="$WORK/node_modules" node "$WORK/capture.cjs" \
    "file://$REPO/site/loop-scene.html?scene=$_scene" "$WORK/frames" \
    "$TOTAL_FRAMES" "$FPS" "$BASE_MS" "$CHROME" "$WIDTH" "$HEIGHT"
  echo "== scène $_scene : encodage (couture xfade ${FADE}s) =="
  # shellcheck disable=SC2086
  ffmpeg -hide_banner -loglevel warning -y \
    -framerate "$FPS" -i "$WORK/frames/f%05d.png" \
    -filter_complex "\
[0:v]trim=start_frame=$FADE_FRAMES:end_frame=$MID_END,setpts=PTS-STARTPTS[mid];\
[0:v]trim=start_frame=$MID_END,setpts=PTS-STARTPTS[tail];\
[0:v]trim=end_frame=$FADE_FRAMES,setpts=PTS-STARTPTS[head];\
[tail][head]xfade=transition=fade:duration=$FADE:offset=0[seam];\
[mid][seam]concat=n=2:v=1[v]" \
    -map "[v]" -an -r "$FPS" $_enc \
    "$_out"
  rm -rf "$WORK/frames"
}

# encodage final : ce que le stream recopie tel quel
ENC_STREAM="-c:v libx264 -preset medium -b:v 4M -maxrate 4M -bufsize 8M -g 60 -keyint_min 60 -pix_fmt yuv420p"
# intermédiaires broadcast : quasi sans perte, ré-encodés à l'assemblage
ENC_INTER="-c:v libx264 -preset veryfast -crf 10 -g 60 -pix_fmt yuv420p"

if [ "$BROADCAST" = 1 ]; then
  for s in a b c; do
    render_base "$s" "$WORK/scene-$s.mp4" "$ENC_INTER"
  done
  echo "== assemblage broadcast : A→B→C→A, fondus ${XFADE}s, total 765 s =="
  # A tuilée 255 s, B et C 300 s (tenue + part des deux fondus) ; le 4e flux
  # est la queue de bouclage : A en phase 15→60 s pour retomber pile sur la
  # première frame de la boucle à 765 s.
  FADE2=$(( HOLD + XFADE ))                       # 255 : fin du fondu A→B
  OFF_BC=$(( FADE2 + HOLD ))                      # 465 : début du fondu B→C
  OFF_CA=$(( OFF_BC + XFADE + HOLD ))             # 720 : début du fondu C→A
  # phase A de la queue : il faut WRAP_START + XFADE ≡ 0 (mod LOOP) -> 15
  WRAP_START=$(( (LOOP - XFADE % LOOP) % LOOP ))
  # shellcheck disable=SC1087,SC2086
  ffmpeg -hide_banner -loglevel warning -y \
    -stream_loop 4 -t "$FADE2" -i "$WORK/scene-a.mp4" \
    -stream_loop 4 -t "$(( HOLD + 2 * XFADE ))" -i "$WORK/scene-b.mp4" \
    -stream_loop 4 -t "$(( HOLD + 2 * XFADE ))" -i "$WORK/scene-c.mp4" \
    -i "$WORK/scene-a.mp4" \
    -filter_complex "\
[3:v]trim=start=$WRAP_START:end=$LOOP,setpts=PTS-STARTPTS[awrap];\
[0:v][1:v]xfade=transition=fade:duration=$XFADE:offset=${HOLD}[ab];\
[ab][2:v]xfade=transition=fade:duration=$XFADE:offset=${OFF_BC}[abc];\
[abc][awrap]xfade=transition=fade:duration=$XFADE:offset=${OFF_CA}[v]" \
    -map "[v]" -an -r "$FPS" $ENC_STREAM \
    "$OUT"
else
  render_base "$SCENE" "$OUT" "$ENC_STREAM"
fi

echo "== fait : $OUT =="
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"

if [ "$DEPLOY" = 1 ]; then
  echo "== deploiement sur le PVC + restart stream =="
  scp "$OUT" gheop.com:/tmp/loop-upload.mp4
  ssh gheop.com '
    set -e
    POD=$(sudo kubectl -n radio get pod -l app=stream \
      -o jsonpath="{.items[0].metadata.name}")
    sudo kubectl -n radio exec -i "$POD" -- \
      sh -c "cat > /data/video/loop.mp4.new" < /tmp/loop-upload.mp4
    sudo kubectl -n radio exec "$POD" -- \
      mv /data/video/loop.mp4.new /data/video/loop.mp4
    rm /tmp/loop-upload.mp4
    sudo kubectl -n radio rollout restart deployment/stream
    sudo kubectl -n radio rollout status deployment/stream --timeout=180s
  '
  echo "== stream relance sur la nouvelle boucle =="
fi
