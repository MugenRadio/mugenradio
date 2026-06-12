#!/usr/bin/env bats
# Tests for the awk budget guard logic extracted from wake.sh
# The guard is:
#   SPENT=$(awk -F, 'NR>1 {s+=$3} END {printf "%.2f", s}' api_usage.csv)
#   if awk "BEGIN{exit !($SPENT >= $LIMIT)}"; then ... fi
#
# We test the awk expression in isolation, plus the final gate.

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"

# Helper: sum column 3 (cost_usd) of a CSV file, skip header.
spend_sum() {
  awk -F, 'NR>1 {s+=$3} END {printf "%.2f", s}' "$1"
}

# Helper: evaluate the threshold gate (returns 0 if budget exceeded, 1 if OK).
budget_exceeded() {
  # $1 = spent (string), $2 = limit
  awk "BEGIN{exit !($1 >= $2)}"
}

setup() {
  WORK=$(mktemp -d)
}

teardown() {
  rm -rf "$WORK"
}

# --- sum ---

@test "empty csv (header only) sums to 0.00" {
  printf 'date,reveil,cout_usd\n' > "$WORK/csv"
  run spend_sum "$WORK/csv"
  [ "$status" -eq 0 ]
  [ "$output" = "0.00" ]
}

@test "csv with blank cost cell contributes 0" {
  printf 'date,reveil,cout_usd\n2026-06-10,ops,\n' > "$WORK/csv"
  run spend_sum "$WORK/csv"
  [ "$status" -eq 0 ]
  [ "$output" = "0.00" ]
}

@test "single row sums correctly" {
  printf 'date,reveil,cout_usd\n2026-06-10,ops,1.50\n' > "$WORK/csv"
  run spend_sum "$WORK/csv"
  [ "$status" -eq 0 ]
  [ "$output" = "1.50" ]
}

@test "multiple rows accumulate" {
  printf 'date,reveil,cout_usd\n2026-06-10,ops,1.00\n2026-06-10,conseil,2.50\n2026-06-10,creation,0.75\n' > "$WORK/csv"
  run spend_sum "$WORK/csv"
  [ "$status" -eq 0 ]
  [ "$output" = "4.25" ]
}

@test "real api_usage.csv parses without error" {
  run spend_sum "$REPO_ROOT/comptes/api_usage.csv"
  [ "$status" -eq 0 ]
  # Must be a non-negative float
  [[ "$output" =~ ^[0-9]+\.[0-9]+$ ]]
}

# --- threshold gate ---

@test "gate: not exceeded when spent < limit" {
  run budget_exceeded "5.00" "45"
  [ "$status" -ne 0 ]   # awk exits 1 → condition false → not exceeded
}

@test "gate: exceeded when spent == limit" {
  run budget_exceeded "45.00" "45"
  [ "$status" -eq 0 ]   # awk exits 0 → condition true → exceeded
}

@test "gate: exceeded when spent > limit" {
  run budget_exceeded "45.01" "45"
  [ "$status" -eq 0 ]
}

@test "gate: not exceeded at zero spend" {
  run budget_exceeded "0.00" "45"
  [ "$status" -ne 0 ]
}

@test "gate: custom limit respected" {
  run budget_exceeded "10.00" "10"
  [ "$status" -eq 0 ]   # exactly at limit → exceeded
}

# --- integration: sum + gate together ---

@test "integration: sum below limit does not trip gate" {
  printf 'date,reveil,cout_usd\n2026-06-10,ops,1.00\n' > "$WORK/csv"
  spent=$(spend_sum "$WORK/csv")
  run budget_exceeded "$spent" "45"
  [ "$status" -ne 0 ]
}

@test "integration: accumulated sum over limit trips gate" {
  {
    printf 'date,reveil,cout_usd\n'
    for i in $(seq 1 10); do printf "2026-06-10,ops,5.00\n"; done
  } > "$WORK/csv"
  spent=$(spend_sum "$WORK/csv")
  # 10 * 5 = 50 > 45
  run budget_exceeded "$spent" "45"
  [ "$status" -eq 0 ]
}
