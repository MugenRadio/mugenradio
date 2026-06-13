#!/bin/sh
# Publie un post sur Mastodon ou Bluesky. Texte du post sur stdin.
# Usage : echo "texte" | post-social.sh mastodon|bluesky
#
# ANTI-DOUBLON MATÉRIEL : le script REFUSE physiquement de publier deux fois le
# même contenu sur la même plateforme dans une fenêtre de COOLDOWN (verrou +
# registre persistant sur le PVC, HORS git pour ne pas dépendre de l'état du
# dépôt). Un push raté, un réveil rejoué ou un bug de l'agent ne peuvent PLUS
# produire de doublon. Même garantie qu'à l'envoi de mail (send-mail.sh).
#
# Poster UNIQUEMENT via ce script. Ne JAMAIS appeler les API Mastodon/Bluesky
# en curl direct : ça contourne l'anti-doublon.
set -eu
PLATFORM=$1
TEXT=$(cat)

LOG=/data/.social-posted.log          # persistant, hors git
LOCK=/data/.social-post.lock
COOLDOWN=${SOCIAL_COOLDOWN_SECONDS:-259200}   # 72h : un repost identique n'est jamais voulu
NOW=$(date +%s)

# Empreinte du contenu : plateforme + texte normalisé (espaces aplatis).
NORM=$(printf '%s' "$TEXT" | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//')
HASH=$(printf '%s|%s' "$PLATFORM" "$NORM" | sha1sum | cut -d' ' -f1)

# Section critique : vérifier + journaliser + publier, sous verrou.
exec 8>"$LOCK"
flock 8

if [ -f "$LOG" ] && awk -F'\t' -v h="$HASH" -v now="$NOW" -v cd="$COOLDOWN" \
     '$2==h && (now-$1)<cd {found=1} END{exit !found}' "$LOG"; then
  echo "post-social: REFUSÉ (doublon $PLATFORM, déjà publié il y a moins de ${COOLDOWN}s) — anti-doublon" >&2
  exit 0
fi

# On journalise AVANT de publier : en cas d'échec réseau on préfère un post
# manqué à un doublon (un doublon est pire qu'un post raté).
printf '%s\t%s\t%s\n' "$NOW" "$HASH" "$PLATFORM" >> "$LOG"

case "$PLATFORM" in
  mastodon)
    curl -sf -X POST "${MASTODON_INSTANCE:?}/api/v1/statuses" \
      -H "Authorization: Bearer ${MASTODON_TOKEN:?}" \
      --data-urlencode "status=${TEXT}" >/dev/null \
      || { echo "post-social: échec Mastodon (pas de réessai, anti-doublon)" >&2; exit 0; }
    ;;
  bluesky)
    SESS=$(curl -sf -X POST "https://bsky.social/xrpc/com.atproto.server.createSession" \
      -H 'Content-Type: application/json' \
      --data "$(jq -n --arg id "${BSKY_HANDLE:?}" --arg pw "${BSKY_APP_PASSWORD:?}" \
        '{identifier:$id,password:$pw}')") \
      || { echo "post-social: échec session Bluesky (pas de réessai)" >&2; exit 0; }
    JWT=$(printf '%s' "$SESS" | jq -r '.accessJwt')
    DID=$(printf '%s' "$SESS" | jq -r '.did')
    [ -n "$JWT" ] && [ "$JWT" != "null" ] || { echo "post-social: session Bluesky invalide" >&2; exit 0; }
    CREATED=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)
    BODY=$(jq -n --arg repo "$DID" --arg text "$TEXT" --arg t "$CREATED" \
      '{repo:$repo,collection:"app.bsky.feed.post",record:{"$type":"app.bsky.feed.post",text:$text,createdAt:$t}}')
    curl -sf -X POST "https://bsky.social/xrpc/com.atproto.repo.createRecord" \
      -H "Authorization: Bearer ${JWT}" -H 'Content-Type: application/json' \
      --data "$BODY" >/dev/null \
      || { echo "post-social: échec post Bluesky (pas de réessai, anti-doublon)" >&2; exit 0; }
    ;;
  *)
    echo "post-social: plateforme inconnue '$PLATFORM' (attendu : mastodon|bluesky)" >&2
    exit 1
    ;;
esac

echo "post-social: publié sur $PLATFORM"
