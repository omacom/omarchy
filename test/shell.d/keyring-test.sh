#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command /usr/bin/python3
require_command dbus-run-session
/usr/bin/python3 -c 'from gi.repository import Gio, GLib' || fail "python-gobject is available"

# This test must never connect to the developer's Secret Service or collections.
dbus-run-session -- /usr/bin/python3 "$ROOT/test/shell.d/keyring-test.py" || fail "keyring enrollment and PAM regressions"
pass "keyring enrollment and PAM regressions"
