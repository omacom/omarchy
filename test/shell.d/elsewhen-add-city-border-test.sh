#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "Elsewhen add-city bottom border clearance test"

TMPDIR=$(mktemp -d)
cleanup() {
  if [[ -d $TMPDIR ]]; then
    rm -rf -- "$TMPDIR"
  fi
}
trap cleanup EXIT

ln -s "$ROOT/shell/Ui" "$TMPDIR/Ui"
ln -s "$ROOT/shell/Commons" "$TMPDIR/Commons"
ln -s "$ROOT/shell/plugins" "$TMPDIR/plugins"

cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "plugins/panels/elsewhen" as Elsewhen

ShellRoot {
  id: root

  property var sizes: [11, 12]
  property int sizeIndex: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function keyboardPanel() {
    for (var i = 0; i < panel.data.length; i++) {
      var child = panel.data[i]
      if (child && child.ensureContent) return child
    }
    return null
  }

  function makeCities(count) {
    var base = [
      { name: "London", zone: "Europe/London" },
      { name: "Toronto", zone: "America/Toronto" },
      { name: "Mumbai", zone: "Asia/Kolkata" },
      { name: "Tokyo", zone: "Asia/Tokyo" },
      { name: "Dubai", zone: "Asia/Dubai" },
      { name: "Los Angeles", zone: "America/Los_Angeles" },
      { name: "New York", zone: "America/New_York" },
      { name: "Sydney", zone: "Australia/Sydney" }
    ]
    return base.slice(0, count)
  }

  function checkCase(baseSize, count, next) {
    Style.fontBaseSize = baseSize
    panel.settings = {
      id: "omarchy.elsewhen",
      units: "C",
      cities: makeCities(count)
    }

    var kp = keyboardPanel()
    if (!kp) {
      fail("KeyboardPanel not found")
      return
    }
    kp.ensureContent()

    waitFrames(3, function() {
      var lc = kp.loadedContent
      if (!lc) {
        fail("loadedContent missing at baseSize=" + baseSize + " count=" + count)
        return
      }

      var label = "baseSize=" + baseSize + " count=" + count
      var clipItem = lc.listWrap.parent
      var stageBottom = lc.listWrap.y + lc.listWrap.implicitHeight + Style.spacing.hairline
      if (clipItem.height + 0.001 < stageBottom) {
        fail(label + ": stage clip height " + clipItem.height + " < bottom+hairline " + stageBottom)
        return
      }

      var addBottom = lc.stage.y + lc.citySearch.y + lc.citySearch.height + Style.spacing.hairline
      if (count <= 3) {
        if (lc.scroller.maxScroll > 0) {
          fail(label + ": scroller.maxScroll=" + lc.scroller.maxScroll + " > 0")
          return
        }
        if (lc.scroller.height + 0.001 < addBottom) {
          fail(label + ": scroller height " + lc.scroller.height + " < addBottom+hairline " + addBottom)
          return
        }
        next()
        return
      }

      panel.focusOn(-1)
      panel.moveFocus(-1)
      waitFrames(3, function() {
        var visibleBottom = lc.scroller.contentY + lc.scroller.height
        if (visibleBottom + 0.001 < addBottom) {
          fail(label + ": scrolled bottom " + visibleBottom + " < addBottom+hairline " + addBottom)
          return
        }
        next()
      })
    })
  }

  function waitFrames(n, fn) {
    if (n <= 0) {
      fn()
      return
    }
    Qt.callLater(function() { waitFrames(n - 1, fn) })
  }

  function runNextSize() {
    if (sizeIndex >= sizes.length) {
      console.log("RESULT pass")
      Qt.quit()
      return
    }
    var baseSize = sizes[sizeIndex++]
    checkCase(baseSize, 3, function() {
      checkCase(baseSize, 8, runNextSize)
    })
  }

  Component.onCompleted: {
    Style.reduceMotion = true
    Qt.callLater(runNextSize)
  }

  Item {
    width: 30
    height: 26

    Elsewhen.Panel {
      id: panel
    }
  }
}
QML

output=$(HOME="$TMPDIR" OMARCHY_PATH="$ROOT" timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Elsewhen add-city bottom border test exits cleanly"
}

if [[ $output != *"RESULT pass"* ]]; then
  printf '%s\n' "$output" >&2
  fail "Elsewhen add-city button clears stage and scroller bottom clip edges"
fi

pass "Elsewhen add-city button clears stage and scroller bottom clip edges"
