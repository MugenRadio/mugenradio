#!/bin/sh
# Envoi d'un mail depuis hello@mugenradio.com (Zoho SMTP). Corps sur stdin.
# Identifiants via env MAIL_*. Usage : echo "corps" | send-mail.sh dest@x "Sujet"
# Politique d'usage : voir agent/prompts/_environnement.md (réponses aux
# auditeurs uniquement, une fois, dans leur langue, jamais de spam).
set -eu
TO=$1
SUBJECT=$2
BODY=$(cat)
MSG=$(mktemp)
{
  printf 'Date: %s\r\n' "$(date -R)"
  printf 'From: MUGEN <%s>\r\n' "${MAIL_USER:?}"
  printf 'To: %s\r\n' "$TO"
  printf 'Subject: %s\r\n' "$SUBJECT"
  printf 'MIME-Version: 1.0\r\n'
  printf 'Content-Type: text/plain; charset=UTF-8\r\n'
  printf '\r\n'
  printf '%s\r\n' "$BODY"
} > "$MSG"
curl -sf --url "${MAIL_SMTP:-smtps://smtp.zoho.com:465}" \
  --user "${MAIL_USER}:${MAIL_PASSWORD:?}" \
  --mail-from "$MAIL_USER" --mail-rcpt "$TO" \
  --upload-file "$MSG"
rm -f "$MSG"
