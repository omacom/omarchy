#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The shared shell/Ui kit carries Qt Accessible roles, names, states and
# actions so screen readers and AT-SPI tools can find and operate controls.

require_compositor "UI kit accessibility runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping UI kit accessibility runtime test"
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

  property var failures: []
  property int buttonClicks: 0
  property int widgetPresses: 0
  property int toggleClicks: 0
  property int switchToggles: 0
  property int sliderMoves: 0
  property int sliderReleases: 0
  property int actionClicks: 0
  property int rowPresses: 0

  function check(condition, message) {
    if (!condition) failures.push(message)
  }

  function same(actual, expected, message) {
    if (actual !== expected) failures.push(message + " expected=" + JSON.stringify(expected) + " actual=" + JSON.stringify(actual))
  }

  function childWith(item, property) {
    for (var i = 0; i < item.children.length; i++) {
      var child = item.children[i]
      if (child[property] !== undefined) return child
      var nested = childWith(child, property)
      if (nested) return nested
    }
    return null
  }

  function runChecks() {
    same(textButton.Accessible.role, Accessible.Button, "Button role")
    same(textButton.Accessible.name, "Refresh", "Button is named by its text")
    same(iconButton.Accessible.name, "Forget network", "icon-only Button falls back to its tooltip")
    same(namedIconButton.Accessible.name, "Previous track", "accessibleName overrides the fallback")
    same(selectedButton.Accessible.selected, true, "selected Button reports selected")

    same(barIcon.Accessible.name, "Wi-Fi: Home", "BarIconButton is named by its tooltip")
    same(bareBarIcon.Accessible.name, "", "BarIconButton never announces its glyph")
    same(widget.Accessible.name, "Calendar", "WidgetButton prefers its tooltip")
    same(textWidget.Accessible.name, "14:32", "WidgetButton falls back to its text")
    same(concealedWidget.Accessible.ignored, true, "concealed WidgetButton is hidden from assistive technology")
    same(staticWidget.Accessible.role, Accessible.StaticText, "non-pressable WidgetButton reads as text")

    same(toggle.Accessible.role, Accessible.CheckBox, "Toggle role")
    same(toggle.Accessible.name, "Wi-Fi", "Toggle is named by its label")
    same(toggle.Accessible.checked, true, "Toggle reports checked")
    var innerSwitch = childWith(toggle, "trackWidth")
    check(innerSwitch !== null, "Toggle contains its switch")
    if (innerSwitch) same(innerSwitch.Accessible.ignored, true, "Toggle's decorative switch is hidden")

    same(bareSwitch.Accessible.role, Accessible.CheckBox, "ToggleSwitch role")
    same(bareSwitch.Accessible.name, "Tailscale", "ToggleSwitch takes accessibleName")
    same(bareSwitch.Accessible.ignored, false, "interactive ToggleSwitch is exposed")

    same(plainField.Accessible.name, "Search", "TextField is named by its placeholder")
    same(passwordField.Accessible.description, "Passphrase for Home", "password TextField carries its name in the description")

    same(slider.Accessible.role, Accessible.Slider, "PanelSlider role")
    same(slider.Accessible.name, "Volume", "PanelSlider takes accessibleName")
    same(slider.minimumValue, 0, "PanelSlider exposes its minimum to the Value interface")
    same(slider.maximumValue, 1.5, "PanelSlider exposes its maximum to the Value interface")
    same(slider.stepSize, 0.05, "PanelSlider exposes its step to the Value interface")

    same(dropdown.accessibleName, "Output", "Dropdown is named by its label")
    same(actionButton.Accessible.name, "Unpair", "PanelActionButton is named by its tooltip")

    same(unnamedRow.Accessible.ignored, true, "unnamed CursorSurface stays out of the tree")
    same(namedRow.Accessible.ignored, false, "named CursorSurface joins the tree")
    same(namedRow.Accessible.role, Accessible.ListItem, "CursorSurface role")
    same(namedRow.Accessible.selected, true, "current CursorSurface reports selected")

    textButton.Accessible.pressAction()
    disabledButton.Accessible.pressAction()
    same(buttonClicks, 1, "Button accessibility press follows enabled click behavior")

    widget.Accessible.pressAction()
    same(widgetPresses, 1, "WidgetButton accessibility press emits a left-button press")

    toggle.Accessible.toggleAction()
    same(toggleClicks, 1, "Toggle accessibility toggle emits clicked")

    bareSwitch.Accessible.toggleAction()
    busySwitch.Accessible.toggleAction()
    same(switchToggles, 1, "ToggleSwitch accessibility toggle respects busy state")

    slider.Accessible.increaseAction()
    slider.Accessible.decreaseAction()
    same(slider.liveValue, 0, "PanelSlider accessibility actions adjust its live value")
    same(sliderMoves, 2, "PanelSlider accessibility actions emit moved")
    same(sliderReleases, 2, "PanelSlider accessibility actions emit released")

    actionButton.Accessible.pressAction()
    same(actionClicks, 1, "PanelActionButton accessibility press emits clicked")

    namedRow.Accessible.pressAction()
    same(rowPresses, 1, "named CursorSurface accessibility press follows its row action")

    console.log(failures.length === 0 ? "RESULT pass" : "RESULT fail " + failures.join("; "))
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  Item {
    Button { id: textButton; text: "Refresh"; onClicked: root.buttonClicks++ }
    Button { id: disabledButton; text: "Disabled"; enabled: false; onClicked: root.buttonClicks++ }
    Button { id: iconButton; iconText: "\u{F0450}"; tooltipText: "Forget network" }
    Button { id: namedIconButton; iconText: "\u{F04AE}"; accessibleName: "Previous track" }
    Button { id: selectedButton; text: "Auto"; selected: true }

    BarIconButton { id: barIcon; text: "\u{F05A9}"; tooltipText: "Wi-Fi: Home" }
    BarIconButton { id: bareBarIcon; text: "\u{F05A9}" }
    WidgetButton { id: widget; text: "14:32"; tooltipText: "Calendar"; onPressed: root.widgetPresses++ }
    WidgetButton { id: textWidget; text: "14:32" }
    WidgetButton { id: concealedWidget; text: "\u{F0F54}"; tooltipText: "Do not disturb"; concealed: true }
    WidgetButton { id: staticWidget; text: "CPU 12%"; pressable: false }

    Toggle { id: toggle; label: "Wi-Fi"; checked: true; onClicked: root.toggleClicks++ }
    ToggleSwitch { id: bareSwitch; accessibleName: "Tailscale"; onToggled: root.switchToggles++ }
    ToggleSwitch { id: busySwitch; accessibleName: "Busy"; busy: true; onToggled: root.switchToggles++ }

    TextField { id: plainField; placeholderText: "Search" }
    TextField { id: passwordField; password: true; placeholderText: "Passphrase"; accessibleName: "Passphrase for Home" }

    PanelSlider {
      id: slider
      accessibleName: "Volume"
      maximum: 1.5
      onMoved: root.sliderMoves++
      onReleased: root.sliderReleases++
    }
    Dropdown { id: dropdown; label: "Output"; options: ["Speakers", "Headphones"] }
    PanelActionButton { id: actionButton; iconText: "\u{F0156}"; tooltipText: "Unpair"; onClicked: root.actionClicks++ }

    CursorSurface { id: unnamedRow }
    CursorSurface {
      id: namedRow
      accessibleName: "Home"
      current: true
      Accessible.onPressAction: root.rowPresses++
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "UI kit accessibility runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "UI kit components expose accessible roles, names and states"
fi

pass "UI kit components expose accessible roles, names and states"
