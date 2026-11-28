#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -Fq '{ key = "N", mods = "Control|Shift", action = "CreateNewWindow" }' \
  "$ROOT/config/alacritty/alacritty.toml" ||
  fail "shipped Alacritty config binds Ctrl+Shift+N to CreateNewWindow"
pass "shipped Alacritty config binds Ctrl+Shift+N to a new window"

migration="$ROOT/migrations/1788799151.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
mkdir -p "$home/.config/alacritty"

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

# Exact shipped last-binding line: insert after it.
cat >"$home/.config/alacritty/alacritty.toml" <<'EOF'
[keyboard]
bindings = [
{ key = "Return", mods = "Alt|Shift", chars = "\u001B[13;4u" }
]
EOF

run_migration || fail "migration runs against the shipped Alacritty bindings"
grep -Fq '{ key = "N", mods = "Control|Shift", action = "CreateNewWindow" }' \
  "$home/.config/alacritty/alacritty.toml" ||
  fail "migration inserts the CreateNewWindow binding"
grep -Fq '{ key = "Return", mods = "Alt|Shift", chars = "\u001B[13;4u" },' \
  "$home/.config/alacritty/alacritty.toml" ||
  fail "migration keeps the previous binding as a valid array item"
pass "migration inserts Ctrl+Shift+N after the shipped Shift+Return binding"

# Already present: leave the file alone.
before=$(cat "$home/.config/alacritty/alacritty.toml")
run_migration || fail "migration reruns when the binding already exists"
[[ $(cat "$home/.config/alacritty/alacritty.toml") == "$before" ]] ||
  fail "migration is a no-op when CreateNewWindow is already bound"
pass "migration is idempotent"

# No Alacritty config: skip without creating one.
rm -rf "$home/.config"
run_migration || fail "migration runs when Alacritty config is absent"
[[ ! -e $home/.config/alacritty/alacritty.toml ]] ||
  fail "migration does not create an Alacritty config"
pass "migration skips a missing Alacritty config"
