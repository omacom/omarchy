#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const template = fs.readFileSync(path.join(root, 'default/themed/shell.toml.tpl'), 'utf8')
const color = fs.readFileSync(path.join(root, 'shell/Commons/Color.qml'), 'utf8')
const surface = fs.readFileSync(path.join(root, 'shell/Ui/BorderSurface.qml'), 'utf8')
const fillOverlay = fs.readFileSync(path.join(root, 'shell/Ui/FillOverlay.qml'), 'utf8')
const qmldir = fs.readFileSync(path.join(root, 'shell/Ui/qmldir'), 'utf8')
const menu = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const clipboard = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')
const emojis = fs.readFileSync(path.join(root, 'shell/plugins/emojis/Emojis.qml'), 'utf8')
const reminders = fs.readFileSync(path.join(root, 'shell/plugins/reminders/ReminderFlow.qml'), 'utf8')

assert(!/^background-gradient\s*=/m.test(template), 'menu fill gradients reuse the canonical background token')
assert(!/^selected-background-gradient\s*=/m.test(template), 'selected fill gradients reuse the canonical selected-background token')
assert(/property var backgroundSpec: root\.fillSpec\("menu\.background"/.test(color), 'Color exposes the menu card fill spec')
assert(/property var selectedBackgroundSpec: root\.fillSpec\("menu\.selected-background"/.test(color), 'Color exposes the selected-item fill spec')
assert(/property var fillSpec: null/.test(surface) && /usesGradientFill/.test(surface), 'BorderSurface supports lazy gradient fills')
assert(/property color fillColor: "transparent"/.test(surface) && /color: usesGradientFill \? "transparent" : fillColor/.test(surface), 'gradient fills replace rather than stack over solid fallbacks')
assert(/FillOverlay 1\.0 FillOverlay\.qml/.test(qmldir), 'FillOverlay is registered in qs.Ui')
assert(/sampledStopPosition\(root\._colors,/.test(fillOverlay) && /sampledStopColor/.test(fillOverlay), 'FillOverlay positions fixed slots around authored stops')
const geometry = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\s*/, '')
const samples = vm.createContext({ Qt: { rgba: (r, g, b, a) => ({ r, g, b, a }) } })
vm.runInContext(geometry, samples)
for (let count = 2; count <= 10; count++) {
  const colors = Array.from({ length: count }, (_, i) => ({ r: i / 10, g: 0, b: 0, a: 1 }))
  const positions = Array.from({ length: 10 }, (_, i) => samples.sampledStopPosition(colors, i, 10))
  assert(positions[0] === 0 && positions[9] === 1 && positions.every((p, i) => i === 0 || p > positions[i - 1]), `${count} stops occupy distinct positions`)
  for (let stop = 0; stop < count; stop++) {
    const slot = Math.floor(stop * 9 / (count - 1))
    assert(Math.abs(positions[slot] - stop / (count - 1)) < 1e-10, `${count}-stop palette retains authored stop ${stop} position`)
    const color = samples.sampledStopColor(colors, slot, 10)
    assert(Math.abs(color.r - colors[stop].r) < 1e-10, `${count}-stop palette retains authored stop ${stop} color`)
  }
}
assert(/fillSpec: root\.backgroundSpec/.test(menu) && /fillSpec: row\.hasCursor \? root\.selectedBackgroundSpec : null/.test(menu), 'Menu renders card and selected-row gradients')
assert((menu.match(/visible: opacity > 0 && !root\.backgroundSpec\.gradient\.enabled/g) || []).length === 2
  && (menu.match(/visible: opacity > 0 && root\.backgroundSpec\.gradient\.enabled/g) || []).length === 2,
  'Menu retains top and bottom scroll cues for both solid and gradient cards')
assert(menu.includes('Util.alpha(root.foreground, 0.18)'), 'gradient scroll cues tint rather than flatten the card fill')
assert(/fillSpec: root\.backgroundSpec/.test(clipboard) && /fillSpec: hasCursor \? root\.selectedBackgroundSpec : null/.test(clipboard), 'Clipboard inherits menu card and selected-row gradients')
assert(/fillSpec: root\.backgroundSpec/.test(emojis) && /fillSpec: hasCursor \? root\.selectedBackgroundSpec : null/.test(emojis), 'Emojis inherit menu card and selected-cell gradients')
assert(/fillSpec: root\.backgroundSpec/.test(reminders), 'Reminders inherit the menu card gradient')
JS

require_compositor "menu gradient runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping menu gradient runtime test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function runChecks() {
    Color.loadUserShell(`
[menu]
background = "#11223380 #445566 25deg"
background-alpha = 0.5
selected-background = "#11223380 foreground 0deg"
selected-background-alpha = 0.35
`)

    Qt.callLater(function() {
      var background = Color.menu.backgroundSpec
      var selected = Color.menu.selectedBackgroundSpec
      if (!background.gradient.enabled || background.gradient.colors.length !== 2 || background.gradient.angle !== 25) {
        fail("menu background gradient spec was not resolved")
        return
      }
      if (Math.abs(background.gradient.colors[0].a - 0.25) > 0.01
          || Math.abs(Color.menu.background.a - background.gradient.colors[0].a) > 0.01) {
        fail("menu background and color-only fallback did not share multiplied alpha")
        return
      }
      if (!selected.gradient.enabled || selected.gradient.colors.length !== 2
          || Math.abs(selected.gradient.colors[0].a - 128 / 255 * 0.35) > 0.01
          || Math.abs(Color.menu.selectedBackground.a - selected.gradient.colors[0].a) > 0.01) {
        fail("selected background gradient and fallback were not resolved consistently")
        return
      }
      if (!card.usesGradientFill || !card.usesOverlayBorder || !selection.usesGradientFill) {
        fail("gradient surfaces did not select the overlay renderers")
        return
      }
      if (card.color.a > 0.01 || selection.color.a > 0.01) {
        fail("gradient fills were composited over their solid fallbacks")
        return
      }

      Color.loadUserShell(`
[menu]
background = "#11223380"
background-alpha = 0.5
selected-background = "#445566"
selected-background-alpha = 0.35
`)
      Qt.callLater(function() {
        if (card.usesGradientFill || selection.usesGradientFill) {
          fail("solid menu values selected a gradient renderer")
          return
        }
        if (Math.abs(card.color.a - 0.5) > 0.01) {
          fail("solid menu alpha compatibility changed")
          return
        }

        Color.loadUserShell(`
[menu]
background = "fill.alias"
[fill]
alias = "menu.background"
`)
        Qt.callLater(function() {
          if (Math.abs(Color.menu.background.r - Color.background.r) > 0.01
              || Math.abs(Color.menu.background.g - Color.background.g) > 0.01
              || Math.abs(Color.menu.background.b - Color.background.b) > 0.01) {
            fail("cyclic fill references did not fall back safely")
            return
          }
          console.log("RESULT pass")
          Qt.quit()
        })
      })
    })
  }

  Timer {
    interval: 100
    running: true
    onTriggered: root.runChecks()
  }

  BorderSurface {
    id: card
    width: 160
    height: 100
    radius: 12
    fillColor: Color.menu.background
    fillSpec: Color.menu.backgroundSpec
    borderSpec: Border.flat("white", 1)
  }

  BorderSurface {
    id: selection
    width: 120
    height: 40
    radius: 8
    fillColor: Color.menu.selectedBackground
    fillSpec: Color.menu.selectedBackgroundSpec
  }
}
QML

output=$(timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "menu gradient runtime fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "menu gradient specs render through gradient surfaces"
fi

pass "menu gradient specs render through gradient surfaces"
