#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Bar buttons carry Qt Accessible roles, names and a press action so screen
# readers and AT-SPI clients can find and operate them.

require_command python3

# Every bar icon button must be named by its tooltip or an accessibleName;
# its text is an icon glyph and never names it.
naming_lint=$(cat <<'PY'
import pathlib
import re
import sys


def unnamed(value):
  literal = value[1:-1] if value[:1] in "\"'" and value[-1:] == value[:1] else None
  if literal is None:
    return False
  text = literal.encode().decode("unicode_escape") if "\\u" in literal else literal
  return all(0xE000 <= ord(c) <= 0xF8FF or ord(c) >= 0xF0000 for c in text)


names = {
  "BarIconButton": ("accessibleName", "tooltipText"),
  "BarIndicator": ("accessibleName", "tooltipText", "activeTooltipText"),
}
failures = []
for path in sorted(pathlib.Path(sys.argv[1]).rglob("*.qml")):
  lines = path.read_text().splitlines()
  for start, line in enumerate(lines):
    match = re.match(r"^(\s*)(BarIconButton|BarIndicator)\s*\{\s*$", line)
    if not match:
      continue
    properties = {}
    for body in lines[start + 1:]:
      if body.startswith(match.group(1) + "}"):
        break
      prop = re.match(re.escape(match.group(1)) + r"  (\w+):\s*(.+?)\s*$", body)
      if prop:
        properties[prop.group(1)] = prop.group(2)
    if all(unnamed(properties[name]) for name in names[match.group(2)] if name in properties) \
        or not any(name in properties for name in names[match.group(2)]):
      failures.append(f"{path.relative_to(sys.argv[1])}:{start + 1} {match.group(2)}")

if failures:
  print("Unnamed bar buttons:\n" + "\n".join(f"  {failure}" for failure in failures), file=sys.stderr)
  raise SystemExit(1)
PY
)

python3 -c "$naming_lint" "$ROOT/shell/plugins"
pass "bar icon buttons provide accessible names"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar accessibility runtime test"
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
import qs.Ui

ShellRoot {
  id: root

  readonly property string glyph: String.fromCodePoint(0xe900)
  property var failures: []
  property var presses: []

  function same(actual, expected, message) {
    if (actual !== expected) failures.push(message + " expected=" + JSON.stringify(expected) + " actual=" + JSON.stringify(actual))
  }

  Item {
    WidgetButton {
      id: widget
      text: "Tuesday 14:32"
      tooltipText: "Calendar"
      onPressed: function(button) { root.presses.push("widget:" + button) }
    }
    WidgetButton { id: textWidget; text: "Tuesday 14:32" }
    WidgetButton { id: staticWidget; text: "3"; pressable: false }
    WidgetButton { id: concealedWidget; text: "x"; concealed: true }
    WidgetButton { id: disabledWidget; text: "x"; enabled: false; onPressed: root.presses.push("disabled") }
    WidgetButton { id: inertWidget; text: "x"; interactive: false; onPressed: root.presses.push("inert") }
    BarIconButton { id: glyphIcon; text: root.glyph }
    BarIconButton {
      id: namedIcon
      text: root.glyph
      accessibleName: "Network"
      tooltipText: "Limited internet access"
      onPressed: function(button) { root.presses.push("icon:" + button) }
    }
  }

  Component.onCompleted: Qt.callLater(runChecks)

  function runChecks() {
    same(widget.Accessible.role, Accessible.Button, "pressable WidgetButton is a button")
    same(widget.Accessible.name, "Calendar", "WidgetButton prefers its tooltip")
    same(textWidget.Accessible.name, "Tuesday 14:32", "WidgetButton falls back to its text")
    same(staticWidget.Accessible.role, Accessible.StaticText, "non-pressable WidgetButton reads as text")
    same(concealedWidget.Accessible.ignored, true, "concealed WidgetButton is hidden")
    same(glyphIcon.Accessible.name, "", "BarIconButton never announces its glyph")
    same(namedIcon.Accessible.name, "Network", "BarIconButton takes accessibleName")
    same(namedIcon.Accessible.description, "Limited internet access", "a tooltip that differs from the name describes the button")

    widget.Accessible.pressAction()
    namedIcon.Accessible.pressAction()
    disabledWidget.Accessible.pressAction()
    inertWidget.Accessible.pressAction()
    same(presses.join(","), "widget:" + Qt.LeftButton + ",icon:" + Qt.LeftButton, "press is a left click, only on enabled interactive buttons")

    console.log(failures.length === 0 ? "RESULT pass" : "RESULT fail " + failures.join("; "))
    Qt.quit()
  }
}
QML

# No window is created, so this runs offscreen, without a compositor.
output=$(QT_QPA_PLATFORM=offscreen timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) ||
  fail "bar accessibility fixture exits cleanly" "$output"

grep -q "RESULT pass" <<<"$output" ||
  fail "bar buttons expose accessible roles, names and a press action" "$output"
pass "bar buttons expose accessible roles, names and a press action"
