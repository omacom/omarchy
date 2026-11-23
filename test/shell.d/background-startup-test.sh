#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const read = file => fs.readFileSync(path.join(root, file), 'utf8')
const background = read('shell/plugins/background/Background.qml')
const intro = read('shell/services/BackgroundIntro.qml')
const geometry = /readonly property size decodePixels: ([^\n]+)/.exec(background)[1]
const canDecode = new Function('width', 'height', 'screen', `return ${geometry}`)
const measureBody = /function measure\(\) \{([\s\S]*?)\n      \}/.exec(intro)[1]
const measure = new Function('panel', 'Qt', 'Util', `with (panel) { ${measureBody} }`)
const screen = { width: 2400, height: 1350 }
const Qt = { size: (width, height) => ({ width, height }) }
const devicePixels = /function devicePixels\(length, scale\) \{([\s\S]*?)\n  \}/.exec(read('shell/Commons/Util.qml'))[1]
const Util = { devicePixels: new Function('length', 'scale', devicePixels) }
for (const [width, height, expected] of [[2400, 1350, true], [2400, 1351, true], [2399, 1350, true], [2400, 1348, false], [100, 100, false], [0, 0, false]]) {
  assertEqual(canDecode(width, height, screen), expected, `wallpaper geometry ${width}x${height}`)
  const panel = { width, height, modelData: screen, devicePixelRatio: 1.6, measured: false, screenPixels: null }
  measure(panel, Qt, Util)
  assertEqual(panel.measured, expected, `theme cover geometry ${width}x${height}`)
  if (expected) assertDeepEqual(panel.screenPixels, Qt.size(Util.devicePixels(width, 1.6), Util.devicePixels(height, 1.6)), 'cover measures the configured window')
}
JS

require_compositor "background startup test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin" "$stage/home/.local/state/omarchy/current"
printf 'P6\n1 1\n255\n\377\000\377' >"$stage/still.ppm"
ln -s "$stage/still.ppm" "$stage/home/.local/state/omarchy/current/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
cp "$SHELL_TEST_DIR/fixtures/background-startup/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" timeout 6 quickshell -p "$stage" --no-color 2>&1) || fail "background startup fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "the wallpaper restores before background plugin loading" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background startup fixture has no QML errors" "$output"
fi
pass "fresh startup hides the desktop until both the background and bar are ready"
