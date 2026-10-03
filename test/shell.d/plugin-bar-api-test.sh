#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const apiSource = fs.readFileSync(root + '/shell/Ui/PluginBarApi.qml', 'utf8')
const clockSource = fs.readFileSync(root + '/shell/plugins/panels/clock/Panel.qml', 'utf8')
const weatherSource = fs.readFileSync(root + '/shell/plugins/panels/weather/Panel.qml', 'utf8')

assert(!/readonly property bool centerHoverRevealSuppressed:/.test(apiSource),
  'PluginBarApi does not mark centerHoverRevealSuppressed readonly')
assert(/property bool centerHoverRevealSuppressed: _centerHoverRevealSuppressed/.test(apiSource),
  'PluginBarApi mirrors host state onto a writable centerHoverRevealSuppressed')
assert(/onCenterHoverRevealSuppressedChanged:/.test(apiSource) && /_setCenterHoverRevealSuppressed/.test(apiSource),
  'PluginBarApi writes through clone assigns to the host callback')
assert(/function setCenterHoverRevealSuppressed\(value\)/.test(apiSource),
  'PluginBarApi keeps the explicit setter')

assert(/function close\(\) \{[\s\S]*?root\.controller\.hide\(\)[\s\S]*?setCenterHoverRevealSuppressed\(false\)/.test(clockSource),
  'clock hides before releasing the hover-reveal flag')
assert(!/function close\(\) \{\s*\n\s*setCenterHoverRevealSuppressed\(false\)/.test(clockSource),
  'clock does not write the hover-reveal flag before hide')
assert(/function close\(\) \{[\s\S]*?root\.controller\.hide\(\)[\s\S]*?setCenterHoverRevealSuppressed\(false\)/.test(weatherSource),
  'weather hides before releasing the hover-reveal flag')
assert(!/function close\(\) \{\s*\n\s*setCenterHoverRevealSuppressed\(false\)/.test(weatherSource),
  'weather does not write the hover-reveal flag before hide')
JS

if ! compositor_reachable; then
  pass "no Wayland compositor; skipping PluginBarApi runtime test"
  exit 0
fi

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping PluginBarApi runtime test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
QS_PID=""
cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

ulimit -c 0 2>/dev/null || true

result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/plugin-bar-api"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/plugin-bar-api/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "PluginBarApi quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "PluginBarApi runtime test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'PluginBarApi runtime result:\n' >&2
  jq . "$result" >&2
  printf 'PluginBarApi runtime log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "PluginBarApi runtime contracts pass"
fi

pass "PluginBarApi runtime contracts pass"
