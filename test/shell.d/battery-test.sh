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

// omarchy-battery-status names the kernel as its source once UPower's
// energy-full has latched; its percentage then beats the display device's.
const latched = 'percentage\t99%\nstate\tcharging\nrate\t0W\nsize\t52Wh\ntime\t\nsource\tkernel\n'
const sound = 'percentage\t51%\nstate\tdischarging\nrate\t10.8W\nsize\t56Wh\ntime\t2h 37m\n'
assertEqual(battery.kernelPercentage(latched), 99, 'battery takes the kernel percentage past a latch')
assertEqual(battery.kernelPercentage(sound), -1, 'battery leaves UPower the percentage while its figures are sound')
assertEqual(battery.kernelPercentage(''), -1, 'battery leaves UPower the percentage when the script prints nothing')
assertEqual(battery.kernelPercentage('source\tkernel\n'), -1, 'battery leaves UPower the percentage when the kernel gives none')
assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.106 }, 99), 99, 'battery prefers the kernel percentage over a latched UPower one')
assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.106 }, -1), 11, 'battery keeps UPower\'s percentage without a kernel one')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }, 99), -1, 'battery reports a missing battery whatever the kernel says')
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false, 99),
  { level: 99, notify: false, notifiedLowBattery: false },
  'battery does not warn on a latched UPower percentage'
)

// The script runs once at startup, then only when UPower's full charge moves
// by more than a factor of two, or, while latched, as its percentage moves.
assert(battery.shouldRereadKernel(-1, 39.87, 0, 0.45, false), 'battery reads the kernel once at startup')
assert(!battery.shouldRereadKernel(39.8658, 39.8772, 0.4458, 0.4412, false), 'battery ignores a sound pack\'s drifting full charge and percentage')
assert(!battery.shouldRereadKernel(0, 0, 0, 0, false), 'battery waits while UPower has no figures yet')
assert(battery.shouldRereadKernel(0, 54.3, 0, 0.99, false), 'battery reads again once UPower has figures')
assert(battery.shouldRereadKernel(54.3, 484.5, 0.99, 0.106, false), 'battery reads again when energy-full latches')
assert(battery.shouldRereadKernel(484.5, 54.3, 0.106, 0.99, true), 'battery reads again when a latch clears')
assert(battery.shouldRereadKernel(484.5, 484.5, 0.106, 0.1071, true), 'battery follows the charge while a latch holds')
assert(!battery.shouldRereadKernel(484.5, 484.5, 0.106, 0.1065, true), 'battery lets a latched percentage move a tenth of a point first')

// A run that prints nothing while latched (around an AC plug event) keeps the
// kernel percentage and reads again on UPower's next move, rather than settling
// on the latched figure until the shell restarts.
assertDeepEqual(battery.kernelReading('', 99), { level: 99, retry: true }, 'battery keeps the kernel percentage through an empty run')
assert(battery.shouldRereadKernel(-1, 484.5, 0.106, 0.1061, false), 'battery reads again after an empty run')
assertDeepEqual(battery.kernelReading(latched, -1), { level: 99, retry: false }, 'battery settles on a run that answered')
assertDeepEqual(battery.kernelReading(sound, 99), { level: -1, retry: false }, 'battery hands back to UPower once the latch clears')

const reply = profile => JSON.stringify({ type: 's', data: profile })
assertEqual(battery.parseActiveProfile(reply('power-saver')), 'power-saver', 'battery parses the busctl profile reply')
assertEqual(battery.parseActiveProfile(''), '', 'battery reads a missing daemon as no profile')

// Walk the profile through a session on battery: a startup read, then change
// signals, with the lock video gated on power-saver.
let profile = battery.profileAfterRead('', reply('balanced'), 0, 0)
assert(!battery.isPowerSaverOnBattery(true, profile), 'battery keeps the video on balanced')
profile = 'power-saver'
assert(battery.isPowerSaverOnBattery(true, profile), 'battery stops the video when power-saver arrives on battery')
assert(!battery.isPowerSaverOnBattery(false, profile), 'battery ignores power-saver on AC')
profile = 'balanced'
assert(!battery.isPowerSaverOnBattery(true, profile), 'battery resumes the video when power-saver ends')

// A read that sampled balanced before a power-saver signal must not undo it.
const signalsAtStart = 3
profile = 'power-saver'
profile = battery.profileAfterRead(profile, reply('balanced'), signalsAtStart, signalsAtStart + 1)
assertEqual(profile, 'power-saver', 'battery drops a read made stale by a change signal')
assert(battery.isPowerSaverOnBattery(true, profile), 'battery keeps the video stopped after a stale read')
assertEqual(
  battery.profileAfterRead('balanced', reply('power-saver'), signalsAtStart, signalsAtStart),
  'power-saver',
  'battery takes a read no signal overtook'
)
JS
