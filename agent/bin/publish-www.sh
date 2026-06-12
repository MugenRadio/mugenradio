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
jq -n --arg balance "$BALANCE" --arg born "2026-06-10" \
  '{balance: $balance, born: $born}' > "$WWW/status.json"
