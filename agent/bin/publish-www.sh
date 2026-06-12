#!/bin/sh
# Publie le site : sources statiques + journal + comptes -> /data/www.
set -eu
REPO=/data/repo
WWW=/data/www
mkdir -p "$WWW/journal"
# site/ embarque site/i18n/ (chaînes UI par langue, décision 0004) -> /i18n/
cp -r "$REPO/site/." "$WWW/"
# Seul journal/public/ est publié : récit en anglais pour le grand public.
# Le reste de journal/ (courriers, comptes-rendus techniques) reste interne.
rm -f "$WWW/journal/"*.md
cp "$REPO/journal/public/"*.md "$WWW/journal/" 2>/dev/null || true
# shellcheck disable=SC2010
ls "$WWW/journal" | grep '\.md$' | sort -r | jq -R . | jq -s . > "$WWW/journal/index.json"
# Traductions du journal (décision 0004) : journal/public/{lang}/*.md, même
# nom de fichier que la source anglaise. Un index.json par langue, toujours
# présent (vide si rien de traduit) pour éviter les 404 côté navigateur.
for lang in fr es pt de it ja ko zh; do
  mkdir -p "$WWW/journal/$lang"
  rm -f "$WWW/journal/$lang/"*.md
  cp "$REPO/journal/public/$lang/"*.md "$WWW/journal/$lang/" 2>/dev/null || true
  # shellcheck disable=SC2010
  ls "$WWW/journal/$lang" | grep '\.md$' | sort -r | jq -R . | jq -s . \
    > "$WWW/journal/$lang/index.json"
done
# Statut public (widget survie du site) : dernier solde du livre de comptes.
BALANCE=$(awk -F'|' '/^\|/ && NF >= 6 {b = $6} END {gsub(/^ +| +$/, "", b); print b}' \
  "$REPO/comptes/livre.md" 2>/dev/null || echo "")
# Crédits Stable Audio : dernière valeur "→ NNNN" du livre de comptes.
CREDITS=$(grep -oE '[→>] [0-9]+' "$REPO/comptes/livre.md" 2>/dev/null | tail -1 | awk '{print $2}' || echo "")
# Nombre de pistes musicales actives (track-*.mp3, hors dj-*).
TRACKS_COUNT=$(ls /data/music/active/track-*.mp3 2>/dev/null | wc -l | tr -d ' ')
jq -n --arg balance "$BALANCE" --arg born "2026-06-10" \
  --arg credits "$CREDITS" --arg tracks "$TRACKS_COUNT" \
  '{balance: $balance, born: $born, credits: $credits, tracks: $tracks}' > "$WWW/status.json"

# -----------------------------------------------------------------------
# Catalogue pistes musicales (décision 0008 — page /tracks)
# Copie les pistes MUSIC (hors dj-*) dans /data/www/music/ et génère :
#   - tracks.json   : [{file, title, duration}] pour la page tracks.html
#   - tracks-list.txt : liste brute des noms de fichiers pour le vote-api
# -----------------------------------------------------------------------
MUSIC_SRC=/data/music/active
MUSIC_DST="$WWW/music"
mkdir -p "$MUSIC_DST"

# Vide les pistes précédentes pour ne pas conserver des pistes retirées.
rm -f "$MUSIC_DST"/*.mp3

TRACKS_JSON="[]"
TRACK_LIST=""

for f in "$MUSIC_SRC"/track-*.mp3; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  # Titre lisible : strip "track-NN-", remplace "-" par espace, Title Case.
  readable=$(echo "$base" \
    | sed 's/^track-[0-9]*-//' \
    | sed 's/\.mp3$//' \
    | sed 's/-/ /g' \
    | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')
  # Durée via ffprobe (retourne N secondes, on convertit en MM:SS).
  dur_s=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$f" 2>/dev/null | cut -d. -f1 || echo "0")
  mins=$((dur_s / 60))
  secs=$((dur_s % 60))
  duration=$(printf "%d:%02d" "$mins" "$secs")
  # Copie MP3.
  cp "$f" "$MUSIC_DST/$base"
  # Accumule JSON.
  TRACKS_JSON=$(printf '%s' "$TRACKS_JSON" \
    | jq --arg file "$base" --arg title "$readable" --arg dur "$duration" \
        '. + [{file: $file, title: $title, duration: $dur}]')
  # Accumule liste texte.
  TRACK_LIST="${TRACK_LIST}${base}
"
done

printf '%s' "$TRACKS_JSON" | jq '.' > "$WWW/tracks.json"
# Fichier utilisé par le vote-api pour valider les noms de pistes soumis.
printf '%s' "$TRACK_LIST" | sed '/^$/d' > "$WWW/tracks-list.txt"

echo "publish-www: $(echo "$TRACK_LIST" | grep -c '.mp3' || true) tracks exported"
