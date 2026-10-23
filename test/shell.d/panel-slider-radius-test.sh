#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const sliderQml = fs.readFileSync(path.join(root, 'shell/Ui/PanelSlider.qml'), 'utf8')

assert(
  /property real trackRadius:\s*trackHeight \/ 2/.test(sliderQml) &&
    /property real tickRadius:\s*1/.test(sliderQml) &&
    /property real knobRadius:\s*knobSize \/ 2/.test(sliderQml),
  'PanelSlider radius defaults reproduce the pill shape callers already render'
)

assert(
  !/radius:\s*height \/ 2/.test(sliderQml) && !/radius:\s*root\.knobSize \/ 2/.test(sliderQml),
  'PanelSlider draws from the radius properties instead of hardcoded expressions'
)
JS

require_compositor "PanelSlider radius runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping PanelSlider radius runtime test"
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
ln -s "$ROOT/shell/Commons" "$TMPDIR/Commons"

cat >"$TMPDIR/shell.qml" <<'QML'
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

  // Track, fill, ticks and knob are internal, so collect every drawn radius
  // rather than depending on the order children happen to be declared in.
  function drawnRadii(item, out) {
    for (var i = 0; i < item.children.length; i++) {
      var child = item.children[i]
      if (child.radius !== undefined) out.push(child.radius)
      root.drawnRadii(child, out)
    }
    return out
  }

  function runChecks() {
    if (defaultSlider.trackRadius !== defaultSlider.trackHeight / 2) {
      root.fail("default trackRadius is " + defaultSlider.trackRadius + ", expected " + defaultSlider.trackHeight / 2)
      return
    }
    if (defaultSlider.knobRadius !== defaultSlider.knobSize / 2) {
      root.fail("default knobRadius is " + defaultSlider.knobRadius + ", expected " + defaultSlider.knobSize / 2)
      return
    }
    if (defaultSlider.tickRadius !== 1) {
      root.fail("default tickRadius is " + defaultSlider.tickRadius + ", expected 1")
      return
    }

    var rounded = root.drawnRadii(defaultSlider, [])
    if (rounded.length === 0) {
      root.fail("default slider drew nothing with a radius")
      return
    }
    for (var i = 0; i < rounded.length; i++) {
      if (rounded[i] <= 0) {
        root.fail("default slider drew a square corner: radius " + rounded[i])
        return
      }
    }

    var squared = root.drawnRadii(squaredSlider, [])
    if (squared.length !== rounded.length) {
      root.fail("squared slider drew " + squared.length + " radii, default drew " + rounded.length)
      return
    }
    for (var j = 0; j < squared.length; j++) {
      if (squared[j] !== 0) {
        root.fail("squared slider kept a rounded corner: radius " + squared[j])
        return
      }
    }

    console.log("RESULT pass")
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  Item {
    PanelSlider {
      id: defaultSlider
      width: 200
      value: 0.5
      tickCount: 5
    }

    PanelSlider {
      id: squaredSlider
      width: 200
      value: 0.5
      tickCount: 5
      trackRadius: 0
      tickRadius: 0
      knobRadius: 0
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "PanelSlider radius runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "PanelSlider radius properties drive the drawn corners"
fi

pass "PanelSlider radius properties drive the drawn corners"
