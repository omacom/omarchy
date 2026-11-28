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
  if ! output=$(timeout 20 dbus-run-session -- /usr/bin/python3 - "$ROOT/shell/plugins/services/idle/screensaver.py" 2>&1 <<'PY'
import json, select, subprocess, sys, time
from gi.repository import Gio, GLib

helper = subprocess.Popen(["/usr/bin/python3", sys.argv[1]], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)

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

def has_owner(connection, name):
  return connection.call_sync(
    "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner",
    GLib.Variant("(s)", (name,)), None, 0, 5000, None,
  ).unpack()[0]

assert apps() == []
player, other = client(), client()
for _ in range(50):
  if has_owner(player, "org.freedesktop.ScreenSaver"):
    break
  time.sleep(0.1)

assert has_owner(player, "org.freedesktop.ScreenSaver"), "ScreenSaver name is owned"
assert not has_owner(player, "org.freedesktop.PowerManagement"), "PowerManagement stays unowned"

(cookie,) = call(player, "/org/freedesktop/ScreenSaver", "Inhibit", GLib.Variant("(ss)", ("chromium", "Video Wake Lock"))).unpack()
assert cookie != 0, "cookie must be nonzero for xdg-desktop-portal-gtk"
assert apps() == ["chromium"], "Inhibit on Chromium path"

# Another client cannot release someone else's inhibit by cookie.
call(other, "/ScreenSaver", "UnInhibit", GLib.Variant("(u)", (cookie,)))
(cookie2,) = call(player, "/ScreenSaver", "Inhibit", GLib.Variant("(ss)", ("firefox", "Playing video"))).unpack()
assert cookie2 != 0 and cookie2 != cookie
assert apps() == ["chromium", "firefox"], "another client cannot release an inhibit"

# Acquiring and releasing a well-known name (like MPRIS) must not drop inhibits.
player.call_sync(
  "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "RequestName",
  GLib.Variant("(su)", ("org.mpris.MediaPlayer2.testplayer", 0)), None, 0, 5000, None,
)
player.call_sync(
  "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "ReleaseName",
  GLib.Variant("(s)", ("org.mpris.MediaPlayer2.testplayer",)), None, 0, 5000, None,
)

# Owner releases its first cookie; second remains active.
call(player, "/org/freedesktop/ScreenSaver", "UnInhibit", GLib.Variant("(u)", (cookie,)))
assert apps() == ["firefox"], "owner releases only its own cookie and MPRIS drop keeps inhibits"

# Client leaving the bus releases remaining inhibits.
player.close_sync(None)
assert apps() == [], "disconnect releases remaining inhibits"

# Closing stdin exits helper promptly.
helper.stdin.close()
assert helper.wait(5) == 0, "helper exits cleanly when stdin closes"

# Broken stdout pipe fails Inhibit and exits instead of holding the name stale.
broken = subprocess.Popen(["/usr/bin/python3", sys.argv[1]], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
assert select.select([broken.stdout], [], [], 5)[0]
assert json.loads(broken.stdout.readline()) == {"inhibitors": []}
watcher = client()
for _ in range(50):
  if has_owner(watcher, "org.freedesktop.ScreenSaver"):
    break
  time.sleep(0.1)
broken.stdout.close()
try:
  call(watcher, "/org/freedesktop/ScreenSaver", "Inhibit", GLib.Variant("(ss)", ("chromium", "Video Wake Lock")))
  sys.exit("Inhibit should fail when helper stdout is closed")
except GLib.Error as err:
  assert "idle service disconnected" in err.message, f"unexpected error: {err.message}"
assert broken.wait(5) == 0, "helper exits cleanly on broken stdout pipe"
broken.stdin.close()
watcher.close_sync(None)
PY
  ); then
    fail "screensaver helper honors inhibits on a private bus" "$output"
  fi
  pass "screensaver helper honors inhibits on a private bus"
fi

no_bus_status=0
env -u DBUS_SESSION_BUS_ADDRESS DBUS_SESSION_BUS_ADDRESS="" /usr/bin/python3 "$ROOT/shell/plugins/services/idle/screensaver.py" </dev/null >/dev/null 2>&1 || no_bus_status=$?
(( no_bus_status == 78 )) || fail "screensaver helper exits 78 without a session bus" "got $no_bus_status"
pass "screensaver helper exits 78 without a session bus"
