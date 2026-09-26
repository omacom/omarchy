#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')

assertDeepEqual(idle.eventParts({ data: 'a,b,c' }, 2), ['a', 'b', 'c'], 'idle parses raw event data')
assertDeepEqual(
  idle.eventParts({ parse: function(count) { return ['parsed', count] } }, 4),
  ['parsed', 4],
  'idle prefers event parser when available'
)

assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, 'b', true),
  { windows: { a: true, b: true }, count: 2 },
  'idle adds visible screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true, b: true }, 'a', false),
  { windows: { b: true }, count: 1 },
  'idle removes closed screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, '', false),
  { windows: { a: true }, count: 1 },
  'idle leaves screensaver windows unchanged without an address'
)

assertDeepEqual(
  idle.monitorSubscription(false, 150, false, -1),
  { live: false, timeout: -1, recreate: false },
  'idle does not subscribe while shell config is unread, even at the builtin timeout'
)
assertDeepEqual(
  idle.monitorSubscription(false, 2, false, -1),
  { live: false, timeout: -1, recreate: false },
  'idle does not subscribe when a custom timeout arrives before shell config has settled'
)
assertDeepEqual(
  idle.monitorSubscription(true, 2, false, -1),
  { live: true, timeout: 2, recreate: true },
  'idle subscribes at the settled custom timeout'
)
assertDeepEqual(
  idle.monitorSubscription(true, 2, false, 2),
  { live: true, timeout: 2, recreate: true },
  'a settled timeout with no monitor still subscribes'
)
assertDeepEqual(
  idle.monitorSubscription(true, 2, true, 2),
  { live: true, timeout: 2, recreate: false },
  'idle keeps the notification while the settled timeout is unchanged'
)
assertDeepEqual(
  idle.monitorSubscription(true, 5, true, 2),
  { live: true, timeout: 5, recreate: true },
  'a later timeout change recreates the notification instead of updating it'
)
assertDeepEqual(
  idle.monitorSubscription(false, 5, true, 2),
  { live: false, timeout: 2, recreate: true },
  'idle drops the notification when shell config is no longer settled'
)
JS

test_tmp=$(mktemp -d)
test_qs=
cleanup() {
  rm -rf "$test_tmp" ${test_qs:+"$test_qs"}
}
trap cleanup EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

if rg -q 'omarchy-shell' "$ROOT/bin/omarchy-toggle-idle"; then
  fail "Stay Awake toggle avoids reentrant shell IPC"
fi

pass "Stay Awake toggle persists state without reentrant shell IPC"

idle_service="$ROOT/shell/plugins/services/idle/Service.qml"
idle_subscription="$ROOT/shell/plugins/services/idle/IdleSubscription.qml"
shell_qml="$ROOT/shell/shell.qml"

if ! rg -q 'IdleSubscription' "$idle_service"; then
  fail "idle service subscribes through IdleSubscription"
fi
if rg -U -q 'IdleMonitor\s*\{[^}]*enabled:\s*root\.idleEnabled' "$idle_service" "$idle_subscription"; then
  fail "IdleMonitor stays subscribed while stay-awake is on"
fi
if rg -U -q 'IdleMonitor\s*\{[^}]*timeout\s*:' "$idle_subscription"; then
  fail "IdleMonitor timeout is not a live binding"
fi
if ! rg -q 'shellConfigLoaded === true' "$idle_service"; then
  fail "idle waits until the host shell config has loaded"
fi
if ! rg -q 'readonly property bool shellConfigLoaded: defaultsConfigLoaded && userConfigLoaded' "$shell_qml"; then
  fail "shell config is settled only after both files have loaded"
fi
if ! rg -q 'defaultsConfigLoaded = true' "$shell_qml" || ! rg -q 'userConfigLoaded = true' "$shell_qml"; then
  fail "both shell config files mark themselves loaded"
fi

pass "IdleMonitor is not unbound from the compositor by stay-awake"

require_compositor "idle subscription creation order"

if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping idle subscription runtime test"
  exit 0
fi

test_qs=$(mktemp -d)

ln -s "$ROOT/shell/plugins/services/idle" "$test_qs/idle"

cat >"$test_qs/shell.qml" <<'QML'
import QtQuick
import Quickshell
import "idle" as Idle

ShellRoot {
  id: root

  property string phase: "hold"
  property var firstMonitor: null
  property var idleService: null

  Item { id: sceneHost }

  QtObject {
    id: fakeShell
    property bool shellConfigLoaded: false
    property var shellConfig: ({ idle: { screensaver: 150, lock: 300 } })
  }

  Idle.IdleSubscription {
    id: sub
    ready: false
    timeoutSeconds: 150
    respectInhibitors: false
  }

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  Timer {
    id: poll
    interval: 50
    repeat: true
    property int ticks: 0
    onTriggered: root.advance()
  }

  function advance() {
    poll.ticks += 1
    if (poll.ticks > 80) root.fail("timed out in " + root.phase + " idle=" + sub.isIdle + " subscribed=" + sub.subscribed + " timeout=" + sub.subscribedTimeout)

    if (root.phase === "hold") {
      if (sub.subscribed) root.fail("subscribed before the shell config settled")
      if (poll.ticks < 3) return
      sub.timeoutSeconds = 1
      root.phase = "custom-unready"
      poll.ticks = 0
      return
    }

    if (root.phase === "custom-unready") {
      if (sub.subscribed) root.fail("subscribed when the custom timeout arrived before the shell config settled")
      if (poll.ticks < 3) return
      sub.ready = true
      root.phase = "await-subscribe"
      poll.ticks = 0
      return
    }

    if (root.phase === "await-subscribe") {
      if (!sub.subscribed) return
      if (Number(sub.subscribedTimeout) !== 1) root.fail("first subscription timeout was " + sub.subscribedTimeout)
      root.firstMonitor = sub.monitor
      root.phase = "await-idle"
      poll.ticks = 0
      if (sub.isIdle) root.onInitialIdle()
      return
    }

    if (root.phase === "await-idle") {
      if (sub.isIdle) root.onInitialIdle()
      return
    }

    if (root.phase === "await-recreate") {
      if (!sub.subscribed || Number(sub.subscribedTimeout) !== 2) return
      if (sub.monitor !== root.firstMonitor) root.fail("timeout change replaced the IdleMonitor")
      root.phase = "await-recreate-idle"
      poll.ticks = 0
      if (sub.isIdle) root.startServiceGate()
      return
    }

    if (root.phase === "await-recreate-idle") {
      if (sub.isIdle) root.startServiceGate()
      return
    }

    if (root.phase === "service-unready" || root.phase === "service-custom" || root.phase === "service-ready") {
      var status = JSON.parse(root.idleService.statusJson())
      var monitor = status.monitor
      if (root.phase === "service-unready") {
        if (monitor.subscribed) root.fail("service subscribed before shellConfigLoaded")
        if (poll.ticks < 3) return
        fakeShell.shellConfig = ({ idle: { screensaver: 90, lock: 120 } })
        root.phase = "service-custom"
        poll.ticks = 0
        return
      }
      if (root.phase === "service-custom") {
        if (monitor.subscribed) root.fail("service subscribed when the custom timeout arrived before shellConfigLoaded")
        if (Number(status.screensaver) !== 90) return
        if (poll.ticks < 3) return
        fakeShell.shellConfigLoaded = true
        root.phase = "service-ready"
        poll.ticks = 0
        return
      }
      if (monitor.subscribed && Number(monitor.timeout) === 90 && Number(status.screensaver) === 90) {
        console.log("RESULT pass")
        Qt.quit()
      }
    }
  }

  function onInitialIdle() {
    if (root.phase !== "await-idle") return
    root.phase = "await-recreate"
    poll.ticks = 0
    sub.timeoutSeconds = 2
  }

  function startServiceGate() {
    if (root.phase !== "await-recreate-idle") return
    sub.ready = false
    root.phase = "service-unready"
    poll.ticks = 0
    var component = Qt.createComponent("idle/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) root.fail("idle service failed to load: " + component.errorString())
    // Production creates the service, then assigns shell. shell.json is still unread.
    root.idleService = component.createObject(sceneHost)
    if (!root.idleService) root.fail("idle service did not construct")
    root.idleService.shell = fakeShell
  }

  Component.onCompleted: poll.start()
}
QML

mkdir -p "$test_qs/home"
output=$(HOME="$test_qs/home" timeout 20 quickshell -p "$test_qs" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "idle subscription runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "idle subscribes at the settled timeout and still receives idled after a timeout change"
fi

pass "idle subscribes at the settled timeout and still receives idled after a timeout change"
