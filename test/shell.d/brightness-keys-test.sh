#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" XDG_RUNTIME_DIR="$scratch/run" OMARCHY_BACKLIGHT_PATH="$scratch/backlight"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$OMARCHY_BACKLIGHT_PATH/panel" "$scratch/bin"
echo 100 >"$OMARCHY_BACKLIGHT_PATH/panel/max_brightness"
cat >"$scratch/bin/brightnessctl" <<'SH'
#!/bin/bash
[[ $1 == "-d" && $2 == "panel" && $3 == "set" ]] || exit 1
echo "${4%\%}" >"$OMARCHY_BACKLIGHT_PATH/panel/brightness"
SH
chmod +x "$scratch/bin/brightnessctl"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const {execFileSync} = require('child_process')
const source = fs.readFileSync(root + '/shell/services/BrightnessKeys.qml', 'utf8')
const keys = vm.createContext({Hyprland: {focusedMonitor: {name: 'eDP-1'}}, device: 'panel', setProc: {running: false}})
vm.runInContext(source.match(/function handle\(action\) \{[^]*?\n  \}/)[0], keys)
const physical = process.env.OMARCHY_BACKLIGHT_PATH + '/panel/brightness'
const saved = process.env.XDG_RUNTIME_DIR + '/omarchy-brightness-display.saved'
function press(action) {
  keys.setProc.running = false
  assert(keys.handle(action), 'internal key is handled')
  const [cmd, ...args] = keys.setProc.command
  return execFileSync(cmd, args, {encoding: 'utf8'}).trim()
}
const steps = [
  ['raise', 60, 65], ['lower', 60, 55],
  ['raise', 4, 5], ['raise', 5, 10], ['lower', 5, 4], ['lower', 6, 1],
  ['raise', 98, 100], ['raise', 100, 100], ['lower', 1, 1], ['lower', 2, 1],
]
for (const [action, current, target] of steps) {
  fs.writeFileSync(physical, current + '\n')
  assertEqual(press(action), String(target), `brightness ${action} from ${current}% reports ${target}%`)
  assertEqual(fs.readFileSync(physical, 'utf8').trim(), String(target), 'lit panel receives the requested level')
}
fs.writeFileSync(saved, '40\n')
fs.writeFileSync(physical, '0\n')
assertEqual(press('raise'), '45', 'the OSD reports the next restore level')
assertEqual(fs.readFileSync(saved, 'utf8').trim(), '45', 'key updates saved brightness')
assertEqual(fs.readFileSync(physical, 'utf8').trim(), '0', 'key leaves the blanked panel dark')
JS
