#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command node

cli="$ROOT/bin/omarchy-mouse-logitech"
[[ -x $cli ]] || fail "omarchy-mouse-logitech CLI is executable"
pass "omarchy-mouse-logitech CLI is executable"

# --- CLI probe & offline status tests using a fake sysfs directory ---

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

empty_hid="$tmp/hid-empty"
present_hid="$tmp/hid-present"
mkdir -p "$empty_hid/0003:05AC:024F.0001" "$present_hid/0003:046D:C548.0001"

if OMARCHY_LOGITECH_HID_ROOT="$empty_hid" OMARCHY_LOGITECH_NO_CACHE=1 "$cli" --json probe >"$tmp/out.json"; then
  fail "probe exits non-zero when no Logitech HID device is present"
fi
jq -e '.present == false' "$tmp/out.json" >/dev/null || fail "probe reports absent in JSON" "$(cat "$tmp/out.json")"
pass "probe detects absence of Logitech HID devices"

OMARCHY_LOGITECH_HID_ROOT="$present_hid" OMARCHY_LOGITECH_NO_CACHE=1 "$cli" --json probe >"$tmp/out.json" ||
  fail "probe exits 0 when a Logitech HID device is present"
jq -e '.present == true' "$tmp/out.json" >/dev/null || fail "probe reports present in JSON" "$(cat "$tmp/out.json")"
pass "probe detects Logitech HID vendor 046D"

OMARCHY_LOGITECH_HID_ROOT="$empty_hid" OMARCHY_LOGITECH_NO_CACHE=1 "$cli" --json status >"$tmp/status.json" ||
  fail "status exits 0 when no Logitech HID device is present"
jq -e '.connected == false' "$tmp/status.json" >/dev/null || fail "status reports disconnected without Logitech hardware" "$(cat "$tmp/status.json")"
pass "status short-circuits cleanly when no Logitech HID device is present"

if OMARCHY_LOGITECH_HID_ROOT="$empty_hid" OMARCHY_LOGITECH_NO_CACHE=1 "$cli" --json set dpi 1000 >"$tmp/set.json"; then
  fail "set fails cleanly when no mouse is connected"
fi
jq -e '.ok == false' "$tmp/set.json" >/dev/null || fail "set reports ok=false when disconnected" "$(cat "$tmp/set.json")"
pass "set returns structured error when disconnected"

# --- Model.js and Store.js unit tests ---

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

function loadQmlLibrary(rel) {
  const src = fs.readFileSync(path.join(root, rel), 'utf8').replace(/^\s*\.pragma library\s*\n/, '')
  const ctx = {}
  vm.runInNewContext(src, ctx, { filename: rel })
  return ctx
}

const Model = loadQmlLibrary('shell/plugins/panels/logitech/Model.js')
const Store = loadQmlLibrary('shell/plugins/panels/logitech/Store.js')

assertDeepEqual(Model.dpiPresets(200, 8000), [800, 1000, 1600, 2400, 4000], 'dpiPresets returns standard stops within bounds')
assertDeepEqual(Model.dpiPresets(1000, 2000), [1000, 1600], 'dpiPresets filters stops outside device bounds')
assertEqual(Model.snapValue(1027, 200, 8000, 50), 1050, 'snapValue rounds to nearest DPI step')
assertEqual(Model.snapValue(99999, 200, 8000, 50), 8000, 'snapValue clamps to max')
assertEqual(Model.snapValue(10, 200, 8000, 50), 200, 'snapValue clamps to min')

assertEqual(Model.batteryStatusKind({ known: false }), 'connected', 'unknown battery falls back to connected')
assertEqual(Model.batteryStatusKind({ known: true, level: 50, charging: true, status: 'recharging' }), 'charging', 'charging battery reports charging')
assertEqual(Model.batteryStatusKind({ known: true, level: 100, charging: false, status: 'full' }), 'full', 'full battery reports full')
assertEqual(Model.batteryStatusKind({ known: true, level: 10, charging: false, status: 'discharging' }), 'low', 'low battery threshold reports low')
assertEqual(Model.batteryStatusKind({ known: true, level: 70, charging: false, status: 'discharging' }), 'discharging', 'normal discharging battery reports discharging')

assertEqual(Model.remappedCount([{ isDefault: true }, { isDefault: false }, { isDefault: false }]), 2, 'remappedCount counts non-default buttons')
assertEqual(Model.isFreespinMode('Freespinning'), true, 'isFreespinMode detects freespin')
assertEqual(Model.isFreespinMode('Ratcheted'), false, 'isFreespinMode detects ratchet')

assertEqual(
  Model.plainSafe('<img src="https://example.invalid/x"> & MX Master 4'),
  '&lt;img src="https://example.invalid/x"&gt; &amp; MX Master 4',
  'plainSafe neutralizes HTML/QML markup in dynamic tooltip strings'
)

// Store leader election, coalescing, and multi-monitor broadcast
const calls = []
const syncedA = []
const syncedB = []
const panelA = {
  syncFromStore(st) { syncedA.push({ connected: st.connected, dpiValue: st.dpiValue }) },
  execCli(args, kind, refreshAfter) { calls.push({ from: 'A', args, kind, refreshAfter }) }
}
const panelB = {
  syncFromStore(st) { syncedB.push({ connected: st.connected, dpiValue: st.dpiValue }) },
  execCli(args, kind, refreshAfter) { calls.push({ from: 'B', args, kind, refreshAfter }) }
}

Store.register(panelA)
Store.register(panelB)
assert(Store.isLeader(panelA) && !Store.isLeader(panelB), 'first registered panel becomes store leader')

Store.enqueueWrite(['set', 'dpi', '1200'], false, panelB)
Store.enqueueWrite(['set', 'dpi', '1400'], false, panelB)
Store.enqueueWrite(['set', 'dpi', '1600'], false, panelB)
assertEqual(calls.length, 1, 'second and third writes wait while first is in flight')
assertEqual(calls[0].from, 'A', 'leader executes writes queued from secondary monitor')

Store.finishExec('write', '{"ok": true}', 0, false)
assertEqual(calls.length, 2, 'coalesced write drains after first completes')
assertDeepEqual(calls[1].args, ['set', 'dpi', '1600'], 'rapid writes to the same setting coalesce to the latest value')

Store.finishExec('write', '{"ok": true}', 0, false)
Store.applyStatusPayload(JSON.stringify({
  solaarInstalled: true,
  connected: true,
  name: 'MX Master 4',
  serial: '2B4A2A11',
  transport: 'Bolt Receiver',
  battery: { known: true, level: 70, status: 'discharging', charging: false },
  features: { dpi: { value: 1600, min: 200, max: 8000, step: 50 } }
}))
assertEqual(syncedA[syncedA.length - 1].dpiValue, 1600, 'status payload syncs to leader panel')
assertEqual(syncedB[syncedB.length - 1].dpiValue, 1600, 'status payload broadcasts to secondary panel')

Store.unregister(panelA)
assert(Store.isLeader(panelB), 'unregistering leader hands off leadership to remaining panel')
Store.unregister(panelB)
JS
