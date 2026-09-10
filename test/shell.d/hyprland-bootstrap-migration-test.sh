#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1781063758.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Writes the given hyprland.lua into a fresh fake $HOME and runs the migration
# there. Echoes the config path so assertions can read what it produced.
run_migration() {
  local name="$1" home="$test_tmp/$1"

  rm -rf "$home"
  mkdir -p "$home/.config/hypr"
  cat >"$home/.config/hypr/hyprland.lua"
  cp "$home/.config/hypr/hyprland.lua" "$test_tmp/$name.original"

  HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >"$test_tmp/$name.out" 2>&1 ||
    fail "migration succeeds on $name" "$(cat "$test_tmp/$name.out")"

  printf '%s\n' "$home/.config/hypr/hyprland.lua"
}

shipped_preamble() {
  cat <<'LUA'
-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy")
  .. "/?.lua;"
  .. package.path
LUA
}

body() {
  cat <<'LUA'

require("default.hypr.omarchy")
require("hypr.monitors")
hl.bind({ "SUPER", "T", "exec", "kitty" })
LUA
}

# The shipped preamble is replaced and nothing else in the file moves.
config=$({ shipped_preamble; body; } | run_migration shipped)
grep -Fq 'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")' "$config" ||
  fail "migration installs the bootstrap dofile"
grep -Fqx 'require("hypr.monitors")' "$config" || fail "migration keeps the user's requires"
grep -Fq 'package.path' "$config" && fail "migration removes the old path preamble"
[[ ! -e $config.omarchy-bootstrap.bak ]] || fail "a shipped preamble leaves no backup behind"
pass "migration rewrites a shipped preamble and leaves the rest alone"

# Running it again is a no-op: the guard sees the bootstrap is already there.
cp "$config" "$test_tmp/shipped.after"
HOME="$test_tmp/shipped" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null 2>&1
cmp -s "$config" "$test_tmp/shipped.after" || fail "migration is idempotent"
pass "migration leaves an already-migrated config untouched"

# A config that never carried this preamble is not this migration's business:
# it must come out byte for byte, with no copy left beside it.
config=$(body | run_migration foreign)
cmp -s "$config" "$test_tmp/foreign.original" || fail "an unrelated config is left byte for byte"
[[ ! -e $config.omarchy-bootstrap.bak ]] || fail "an unrelated config gets no backup"
[[ ! -s $test_tmp/foreign.out ]] ||
  grep -Fqv 'Saved your previous file' "$test_tmp/foreign.out" ||
  fail "an unrelated config draws no backup notice"
pass "migration ignores a config it has nothing to rewrite"

# A user who wrapped the assignment differently: the terminator line the old
# awk looked for is not there verbatim, and everything after it used to be
# swallowed to EOF, leaving a two-line config.
config=$({
  cat <<'LUA'
-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/?.lua;" .. package.path
LUA
  body
} | run_migration rewrapped)
grep -Fqx 'require("hypr.monitors")' "$config" || fail "a rewrapped assignment keeps the user's requires"
grep -Fqx 'hl.bind({ "SUPER", "T", "exec", "kitty" })' "$config" ||
  fail "a rewrapped assignment keeps the user's own lines"
pass "migration keeps the config when the assignment is wrapped differently"

# A user who appended their own path entry: that entry belongs to the
# assignment the bootstrap now owns, so it goes -- but the whole original file
# has to stay recoverable rather than being absorbed without trace.
config=$({
  shipped_preamble
  printf '%s\n' '  .. ";" .. os.getenv("HOME") .. "/dotfiles/?.lua"'
  body
} | run_migration extended)
grep -Fqx 'require("hypr.monitors")' "$config" || fail "an extended path keeps the user's requires"
grep -Fq '.. ";" .. os.getenv("HOME")' "$config" &&
  fail "an extended path is not left dangling after the dofile"
[[ -f $config.omarchy-bootstrap.bak ]] || fail "an extended path is backed up"
cmp -s "$config.omarchy-bootstrap.bak" "$test_tmp/extended.original" ||
  fail "the backup is the file as it was before the migration"
grep -Fq "$config.omarchy-bootstrap.bak" "$test_tmp/extended.out" ||
  fail "the migration says where the backup went"
pass "migration backs up a customized preamble instead of absorbing it"
