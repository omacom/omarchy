#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -qx 'singleton SystemSleep 1.0 SystemSleep.qml' "$ROOT/shell/Commons/qmldir" ||
  fail "qs.Commons registers the SystemSleep singleton"
pass "qs.Commons registers the SystemSleep singleton"

require_compositor "system sleep watcher test"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping system sleep watcher test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/config" "$test_tmp/bin"
ln -s "$ROOT/shell/Commons" "$test_tmp/config/Commons"

cat >"$test_tmp/bin/dbus-monitor" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB_DIR/args"
if [[ ! -e $STUB_DIR/started ]]; then
  touch "$STUB_DIR/started"
  printf '%s\n' \
    'signal time=1.0 sender=org.freedesktop.DBus -> destination=:1.9 serial=2 path=/org/freedesktop/DBus; interface=org.freedesktop.DBus; member=NameAcquired' \
    '   string ":1.9"' \
    'signal time=2.0 sender=:1.3 -> destination=(null destination) serial=10 path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep' \
    '   boolean true' \
    'signal time=3.0 sender=:1.3 -> destination=(null destination) serial=11 path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep' \
    '   boolean false'
  exit 0
fi
printf '%s\n' \
  'signal time=4.0 sender=:1.3 -> destination=(null destination) serial=12 path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep' \
  '   boolean false'
exec sleep 30
SH
chmod +x "$test_tmp/bin/dbus-monitor"

cat >"$test_tmp/config/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons

ShellRoot {
  id: root

  property int wakes: 0

  Connections {
    target: SystemSleep
    function onResumed() { root.wakes += 1 }
  }

  Timer {
    interval: 3500
    running: true
    onTriggered: {
      console.log("RESULT wakes " + root.wakes)
      Qt.quit()
    }
  }
}
QML

output=$(timeout 15 env \
  PATH="$test_tmp/bin:$PATH" \
  STUB_DIR="$test_tmp" \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp/config" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "system sleep fixture exits cleanly"
}

args=$(head -n1 "$test_tmp/args" 2>/dev/null || true)
[[ $args == "--system type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" ]] ||
  fail "system sleep watcher listens for logind's PrepareForSleep on the system bus" "args: $args"
pass "system sleep watcher listens for logind's PrepareForSleep on the system bus"

(( $(wc -l <"$test_tmp/args") == 2 )) ||
  fail "system sleep watcher comes back after it dies" "$(cat "$test_tmp/args")"
pass "system sleep watcher comes back after it dies"

grep -qx '.*RESULT wakes 2' <<<"$output" || {
  printf '%s\n' "$output" >&2
  fail "system sleep watcher announces each wake, and only wakes"
}
pass "system sleep watcher announces each wake, and only wakes"
