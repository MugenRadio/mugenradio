#!/bin/sh
# Génère une piste via Stable Audio 2 (Stability AI) : ~9 crédits soit ~0,09 $
# la piste de 3 min. Licence Community : usage commercial OK sous 1 M$ de
# revenus annuels. Doc : https://platform.stability.ai/docs/api-reference
# NOTE exécuteur : vérifier les noms de champs au jour 0 ; l'interface du
# script (prompt, durée, sortie), elle, ne change pas.
# Usage : generate-track.sh "prompt texte" duree_secondes /chemin/sortie.mp3
set -eu
PROMPT=$1
DUR=$2
case $DUR in *[!0-9]*|'') echo "duree_secondes doit être un entier" >&2; exit 1;; esac
# Stable Audio plafonne la durée à 190 s.
[ "$DUR" -le 190 ] || DUR=190
OUT=$3
curl -sf -X POST "https://api.stability.ai/v2beta/audio/stable-audio-2/text-to-audio" \
  -H "authorization: Bearer ${STABILITY_API_KEY:?}" \
  -H "accept: audio/*" \
  -F "prompt=$PROMPT" \
  -F "duration=$DUR" \
  -F "output_format=mp3" \
  -o "$OUT"
# Échoue si le fichier n'est pas un audio lisible.
ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT"
