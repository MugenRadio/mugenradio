#!/bin/sh
# Réveil du cerveau : pull mémoire, garde-fou budget, Claude, comptes, publication.
set -eu
REPO=/data/repo
PROMPT="$REPO/agent/prompts/${WAKE_KIND:?WAKE_KIND requis (ops|creation|conseil)}.md"
export HOME=/data/home
mkdir -p "$HOME"

# VERROU anti-concurrence : tous les réveils partagent le même clone /data/repo.
# Sans ça, deux réveils simultanés (ex. drive + ops) se marchent dessus et
# corrompent l'état git. flock -n : si un autre réveil tient le verrou, on
# saute CE cycle proprement (mieux que d'empiler et casser le repo).
LOCK=/data/.wake.lock
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "$(date -Iseconds) réveil $WAKE_KIND sauté : un autre réveil tient le verrou" \
    >> "$REPO/journal/incidents.log" 2>/dev/null || true
  exit 0
fi
git config --global user.name radio-agent
git config --global user.email agent@radio.invalid
git config --global --add safe.directory '*'
git -C "$REPO" pull --rebase || true

# Garde-fou : caisse API vide -> le cerveau ne pense plus, il le note et sort.
SPENT=$(awk -F, 'NR>1 {s+=$3} END {printf "%.2f", s}' "$REPO/comptes/api_usage.csv" 2>/dev/null || echo "0.00")
LIMIT="${API_BUDGET_USD:-45}"
if awk "BEGIN{exit !($SPENT >= $LIMIT)}"; then
  echo "$(date -Iseconds) caisse API vide ($SPENT/$LIMIT USD), réveil $WAKE_KIND annulé" \
    >> "$REPO/journal/incidents.log"
  git -C "$REPO" add -A
  git -C "$REPO" commit -m "ops: cerveau à sec ($SPENT USD dépensés)" || true
  git -C "$REPO" push || true
  exit 0
fi

cd "$REPO"
OUT=/tmp/wake.json
claude -p "$(cat "$PROMPT")" \
  --model "${MODEL:-claude-sonnet-4-6}" \
  --max-turns "${MAX_TURNS:-40}" \
  --dangerously-skip-permissions \
  --output-format json > "$OUT" || true
COST=$(jq -r '.total_cost_usd // 0' "$OUT" 2>/dev/null || echo 0)
[ -z "$COST" ] && COST=0
echo "$(date -Iseconds),$WAKE_KIND,$COST" >> "$REPO/comptes/api_usage.csv"

"$REPO/agent/bin/publish-www.sh"
git add -A
git commit -m "réveil $WAKE_KIND" || true
git push || true

# Miroir public GitHub (décision 0006). Token lu du coffre, jamais journalisé.
# URL passée directement à push : le jeton n'est pas écrit dans .git/config.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git push "https://MugenRadio:${GITHUB_TOKEN}@github.com/MugenRadio/mugenradio.git" \
    HEAD:main >/dev/null 2>&1 || true
fi
