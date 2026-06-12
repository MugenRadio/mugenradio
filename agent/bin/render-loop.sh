#!/bin/sh
# Rend site/loop-scene.html (jardin zen, scène B 深夜 — décision 0002) en une
# boucle vidéo 1920x1080 30 fps de 60 s, sans couture, pour la diffusion
# (le stream recopie cette vidéo telle quelle : GOP 2 s obligatoire).
#
# ATTENTION : nécessite un Chrome/Chromium local + node + ffmpeg. L'image
# radio-brain du cluster n'a PAS de Chrome : ce script se lance depuis une
# machine de travail, puis pousse le mp4 sur le PVC via ssh + kubectl (--deploy).
#
# Méthode de capture : les animations CSS sont mises en pause via la Web
# Animations API (document.getAnimations) et le temps est avancé image par
# image en fixant currentTime — rendu déterministe, aucune frame perdue.
# Couture : on capture LOOP+FADE secondes, puis la fin (60→62 s) est fondue
# (xfade) dans le début (0→2 s) ; le point de bouclage retombe sur une frame
# identique à la frame d'entrée.
#
# Usage : render-loop.sh [sortie.mp4] [--deploy]
set -eu

REPO=$(cd "$(dirname "$0")/../.." && pwd)
OUT=loop.mp4
DEPLOY=0
for arg in "$@"; do
  case "$arg" in
    --deploy) DEPLOY=1 ;;
    *) OUT=$arg ;;
  esac
done

FPS=30
LOOP=60          # durée finale en secondes
FADE=2           # secondes de fondu tête/queue pour masquer la couture
BASE_MS=600000   # offset : 10 min de "régime établi" (pétales etc. en vol)
WIDTH=1920
HEIGHT=1080

CHROME=${CHROME_BIN:-}
if [ -z "$CHROME" ]; then
  for c in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then CHROME=$(command -v "$c"); break; fi
  done
fi
[ -n "$CHROME" ] || { echo "Chrome introuvable (définir CHROME_BIN)"; exit 1; }
command -v node >/dev/null || { echo "node requis"; exit 1; }
command -v ffmpeg >/dev/null || { echo "ffmpeg requis"; exit 1; }

WORK=$(mktemp -d /tmp/render-loop.XXXXXX)
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/frames"

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

echo "== capture: $TOTAL_FRAMES frames a $FPS fps =="
NODE_PATH="$WORK/node_modules" node "$WORK/capture.cjs" \
  "file://$REPO/site/loop-scene.html" "$WORK/frames" \
  "$TOTAL_FRAMES" "$FPS" "$BASE_MS" "$CHROME" "$WIDTH" "$HEIGHT"

echo "== encodage (couture xfade ${FADE}s) =="
ffmpeg -hide_banner -loglevel warning -y \
  -framerate "$FPS" -i "$WORK/frames/f%05d.png" \
  -filter_complex "\
[0:v]trim=start_frame=$FADE_FRAMES:end_frame=$MID_END,setpts=PTS-STARTPTS[mid];\
[0:v]trim=start_frame=$MID_END,setpts=PTS-STARTPTS[tail];\
[0:v]trim=end_frame=$FADE_FRAMES,setpts=PTS-STARTPTS[head];\
[tail][head]xfade=transition=fade:duration=$FADE:offset=0[seam];\
[mid][seam]concat=n=2:v=1[v]" \
  -map "[v]" -an -r "$FPS" \
  -c:v libx264 -preset medium -b:v 4M -maxrate 4M -bufsize 8M \
  -g 60 -keyint_min 60 -pix_fmt yuv420p \
  "$OUT"

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
