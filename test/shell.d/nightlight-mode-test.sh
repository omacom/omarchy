#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/services/nightlight/Service.qml'), 'utf8')

function service(scheduled) {
  const context = vm.createContext({
    root: {
      scheduleLoaded: true,
      scheduled,
      requestedSchedule: null,
      nightTemperature: 4000,
      dayTemperature: 6500,
      temperature: 6500
    },
    statusProbe: { running: false },
    scheduleProbe: { running: false },
    scheduleTimer: { stop() {}, restart() {} },
    scheduleChangeProcess: { running: false, command: [] },
    warnings: []
  })
  context.console = { warn: message => context.warnings.push(message) }

  for (const match of source.matchAll(/^  function (\w+)\(([^)]*)\) \{([\s\S]*?)^  \}/gm)) {
    vm.runInContext(`root.${match[1]} = function(${match[2]}) {${match[3]}}`, context)
  }
  for (const key of Object.keys(context.root)) {
    Object.defineProperty(context, key, {
      get: () => context.root[key],
      set: value => { context.root[key] = value }
    })
  }
  const exits = {}
  for (const name of ['scheduleChangeProcess', 'statusProbe']) {
    const match = source.match(new RegExp(`id: ${name}\\b[\\s\\S]*?(onExited: function\\(exitCode\\) \\{[\\s\\S]*?^    \\})`, 'm'))
    if (match) exits[name] = vm.runInContext(`(${match[1].replace('onExited: ', '')})`, context)
  }
  const scheduleOutput = source.match(/id: scheduleProbe[\s\S]*?onStreamFinished: \{([\s\S]*?)^      \}/m)
  const finishSchedule = vm.runInContext(`(function(text) {${scheduleOutput[1]}})`, context)
  vm.runInContext('root.applyTemperature = function(temp) { root.temperature = temp }', context)

  let persisted = scheduled
  const writes = []
  function finishWrite(exitCode = 0) {
    const process = context.scheduleChangeProcess
    assertEqual(process.running, true, 'a mode write is in flight')
    const enabling = process.command[1] === 'enable'
    if (exitCode === 0) persisted = enabling
    writes.push(enabling)
    process.running = false
    exits.scheduleChangeProcess(exitCode)
  }
  function settle() {
    for (let count = 0; count < 5; count++) {
      if (!context.scheduleChangeProcess.running) break
      finishWrite()
    }
    assertEqual(context.root.requestedSchedule, null, 'the latest mode request settles')
    return persisted
  }
  return { context, finishWrite, settle, writes, finishStatus: exits.statusProbe, finishSchedule }
}

for (const warm of [true, false]) {
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(warm)
  assertEqual(test.settle(), false, `manual ${warm ? 'night light' : 'daylight'} wins over pending Sunset`)
  assertEqual(test.context.root.temperature, warm ? 4000 : 6500, 'the latest manual temperature is retained')
  assertDeepEqual(test.writes, [true, false], 'manual mode is persisted after the older enable completes')
}

{
  const test = service(true)
  test.context.root.setNightlight(false)
  test.context.root.setScheduleEnabled(true)
  assertEqual(test.settle(), true, 'Sunset wins over pending manual persistence')
  assertDeepEqual(test.writes, [false, true], 'Sunset waits for the older disable to complete')
}

{
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(true)
  test.context.root.setScheduleEnabled(true)
  assertEqual(test.settle(), true, 'Sunset wins after enable-manual-enable')
  assertDeepEqual(test.writes, [true], 'superseded requests do not cause extra writes')
}

{
  const test = service(true)
  test.context.root.setNightlight(true)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(false)
  assertEqual(test.settle(), false, 'manual mode wins after manual-enable-manual')
  assertEqual(test.context.root.temperature, 6500, 'the newest manual temperature wins too')
  assertDeepEqual(test.writes, [false], 'a superseded enable does not run')
}

{
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.finishStatus(0)
  assertEqual(test.context.scheduleProbe.running, false, 'status completion cannot evaluate an intermediate mode')
  test.context.root.setNightlight(false)
  test.finishSchedule(JSON.stringify({ scheduled: true, night: true }))
  assertEqual(test.context.root.scheduled, false, 'a stale solar response cannot reselect Sunset during a manual request')
  assertEqual(test.context.root.temperature, 6500, 'a stale solar response cannot override manual daylight')
  test.finishWrite(1)
  assertEqual(test.settle(), false, 'the latest manual request survives a failed older enable')
  assertEqual(test.context.warnings.length, 1, 'a failed mode write is reported')
}
JS

require_compositor "nightlight mode persistence runtime test"
require_command quickshell

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir "$test_tmp/bin"
cp "$SHELL_TEST_DIR/fixtures/nightlight-mode/shell.qml" "$test_tmp/shell.qml"
cp "$SHELL_TEST_DIR/fixtures/nightlight-mode/schedule-command" "$test_tmp/bin/omarchy-nightlight-schedule"
chmod +x "$test_tmp/bin/omarchy-nightlight-schedule"
ln -s "$ROOT/shell/plugins/services/nightlight" "$test_tmp/Nightlight"

output=$(PATH="$test_tmp/bin:$PATH" OMARCHY_NIGHTLIGHT_STATE="$test_tmp/mode" \
  timeout 10 quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "nightlight mode persistence fixture exits cleanly"
}
if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "manual mode wins after an in-flight Sunset write"
fi
pass "manual mode wins after an in-flight Sunset write"
