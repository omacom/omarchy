#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "bar style test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar style test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons

ShellRoot {
  function expect(raw, wanted, label) {
    Commons.Color.loadShell(raw)
    if (Style.bar.style !== wanted) {
      console.log("RESULT fail " + label + ": got " + Style.bar.style)
      return false
    }
    return true
  }

  function run() {
    if (expect("", "strip", "no [bar] style")
      && expect("[bar]\nstyle = \"islands\"\n", "islands", "quoted islands")
      && expect("[bar]\nstyle = islands # floating\n", "islands", "bare islands with comment")
      && expect("[bar]\nstyle = \"capsules\"\n", "strip", "unknown style")
      && expect("[font]\nstyle = \"islands\"\n", "strip", "style outside [bar]"))
      console.log("RESULT pass")
    Qt.quit()
  }

  // Quit once the engine is running; quitting from onCompleted has no receiver yet.
  Component.onCompleted: Qt.callLater(run)
}
QML

output=$(timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "bar style fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "shell.toml [bar] style selects strip or islands"
fi

pass "shell.toml [bar] style selects strip or islands"
