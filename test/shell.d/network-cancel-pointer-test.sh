#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Pointer-event regression for the network panel's Cancel/Forget slot. Unlike
# network-cancel-test.sh (which needs a compositor for the layer-shell panel
# and drives panel methods directly), this runs the real Panel.qml offscreen
# with a plain-Item KeyboardPanel stand-in and sends actual Qt mouse events
# through the real MouseArea dispatch, so a double-click that used to Forget
# the network fails here.
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/network-cancel-pointer"
mkdir -p "$stage/network" "$stage/bin" "$stage/home" "$stage/runtime"
chmod 700 "$stage/runtime"
# Copy (not symlink) Ui so the layer-shell KeyboardPanel can be replaced with
# a plain Item; everything else in the panel, including the rows and the slot
# MouseArea, is the real production code.
cp -r "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
# Reuse the cancel lane's mock backend, whose guards mirror the real
# Quickshell frontend guards.
cp -r "$SHELL_TEST_DIR/fixtures/network-cancel/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/network/Model.js" "$stage/network/Model.js"
node - "$ROOT" "$stage" <<'JS'
const fs = require('fs')
const [root, stage] = process.argv.slice(2)
let source = fs.readFileSync(`${root}/shell/plugins/panels/network/Panel.qml`, 'utf8')
// Keep the panel's real logic and UI bindings; only swap the singleton.
source = source.replace('import Quickshell.Networking', 'import Quickshell.Networking\nimport "../mocks"')
source = source.replace(/\bNetworking\./g, 'NetworkMock.')
fs.writeFileSync(`${stage}/network/Panel.qml`, source)
JS
cat >"$stage/Ui/KeyboardPanel.qml" <<'QML'
import QtQuick
Item {
  id: root
  required property Item anchorItem
  required property QtObject bar
  property var owner: null
  property int contentWidth: 380
  property int contentHeight: 200
  property bool open: false
  property Item focusTarget: null
  default property alias contentItem: holder.children
  function fittedContentWidth(w) { return w }
  function fittedContentHeight(h) { return h }
  visible: open; width: contentWidth; height: contentHeight
  Item { id: holder; anchors.fill: parent }
}
QML
printf '#!/bin/bash\nexit 0\n' >"$stage/bin/noop"
chmod +x "$stage/bin/noop"
for command in omarchy-dns omarchy-network-band omarchy-network-status; do
  ln -s noop "$stage/bin/$command"
done

# Offscreen rendering exercises the real QML event dispatch without a
# compositor, and the mocked backend means the host network is never touched.
output=$(HOME="$stage/home" XDG_RUNTIME_DIR="$stage/runtime" OMARCHY_PATH="$ROOT" PATH="$stage/bin:$PATH" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 60 quickshell -p "$stage" --no-color 2>&1) || fail "network cancel pointer fixture exits cleanly" "$output"
echo "$output" | grep -E '^ DEBUG qml: (PASS|FAIL) ' | sed 's/^ DEBUG qml: //'

if grep -q '^ DEBUG qml: FAIL ' <<<"$output"; then
  fail "every network cancel pointer assertion holds" "$(grep '^ DEBUG qml: FAIL ' <<<"$output")"
fi
[[ $output == *"RESULT pass cancel-pointer-regression"* ]] ||
  fail "network cancel pointer fixture reports success" "$output"
if rg -q 'ReferenceError|TypeError|Unable to assign' <<<"$output"; then
  fail "network cancel pointer fixture has no QML errors" "$output"
fi
# "Binding loop ... height" on a row's status line is pre-existing: starting a
# connect triggers it on the base Panel.qml as well, so it is not this change's
# to fix here.
pass "double-clicking Cancel cancels once and never forgets the network"
