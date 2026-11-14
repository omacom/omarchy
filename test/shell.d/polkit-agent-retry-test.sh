#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Quickshell gives one polkit listener to the first agent of a shell and none
# to an agent created while it is held, and registers an agent only once, when
# it is created. Enabling a clone of omarchy.polkit live creates the clone's
# agent before the built-in one is destroyed, so the clone's agent has to try
# again once the listener is free, and again after each attempt that fails.
require_compositor "polkit agent retry runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping polkit agent retry runtime test"
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
ln -s "$ROOT/shell/plugins/polkit" "$TMPDIR/polkit"

cat >"$TMPDIR/shell.qml" <<'QML'
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

ShellRoot {
  id: root

  property var holder: null
  property var agent: null

  Component {
    id: holderComponent
    PolkitAgent { path: "/org/omarchy/PolkitAgentHolder" }
  }

  Component.onCompleted: {
    holder = holderComponent.createObject(root)
    var component = Qt.createComponent(Quickshell.shellPath("polkit/PolkitAgent.qml"), Component.PreferSynchronous)
    agent = component.createObject(root, { registerRetryInterval: 100 })
    if (!agent) {
      console.log("RESULT fail " + component.errorString())
      Qt.quit()
      return
    }
    Qt.callLater(function() {
      holder.destroy()
      console.log("RESULT holder-released")
    })
  }

  Timer {
    interval: 2500
    running: true
    onTriggered: {
      console.log("RESULT done")
      Qt.quit()
    }
  }
}
QML

output=$(timeout 15 quickshell -p "$TMPDIR" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "polkit agent retry runtime fixture exits cleanly"
}

if ! grep -q "RESULT done" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "polkit agent retry runtime fixture runs to the end"
fi

# Without a session or polkitd each attempt fails, and Quickshell names the
# path it tried; with them the first one registers. Retrying from 100 ms, an
# agent that gets the listener on every retry has tried at least three times by
# the end.
after_release=$(sed -n '/RESULT holder-released/,$p' <<<"$output")
attempts=$(grep -c 'failed to register listener on path "/org/omarchy/PolkitAgent"' <<<"$after_release" || true)
if ! grep -q 'omarchy polkit agent registered' <<<"$after_release" && (( attempts < 3 )); then
  printf '%s\n' "$output" >&2
  fail "polkit agent tries to register again once another agent frees the listener (attempts: $attempts)"
fi

pass "polkit agent tries to register again once another agent frees the listener"
