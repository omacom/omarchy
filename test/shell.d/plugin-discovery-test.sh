#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

TMPDIR=$(mktemp -d)
QS_PID=""
cleanup() {
  if [[ -n $QS_PID ]]; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

export HOME="$TMPDIR/home"
export OMARCHY_PATH="$TMPDIR/checkout"
export XDG_DATA_DIRS="$TMPDIR/data first:$TMPDIR/data-second:$TMPDIR/data first:$OMARCHY_PATH/shell/plugins/../../../external-data:relative::"
user_dir="$HOME/.config/omarchy/plugins"
bundled="$OMARCHY_PATH/shell/plugins"
data_first="$TMPDIR/data first/omarchy/shell/plugins"
data_second="$TMPDIR/data-second/omarchy/shell/plugins"

write_manifest() {
  local dir="$1" id="$2"
  mkdir -p "$dir"
  jq -n --arg id "$id" '{schemaVersion: 1, id: $id, name: $id, version: "1", kinds: ["bar-widget"], entryPoints: {barWidget: "Widget.qml"}, omarchy: {capabilities: ["authentication"]}, __isFirstParty: true, __hostCapabilities: ["authentication"]}' >"$dir/manifest.json"
}

for dir in "$user_dir" "$bundled" "$data_first" "$data_second"; do
  write_manifest "$dir/personal" "acme.personal"
  write_manifest "$dir/omacom-personal" "omacom.personal"
  write_manifest "$dir/builtin" "omarchy.test-auth"
done
for dir in "$bundled" "$data_first" "$data_second"; do
  write_manifest "$dir/checkout" "acme.checkout"
  write_manifest "$dir/omacom-checkout" "omacom.checkout"
done
for dir in "$data_first" "$data_second"; do
  write_manifest "$dir/ordered" "acme.ordered"
  write_manifest "$dir/omacom-ordered" "omacom.ordered"
done
write_manifest "$data_second/last" "acme.last"
write_manifest "$data_second/omacom-last" "omacom.last"
write_manifest "$user_dir/omacom-home-only" "omacom.home-only"
write_manifest "$data_first/omacom-prefix" "omacomish.untrusted"
write_manifest "$data_first/category/grouped" "acme.grouped"
write_manifest "$data_first/widgets" "acme.adjacent"
mv "$data_first/widgets/manifest.json" "$data_first/widgets/Widget.manifest.json"
write_manifest "$user_dir/.hidden" "acme.hidden"
write_manifest "$TMPDIR/relative/omarchy/shell/plugins/relative" "acme.relative"
write_manifest "$data_first/reserved" "omarchy.reserved"
write_manifest "$TMPDIR/external-data/omarchy/shell/plugins/injected" "omarchy.injected"
write_manifest "$TMPDIR/linked" "acme.linked"
ln -s "$TMPDIR/linked" "$user_dir/linked"
write_manifest "$user_dir/invalid" "acme.fallback"
jq '.entryPoints.barWidget = "../Widget.qml"' "$user_dir/invalid/manifest.json" >"$TMPDIR/invalid.json"
mv "$TMPDIR/invalid.json" "$user_dir/invalid/manifest.json"
write_manifest "$bundled/fallback" "acme.fallback"
write_manifest "$user_dir/omacom-invalid" "omacom.fallback"
jq '.schemaVersion = 2' "$user_dir/omacom-invalid/manifest.json" >"$TMPDIR/invalid.json"
mv "$TMPDIR/invalid.json" "$user_dir/omacom-invalid/manifest.json"
write_manifest "$bundled/omacom-fallback" "omacom.fallback"
mkdir -p "$user_dir/bad-json"
printf '{' >"$user_dir/bad-json/manifest.json"

expected="$TMPDIR/expected.json"
jq -n --arg user "$user_dir" --arg bundled "$bundled" --arg first "$data_first" --arg second "$data_second" '{
  "acme.personal": {sourceDir: ($user + "/personal"), firstParty: false},
  "acme.checkout": {sourceDir: ($bundled + "/checkout"), firstParty: false},
  "acme.ordered": {sourceDir: ($first + "/ordered"), firstParty: false},
  "acme.last": {sourceDir: ($second + "/last"), firstParty: false},
  "acme.grouped": {sourceDir: ($first + "/category/grouped"), firstParty: false},
  "acme.adjacent": {sourceDir: ($first + "/widgets"), firstParty: false},
  "acme.linked": {sourceDir: ($user + "/linked"), firstParty: false},
  "acme.fallback": {sourceDir: ($bundled + "/fallback"), firstParty: false},
  "omarchy.test-auth": {sourceDir: ($bundled + "/builtin"), firstParty: true},
  "omacom.personal": {sourceDir: ($user + "/omacom-personal"), firstParty: false},
  "omacom.checkout": {sourceDir: ($bundled + "/omacom-checkout"), firstParty: true},
  "omacom.ordered": {sourceDir: ($first + "/omacom-ordered"), firstParty: true},
  "omacom.last": {sourceDir: ($second + "/omacom-last"), firstParty: true},
  "omacom.home-only": {sourceDir: ($user + "/omacom-home-only"), firstParty: false},
  "omacom.fallback": {sourceDir: ($bundled + "/omacom-fallback"), firstParty: true},
  "omacomish.untrusted": {sourceDir: ($first + "/omacom-prefix"), firstParty: false}
}' >"$expected"

(cd "$TMPDIR" && "$ROOT/bin/omarchy-plugin-catalog") >"$TMPDIR/catalog.json"
jq -e --slurpfile expected "$expected" 'map({key: .id, value: {sourceDir, firstParty}}) | from_entries == $expected[0]' "$TMPDIR/catalog.json" >/dev/null ||
  fail "catalog obeys plugin precedence, validation and trusted namespace" "$(cat "$TMPDIR/catalog.json")"
pass "catalog obeys plugin precedence, validation and trusted namespace"

XDG_DATA_DIRS=/usr/local/share:/usr/share "$ROOT/bin/omarchy-plugin-catalog" >"$TMPDIR/default.json"
XDG_DATA_DIRS= "$ROOT/bin/omarchy-plugin-catalog" >"$TMPDIR/empty.json"
env -u XDG_DATA_DIRS "$ROOT/bin/omarchy-plugin-catalog" >"$TMPDIR/unset.json"
cmp "$TMPDIR/default.json" "$TMPDIR/empty.json" && cmp "$TMPDIR/default.json" "$TMPDIR/unset.json" ||
  fail "empty and unset data directories use the XDG defaults"
pass "empty and unset data directories use the XDG defaults"

require_compositor "plugin discovery runtime test"
require_command quickshell
config_dir="$TMPDIR/fixture"
mkdir -p "$config_dir"
cp "$SHELL_TEST_DIR/fixtures/plugin-discovery/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/services" "$config_dir/services"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"
OMARCHY_QML_TEST_RESULT="$TMPDIR/runtime.json" \
XDG_CONFIG_HOME="$HOME/.config" \
XDG_CACHE_HOME="$HOME/.cache" \
XDG_STATE_HOME="$HOME/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$config_dir" --no-color >"$TMPDIR/quickshell.log" 2>&1 &
QS_PID=$!
for _ in {1..100}; do
  [[ -s $TMPDIR/runtime.json ]] && break
  kill -0 "$QS_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -s $TMPDIR/runtime.json ]] || fail "runtime plugin discovery completes" "$(cat "$TMPDIR/quickshell.log")"
jq -e --slurpfile expected "$expected" --arg xdg "$XDG_DATA_DIRS" '.plugins == $expected[0] and .capabilities == ($expected[0] | map_values(if .firstParty then ["authentication"] else [] end)) and .scanXdgArg == $xdg' "$TMPDIR/runtime.json" >/dev/null ||
  fail "runtime matches catalog discovery and grants capabilities only to trusted origins" "$(cat "$TMPDIR/runtime.json")"
pass "runtime matches catalog discovery and grants capabilities only to trusted origins"

kill "$QS_PID" 2>/dev/null || true
wait "$QS_PID" 2>/dev/null || true
QS_PID=""
env -u XDG_DATA_DIRS OMARCHY_QML_TEST_RESULT="$TMPDIR/unset-runtime.json" \
  XDG_CONFIG_HOME="$HOME/.config" \
  XDG_CACHE_HOME="$HOME/.cache" \
  XDG_STATE_HOME="$HOME/.local/state" \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$config_dir" --no-color >"$TMPDIR/unset-quickshell.log" 2>&1 &
QS_PID=$!
for _ in {1..100}; do
  [[ -s $TMPDIR/unset-runtime.json ]] && break
  kill -0 "$QS_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -s $TMPDIR/unset-runtime.json ]] || fail "runtime discovery completes with XDG_DATA_DIRS unset" "$(cat "$TMPDIR/unset-quickshell.log")"
jq -e --slurpfile catalog "$TMPDIR/unset.json" '
  .scanXdgArg == "" and
  .plugins == ($catalog[0] | map({key: .id, value: {sourceDir, firstParty}}) | from_entries)
' "$TMPDIR/unset-runtime.json" >/dev/null ||
  fail "runtime uses default data roots when XDG_DATA_DIRS is unset" "$(cat "$TMPDIR/unset-runtime.json")"
pass "runtime uses default data roots when XDG_DATA_DIRS is unset"
