#!/usr/bin/env bats
# Tests for publish-www.sh
# We run the actual script against a fixture tree in a tmp dir, overriding
# REPO and WWW via environment patching (the script hardcodes REPO=/data/repo
# and WWW=/data/www, so we use a thin wrapper that substitutes those paths).

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
FIXTURES="$BATS_TEST_DIRNAME/../fixtures"

setup() {
  WORK=$(mktemp -d)
  FAKE_REPO="$WORK/repo"
  FAKE_WWW="$WORK/www"

  # Mirror the real repo layout that publish-www.sh expects
  mkdir -p "$FAKE_REPO/site/i18n"
  mkdir -p "$FAKE_REPO/journal/public/fr"
  mkdir -p "$FAKE_REPO/journal/public/es"
  mkdir -p "$FAKE_REPO/comptes"

  # site/ stubs
  printf '{}' > "$FAKE_REPO/site/i18n/en.json"
  printf '{"test":"fr"}' > "$FAKE_REPO/site/i18n/fr.json"

  # Public journal entries (English)
  printf '# Entry one\nContent.' > "$FAKE_REPO/journal/public/2026-06-10-first.md"
  printf '# Entry two\nContent.' > "$FAKE_REPO/journal/public/2026-06-12-second.md"

  # French translation of only the first entry
  printf '# Première entrée\nContenu.' > "$FAKE_REPO/journal/public/fr/2026-06-10-first.md"

  # Comptes: valid ledger with a balance column
  cat > "$FAKE_REPO/comptes/livre.md" << 'MD'
# Comptes
| Date | Libellé | Débit | Crédit | Solde |
|---|---|---|---|---|
| 2026-06-10 | Apport initial | | 20,00 € | 20,00 € |
| 2026-06-12 | Achat | 14,00 € | | 6,00 € |
MD

  # Patched copy of publish-www.sh with REPO/WWW substituted
  sed \
    -e "s|REPO=/data/repo|REPO=$FAKE_REPO|" \
    -e "s|WWW=/data/www|WWW=$FAKE_WWW|" \
    "$REPO_ROOT/agent/bin/publish-www.sh" > "$WORK/publish-www.sh"
  chmod +x "$WORK/publish-www.sh"
}

teardown() {
  rm -rf "$WORK"
}

run_publish() {
  run "$WORK/publish-www.sh"
}

# --- basic execution ---

@test "publish-www.sh exits 0 with valid fixture tree" {
  run_publish
  [ "$status" -eq 0 ]
}

# --- journal/index.json ---

@test "journal/index.json is created" {
  run_publish
  [ -f "$FAKE_WWW/journal/index.json" ]
}

@test "journal/index.json contains only .md entries, reverse-sorted" {
  run_publish
  content=$(cat "$FAKE_WWW/journal/index.json")
  # Must be a JSON array
  [[ "$content" =~ ^\[ ]]
  # First entry (reverse sort) should be the 2026-06-12 file
  first=$(node -e "const a=JSON.parse(require('fs').readFileSync('$FAKE_WWW/journal/index.json')); console.log(a[0])")
  [[ "$first" == *"2026-06-12-second.md"* ]]
  # Second entry is the 2026-06-10 file
  second=$(node -e "const a=JSON.parse(require('fs').readFileSync('$FAKE_WWW/journal/index.json')); console.log(a[1])")
  [[ "$second" == *"2026-06-10-first.md"* ]]
}

# --- per-language indexes ---

@test "journal/fr/index.json is created with translated entry" {
  run_publish
  [ -f "$FAKE_WWW/journal/fr/index.json" ]
  content=$(cat "$FAKE_WWW/journal/fr/index.json")
  [[ "$content" =~ "2026-06-10-first.md" ]]
}

@test "journal/es/index.json is created and empty when no translations" {
  run_publish
  [ -f "$FAKE_WWW/journal/es/index.json" ]
  content=$(cat "$FAKE_WWW/journal/es/index.json")
  [ "$content" = "[]" ]
}

@test "all 8 non-English languages get an index.json" {
  run_publish
  for lang in fr es pt de it ja ko zh; do
    [ -f "$FAKE_WWW/journal/$lang/index.json" ] || {
      echo "Missing: $FAKE_WWW/journal/$lang/index.json" >&2
      return 1
    }
  done
}

# --- status.json ---

@test "status.json is created" {
  run_publish
  [ -f "$FAKE_WWW/status.json" ]
}

@test "status.json has born field" {
  run_publish
  born=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$FAKE_WWW/status.json')).born)")
  [ "$born" = "2026-06-10" ]
}

@test "status.json balance is the last ledger balance" {
  run_publish
  balance=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$FAKE_WWW/status.json')).balance)")
  # Last row in our fixture ends with "6,00 €"
  [ "$balance" = "6,00 €" ]
}

# --- site/ copy ---

@test "site/i18n/ files are copied into www" {
  run_publish
  [ -f "$FAKE_WWW/i18n/en.json" ]
  [ -f "$FAKE_WWW/i18n/fr.json" ]
}

# --- no internal journal files leaked ---

@test "journal/ contains only .md from public/, not internal files" {
  # Add an internal (non-public) md file to make sure it stays out
  printf '# Internal\n' > "$FAKE_REPO/journal/ops.log"
  run_publish
  # ops.log should not appear in www/journal/
  [ ! -f "$FAKE_WWW/journal/ops.log" ]
}
