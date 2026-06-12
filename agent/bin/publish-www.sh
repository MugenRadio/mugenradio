#!/bin/sh
# Publie le site : sources statiques + journal + comptes -> /data/www.
set -eu
REPO=/data/repo
WWW=/data/www
mkdir -p "$WWW/journal"
cp -r "$REPO/site/." "$WWW/"
cp "$REPO/journal/"*.md "$WWW/journal/" 2>/dev/null || true
cp "$REPO/comptes/livre.md" "$WWW/journal/000-comptes.md" 2>/dev/null || true
# shellcheck disable=SC2010
ls "$WWW/journal" | grep '\.md$' | sort -r | jq -R . | jq -s . > "$WWW/journal/index.json"
# Statut public (widget survie du site) : dernier solde du livre de comptes.
BALANCE=$(awk -F'|' '/^\|/ && NF >= 6 {b = $6} END {gsub(/^ +| +$/, "", b); print b}' \
  "$REPO/comptes/livre.md" 2>/dev/null || echo "")
jq -n --arg balance "$BALANCE" --arg born "2026-06-10" \
  '{balance: $balance, born: $born}' > "$WWW/status.json"
