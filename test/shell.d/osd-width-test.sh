#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/osd/Osd.qml'), 'utf8')
const capExpression = /readonly property int maxMessageWidth: ([\s\S]*?)\n\n/.exec(qml)[1]
const cap = new Function('root', 'Style', `return ${capExpression}`)
const fixture = fs.readFileSync(path.join(root, 'test/shell.d/osd-width-test.sh'), 'utf8')
const boundExpression = /check\((card.width <= [^\n]+), "long status respects ceiling or minimum"\)/.exec(fixture)[1]
const withinBound = new Function('card', 'screenWidth', 'Style', 'osd', `return ${boundExpression}`)

// Exercise the production cap and runtime assertion on outputs where the
// minimum card width is larger than half the screen, without a compositor.
for (const [screenWidth, scale] of [[400, 1], [1440, 1], [1440, 3]]) {
  const Style = { space(px) { return Math.round(px * scale) } }
  const state = { mediaOsd: false, screenWidth, messageChromeWidth: Math.round(80 * scale) }
  const textWidth = cap(state, Style)
  const card = { width: textWidth + state.messageChromeWidth }
  assert(withinBound(card, screenWidth, Style, state),
    `valid status card fits its ceiling or minimum at ${screenWidth}px and ${scale}x spacing`)
  assert(!withinBound({ width: card.width + 5 }, screenWidth, Style, state),
    `oversized status card fails at ${screenWidth}px and ${scale}x spacing`)
  assert(textWidth >= Style.space(190), 'status retains its minimum text width')
}
JS

require_compositor "OSD width runtime test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$ROOT/shell/plugins/osd/OsdModel.js" "$stage/OsdModel.js"
# Expose geometry only in the fixture; exercise the real OSD and OverlayWindow.
sed '/id: root/a\  readonly property alias testPanel: panel\n  readonly property alias testCard: card' "$ROOT/shell/plugins/osd/Osd.qml" > "$stage/Osd.qml"
cat > "$stage/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: fixture
  property bool capturing: false
  property int step: 0
  property real progressWidth: 0
  property real shortWidth: 0
  property real mediaWidth: 0
  property string longText: "A deliberately overlong application and audio output description ".repeat(30)
  property Osd osd: Osd {}

  function check(condition, message) {
    if (!condition) {
      console.log("RESULT fail " + message)
      Qt.quit()
      throw new Error(message)
    }
  }

  function show(icon, message, value) {
    osd.show(icon, message, value === undefined ? "" : String(value), "100", "", "0")
  }

  function capture(name, next) {
    var dir = Quickshell.env("OSD_TEST_CAPTURE_DIR")
    if (!dir) { next(); return }
    capturing = true
    osd.testCard.grabToImage(function(result) {
      result.saveToFile(dir + "/" + name + ".png")
      capturing = false
      next()
    })
  }

  Timer {
    interval: 250
    running: true
    repeat: true
    onTriggered: {
      if (fixture.capturing || !osd.testPanel.contentRevealed) return
      var card = osd.testCard
      var screenWidth = osd.testPanel.width
      check(screenWidth === osd.testPanel.targetScreen.width, "card uses selected output geometry")
      if (fixture.step === 0) {
        fixture.shortWidth = card.width
        capture("short", function() { show("volume", fixture.longText) })
      } else if (fixture.step === 1) {
        check(card.width > fixture.shortWidth, "long status expands")
        check(card.width <= Math.max(screenWidth / 2 + 1, Style.space(190) + osd.messageChromeWidth), "long status respects ceiling or minimum")
        check(osd.messageWidth < osd.message.length * Style.font.baseSize, "overlong status is bounded")
        capture("long-status", function() { show("media-play", fixture.longText) })
      } else if (fixture.step === 2) {
        fixture.mediaWidth = card.width
        check(osd.messageWidth === Style.space(325), "media retains fixed text cap")
        capture("media", function() { show("volume", "", 9) })
      } else if (fixture.step === 3) {
        fixture.progressWidth = card.width
        capture("progress", function() { show("volume", "", 100) })
      } else if (fixture.step === 4) {
        check(card.width === fixture.progressWidth, "progress width stays stable across percentages")
        Style.fontBaseSize = 18
        show("volume", fixture.longText)
      } else if (fixture.step === 5) {
        check(osd.maxMessageWidth >= Style.space(190), "scaled status preserves minimum text cap")
        check(card.width <= Math.max(screenWidth / 2 + 1, Style.space(190) + osd.messageChromeWidth), "scaled status respects ceiling or minimum")
        check(card.width === card.contentLeftInset + osd.contentWidth + card.contentRightInset, "scaled frame agrees with content insets")
        capture("scaled-status", function() { show("media-play", fixture.longText) })
      } else if (fixture.step === 6) {
        check(osd.messageWidth === Style.space(325), "scaled media retains fixed text cap")
        osd.close()
        Qt.callLater(function() {
          check(!osd.testPanel.visible, "closing unmaps overlay")
          console.log("RESULT pass")
          Qt.quit()
        })
      }
      fixture.step++
    }
  }

  Component.onCompleted: show("volume", "Ready")
}
QML

output=$(timeout 15 quickshell -p "$stage" --no-color 2>&1) || fail "OSD runtime fixture exits cleanly" "$output"
if ! rg -q 'RESULT pass' <<< "$output"; then
  fail "OSD status, media, progress, and scaling geometry" "$output"
fi
pass "OSD status, media, progress, and scaling geometry"
