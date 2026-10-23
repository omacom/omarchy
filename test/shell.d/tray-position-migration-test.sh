#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

migration="$ROOT/migrations/1791968925.sh"
split="$ROOT/migrations/1791969355.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
config="$test_dir/home/.config/omarchy/shell.json"

run() {
  local script
  for script in "$@"; do
    env HOME="$test_dir/home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$script" >"$test_dir/output" 2>&1 ||
      fail "migration runs" "$(cat "$test_dir/output")"
  done
}

# Writes a shell.json, runs the given migrations, and compares its bar to the
# expected one, ignoring key order.
check() {
  local given="$1" expected="$2" message="$3"
  shift 3
  mkdir -p "$(dirname "$config")"
  printf '%s\n' "$given" >"$config"
  run "${@:-$migration}"
  local actual wanted
  actual=$(jq -cS .bar "$config")
  wanted=$(jq -cS . <<<"$expected")
  [[ $actual == "$wanted" ]] || fail "$message" "$actual"
  pass "$message"
}

check '{"version":1,"bar":{"position":"top","layout":{"left":["omarchy.menu"],"center":["omarchy.clock"],"right":[{"id":"omarchy.keyboard-layout"},{"id":"omarchy.tray","pinned":["steam"]},{"id":"omarchy.agents"}]}}}' \
  '{"position":"top","layout":{"left":["omarchy.menu"],"center":["omarchy.clock"],"right":[{"id":"omarchy.tray","pinned":["steam"]},{"id":"omarchy.keyboard-layout"},{"id":"omarchy.agents"}]}}' \
  "a tray in the right section moves to its start, settings and all"

check '{"bar":{"layout":{"left":["omarchy.tray","omarchy.menu","omarchy.workspaces"]}}}' \
  '{"layout":{"left":["omarchy.menu","omarchy.workspaces","omarchy.tray"]}}' \
  "a tray in the left section moves to its end"

check '{"bar":{"layout":{"center":["omarchy.tray","omarchy.clock","omarchy.weather"]}}}' \
  '{"layout":{"center":["omarchy.clock","omarchy.weather","omarchy.tray"]}}' \
  "a tray in the center section moves to its end"

check '{"bar":{"layout":{"right":["a",{"id":"omarchy.tray","pinned":["x"]},"b","omarchy.tray"],"left":["omarchy.tray","c","omarchy.tray"]}}}' \
  '{"layout":{"right":["omarchy.tray","a","b"],"left":["c","omarchy.tray"]}}' \
  "only the last tray a section lists stays, as only it was drawn"

check '{"bar":{"id":"omarchy.bar","layout":{"right":["a","omarchy.tray"]}}}' \
  '{"id":"omarchy.bar","layout":{"right":["omarchy.tray","a"]}}' \
  "the built-in bar named by id is pinned like the default"

# The old bar pinned the tray and then split the center around its anchor, so
# a tray before the clock was drawn at the far end of what followed it.
# omarchy-migrate runs migrations in filename order.
[[ ${migration##*/} < ${split##*/} ]] || fail "the tray moves before the center is split"
pass "the tray moves before the center is split"
check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":["omarchy.tray","omarchy.indicators","omarchy.clock","omarchy.weather"]}}}' \
  '{"layout":{"centerBegin":["omarchy.indicators"],"center":["omarchy.clock"],"centerEnd":["omarchy.weather","omarchy.tray"]}}' \
  "run before the center split, a tray before the anchor ends up where the bar drew it" \
  "$migration" "$split"

for given in \
  '{"version":1,"bar":{"layout":{"left":["omarchy.menu"],"right":["omarchy.tray","omarchy.audio"]}},"plugins":[]}' \
  '{"version":1,"bar":{"layout":{"right":["omarchy.audio"]}}}' \
  '{"version":1,"bar":{"id":"local.bar","layout":{"right":["omarchy.audio","omarchy.tray"]}}}' \
  '{"version":1,"bar":{"layout":{"right":"omarchy.tray"}}}' \
  '{"version":1,"bar":{"layout":["omarchy.tray"]}}' \
  '{"version":1}'; do
  printf '%s\n' "$given" >"$config"
  before=$(sha256sum "$config")
  run "$migration"
  [[ $(sha256sum "$config") == "$before" ]] || fail "a config with the tray already in place, without one, or for a replacement bar, is left byte for byte" "$given"
done
pass "a config with the tray already in place, without one, or for a replacement bar, is left byte for byte"

check '{"bar":{"layout":{"right":["a","omarchy.tray"]}}}' '{"layout":{"right":["omarchy.tray","a"]}}' "first run moves the tray"
run "$migration"
[[ $(jq -cS .bar "$config") == '{"layout":{"right":["omarchy.tray","a"]}}' ]] ||
  fail "a second run changes nothing" "$(jq -cS .bar "$config")"
pass "a second run changes nothing"

rm -f "$config"
run "$migration"
[[ ! -e $config ]] || fail "without a shell.json the migration writes none"
pass "without a shell.json the migration writes none"
