#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command node
require_command quickshell

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/home" "$tmpdir/runtime"
chmod 700 "$tmpdir/runtime"
ln -s "$ROOT/shell/Ui" "$tmpdir/Ui"
ln -s "$ROOT/shell/Commons" "$tmpdir/Commons"

# Load the shipped transport row, not a second copy of its layout.
node - "$tmpdir/shell.qml" <<'JS'
const fs = require('fs')
const path = require('path')
const source = fs.readFileSync(path.join(process.env.ROOT, 'shell/plugins/services/media/BarWidget.qml'), 'utf8')
const row = source.match(/      Row \{\n        anchors.horizontalCenter: parent.horizontalCenter[\s\S]*?\n      \}/)
if (!row) throw new Error('media transport row not found')

fs.writeFileSync(process.argv[2], `
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  Item {
    id: root
    width: 320
    height: 100
    property QtObject bar: QtObject { property color foreground: "white" }
    property QtObject activePlayer: QtObject {
      property bool isPlaying: true
      property bool canGoPrevious: true
      property bool canGoNext: true
      property bool canTogglePlaying: true
      property bool canPlay: true
      property bool canPause: true
    }
    property var mediaService: null

    ${row[0].replace('Row {', 'Row { id: controls')}

    function checkCenters(state) {
      controls.forceLayout()
      var centers = []
      for (var i = 0; i < controls.children.length; i++) {
        var button = controls.children[i]
        centers.push(button.y + button.height / 2)
      }
      if (centers.length !== 3 || Math.max.apply(null, centers) - Math.min.apply(null, centers) > 0.5) {
        console.log("RESULT fail " + state + " button centers: " + centers.join(", "))
        Qt.quit()
        return false
      }
      return true
    }

    Component.onCompleted: Qt.callLater(function() {
      var expectedScale = Number(Quickshell.env("QT_SCALE_FACTOR"))
      if (Math.abs(Quickshell.screens[0].devicePixelRatio - expectedScale) > 0.01) {
        console.log("RESULT fail display scale was not applied")
        Qt.quit()
        return
      }
      if (!checkCenters("playing")) return
      activePlayer.isPlaying = false
      Qt.callLater(function() {
        if (!checkCenters("paused")) return
        console.log("RESULT pass")
        Qt.quit()
      })
    })
  }
}
`)
JS

# No window or compositor is needed to measure QQuickItem geometry.
for scale in 1 1.25 1.5 2; do
  output=$(env -u WAYLAND_DISPLAY -u DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE \
    -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE \
    HOME="$tmpdir/home" XDG_RUNTIME_DIR="$tmpdir/runtime" \
    QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    QT_SCALE_FACTOR=$scale QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough \
    timeout 15 quickshell -p "$tmpdir" --no-color 2>&1) || {
    printf '%s\n' "$output" >&2
    fail "media controls geometry fixture exits cleanly at scale $scale"
  }
  if ! grep -q "RESULT pass" <<<"$output"; then
    printf '%s\n' "$output" >&2
    fail "media controls share a vertical center at scale $scale"
  fi
  pass "media controls share a vertical center while playing and paused at scale $scale"
done
