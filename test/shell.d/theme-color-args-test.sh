#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command timeout

reject_missing_file() {
  local output status=0

  # A failed shift used to leave --file in the argument loop forever.
  output=$(timeout 2 "$ROOT/bin/omarchy-theme-color" "$@" 2>&1) || status=$?
  (( status == 1 )) || fail "theme color rejects a missing --file operand: $*" "exit $status: $output"
  [[ $output == "Usage: omarchy-theme-color"* ]] ||
    fail "theme color explains a missing --file operand: $*" "$output"
  pass "theme color rejects a missing --file operand: $*"
}

reject_missing_file --file
reject_missing_file --raw --file

test_tmp=$(mktemp -d)
colors_file="$test_tmp/colors.toml"
trap 'rm -f "$colors_file"; rmdir "$test_tmp"' EXIT

cat >"$colors_file" <<'EOF'
background = "#112233"
foreground = "#ddeeff"
accent = "#abcdef"
EOF

output=$("$ROOT/bin/omarchy-theme-color" --file "$colors_file" background) ||
  fail "theme color reads a valid --file operand"
[[ $output == "#112233" ]] || fail "theme color reads a valid --file operand" "$output"
pass "theme color reads a valid --file operand"

output=$("$ROOT/bin/omarchy-theme-color" --raw --file "$colors_file") ||
  fail "theme color accepts --file after --raw"
expected=$'background\t#112233\nforeground\t#ddeeff\naccent\t#abcdef'
[[ $output == "$expected" ]] || fail "theme color accepts --file after --raw" "$output"
pass "theme color accepts --file after --raw"
