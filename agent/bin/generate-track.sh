#!/bin/sh
# Génère une piste via ElevenLabs Music (API officielle, droits commerciaux
# sur plan payant). Doc : https://elevenlabs.io/docs/api-reference/music
# NOTE exécuteur : vérifier le nom exact du champ durée dans la doc au moment
# de l'exécution ; l'API évolue. Le contrat du script, lui, ne change pas.
# Usage : generate-track.sh "prompt texte" duree_secondes /chemin/sortie.mp3
set -eu
PROMPT=$1
DUR=$2
OUT=$3
curl -sf -X POST "https://api.elevenlabs.io/v1/music" \
  -H "xi-api-key: ${ELEVENLABS_API_KEY:?}" \
  -H "Content-Type: application/json" \
  -d "{\"prompt\": $(printf '%s' "$PROMPT" | jq -Rs .), \"music_length_ms\": $((DUR * 1000))}" \
  -o "$OUT"
# Échoue si le fichier n'est pas un audio lisible.
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
