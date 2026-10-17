#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const qml = fs.readFileSync(path.join(root, 'shell/Ui/ConfirmDialog.qml'), 'utf8')

// A fixed 88px width with an unbounded label is the overflow bug.
assert(
  !/^\s*width:\s*Style\.space\(88\)\s*$/m.test(qml),
  'confirm buttons do not hardcode a fixed Style.space(88) width'
)

assert(/elide:\s*Text\.ElideRight/.test(qml), 'confirm button labels elide')
JS

require_compositor "ConfirmDialog button geometry runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping ConfirmDialog button geometry runtime test"
  exit 0
fi

TMPDIR=$(mktemp -d)
cleanup() {
  if [[ -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

config_dir="$TMPDIR/confirm-dialog"
mkdir -p "$config_dir" "$TMPDIR/home"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

cat >"$config_dir/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  id: root

  // [host width, cancel, confirm, how the confirm button should size]
  property var cases: [
    [600, "Cancel", "Delete", "minimum"],
    [600, "Cancel", "Delete permanently", "grown"],
    [600, "Abbrechen", "Endgültig löschen", "grown"],
    [600, "Cancel", "Delete every clipboard entry permanently and forever", "capped"],
    [260, "Cancel", "Delete permanently", "capped"]
  ]
  property int current: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  function find(item, test, out) {
    if (test(item)) out.push(item)
    for (var i = 0; i < item.children.length; i++) find(item.children[i], test, out)
    return out
  }

  function check() {
    var c = cases[current]
    var card = find(dialog, function(item) { return item.hasOwnProperty("contentLeftInset") }, [])[0]
    var buttons = find(card, function(item) { return item.hasOwnProperty("modelData") && item.hasOwnProperty("destructive") }, [])

    if (buttons.length !== 2) return fail("expected two buttons, found " + buttons.length)
    buttons[0].parent.forceLayout()

    for (var i = 0; i < buttons.length; i++) {
      var button = buttons[i]
      var label = find(button, function(item) { return item.hasOwnProperty("elide") }, [])[0]
      var name = "'" + button.modelData + "' in a " + c[0] + "px host"
      var left = label.mapToItem(button, 0, 0).x + (label.width - label.paintedWidth) / 2
      var x = button.mapToItem(card, 0, 0).x

      if (left < 0 || left + label.paintedWidth > button.width + 0.5)
        return fail(name + " paints " + label.paintedWidth + "px of text in a " + button.width + "px button")
      if (x < card.contentLeftInset - 0.5 || x + button.width > card.width - card.contentRightInset + 0.5)
        return fail(name + " leaves the card")
    }

    var confirm = buttons[1]
    var confirmLabel = find(confirm, function(item) { return item.hasOwnProperty("elide") }, [])[0]
    var content = card.width - card.contentLeftInset - card.contentRightInset
    var cap = Math.floor((content - Style.space(10)) / 2)
    var size = c[3]
    var name = "'" + c[2] + "' in a " + c[0] + "px host"

    if (size === "minimum" && confirm.width !== Style.space(88))
      return fail(name + " is " + confirm.width + "px wide, expected the " + Style.space(88) + "px minimum")
    if (size === "grown" && (confirm.width <= Style.space(88) || confirmLabel.truncated))
      return fail(name + " is " + confirm.width + "px wide and truncated=" + confirmLabel.truncated + ", expected to grow and show in full")
    if (size === "capped" && (confirm.width !== cap || !confirmLabel.truncated))
      return fail(name + " is " + confirm.width + "px wide and truncated=" + confirmLabel.truncated + ", expected to elide at the " + cap + "px cap")
    if (size !== "capped" && confirmLabel.truncated)
      return fail(name + " elides although it fits")

    current++
    if (current >= cases.length) {
      console.log("RESULT pass")
      Qt.quit()
    } else {
      load()
    }
  }

  function load() {
    var c = cases[current]
    host.width = c[0]
    dialog.cancelText = c[1]
    dialog.confirmText = c[2]
    Qt.callLater(function() { Qt.callLater(check) })
  }

  Component.onCompleted: Qt.callLater(load)

  Item {
    id: host
    width: 600
    height: 400

    ConfirmDialog {
      id: dialog
      anchors.fill: parent
      opened: true
      message: "Clear history?"
    }
  }
}
QML

# Keep the user's and the theme's shell.toml, which can change font sizes, out of the geometry.
output=$(HOME="$TMPDIR/home" XDG_CONFIG_HOME="$TMPDIR/home/.config" XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  timeout 15 quickshell -p "$config_dir" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "ConfirmDialog button geometry runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "ConfirmDialog button labels stay inside their buttons and the card"
fi

pass "ConfirmDialog button labels stay inside their buttons and the card"
