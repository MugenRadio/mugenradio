#!/bin/sh
# Upload une vidéo (Short) sur la chaîne. OAuth créé au jour 0 (docs/jour0.md).
# Usage : youtube-upload.sh video.mp4 "titre" "description"
set -eu
VIDEO=$1
TITLE=$2
DESC=$3
TOKEN=$(curl -sf https://oauth2.googleapis.com/token \
  -d client_id="${YT_CLIENT_ID:?}" -d client_secret="${YT_CLIENT_SECRET:?}" \
  -d refresh_token="${YT_REFRESH_TOKEN:?}" -d grant_type=refresh_token \
  | jq -r .access_token)
META=$(jq -n --arg t "$TITLE" --arg d "$DESC" \
  '{snippet:{title:$t,description:$d,categoryId:"10"},
    status:{privacyStatus:"public",selfDeclaredMadeForKids:false,containsSyntheticMedia:true}}')
LOC=$(curl -sf -D - -o /dev/null -X POST \
  "https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "$META" | awk -F': ' 'tolower($1)=="location" {print $2}' | tr -d '\r')
curl -sf -X PUT "$LOC" -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: video/mp4" -T "$VIDEO" | jq -r .id
