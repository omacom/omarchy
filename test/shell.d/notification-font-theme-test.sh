#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command quickshell
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export FONT_TEST_STAGE="$test_tmp"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
# Compile the production bindings in a small host, without starting another
# notification server. Test actual QML reactivity and render the resolved font.
node <<'JS'
const fs = require('fs')
const source = fs.readFileSync(process.env.ROOT + '/shell/plugins/notifications/Service.qml', 'utf8')
const start = source.indexOf('  readonly property string notificationFontSetting:')
const end = source.indexOf('\n  // Live Notification', start)
if (start < 0 || end < 0) throw Error('missing font bindings')
fs.writeFileSync(process.env.FONT_TEST_STAGE + '/shell.qml', `
import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
ShellRoot {
  id: service
  property var shell: ({ shellConfig: {}, bar: { fontFamily: "monospace" } })
${source.slice(start, end)}
  FloatingWindow {
    width: 480; height: 160; visible: true
    color: "#202030"
    Text { anchors.centerIn: parent; text: "Notification theme font\\nSummary and body preview"; color: "white"; font.pixelSize: 22; font.family: service.notificationTextFontFamily }
  }
  function check(expected) {
    if (notificationTextFontFamily !== expected) throw Error("font: " + notificationTextFontFamily + " expected " + expected)
  }
  Component.onCompleted: Qt.callLater(function() {
    check("Liberation Sans")
    Commons.Color.shellValues = ({ "notifications.font-family": "serif" })
    check("serif")
    shell = ({ shellConfig: { notifications: { font: "sans-serif" } }, bar: { fontFamily: "monospace" } })
    check("sans-serif")
    Commons.Color.shellValues = ({ "notifications.font-family": "monospace" })
    check("sans-serif")
    shell = ({ shellConfig: { notifications: { font: "default" } } })
    check("monospace")
    shell = ({ shellConfig: { notifications: { font: "system" } }, bar: { fontFamily: "serif" } })
    check("serif")
    console.log("RESULT pass")
    if (Quickshell.env("FONT_TEST_VISUAL") !== "1") Qt.quit()
  })
}
`)
JS
if [[ ${FONT_TEST_VISUAL:-0} == 1 ]]; then
  quickshell -p "$test_tmp" --no-color
else
  output=$(QT_QPA_PLATFORM=offscreen timeout 15 quickshell -p "$test_tmp" --no-color 2>&1)
  [[ $output == *"RESULT pass"* ]] || fail "notification font precedence reacts live" "$output"
  pass "notification theme default and user overrides react live"
fi
