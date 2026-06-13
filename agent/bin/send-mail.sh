#!/bin/sh
# Envoi d'un mail depuis hello@mugenradio.com (Zoho SMTP). Corps sur stdin.
# Identifiants via env MAIL_*. Usage : echo "corps" | send-mail.sh dest@x "Sujet"
# Politique d'usage : voir agent/prompts/_environnement.md (réponses aux
# auditeurs uniquement, une fois, dans leur langue, jamais de spam).
#
# ANTI-DOUBLON MATÉRIEL : le script REFUSE physiquement d'envoyer deux fois au
# même destinataire dans une fenêtre de 24h (verrou + registre persistant sur
# le PVC, hors git pour ne pas dépendre de l'état du dépôt). C'est une garantie
# au niveau du script, pas une politique "à la confiance" — un bug de l'agent
# ou de la concurrence ne peut PLUS produire de doublon.
set -eu
TO=$1
SUBJECT=$2
BODY=$(cat)

SENTLOG=/data/.mail-sent.log     # persistant, hors git
LOCK=/data/.mail-send.lock
COOLDOWN=${MAIL_COOLDOWN_SECONDS:-86400}   # 24h
NOW=$(date +%s)
TO_NORM=$(printf '%s' "$TO" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

# Section critique : vérifier + (éventuellement) envoyer + journaliser, sous verrou.
exec 8>"$LOCK"
flock 8

# Déjà écrit à ce destinataire dans la fenêtre ? -> refus net, pas d'envoi.
if [ -f "$SENTLOG" ] && awk -F'\t' -v dst="$TO_NORM" -v now="$NOW" -v cd="$COOLDOWN" \
     '$2==dst && (now-$1)<cd {found=1} END{exit !found}' "$SENTLOG"; then
  echo "send-mail: REFUSÉ (déjà écrit à $TO il y a moins de 24h) — anti-doublon" >&2
  exit 0
fi

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

# On journalise AVANT l'envoi : en cas d'échec réseau, on préfère ne pas
# réessayer (risque de doublon) plutôt que de spammer. Un envoi manqué est
# moins grave qu'un doublon.
printf '%s\t%s\t%s\n' "$NOW" "$TO_NORM" "$SUBJECT" >> "$SENTLOG"

curl -sf --url "${MAIL_SMTP:-smtps://smtp.zoho.com:465}" \
  --user "${MAIL_USER}:${MAIL_PASSWORD:?}" \
  --mail-from "$MAIL_USER" --mail-rcpt "$TO" \
  --upload-file "$MSG" || echo "send-mail: échec SMTP (pas de réessai, anti-doublon)" >&2
rm -f "$MSG"
