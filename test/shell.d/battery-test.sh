#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const discharging = 1

assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.126 }), 13, 'battery rounds display percentage')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }), -1, 'battery reports missing battery')
assert(battery.isDischarging({ isPresent: true, state: discharging }, true, discharging), 'battery detects discharging state')
assert(!battery.isDischarging({ isPresent: true, state: discharging }, false, discharging), 'battery requires on-battery state')

assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery warns once under threshold'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: 8, notify: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, true),
  { level: 40, notify: false, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)

const reply = profile => JSON.stringify({ type: 's', data: profile })
assertEqual(battery.parseActiveProfile(reply('power-saver')), 'power-saver', 'battery parses the busctl profile reply')
assertEqual(battery.parseActiveProfile(''), '', 'battery reads a missing daemon as no profile')

assertEqual(battery.profileAfterRead('', reply('balanced'), 0, 0), 'balanced', 'battery takes its startup read')

// A read that sampled balanced before a power-saver signal must not undo it.
const signalsAtStart = 3
assertEqual(
  battery.profileAfterRead('power-saver', reply('balanced'), signalsAtStart, signalsAtStart + 1),
  'power-saver',
  'battery drops a read made stale by a change signal'
)
assertEqual(
  battery.profileAfterRead('balanced', reply('power-saver'), signalsAtStart, signalsAtStart),
  'power-saver',
  'battery takes a read no signal overtook'
)
assertDeepEqual(
  battery.gateStartupWarning({ level: 8, notify: true, notifiedLowBattery: true }, false, false),
  { level: 8, notify: false, notifiedLowBattery: false },
  'battery suppresses and does not record a stale low sample while startup checks are gated'
)
assertDeepEqual(
  battery.gateStartupWarning({ level: 8, notify: false, notifiedLowBattery: false }, true, false),
  { level: 8, notify: false, notifiedLowBattery: false },
  'battery clears notified state on AC while startup checks are gated'
)
assertDeepEqual(
  battery.gateStartupWarning({ level: 8, notify: false, notifiedLowBattery: true }, true, false),
  { level: 8, notify: false, notifiedLowBattery: true },
  'battery preserves notified state while a gated low condition remains'
)
assertDeepEqual(
  battery.gateStartupWarning({ level: 8, notify: true, notifiedLowBattery: true }, false, true),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery applies the normal warning decision after startup checks are ready'
)
JS

require_compositor "battery startup gate runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping battery startup gate runtime test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/plugins/services/battery/BatteryStartupGate.qml" "$test_tmp/BatteryStartupGate.qml"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell

ShellRoot {
  id: root

  property double readyAt: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  BatteryStartupGate {
    id: gate
    deviceReady: false
    interval: 100

    onChecksReadyChanged: {
      if (!checksReady) return
      if (!deviceReady) {
        root.fail("gate settled before device readiness")
        return
      }
      if (Date.now() - root.readyAt < 80) {
        root.fail("gate settled before its post-readiness interval")
        return
      }
      console.log("RESULT pass")
      Qt.quit()
    }
  }

  Timer {
    interval: 50
    running: true
    onTriggered: {
      if (gate.checksReady) {
        root.fail("gate ran while the device was not ready")
        return
      }
      root.readyAt = Date.now()
      gate.deviceReady = true
      earlyProbe.start()
    }
  }

  Timer {
    id: earlyProbe
    interval: 50
    onTriggered: if (gate.checksReady) root.fail("gate skipped its post-readiness interval")
  }

  Timer {
    interval: 1000
    running: true
    onTriggered: root.fail("gate never settled")
  }
}
QML

output=$(timeout 15 quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "battery startup gate runtime fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "battery startup gate waits for readiness and its settle interval"
fi

pass "battery startup gate waits for readiness and its settle interval"
