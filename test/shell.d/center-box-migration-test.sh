#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

migration="$ROOT/migrations/1791969355.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
config="$test_dir/home/.config/omarchy/shell.json"

run() {
  env HOME="$test_dir/home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >"$test_dir/output" 2>&1 ||
    fail "migration runs" "$(cat "$test_dir/output")"
}

# Writes a shell.json, runs the migration, and compares its bar to the expected
# one, ignoring key order.
check() {
  local given="$1" expected="$2" message="$3"
  mkdir -p "$(dirname "$config")"
  printf '%s\n' "$given" >"$config"
  run
  local actual wanted
  actual=$(jq -cS .bar "$config")
  wanted=$(jq -cS . <<<"$expected")
  [[ $actual == "$wanted" ]] || fail "$message" "$actual"
  pass "$message"
}

check '{"version":1,"bar":{"position":"top","centerAnchor":"omarchy.clock","layout":{"left":["omarchy.menu"],"center":[{"id":"omarchy.indicators"},{"id":"omarchy.clock","format":"HH:mm"},{"id":"omarchy.elsewhen","zones":"Tokyo"},"omarchy.weather"],"right":[]}}}' \
  '{"position":"top","layout":{"left":["omarchy.menu"],"centerBegin":[{"id":"omarchy.indicators"}],"center":[{"id":"omarchy.clock","format":"HH:mm"}],"centerEnd":[{"id":"omarchy.elsewhen","zones":"Tokyo"},"omarchy.weather"],"right":[]}}' \
  "the anchor stays in the box and what flanked it moves to the sections either side, settings and all"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":["omarchy.clock","omarchy.weather"]}}}' \
  '{"layout":{"centerBegin":[],"center":["omarchy.clock"],"centerEnd":["omarchy.weather"]}}' \
  "an anchor at the start of the center leaves centerBegin empty"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":["omarchy.media","omarchy.clock"]}}}' \
  '{"layout":{"centerBegin":["omarchy.media"],"center":["omarchy.clock"],"centerEnd":[]}}' \
  "an anchor at the end of the center leaves centerEnd empty"

check '{"bar":{"centerAnchor":"","layout":{"center":["omarchy.media","omarchy.clock"]}}}' \
  '{"layout":{"center":["omarchy.media","omarchy.clock"]}}' \
  "a center without an anchor was centered as one group and stays whole in the box"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"left":["omarchy.clock"],"center":["omarchy.media","omarchy.weather"]}}}' \
  '{"layout":{"left":["omarchy.clock"],"center":["omarchy.media","omarchy.weather"]}}' \
  "an anchor the center does not hold leaves the center whole in the box"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":["omarchy.clock","omarchy.media","omarchy.clock"]}}}' \
  '{"layout":{"centerBegin":[],"center":["omarchy.clock"],"centerEnd":["omarchy.media","omarchy.clock"]}}' \
  "a repeated anchor splits at its first entry, as the bar drew it"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"centerBegin":["a"],"center":["b","omarchy.clock","c"],"centerEnd":["d"]}}}' \
  '{"layout":{"centerBegin":["a","b"],"center":["omarchy.clock"],"centerEnd":["c","d"]}}' \
  "entries already in centerBegin and centerEnd keep their places on the outside"

check '{"bar":{"centerAnchor":"omarchy.clock","id":"omarchy.bar","layout":{"center":["a","omarchy.clock","b"]}}}' \
  '{"id":"omarchy.bar","layout":{"centerBegin":["a"],"center":["omarchy.clock"],"centerEnd":["b"]}}' \
  "the built-in bar named by id is split like the default"

check '{"bar":{"centerAnchor":"omarchy.clock","id":"","layout":{"center":["a","omarchy.clock"]}}}' \
  '{"id":"","layout":{"centerBegin":["a"],"center":["omarchy.clock"],"centerEnd":[]}}' \
  "an empty bar id means the built-in bar, as it does to the shell"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":["omarchy.clock"]}}' \
  '{"layout":["omarchy.clock"]}' \
  "a layout that is not an object only loses the anchor, and the queue moves on"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":"omarchy.clock"}}}' \
  '{"layout":{"center":"omarchy.clock"}}' \
  "a center that is not a list only loses the anchor"

for given in \
  '{"version":1,"bar":{"layout":{"center":["omarchy.media","omarchy.clock"]}},"plugins":[]}' \
  '{"version":1,"bar":{"id":"local.bar","centerAnchor":"omarchy.clock","layout":{"center":["a","omarchy.clock","b"]}}}'; do
  printf '%s\n' "$given" >"$config"
  before=$(sha256sum "$config")
  run
  [[ $(sha256sum "$config") == "$before" ]] || fail "a config without centerAnchor, or for a replacement bar, is left byte for byte" "$given"
done
pass "a config without centerAnchor, or for a replacement bar, is left byte for byte"

check '{"bar":{"centerAnchor":"omarchy.clock","layout":{"center":["a","omarchy.clock","b"]}}}' \
  '{"layout":{"centerBegin":["a"],"center":["omarchy.clock"],"centerEnd":["b"]}}' \
  "first run splits the center"
run
[[ $(jq -cS .bar "$config") == '{"layout":{"center":["omarchy.clock"],"centerBegin":["a"],"centerEnd":["b"]}}' ]] ||
  fail "a second run changes nothing" "$(jq -cS .bar "$config")"
pass "a second run changes nothing"

rm -f "$config"
run
[[ ! -e $config ]] || fail "without a shell.json the migration writes none"
pass "without a shell.json the migration writes none"
