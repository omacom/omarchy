#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/power/Panel.qml', 'utf8')

assertEqual(power.parseChargeLimit('80'), 80, 'charge limit parses a plain integer')
assertEqual(power.parseChargeLimit('90\n'), 90, 'charge limit trims trailing newline')
assertEqual(power.parseChargeLimit(''), null, 'charge limit rejects empty output')
assertEqual(power.parseChargeLimit('abc'), null, 'charge limit rejects non-numeric output')
assertEqual(power.parseChargeLimit('150'), null, 'charge limit rejects values above 100')
assertEqual(power.parseChargeLimit('-5'), null, 'charge limit rejects negative values')
for (const invalid of ['80junk', '80.5', '08', 'mixed', 'NaN']) {
  assertEqual(power.parseChargeLimit(invalid), null, 'charge limit rejects ' + invalid)
}
assertEqual(power.parseChargeLimit('100'), 100, 'charge limit accepts full charge')

assert(/command: \["omarchy-battery-limit-get"\]/.test(panelSource), 'charge limit reads via omarchy-battery-limit-get')
assert(/command = \["omarchy-battery-limit-set", String\(value\)\]/.test(panelSource), 'charge limit sets via omarchy-battery-limit-set')
assert(/command: \["omarchy-hw-battery-charge-limit"\]/.test(panelSource), 'charge limit probes support via omarchy-hw-battery-charge-limit')
assert(!/charge_control_end_threshold/.test(panelSource), 'charge limit does not hardcode the sysfs path')
assert(!/sudo/.test(panelSource), 'charge limit does not self-elevate in the shell')

assert(/root\.chargeLimitSupported = exitCode === 0/.test(panelSource), 'charge limit caches support from the probe exit code')
assert(/onOpenedChanged:[\s\S]*?chargeLimitCheckProc\.running = true/.test(panelSource), 'charge limit probes support once per panel open')
assert(/function refresh\(\) \{[\s\S]*?if \(chargeLimitSupported && !thresholdReadProc\.running\) thresholdReadProc\.running = true/.test(panelSource), 'charge limit refresh is gated on support')
assertEqual(panelSource.match(/visible: root\.chargeLimitSupported/g).length, 2, 'charge limit hides the separator and section when unsupported')
assert(/command: \["omarchy-battery-limit-get", "--options"\]/.test(panelSource), 'charge presets come from hardware discovery')
assert(/root\.chargeLimitRaw === "mixed"/.test(panelSource), 'charge limit distinguishes mixed and unreadable hardware')
JS

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
assertDeepEqual(power.parseChargeLimitOptions('80 100\n'), [80, 100], 'LG hides 90')
assertDeepEqual(power.parseChargeLimitOptions('80 90 100'), [80, 90, 100], 'usual presets remain available')
assertDeepEqual(power.parseChargeLimitOptions('100 80 80'), [80, 100], 'presets are sorted and unique')
for (const raw of ['', '80 junk', '80 85 100', 'NaN', '080 100']) {
  assertDeepEqual(power.parseChargeLimitOptions(raw), [], 'invalid options fail closed: ' + raw)
}
assertEqual(power.selectProfileIndex(0, 1, [80, 100]), 1, 'right selects 100 on LG')
assertEqual(power.selectProfileIndex(1, 1, [80, 100]), 1, 'right stays within LG options')
assertEqual(power.selectProfileIndex(1, -1, [80, 100]), 0, 'left selects 80 on LG')
assert(power.chargeLimitError('Error: battery did not accept charge limit 90. Previous battery thresholds restored').includes('battery rejected'), 'driver rejection explains preset restrictions')
assert(power.chargeLimitError('battery did not accept charge limit 90; could not restore previous thresholds').includes('Could not restore'), 'rollback failure takes priority over rejection')
assert(power.chargeLimitError('Previous battery thresholds restored').includes('Could not apply'), 'other transaction failures retain their message')
JS
