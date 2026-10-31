#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

pass "Stay Awake toggle persists state"

if ! command -v dbus-run-session >/dev/null; then
  skip "screensaver helper honors inhibits on a private bus"
else
  # The two clients share one bus, so the second could release the first's
  # inhibit by cookie, and only the bus dropping the first should release it.
  if ! output=$(timeout 20 dbus-run-session -- python3 - "$ROOT/shell/plugins/services/idle/screensaver.py" 2>&1 <<'PY'
import json, select, subprocess, sys, time
from gi.repository import Gio, GLib

helper = subprocess.Popen(["python3", sys.argv[1]], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)

def apps():
  if not select.select([helper.stdout], [], [], 5)[0]:
    sys.exit("helper published nothing")
  return [i["app"] for i in json.loads(helper.stdout.readline())["inhibitors"]]

def client():
  address = Gio.dbus_address_get_for_bus_sync(Gio.BusType.SESSION, None)
  flags = Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION
  return Gio.DBusConnection.new_for_address_sync(address, flags, None, None)

def call(connection, path, method, args):
  return connection.call_sync("org.freedesktop.ScreenSaver", path, "org.freedesktop.ScreenSaver", method, args, None, 0, 5000, None)

assert apps() == []
player, other = client(), client()
for _ in range(50):
  if player.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner",
                      GLib.Variant("(s)", ("org.freedesktop.ScreenSaver",)), None, 0, -1, None).unpack()[0]:
    break
  time.sleep(0.1)

(cookie,) = call(player, "/org/freedesktop/ScreenSaver", "Inhibit", GLib.Variant("(ss)", ("chromium", "video"))).unpack()
assert apps() == ["chromium"], "Inhibit on the Chromium path"
call(other, "/ScreenSaver", "UnInhibit", GLib.Variant("(u)", (cookie,)))
call(player, "/ScreenSaver", "Inhibit", GLib.Variant("(ss)", ("firefox", "video")))
assert apps() == ["chromium", "firefox"], "another client cannot release an inhibit"
call(player, "/org/freedesktop/ScreenSaver", "UnInhibit", GLib.Variant("(u)", (cookie,)))
assert apps() == ["firefox"], "the owner releases its inhibit"
player.close_sync(None)
assert apps() == [], "a client leaving the bus releases its inhibits"
helper.stdin.close()
helper.wait(5)
PY
  ); then
    fail "screensaver helper honors inhibits on a private bus" "$output"
  fi
  pass "screensaver helper honors inhibits on a private bus"
fi
