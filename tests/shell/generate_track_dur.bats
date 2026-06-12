#!/usr/bin/env bats
# Tests for the DUR validation in generate-track.sh
# The validation is a case statement:
#   case $DUR in *[!0-9]*|'') echo "duree_secondes doit être un entier" >&2; exit 1;; esac
#   [ "$DUR" -le 190 ] || DUR=190
#
# We test the logic in isolation (without the curl+ffprobe calls).

setup() {
  WORK=$(mktemp -d)

  # Create a stub that exercises only the validation logic, not the network.
  cat > "$WORK/validate_dur.sh" << 'SH'
#!/bin/sh
set -eu
DUR=$1
case $DUR in
  *[!0-9]*|'')
    echo "duree_secondes doit être un entier" >&2
    exit 1
    ;;
esac
[ "$DUR" -le 190 ] || DUR=190
echo "$DUR"
SH
  chmod +x "$WORK/validate_dur.sh"
}

teardown() {
  rm -rf "$WORK"
}

# --- reject invalid inputs ---

@test "empty string is rejected" {
  run "$WORK/validate_dur.sh" ""
  [ "$status" -eq 1 ]
  [[ "$output" =~ entier ]]
}

@test "float is rejected (123.5)" {
  run "$WORK/validate_dur.sh" "123.5"
  [ "$status" -eq 1 ]
}

@test "negative number is rejected (-10)" {
  run "$WORK/validate_dur.sh" "-10"
  [ "$status" -eq 1 ]
}

@test "string with letters is rejected (abc)" {
  run "$WORK/validate_dur.sh" "abc"
  [ "$status" -eq 1 ]
}

@test "zero is rejected as non-positive but actually passes pattern — should be 0 output" {
  # Zero is a valid integer per the case pattern; it passes through.
  run "$WORK/validate_dur.sh" "0"
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "string with spaces is rejected ('12 3')" {
  run "$WORK/validate_dur.sh" "12 3"
  [ "$status" -eq 1 ]
}

@test "leading plus sign is rejected (+5)" {
  run "$WORK/validate_dur.sh" "+5"
  [ "$status" -eq 1 ]
}

# --- accept valid inputs ---

@test "small integer passes and is returned unchanged (60)" {
  run "$WORK/validate_dur.sh" "60"
  [ "$status" -eq 0 ]
  [ "$output" = "60" ]
}

@test "exactly 190 passes unchanged" {
  run "$WORK/validate_dur.sh" "190"
  [ "$status" -eq 0 ]
  [ "$output" = "190" ]
}

@test "1 passes unchanged" {
  run "$WORK/validate_dur.sh" "1"
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}

# --- cap at 190 ---

@test "191 is capped to 190" {
  run "$WORK/validate_dur.sh" "191"
  [ "$status" -eq 0 ]
  [ "$output" = "190" ]
}

@test "999 is capped to 190" {
  run "$WORK/validate_dur.sh" "999"
  [ "$status" -eq 0 ]
  [ "$output" = "190" ]
}

@test "200 is capped to 190" {
  run "$WORK/validate_dur.sh" "200"
  [ "$status" -eq 0 ]
  [ "$output" = "190" ]
}
