#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

require_command dbus-run-session
require_command gdbus
require_command jq

state_file="$test_tmp/idle-inhibit/state"
runtime_dir="$test_tmp/runtime"
mkdir -p "$runtime_dir/omarchy/idle-inhibit" "$(dirname "$state_file")"

run_debug_idle() {
  XDG_RUNTIME_DIR="$runtime_dir" "$ROOT/bin/omarchy-debug-idle" 2>/dev/null \
    | sed -n '/^== D-Bus idle inhibitors ==$/,/^== .* ==$/p'
}

output="$(run_debug_idle)"
[[ $output == *"none"* ]] || fail "missing state file reports none" "$output"
pass "missing state file reports none"

printf '%s' '{"count":0,"holders":[]}' > "$runtime_dir/omarchy/idle-inhibit/state"
output="$(run_debug_idle)"
[[ $output == *"none"* ]] || fail "empty inhibitor list reports none" "$output"
pass "empty inhibitor list reports none"

printf '%s' '{"count":2,"holders":[{"app":"Chromium","reason":"Playing video","cookie":1},{"app":"VLC","reason":"Playing audio","cookie":2}]}' > "$runtime_dir/omarchy/idle-inhibit/state"
output="$(run_debug_idle)"
[[ $output == *"active count: 2"* ]] || fail "active count is shown" "$output"
[[ $output == *"Chromium: Playing video (cookie 1)"* ]] || fail "first inhibitor is rendered" "$output"
[[ $output == *"VLC: Playing audio (cookie 2)"* ]] || fail "second inhibitor is rendered" "$output"
pass "active inhibitors are rendered with app, reason, and cookie"

python3 -c "import ast; ast.parse(open('$ROOT/bin/omarchy-idle-inhibit').read())" \
  || fail "idle-inhibit daemon is valid python"
grep -q "omarchy:summary=" "$ROOT/bin/omarchy-idle-inhibit" \
  || fail "idle-inhibit daemon declares a summary"
grep -q "omarchy:hidden=true" "$ROOT/bin/omarchy-idle-inhibit" \
  || fail "idle-inhibit daemon is hidden from listings"
pass "idle-inhibit daemon is valid and declares its metadata"

probe_empty="$("$ROOT/bin/omarchy-idle-inhibit-probe" "$test_tmp/missing-state")"
[[ $probe_empty == "" ]] || fail "probe is silent for a missing file" "$probe_empty"
pass "probe is silent for a missing file"

dead_pid=$(bash -c 'echo $$')
printf '%s' "{\"pid\":$dead_pid,\"count\":3}" > "$test_tmp/dead-pid-state"
probe_dead="$("$ROOT/bin/omarchy-idle-inhibit-probe" "$test_tmp/dead-pid-state")"
[[ $probe_dead == "" ]] || fail "probe is silent for a dead pid" "$probe_dead"
pass "probe is silent for a dead pid"

cat >"$test_tmp/hold.py" <<'PY'
import sys, time
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

path = sys.argv[1]
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
proxy = Gio.DBusProxy.new_sync(
  bus, Gio.DBusProxyFlags.NONE, None,
  "org.freedesktop.ScreenSaver", path, "org.freedesktop.ScreenSaver", None,
)
cookie = proxy.call_sync("Inhibit", GLib.Variant("(ss)", ("hold-client", "PR test")), Gio.DBusCallFlags.NONE, -1, None)
print(int(cookie.unpack()[0]), flush=True)
time.sleep(30)
PY

cat >"$test_tmp/crash.py" <<'PY'
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
proxy = Gio.DBusProxy.new_sync(
  bus, Gio.DBusProxyFlags.NONE, None,
  "org.freedesktop.ScreenSaver", "/org/freedesktop/ScreenSaver",
  "org.freedesktop.ScreenSaver", None,
)
cookie = proxy.call_sync("Inhibit", GLib.Variant("(ss)", ("brief-app", "momentary")), Gio.DBusCallFlags.NONE, -1, None)
print(int(cookie.unpack()[0]), flush=True)
PY

daemon_log="$test_tmp/daemon.log"

scenario() {
  local script="$1"
  dbus-run-session -- bash -c "
    trap 'kill -9 \$(jobs -p) 2>/dev/null || true; wait 2>/dev/null || true' EXIT
    python3 '$ROOT/bin/omarchy-idle-inhibit' --state-file '$state_file' >>'$daemon_log' 2>&1 &
    for _ in \$(seq 1 30); do
      gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
        --method org.freedesktop.DBus.NameHasOwner org.freedesktop.ScreenSaver 2>/dev/null | grep -q true && break
      sleep 0.1
    done
    $script
    sleep 0.4
    cat '$state_file'
  " 2>/dev/null | tail -1 | jq -r '.count // 0'
}

[[ $(scenario "true") == "0" ]] || fail "daemon starts with zero inhibitors"
pass "daemon starts with zero inhibitors"

chromium_hold=$(scenario "
  python3 '$test_tmp/hold.py' /org/freedesktop/ScreenSaver >'$test_tmp/cookie.txt' 2>&1 &
  sleep 0.8
")
[[ $(cat "$test_tmp/cookie.txt") == "1" ]] || fail "Chromium-path Inhibit returns a cookie" "cookie=$(cat "$test_tmp/cookie.txt")"
[[ $chromium_hold == "1" ]] || fail "daemon persists a Chromium-path inhibitor" "count=$chromium_hold"
pass "Chromium-path Inhibit persists while the caller holds the bus"

legacy_hold=$(scenario "
  python3 '$test_tmp/hold.py' /ScreenSaver >'$test_tmp/cookie.txt' 2>&1 &
  sleep 0.8
")
[[ $legacy_hold == "1" ]] || fail "daemon persists a /ScreenSaver inhibitor" "count=$legacy_hold"
pass "/ScreenSaver Inhibit persists while the caller holds the bus"

pm_owner=$(dbus-run-session -- bash -c "
  trap 'kill -9 \$(jobs -p) 2>/dev/null || true; wait 2>/dev/null || true' EXIT
  python3 '$ROOT/bin/omarchy-idle-inhibit' --state-file '$state_file' >>'$daemon_log' 2>&1 &
  for _ in \$(seq 1 30); do
    gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
      --method org.freedesktop.DBus.NameHasOwner org.freedesktop.ScreenSaver 2>/dev/null | grep -q true && break
    sleep 0.1
  done
  gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
    --method org.freedesktop.DBus.NameHasOwner org.freedesktop.PowerManagement
")
[[ $pm_owner == *false* ]] || fail "PowerManagement name stays unowned so audio/downloads cannot pin idle" "$pm_owner"
pass "PowerManagement name stays unowned so audio/downloads cannot pin idle"

cleared=$(scenario "
  python3 '$test_tmp/hold.py' /org/freedesktop/ScreenSaver >'$test_tmp/cookie.txt' 2>&1 &
  sleep 0.8
  gdbus call --session --dest org.freedesktop.ScreenSaver --object-path /org/freedesktop/ScreenSaver \
    --method org.freedesktop.ScreenSaver.UnInhibit \$(cat '$test_tmp/cookie.txt') >/dev/null
  sleep 0.4
")
[[ $cleared == "0" ]] || fail "UnInhibit on Chromium path clears the inhibitor" "count=$cleared"
pass "UnInhibit on Chromium path clears the inhibitor"

crashed=$(scenario "
  python3 '$test_tmp/crash.py' >'$test_tmp/cookie.txt' 2>&1 &
  echo \$! >'$test_tmp/crash.pid'
  sleep 0.8
  kill -9 \$(cat '$test_tmp/crash.pid') 2>/dev/null
  sleep 0.8
")
[[ $crashed == "0" ]] || fail "disconnecting caller releases its inhibitor" "count=$crashed state=$(cat "$test_tmp/idle-inhibit/state" 2>/dev/null || true)"
pass "disconnecting caller releases its inhibitor"

cat >"$test_tmp/release-name.py" <<'PY'
import time
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
proxy = Gio.DBusProxy.new_sync(
  bus, Gio.DBusProxyFlags.NONE, None,
  "org.freedesktop.ScreenSaver", "/org/freedesktop/ScreenSaver",
  "org.freedesktop.ScreenSaver", None,
)
proxy.call_sync("Inhibit", GLib.Variant("(ss)", ("player", "Playing video")), Gio.DBusCallFlags.NONE, -1, None)
names = Gio.DBusProxy.new_sync(
  bus, Gio.DBusProxyFlags.NONE, None,
  "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", None,
)
names.call_sync("RequestName", GLib.Variant("(su)", ("org.mpris.MediaPlayer2.omarchytest", 0)), Gio.DBusCallFlags.NONE, -1, None)
names.call_sync("ReleaseName", GLib.Variant("(s)", ("org.mpris.MediaPlayer2.omarchytest",)), Gio.DBusCallFlags.NONE, -1, None)
time.sleep(30)
PY

released_name=$(scenario "
  python3 '$test_tmp/release-name.py' >/dev/null 2>&1 &
  sleep 0.8
")
[[ $released_name == "1" ]] || fail "a caller dropping a well-known name keeps its inhibitor" "count=$released_name"
pass "a caller dropping a well-known name keeps its inhibitor"

rg -F 'dbusInhibitorCount === 0' "$ROOT/shell/plugins/services/idle/Service.qml" >/dev/null \
  || fail "idleEnabled folds D-Bus inhibitors"
rg -F 'omarchy-idle-inhibit-probe' "$ROOT/shell/plugins/services/idle/Service.qml" >/dev/null \
  || fail "idle service probes the inhibit state file"
rg -F 'mkdir -p \"$XDG_RUNTIME_DIR/omarchy/idle-inhibit\"' "$ROOT/shell/plugins/services/idle/Service.qml" >/dev/null \
  || fail "idle service creates the inhibit state directory before watching it"
rg -F 'inhibitorStateDirWatcher.reload' "$ROOT/shell/plugins/services/idle/Service.qml" >/dev/null \
  || fail "idle service reloads the inhibit watcher after mkdir"
rg -F 'setIdleEnabled(root.stayAwake)' "$ROOT/shell/plugins/services/idle/Service.qml" >/dev/null \
  || fail "idle toggle derives from stayAwake"
pass "idle service wires D-Bus inhibitors into idleEnabled"

if awk '/enable --now \\/,/omarchy-crash-watch.service/' "$ROOT/install/user/first-run/enable-user-units.sh" | grep -q omarchy-idle-inhibit.service; then
  fail "idle-inhibit is not in the batch enable --now list"
fi
grep -q 'enable --now omarchy-idle-inhibit.service' "$ROOT/install/user/first-run/enable-user-units.sh" \
  || fail "idle-inhibit is enabled on its own after the batch"
pass "first-run enables idle-inhibit separately so a missing unit cannot fail sleep-lock"
