#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Quickshell forwards QScreen::geometryChanged to x, y, width and height alike,
# so a rotation, mode or scale change fires onXChanged/onYChanged even when the
# origin stays put. Remapping on each one flashed the bar and background and
# rebuilt the bar's widgets. The guard has to remember the last origin and
# pulse only when it actually moved.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/Ui/ScreenMoveRemap.qml', 'utf8')

assert(
  !/function on[XY]Changed\(\)\s*\{\s*settleTimer\.restart\(\)/.test(source),
  'a screen x or y signal does not restart the settle timer unconditionally'
)

const moved = source.match(/function originMoved\(\)\s*\{([^}]*)\}/)
assert(
  moved && /screen\.x === lastX && screen\.y === lastY/.test(moved[1]) &&
    moved[1].indexOf('return') !== -1 &&
    moved[1].indexOf('return') < moved[1].indexOf('settleTimer.restart()'),
  'an unchanged origin returns before the settle timer restarts'
)
assert(
  /function onXChanged\(\)\s*\{\s*root\.originMoved\(\)/.test(source) &&
    /function onYChanged\(\)\s*\{\s*root\.originMoved\(\)/.test(source),
  'both x and y signals go through the origin comparison'
)

assert(
  /function syncOrigin\(\)\s*\{[^}]*lastX = screen\.x[^}]*lastY = screen\.y/.test(source) &&
    /Component\.onCompleted: syncOrigin\(\)/.test(source) &&
    /onScreenChanged: syncOrigin\(\)/.test(source),
  'the remembered origin is seeded on completion and whenever the screen is re-pointed'
)
JS

# Drive the real item against fake screens. Size-only changes mimic Quickshell's
# shared geometry signal: swap width/height, then emit x/yChanged by hand.
require_compositor "screen move remap runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping screen move remap runtime test"
  exit 0
fi

TMPDIR=$(mktemp -d)
cleanup() {
  if [[ -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

ln -s "$ROOT/shell/Ui" "$TMPDIR/Ui"

cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Ui

ShellRoot {
  id: root

  property int pulses: 0
  property int step: 0

  QtObject {
    id: screenA
    property int x: 0
    property int y: 0
    property int width: 1536
    property int height: 2048
  }

  QtObject {
    id: screenB
    property int x: 500
    property int y: 0
    property int width: 1920
    property int height: 1080
  }

  QtObject {
    id: fakeWindow
    property var screen: screenA
  }

  ScreenMoveRemap {
    id: guard
    window: fakeWindow
    onRemappingChanged: if (remapping) root.pulses++
  }

  function resize(screen) {
    var w = screen.width
    screen.width = screen.height
    screen.height = w
    screen.xChanged()
    screen.yChanged()
  }

  // Each step acts; after the settle window the pulse total must equal `expect`.
  readonly property var steps: [
    { label: "1", expect: 0, act: function() { root.resize(screenA) } },
    { label: "2", expect: 1, act: function() { screenA.x = 1920 } },
    { label: "3", expect: 1, act: function() { root.resize(screenA) } },
    { label: "4", expect: 2, act: function() { screenA.y = 100 } },
    { label: "5", expect: 3, act: function() { screenA.x = 100; backTimer.start() } },
    { label: "6a", expect: 3, act: function() { fakeWindow.screen = screenB } },
    { label: "6b", expect: 3, act: function() { root.resize(screenB) } },
    { label: "6c", expect: 4, act: function() { screenB.x = 0 } }
  ]

  Timer {
    id: backTimer
    interval: 50
    onTriggered: screenA.x = 1920
  }

  Timer {
    id: stepTimer
    interval: 600
    repeat: true
    running: true
    onTriggered: {
      if (root.step > 0) {
        var prev = root.steps[root.step - 1]
        if (root.pulses !== prev.expect) {
          console.log("RESULT fail step " + prev.label + " expected " + prev.expect + " got " + root.pulses)
          Qt.quit()
          return
        }
        if (guard.remapping) {
          console.log("RESULT fail step " + prev.label + " remapping still true after settle")
          Qt.quit()
          return
        }
      }
      if (root.step >= root.steps.length) {
        console.log("RESULT pass")
        Qt.quit()
        return
      }
      root.steps[root.step].act()
      root.step++
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "screen move remap runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "the remap guard pulses only when the screen origin really moves"
fi

pass "the remap guard pulses only when the screen origin really moves"
