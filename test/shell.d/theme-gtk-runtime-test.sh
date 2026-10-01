#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command gtk4-broadwayd
require_command dbus-run-session

# A private display and bus exercise GTK itself without touching the desktop.
dbus-run-session -- /usr/bin/python "$SHELL_TEST_DIR/fixtures/gtk-theme-runtime.py"
pass "Nautilus reloads valid CSS through D-Bus and filesystem events"
pass "Nautilus retains valid CSS on parse errors and defers full clearing until restart"
