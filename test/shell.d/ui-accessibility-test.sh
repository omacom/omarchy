#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The shared shell/Ui kit carries Qt Accessible roles, names, states and
# actions so screen readers and AT-SPI tools can find and operate controls.

require_command python3

python3 - "$ROOT" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])


def tokens(source):
  result = []
  i = 0
  line = 1
  while i < len(source):
    char = source[i]
    if char == "\n":
      line += 1
      i += 1
    elif char.isspace():
      i += 1
    elif source.startswith("//", i):
      end = source.find("\n", i + 2)
      i = len(source) if end == -1 else end
    elif source.startswith("/*", i):
      end = source.find("*/", i + 2)
      if end == -1:
        raise ValueError(f"unterminated comment at line {line}")
      line += source.count("\n", i, end + 2)
      i = end + 2
    elif char in "\"'`":
      quote = char
      start_line = line
      value = []
      i += 1
      while i < len(source):
        char = source[i]
        if char == "\\":
          if i + 1 < len(source):
            value.extend(source[i:i + 2])
            i += 2
          else:
            i += 1
        elif char == quote:
          i += 1
          break
        else:
          if char == "\n":
            line += 1
          value.append(char)
          i += 1
      result.append(("STRING", "".join(value), start_line))
    elif char.isalpha() or char == "_":
      match = re.match(r"[A-Za-z_][A-Za-z0-9_.]*", source[i:])
      value = match.group(0)
      result.append(("IDENT", value, line))
      i += len(value)
    else:
      result.append((char, char, line))
      i += 1
  return result


def direct_properties(all_tokens, opening):
  entries = []
  depth = 1
  index = opening + 1
  closing = len(all_tokens)
  while index < len(all_tokens) and depth:
    kind, value, line = all_tokens[index]
    if kind == "{":
      depth += 1
    elif kind == "}":
      depth -= 1
      if depth == 0:
        closing = index
        break
    elif depth == 1 and kind == "IDENT" and index + 1 < len(all_tokens) and all_tokens[index + 1][0] == ":":
      entries.append((index, value))
    index += 1

  properties = {}
  for entry_index, (position, name) in enumerate(entries):
    end = entries[entry_index + 1][0] if entry_index + 1 < len(entries) else closing
    expression = all_tokens[position + 2:end]
    while expression and expression[-1][0] == ";":
      expression.pop()
    properties[name] = expression
  return properties


def glyph_string(expression):
  if len(expression) != 1 or expression[0][0] != "STRING":
    return False
  chars = [char for char in expression[0][1] if not char.isspace()]
  return bool(chars) and all(0xE000 <= ord(char) <= 0xF8FF or ord(char) >= 0xF0000 for char in chars)


def expression_nonempty(expression):
  if not expression or any(token[0] == "STRING" and token[1] == "" for token in expression):
    return False
  return not glyph_string(expression)


def nonempty(properties, names):
  return any(expression_nonempty(properties.get(name, [])) for name in names)


required_names = {
  "BarIconButton": ("accessibleName", "tooltipText", "label"),
  "BarIndicator": ("accessibleName", "tooltipText", "activeTooltipText", "inactiveTooltipText", "label"),
  "ToggleSwitch": ("accessibleName", "tooltipText", "label"),
  "PanelSlider": ("accessibleName", "tooltipText", "label"),
  "PanelActionButton": ("accessibleName", "tooltipText", "label"),
}
failures = []
for path in sorted((root / "shell/plugins").rglob("*.qml")):
  source_tokens = tokens(path.read_text())
  for index, token in enumerate(source_tokens[:-1]):
    if token[0] != "IDENT" or token[1] not in set(required_names) | {"Button"} or source_tokens[index + 1][0] != "{":
      continue
    component = token[1]
    properties = direct_properties(source_tokens, index + 1)
    if component == "Button":
      if "iconText" not in properties or ("text" in properties and not glyph_string(properties["text"])):
        continue
      names = ("accessibleName", "tooltipText", "label", "text")
    else:
      names = required_names[component]
    if not nonempty(properties, names):
      failures.append(f"{path.relative_to(root)}:{token[2]} {component}")

if failures:
  print("Unnamed first-party controls:", file=sys.stderr)
  for failure in failures:
    print(f"  {failure}", file=sys.stderr)
  raise SystemExit(1)
PY
pass "first-party icon controls provide accessible names"

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
  property int dropdownChanges: 0
  property int searchableChanges: 0
  property int multiChanges: 0
  property int dialogCancels: 0
  property int dialogConfirms: 0
  property real boundVolume: 0.4
  property int boundSliderReleases: 0
  property int disabledSliderMoves: 0
  property int disabledToggleEvents: 0

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

  function accessibleChild(item, name, role, seen) {
    if (!item) return null
    seen = seen || []
    if (seen.indexOf(item) !== -1) return null
    seen.push(item)
    if (item.Accessible && item.Accessible.name === name && item.Accessible.role === role) return item
    if (item.data) {
      for (var i = 0; i < item.data.length; i++) {
        var owned = accessibleChild(item.data[i], name, role, seen)
        if (owned) return owned
      }
    }
    if (item.children) {
      for (var j = 0; j < item.children.length; j++) {
        var child = accessibleChild(item.children[j], name, role, seen)
        if (child) return child
      }
    }
    if (item.contentItem && item.contentItem !== item) return accessibleChild(item.contentItem, name, role, seen)
    return null
  }

  function finishChecks() {
    console.log(failures.length === 0 ? "RESULT pass" : "RESULT fail " + failures.join("; "))
    Qt.quit()
  }

  function checkCompositeControls() {
    var panelCard = accessibleChild(keyboardPanel, "Network", Accessible.Dialog)
    check(panelCard !== null, "KeyboardPanel card is exposed as a named dialog")

    var dropdownTrigger = accessibleChild(testWindow.contentItem, "Output", Accessible.ComboBox)
    check(dropdownTrigger !== null, "Dropdown trigger is exposed as a combo box")
    if (!dropdownTrigger) { finishChecks(); return }
    same(dropdownTrigger.Accessible.description, "Speakers", "Dropdown describes its current value")
    dropdownTrigger.Accessible.pressAction()
    same(dropdown.popupOpen, true, "Dropdown accessibility press opens its popup")
    Qt.callLater(checkDropdownOption)
  }

  function checkDropdownOption() {
    var option = accessibleChild(testWindow.contentItem, "Headphones", Accessible.ListItem)
    check(option !== null, "Dropdown popup exposes option rows")
    if (!option) { finishChecks(); return }
    same(option.Accessible.selected, false, "Dropdown option reports selection")
    option.Accessible.pressAction()
    same(dropdown.value, "headphones", "Dropdown option press selects its value")
    same(dropdownChanges, 1, "Dropdown option press emits changed")

    var trigger = accessibleChild(testWindow.contentItem, "Country", Accessible.ComboBox)
    check(trigger !== null, "SearchableDropdown trigger is exposed as a combo box")
    if (!trigger) { finishChecks(); return }
    trigger.Accessible.pressAction()
    same(searchable.popupOpen, true, "SearchableDropdown accessibility press opens its popup")
    Qt.callLater(checkSearchableOption)
  }

  function checkSearchableOption() {
    var option = accessibleChild(testWindow.contentItem, "Beta", Accessible.ListItem)
    check(option !== null, "SearchableDropdown popup exposes option rows")
    if (!option) { finishChecks(); return }
    same(option.Accessible.description, "Second", "SearchableDropdown option exposes its description")
    option.Accessible.pressAction()
    same(searchable.value, "beta", "SearchableDropdown option press selects its value")
    same(searchableChanges, 1, "SearchableDropdown option press emits changed")

    var trigger = accessibleChild(testWindow.contentItem, "Tags", Accessible.ComboBox)
    check(trigger !== null, "MultiSelect trigger is exposed as a combo box")
    if (!trigger) { finishChecks(); return }
    trigger.Accessible.pressAction()
    same(multi.popupOpen, true, "MultiSelect accessibility press opens its popup")
    Qt.callLater(checkMultiOption)
  }

  function checkMultiOption() {
    var option = accessibleChild(testWindow.contentItem, "One", Accessible.CheckBox)
    check(option !== null, "MultiSelect popup exposes option rows")
    if (!option) { finishChecks(); return }
    same(option.Accessible.checked, false, "MultiSelect option reports unchecked")
    option.Accessible.toggleAction()
    same(multi.values.length, 1, "MultiSelect option toggle updates selection")
    same(multi.values[0], "one", "MultiSelect option toggle selects its value")
    same(multiChanges, 1, "MultiSelect option toggle emits changed")
    same(option.Accessible.checked, true, "MultiSelect option reports checked")
    multi.close()

    var dialog = accessibleChild(testWindow.contentItem, "Delete this item?", Accessible.Dialog)
    var cancel = accessibleChild(testWindow.contentItem, "Cancel", Accessible.Button)
    var confirm = accessibleChild(testWindow.contentItem, "Delete", Accessible.Button)
    check(dialog !== null, "ConfirmDialog is exposed as a named dialog")
    check(cancel !== null && confirm !== null, "ConfirmDialog exposes both buttons")
    if (cancel && confirm) {
      cancel.Accessible.pressAction()
      confirm.Accessible.pressAction()
    }
    same(dialogCancels, 1, "ConfirmDialog cancel action emits canceled")
    same(dialogConfirms, 1, "ConfirmDialog confirm action emits confirmed")
    finishChecks()
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

    same(slider.accessibleItem.Accessible.role, Accessible.Slider, "PanelSlider role")
    same(slider.accessibleItem.Accessible.name, "Volume", "PanelSlider takes accessibleName")
    same(slider.accessibleItem.minimumValue, 0, "PanelSlider exposes its minimum to the Value interface")
    same(slider.accessibleItem.maximumValue, 1.5, "PanelSlider exposes its maximum to the Value interface")
    same(slider.accessibleItem.stepSize, 0.05, "PanelSlider exposes its step to the Value interface")

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

    slider.accessibleItem.Accessible.increaseAction()
    slider.accessibleItem.Accessible.decreaseAction()
    same(slider.liveValue, 0, "PanelSlider accessibility actions adjust its live value")
    same(sliderMoves, 2, "PanelSlider accessibility actions emit moved")
    same(sliderReleases, 2, "PanelSlider accessibility actions emit released")

    // A value written through the Value interface commits like a drag, and
    // the caller's binding keeps driving the slider afterwards.
    boundSlider.accessibleItem.value = 0.8
    same(boundVolume, 0.8, "PanelSlider value write commits through moved/released")
    same(boundSliderReleases, 1, "PanelSlider value write emits released once")
    root.boundVolume = 0.2
    same(boundSlider.liveValue, 0.2, "PanelSlider keeps its caller binding after a value write")
    same(boundSlider.accessibleItem.value, 0.2, "PanelSlider mirrors the caller value to assistive technology")
    same(boundSliderReleases, 1, "PanelSlider mirroring a caller value does not commit it again")

    // Disabled controls ignore accessibility actions, as they ignore the pointer.
    disabledSlider.accessibleItem.Accessible.increaseAction()
    disabledSlider.accessibleItem.value = 0.9
    same(disabledSliderMoves, 0, "disabled PanelSlider ignores accessibility actions")
    same(disabledSlider.liveValue, 0.5, "disabled PanelSlider keeps its value")
    disabledToggle.Accessible.toggleAction()
    disabledToggle.Accessible.pressAction()
    disabledSwitch.Accessible.toggleAction()
    same(disabledToggleEvents, 0, "disabled Toggle and ToggleSwitch ignore accessibility actions")
    var disabledTrigger = accessibleChild(testWindow.contentItem, "Unavailable dropdown", Accessible.ComboBox)
    check(disabledTrigger !== null, "disabled Dropdown trigger is exposed as a combo box")
    if (disabledTrigger) disabledTrigger.Accessible.pressAction()
    same(disabledDropdown.popupOpen, false, "disabled Dropdown ignores its accessibility press")
    var disabledSearchableTrigger = accessibleChild(testWindow.contentItem, "Unavailable searchable dropdown", Accessible.ComboBox)
    check(disabledSearchableTrigger !== null, "disabled SearchableDropdown trigger is exposed as a combo box")
    if (disabledSearchableTrigger) disabledSearchableTrigger.Accessible.pressAction()
    same(disabledSearchable.popupOpen, false, "disabled SearchableDropdown ignores its accessibility press")
    var disabledMultiTrigger = accessibleChild(testWindow.contentItem, "Unavailable multi-select", Accessible.ComboBox)
    check(disabledMultiTrigger !== null, "disabled MultiSelect trigger is exposed as a combo box")
    if (disabledMultiTrigger) disabledMultiTrigger.Accessible.pressAction()
    same(disabledMulti.popupOpen, false, "disabled MultiSelect ignores its accessibility press")

    // A row whose press turns something on or off reports that as checked,
    // not the cursor's focus as selected (the Display panel's monitor rows).
    same(toggleRow.Accessible.checkable, true, "on/off row is checkable")
    same(toggleRow.Accessible.checked, true, "on/off row reports its state as checked")
    same(toggleRow.Accessible.selected, false, "on/off row keeps focus out of selected")

    actionButton.Accessible.pressAction()
    same(actionClicks, 1, "PanelActionButton accessibility press emits clicked")

    namedRow.Accessible.pressAction()
    same(rowPresses, 1, "named CursorSurface accessibility press follows its row action")

    checkCompositeControls()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  QtObject {
    id: testBar
    property string position: "top"
    property int barSize: Style.bar.sizeHorizontal
    property var activePopout: null
    property var clickTargets: []
    function requestPopout(owner) {}
    function releasePopout(owner) {}
    function targetBelongsToWindow(target, window) { return false }
  }

  FloatingWindow {
    id: testWindow
    visible: true
    implicitWidth: 720
    implicitHeight: 640

    Item {
      anchors.fill: parent

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
    PanelSlider {
      id: boundSlider
      accessibleName: "Bound volume"
      value: root.boundVolume
      onReleased: function(v) { root.boundVolume = v; root.boundSliderReleases++ }
    }
    PanelSlider { id: disabledSlider; accessibleName: "Unavailable"; enabled: false; value: 0.5; onMoved: root.disabledSliderMoves++ }
    Toggle { id: disabledToggle; label: "Unavailable"; enabled: false; onClicked: root.disabledToggleEvents++ }
    ToggleSwitch { id: disabledSwitch; accessibleName: "Unavailable"; enabled: false; onToggled: root.disabledToggleEvents++ }
    Dropdown {
      id: disabledDropdown
      y: 40
      label: "Unavailable dropdown"
      enabled: false
      options: ["Disabled dropdown one", "Disabled dropdown two"]
    }
    SearchableDropdown {
      id: disabledSearchable
      y: 40
      label: "Unavailable searchable dropdown"
      enabled: false
      options: ["Disabled searchable one", "Disabled searchable two"]
    }
    MultiSelect {
      id: disabledMulti
      y: 40
      label: "Unavailable multi-select"
      enabled: false
      options: ["Disabled multi-select one", "Disabled multi-select two"]
    }
    CursorSurface {
      id: toggleRow
      accessibleName: "DP-2"
      current: true
      Accessible.checkable: true
      Accessible.checked: true
      Accessible.selected: false
    }
    Dropdown {
      id: dropdown
      y: 80
      label: "Output"
      value: "speakers"
      options: [{ value: "speakers", label: "Speakers" }, { value: "headphones", label: "Headphones" }]
      onChanged: root.dropdownChanges++
    }
    SearchableDropdown {
      id: searchable
      y: 150
      label: "Country"
      value: "alpha"
      options: [{ value: "alpha", label: "Alpha", description: "First" }, { value: "beta", label: "Beta", description: "Second" }]
      onChanged: root.searchableChanges++
    }
    MultiSelect {
      id: multi
      y: 220
      label: "Tags"
      options: [{ value: "one", label: "One", description: "First tag" }, { value: "two", label: "Two", description: "Second tag" }]
      onChanged: root.multiChanges++
    }
    PanelActionButton { id: actionButton; iconText: "\u{F0156}"; tooltipText: "Unpair"; onClicked: root.actionClicks++ }

    CursorSurface { id: unnamedRow }
    CursorSurface {
      id: namedRow
      accessibleName: "Home"
      current: true
      Accessible.onPressAction: root.rowPresses++
    }

    Item { id: panelAnchor; width: 40; height: 40 }

    ConfirmDialog {
      anchors.fill: parent
      opened: true
      message: "Delete this item?"
      confirmText: "Delete"
      onCanceled: root.dialogCancels++
      onConfirmed: root.dialogConfirms++
    }
    }
  }

  KeyboardPanel {
    id: keyboardPanel
    anchorItem: panelAnchor
    bar: testBar
    accessibleName: "Network"
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
