#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -q 'hideOpenPanels' "$ROOT/bin/omarchy-launch-screensaver" ||
  fail "screensaver launch dismisses open panels"
pass "screensaver launch dismisses open panels"

grep -q 'focus_grace_until' "$ROOT/bin/omarchy-screensaver" ||
  fail "screensaver grants a focus grace period before self-dismiss"
pass "screensaver grants a focus grace period before self-dismiss"

grep -q 'hideOpenBarWidgets' "$ROOT/shell/plugins/bar/Bar.qml" ||
  fail "bar can close every open widget panel"
pass "bar can close every open widget panel"

grep -q 'function hideOpenPanels' "$ROOT/shell/shell.qml" ||
  fail "shell exposes hideOpenPanels"
pass "shell exposes hideOpenPanels"

grep -q 'function hideOpenPanels(): void' "$ROOT/shell/shell.qml" ||
  fail "shell IPC exposes hideOpenPanels"
pass "shell IPC exposes hideOpenPanels"
