#!/bin/bash
source "$(dirname "$0")/base-test.sh"

require_compositor "Button hidden width runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping Button hidden width runtime test"
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

# Plugins measure a label by giving a hidden Button the full text and reading
# its implicitWidth, so a hidden Button has to report the same width.
cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

ShellRoot {
  Component.onCompleted: Qt.callLater(function() {
    var pairs = [[shownLabel, hiddenLabel, "label"], [shownIcon, hiddenIcon, "icon and label"]]
    for (var i = 0; i < pairs.length; i++) {
      if (pairs[i][0].implicitWidth !== pairs[i][1].implicitWidth) {
        console.log("RESULT fail " + pairs[i][2] + ": shown " + pairs[i][0].implicitWidth + ", hidden " + pairs[i][1].implicitWidth)
        Qt.quit()
        return
      }
    }
    console.log("RESULT pass")
    Qt.quit()
  })

  Item {
    Button { id: shownLabel; text: "#homelab" }
    Button { id: shownIcon; text: "Refresh"; iconText: "R" }
  }

  Item {
    visible: false
    Button { id: hiddenLabel; text: "#homelab" }
    Button { id: hiddenIcon; text: "Refresh"; iconText: "R" }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "Button hidden width runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "Hidden Button reports the same implicitWidth as a shown one"
fi

pass "Hidden Button reports the same implicitWidth as a shown one"
