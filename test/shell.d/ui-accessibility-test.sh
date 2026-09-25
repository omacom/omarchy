#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The shared shell/Ui kit carries Qt Accessible roles, names, states and
# actions so screen readers and AT-SPI tools can find and press controls.
# Static checks run everywhere; the runtime half reads the attached
# properties from a live Quickshell instance.

run_node_test <<'JS'
const fs = require('fs')

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) return walk(full)
    return entry.name.endsWith('.qml') ? [full] : []
  })
}

// A string literal made only of icon-font code points (Private Use Area,
// surrogate halves, or \u escapes of either) reads as noise, not a name.
function isGlyphLiteral(value) {
  const match = /^"((?:[^"\\]|\\.)*)"$/.exec(value.trim())
  if (!match) return false
  const decoded = match[1].replace(/\\u\{([0-9a-fA-F]+)\}|\\u([0-9a-fA-F]{4})/g,
    (_, braced, plain) => String.fromCodePoint(parseInt(braced || plain, 16)))
  const chars = Array.from(decoded).filter(ch => ch.trim() !== '')
  return chars.length > 0 && chars.every(ch => {
    const cp = ch.codePointAt(0)
    return (cp >= 0xe000 && cp <= 0xf8ff) || cp >= 0xf0000 || (cp >= 0xd800 && cp <= 0xdfff)
  })
}

// Properties that give each control an accessible name. Text only counts
// where the component announces it, and never when it is a bare glyph.
const namingProperties = {
  BarIconButton: ['accessibleName', 'tooltipText'],
  BarIndicator: ['accessibleName', 'tooltipText', 'activeTooltipText'],
  WidgetButton: ['accessibleName', 'tooltipText', 'text'],
  Button: ['accessibleName', 'text', 'tooltipText'],
  PanelActionButton: ['accessibleName', 'tooltipText'],
  ToggleSwitch: ['accessibleName'],
  PanelSlider: ['accessibleName'],
}
const opener = new RegExp('^(\\s*)(' + Object.keys(namingProperties).join('|') + ')\\s*\\{(.*)$')

function directProperties(lines, start, indent, inline) {
  const props = {}
  const record = text => {
    const match = /^\s*([A-Za-z_][\w.]*)\s*:\s*(.*?)\s*;?\s*$/.exec(text)
    if (match) props[match[1]] = match[2]
  }
  if (inline.includes('}')) {
    inline.slice(0, inline.lastIndexOf('}')).split(';').forEach(record)
    return props
  }
  for (let i = start + 1; i < lines.length; i++) {
    const line = lines[i]
    const lineIndent = line.length - line.trimStart().length
    if (line.trim() === '}' && lineIndent === indent) break
    if (lineIndent === indent + 2) record(line)
  }
  return props
}

const unnamed = []
for (const file of walk(path.join(root, 'shell/plugins'))) {
  const lines = fs.readFileSync(file, 'utf8').split('\n')
  lines.forEach((line, index) => {
    const match = opener.exec(line)
    if (!match) return
    const component = match[2]
    const props = directProperties(lines, index, match[1].length, match[3])
    const named = namingProperties[component].some(name =>
      props[name] !== undefined && props[name] !== '""' && !isGlyphLiteral(props[name]))
    if (!named) unnamed.push(`${path.relative(root, file)}:${index + 1} ${component}`)
  })
}

assert(unnamed.length === 0,
  'every first-party icon-only control has an accessible name' +
  (unnamed.length ? '\n  unnamed: ' + unnamed.join('\n  unnamed: ') : ''))

assert(isGlyphLiteral('"\\uf053"') && isGlyphLiteral('"\\u{F0450}"') && !isGlyphLiteral('"Wi-Fi"'),
  'glyph detection separates icon code points from words')

// Accessibility actions must reuse the path a click takes, so there is no
// second code path to drift.
const kit = name => fs.readFileSync(path.join(root, 'shell/Ui', name), 'utf8')
const wiring = [
  ['Button.qml', 'press', /Accessible\.onPressAction:\s*if \(root\.enabled\) root\.clicked\(\)/],
  ['WidgetButton.qml', 'press', /Accessible\.onPressAction:\s*if \(root\.interactive && root\.pressable\) root\.triggerPress\(Qt\.LeftButton\)/],
  ['Toggle.qml', 'toggle', /Accessible\.onToggleAction:\s*root\.clicked\(\)/],
  ['ToggleSwitch.qml', 'toggle', /Accessible\.onToggleAction:\s*if \(!root\.busy\) root\.toggled\(\)/],
  ['PanelActionButton.qml', 'press', /Accessible\.onPressAction:\s*if \(root\.enabled\) root\.clicked\(\)/],
  ['PanelSlider.qml', 'increase', /Accessible\.onIncreaseAction:\s*root\._stepBy\(root\.step\)/],
  ['PanelSlider.qml', 'decrease', /Accessible\.onDecreaseAction:\s*root\._stepBy\(-root\.step\)/],
  ['Dropdown.qml', 'trigger press', /Accessible\.onPressAction:\s*root\.toggle\(\)/],
  ['Dropdown.qml', 'option press', /Accessible\.onPressAction:\s*\{\s*optionList\.currentIndex = index\s*optionList\.selectCurrent\(\)/],
  ['SearchableDropdown.qml', 'option press', /Accessible\.onPressAction:\s*\{\s*resultList\.currentIndex = index\s*resultList\.selectCurrent\(\)/],
  ['MultiSelect.qml', 'option toggle', /Accessible\.onToggleAction:\s*root\.toggleValue\(modelData\.value\)/],
  ['ConfirmDialog.qml', 'button press', /Accessible\.onPressAction:\s*\{\s*if \(index === 0\) root\.canceled\(\)\s*else root\.confirmed\(\)/],
]
for (const [file, action, pattern] of wiring) {
  assert(pattern.test(kit(file)), `${file} ${action} action reuses the click path`)
}
JS

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

    console.log(failures.length === 0 ? "RESULT pass" : "RESULT fail " + failures.join("; "))
    Qt.quit()
  }

  Component.onCompleted: Qt.callLater(runChecks)

  Item {
    Button { id: textButton; text: "Refresh" }
    Button { id: iconButton; iconText: "\u{F0450}"; tooltipText: "Forget network" }
    Button { id: namedIconButton; iconText: "\u{F04AE}"; accessibleName: "Previous track" }
    Button { id: selectedButton; text: "Auto"; selected: true }

    BarIconButton { id: barIcon; text: "\u{F05A9}"; tooltipText: "Wi-Fi: Home" }
    BarIconButton { id: bareBarIcon; text: "\u{F05A9}" }
    WidgetButton { id: widget; text: "14:32"; tooltipText: "Calendar" }
    WidgetButton { id: textWidget; text: "14:32" }
    WidgetButton { id: concealedWidget; text: "\u{F0F54}"; tooltipText: "Do not disturb"; concealed: true }
    WidgetButton { id: staticWidget; text: "CPU 12%"; pressable: false }

    Toggle { id: toggle; label: "Wi-Fi"; checked: true }
    ToggleSwitch { id: bareSwitch; accessibleName: "Tailscale" }

    TextField { id: plainField; placeholderText: "Search" }
    TextField { id: passwordField; password: true; placeholderText: "Passphrase"; accessibleName: "Passphrase for Home" }

    PanelSlider { id: slider; accessibleName: "Volume"; maximum: 1.5 }
    Dropdown { id: dropdown; label: "Output"; options: ["Speakers", "Headphones"] }
    PanelActionButton { id: actionButton; iconText: "\u{F0156}"; tooltipText: "Unpair" }

    CursorSurface { id: unnamedRow }
    CursorSurface { id: namedRow; accessibleName: "Home"; current: true }
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
