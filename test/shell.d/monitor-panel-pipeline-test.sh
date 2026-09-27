#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

task_tmp=$(mktemp -d)
trap 'rm -rf "$task_tmp"' EXIT
mkdir -p "$task_tmp/bin"
export MONITOR_PIPELINE_FIXTURE="$task_tmp/monitors.json"
cat > "$task_tmp/bin/hyprctl" <<'STUB'
#!/bin/bash
[[ $* == 'monitors all -j' ]] || exit 1
cat "$MONITOR_PIPELINE_FIXTURE"
STUB
for helper in omarchy-brightness-display omarchy-hyprland-monitor-scaling; do
  printf '#!/bin/bash\necho 1\n' > "$task_tmp/bin/$helper"
done
chmod +x "$task_tmp/bin/"*
export PATH="$task_tmp/bin:$PATH"

run_node_test <<'JS'
const fs = require('fs')
const { execFileSync } = require('child_process')
const model = require(process.env.MONITOR_PIPELINE_MODEL || path.join(root, 'shell/plugins/panels/monitor/Model.js'))
const internal = { name: 'eDP-2', disabled: false, width: 2880, height: 1800, description: 'Apple Color LCD', availableModes: ['2880x1800@60'], mirrorOf: 'none' }
const ghost = { name: 'eDP-1', disabled: false, width: 0, height: 0, description: '', make: '', model: '', availableModes: [], mirrorOf: 'none' }
function roundTrip(displays) {
  fs.writeFileSync(process.env.MONITOR_PIPELINE_FIXTURE, JSON.stringify(displays))
  const output = execFileSync('bash', [path.join(root, 'bin/omarchy-monitor-state')], { encoding: 'utf8' })
  const lines = output.trimEnd().split('\n')
  assertEqual(lines.length, 8, 'panel protocol retains eight lines')
  return model.parseDisplays(lines[7])
}
let actual = roundTrip([ghost, internal, { name: 'DP-1', disabled: false, width: 0, height: 0, description: 'Real external monitor', availableModes: ['2560x1440@60'], mirrorOf: 'none' }])
assertDeepEqual(actual.displays.map(d => d.name), ['eDP-2', 'DP-1'], 'real external monitor awaiting mode recovery remains available in the panel')
assertEqual(actual.enabledDisplayCount, 2, 'enabled display count includes the recoverable real monitor')
actual = roundTrip([{ ...ghost, disabled: true }, { ...internal, disabled: true, width: 0, height: 0 }])
assertDeepEqual(actual.displays.map(d => d.name), ['eDP-2'], 'disabled real panel remains listed while a disabled identityless ghost is omitted')
assertEqual(actual.enabledDisplayCount, 0, 'disabled panels do not count as enabled')
actual = roundTrip([{ name: 'DP-2', disabled: false, width: 0, height: 0, availableModes: ['1920x1080@60'], mirrorOf: 'none' }])
assertEqual(actual.displays.length, 1, 'advertised modes suffice while identity and geometry are temporarily missing')
actual = roundTrip([ghost, internal])
assertDeepEqual(actual.displays.map(d => d.name), ['eDP-2'], 'empty duplicate does not reappear after model parsing')
JS
