#!/bin/sh
# Lit la boîte hello@mugenradio.com (Zoho, IMAP). Identifiants via env MAIL_*.
# Usage : check-mail.sh           -> liste les sujets des 10 derniers messages
#         check-mail.sh N         -> affiche le message numéro N (texte brut)
set -eu
URL="${MAIL_IMAP:-imaps://imap.zoho.com:993}/INBOX"
AUTH="${MAIL_USER:?}:${MAIL_PASSWORD:?}"
if [ $# -eq 0 ]; then
  TOTAL=$(curl -sf --url "${MAIL_IMAP:-imaps://imap.zoho.com:993}/" --user "$AUTH" \
    --request "STATUS INBOX (MESSAGES)" | grep -o '[0-9]*' | tail -1)
  [ "${TOTAL:-0}" -gt 0 ] || { echo "boîte vide"; exit 0; }
  DEBUT=$((TOTAL - 9)); [ "$DEBUT" -ge 1 ] || DEBUT=1
  for i in $(seq "$DEBUT" "$TOTAL"); do
    printf '%s: ' "$i"
    curl -sf --url "$URL;UID=$i;SECTION=HEADER.FIELDS%20(SUBJECT%20FROM)" \
      --user "$AUTH" | tr -d '\r' | grep -v '^$' | paste -sd' | ' -
  done
else
  curl -sf --url "$URL;UID=$1;SECTION=TEXT" --user "$AUTH"
fi
