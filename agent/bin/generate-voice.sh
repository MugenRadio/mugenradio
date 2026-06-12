#!/bin/sh
# Voix antenne (DJ) via Kokoro TTS, service interne gratuit (CPU local).
# La voix parle ANGLAIS. Usage : generate-voice.sh "texte" /chemin/sortie.mp3 [voix]
set -eu
TEXT=$1
OUT=$2
VOICE=${3:-af_heart}
curl -sf -X POST "http://kokoro.radio.svc.cluster.local:8880/v1/audio/speech" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TEXT" --arg v "$VOICE" \
        '{model:"kokoro", input:$t, voice:$v, response_format:"mp3", speed:1.0}')" \
  -o "$OUT"
# Échoue si le fichier n'est pas un audio lisible.
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
