#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1781063758.sh"

require_command luac

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

# The preamble as Omarchy shipped it, with the given OMARCHY_PATH fallback; the
# first one quattro carried was ~/.local/share/omarchy.
shipped_preamble() {
  printf '%s\n' \
    '-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.' \
    'package.path = os.getenv("HOME")' \
    '  .. "/.config/?.lua;"' \
    "  .. (os.getenv(\"OMARCHY_PATH\") or ${1:-\"/usr/share/omarchy\"})" \
    '  .. "/?.lua;"' \
    '  .. package.path'
}

body() {
  cat <<'LUA'

require("default.hypr.omarchy")
require("hypr.monitors")
hl.bind({ "SUPER", "T", "exec", "kitty" })
LUA
}

assert_rewritten() {
  local name="$1" config="$2"

  grep -Fqx 'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")' "$config" ||
    fail "$name: the bootstrap dofile is installed" "$(cat "$config")"
  ! grep -Fq 'package.path' "$config" || fail "$name: the old path preamble is gone" "$(cat "$config")"
  grep -Fqx 'require("hypr.monitors")' "$config" || fail "$name: the user's requires stay"
  luac -p "$config" 2>/dev/null || fail "$name: the result parses" "$(cat "$config")"
  ! grep -Fq 'Left ' "$test_tmp/$name.out" || fail "$name: no hand-edit notice"
  ! compgen -G "$config.*" >/dev/null || fail "$name: Omarchy's own preamble needs no backup" "$(ls "$config".*)"
}

# A preamble that is not exactly one Omarchy shipped is the user's own Lua: the
# file comes out byte for byte, and the user is told what to change by hand.
assert_left_alone() {
  local name="$1" config="$2"

  cmp -s "$config" "$test_tmp/$name.original" || fail "$name: the config is left byte for byte" "$(cat "$config")"
  grep -Fq "Left $config unchanged" "$test_tmp/$name.out" ||
    fail "$name: the user is told to switch by hand" "$(cat "$test_tmp/$name.out")"
}

# A preamble continued with a trailing "..", with the given line between that
# and the next operand.
trailing_preamble() {
  printf '%s\n' \
    '-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.' \
    'package.path = os.getenv("HOME")' \
    "  .. \"/.config/?.lua;\" ..$1" \
    "$2" \
    '  (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/?.lua;" ..' \
    '  package.path'
}

# The shipped preamble is replaced and nothing else in the file moves.
config=$({ shipped_preamble; body; } | run_migration shipped)
assert_rewritten shipped "$config"
{
  echo "-- Omarchy's bootstrap keeps path setup out of this user config."
  echo 'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")'
  body
} | cmp -s - "$config" || fail "a shipped preamble becomes exactly the bootstrap dofile" "$(cat "$config")"
pass "migration rewrites a shipped preamble and leaves the rest alone"

# Running it again is a no-op: the guard sees the bootstrap is already there.
cp "$config" "$test_tmp/shipped.after"
HOME="$test_tmp/shipped" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null 2>&1
cmp -s "$config" "$test_tmp/shipped.after" || fail "migration is idempotent"
pass "migration leaves an already-migrated config untouched"

# The earlier shipped preamble, and either one after 1781043107 ran first on an
# old install and added the state path, are still Omarchy's, not the user's.
legacy_fallback='(os.getenv("HOME") .. "/.local/share/omarchy")'
config=$({ shipped_preamble "$legacy_fallback"; body; } | run_migration legacy)
assert_rewritten legacy "$config"

state_case=0
for fallback in '"/usr/share/omarchy"' "$legacy_fallback"; do
  name=state-path-$((++state_case))
  state_home="$test_tmp/$name-source"
  mkdir -p "$state_home/.config/hypr"
  { shipped_preamble "$fallback"; body; } >"$state_home/.config/hypr/hyprland.lua"
  HOME="$state_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1781043107.sh" >/dev/null 2>&1 ||
    fail "1781043107 runs on the shipped preamble"
  grep -Fq '/.local/state/?.lua;' "$state_home/.config/hypr/hyprland.lua" ||
    fail "1781043107 adds the state path this case depends on"
  config=$(run_migration "$name" <"$state_home/.config/hypr/hyprland.lua")
  assert_rewritten "$name" "$config"
done
pass "migration rewrites every preamble Omarchy shipped, before and after 1781043107"

# A shipped preamble followed by the user's own comments and code is still the
# whole assignment.
config=$({ shipped_preamble; printf '%s\n' '' '-- My overrides' 'local gaps = 8 -- px'; body; } | run_migration followed)
assert_rewritten followed "$config"
grep -Fqx 'local gaps = 8 -- px' "$config" || fail "followed: the user's own lines stay"
pass "migration rewrites a shipped preamble followed by the user's code"

# A config that never carried this preamble is not this migration's business.
config=$(body | run_migration foreign)
cmp -s "$config" "$test_tmp/foreign.original" || fail "an unrelated config is left byte for byte"
! grep -Fq 'Left ' "$test_tmp/foreign.out" || fail "an unrelated config draws no notice"
pass "migration ignores a config it has nothing to rewrite"

# The shipped block can be the start of a longer assignment the user extended;
# a ".." after it, even past blank and comment lines, means it is not the whole
# preamble, and cutting the block out left a dangling ".." after the dofile.
config=$({ shipped_preamble; printf '%s\n' '  .. ";/custom/?.lua"'; body; } | run_migration extended)
assert_left_alone extended "$config"
config=$({ shipped_preamble; printf '%s\n' '' '  -- mine' '  .. ";/custom/?.lua"'; body; } | run_migration extended-later)
assert_left_alone extended-later "$config"
pass "migration leaves a shipped block alone when the user's assignment goes on past it"

# Customized preambles, in the shapes that cost users their config: rewrapped,
# where the old terminator line never came and the rest of the file went with
# it, and continued with a trailing ".." past a comment, a blank line or a
# comment on the same line.
config=$({
  printf '%s\n' \
    '-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.' \
    'package.path = os.getenv("HOME")' \
    '  .. "/.config/?.lua;"' \
    '  .. (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/?.lua;" .. package.path'
  body
} | run_migration rewrapped)
assert_left_alone rewrapped "$config"
config=$({ trailing_preamble '' '  -- note'; body; } | run_migration trailing-comment)
assert_left_alone trailing-comment "$config"
config=$({ trailing_preamble '' ''; body; } | run_migration trailing-blank)
assert_left_alone trailing-blank "$config"
config=$({ trailing_preamble ' -- note' '  -- more'; body; } | run_migration trailing-inline-comment)
assert_left_alone trailing-inline-comment "$config"
pass "migration leaves a customized preamble to the user"

# A shape nobody anticipated: the shipped block, then a continuation hidden
# behind a long comment on the same line. Lua would not load the rewrite, so the
# file is not replaced.
config=$({ shipped_preamble; printf '%s\n' '--[[ mine ]] .. ";/custom/?.lua"'; body; } | run_migration long-comment)
assert_left_alone long-comment "$config"
pass "migration never installs a hyprland.lua that Lua cannot load"

# The shipped preamble commented out above the user's own: rewriting the dead
# copy would bury the bootstrap in a comment and mark the migration done.
config=$({
  echo '--[['
  shipped_preamble
  echo ']]'
  printf '%s\n' 'package.path = os.getenv("HOME") .. "/dotfiles/?.lua;" .. package.path'
  body
} | run_migration commented-out)
assert_left_alone commented-out "$config"
pass "migration leaves a config alone when the live path setup is the user's own"

# The file is either rewritten from Omarchy's own preamble or left as it was, so
# there is never a copy to keep.
backups=$(find "$test_tmp" -name '*.omarchy-bootstrap.bak*')
[[ -z $backups ]] || fail "no backup files are written" "$backups"
pass "migration writes no backup files"
