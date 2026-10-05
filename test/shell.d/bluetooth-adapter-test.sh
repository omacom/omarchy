#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const Model = requireFromRoot('shell/plugins/panels/bluetooth/Model.js')
const source = fs.readFileSync(root + '/shell/plugins/panels/bluetooth/Panel.qml', 'utf8')
const address = 'AA:BB:CC:DD:EE:FF'
const first = { address, dbusPath: '/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF', connected: true }
const second = { address, dbusPath: '/org/bluez/hci1/dev_AA_BB_CC_DD_EE_FF', connected: false }
const context = vm.createContext({
  Model, devices: [first, second], pendingActions: {},
  cloneMap: Model.cloneMap, scheduleAudioOutputSwitch: () => {}
})
for (const name of ['deviceFor', 'deviceCommand', 'syncPendingActions']) {
  const body = source.match(new RegExp('  function ' + name + '\\([^]*?\\n  }'))
  assert(body, 'panel exposes ' + name)
  vm.runInContext(body[0], context)
}
assertEqual(context.deviceFor({ dev: Model.deviceRow(second) }), second,
  'a row resolves the device on its own adapter when both adapters know the address')
assertEqual(context.deviceFor({ dev: { address } }), null,
  'a stale row without adapter identity cannot fall back to another device')
for (const action of ['pair', 'connect', 'disconnect', 'forget']) {
  assertDeepEqual(Array.from(context.deviceCommand(action, second)),
    ['omarchy-bluetooth-device', action, address, second.dbusPath],
    action + ' carries the selected device path to the command')
}
context.pendingActions = { [second.dbusPath]: 'connecting' }
context.syncPendingActions()
assertEqual(context.pendingActions[second.dbusPath], 'connecting',
  'a connection on another adapter does not finish the pending action')
second.connected = true
context.syncPendingActions()
assertEqual(Object.keys(context.pendingActions).length, 0,
  'the pending action finishes when its own adapter connects')
context.devices = [first]
assertEqual(context.deviceFor({ dev: Model.deviceRow(second) }), null,
  'removing the selected adapter cannot redirect a row to the remaining adapter')
JS

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export ADAPTER_LOG="$scratch/log"
cat >"$scratch/bin/busctl" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >>"$ADAPTER_LOG"
[[ -z ${BUSCTL_FAIL:-} ]] || exit 1
if [[ -n ${ADAPTER_POWER_FAIL:-} && $* == *"set-property"*"Powered b true" ]]; then
  exit 1
fi
if [[ $* == *"get-property"* ]]; then
  printf 'b %s\n' "${ADAPTER_POWERED:-true}"
fi
MOCK
cat >"$scratch/bin/bluetoothctl" <<'MOCK'
#!/bin/bash
echo "unexpected default-controller command" >>"$ADAPTER_LOG"
exit 1
MOCK
cat >"$scratch/bin/omarchy-bluetooth-power" <<'MOCK'
#!/bin/bash
printf 'power %s\n' "$*" >>"$ADAPTER_LOG"
exit "${POWER_HELPER_EXIT:-0}"
MOCK
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"

for adapter in hci0 hci1; do
  device="/org/bluez/$adapter/dev_AA_BB_CC_DD_EE_FF"
  for action in pair connect disconnect forget; do
    : >"$ADAPTER_LOG"
    "$ROOT/bin/omarchy-bluetooth-device" "$action" AA:BB:CC:DD:EE:FF "$device"
    case "$action" in
      pair | connect)
        grep -Fxq -- "--system --timeout=20 call org.bluez $device org.bluez.Device1 Connect" "$ADAPTER_LOG" || fail "connect uses $adapter"
        grep -Fxq -- "--system set-property org.bluez $device org.bluez.Device1 Trusted b true" "$ADAPTER_LOG" || fail "trust uses $adapter"
        if [[ $action == "pair" ]]; then
          grep -Fxq -- "--system --timeout=20 call org.bluez $device org.bluez.Device1 Pair" "$ADAPTER_LOG" || fail "pair uses $adapter"
        fi
        ;;
      disconnect)
        grep -Fxq -- "--system --timeout=20 call org.bluez $device org.bluez.Device1 Disconnect" "$ADAPTER_LOG" || fail "disconnect uses $adapter"
        ;;
      forget)
        grep -Fxq -- "--system --timeout=20 call org.bluez /org/bluez/$adapter org.bluez.Adapter1 RemoveDevice o $device" "$ADAPTER_LOG" || fail "forget uses $adapter"
        ;;
    esac
    grep -q 'unexpected\|^power' "$ADAPTER_LOG" && fail "powered device actions do not use the default controller or change power"
    pass "$action targets the device on $adapter"
  done
done

: >"$ADAPTER_LOG"
ADAPTER_POWERED=false "$ROOT/bin/omarchy-bluetooth-device" connect aa:bb:cc:dd:ee:ff "$device"
grep -Fxq -- "--system set-property org.bluez /org/bluez/hci1 org.bluez.Adapter1 Powered b true" "$ADAPTER_LOG" || fail "power on targets the device's adapter"
pass "a powered-down secondary adapter is powered on explicitly"

# The general helper may fail after trying the default controller. Pair and
# connect must still try the selected controller, but must not ignore its error.
for action in pair connect; do
  : >"$ADAPTER_LOG"
  ADAPTER_POWERED=false POWER_HELPER_EXIT=1 "$ROOT/bin/omarchy-bluetooth-device" "$action" AA:BB:CC:DD:EE:FF "$device" ||
    fail "$action attempts the selected adapter after the general power helper fails"
  {
    echo "--system --timeout=2 get-property org.bluez /org/bluez/hci1 org.bluez.Adapter1 Powered"
    echo "power on"
    echo "--system set-property org.bluez /org/bluez/hci1 org.bluez.Adapter1 Powered b true"
    if [[ $action == "pair" ]]; then
      echo "--system --timeout=20 call org.bluez $device org.bluez.Device1 Pair"
    fi
    echo "--system set-property org.bluez $device org.bluez.Device1 Trusted b true"
    echo "--system --timeout=20 call org.bluez $device org.bluez.Device1 Connect"
  } >"$scratch/expected"
  diff -u "$scratch/expected" "$ADAPTER_LOG" || fail "$action powers its adapter before acting on the device"
  pass "$action recovers from a general power helper failure on the selected adapter"

  : >"$ADAPTER_LOG"
  if ADAPTER_POWERED=false POWER_HELPER_EXIT=1 ADAPTER_POWER_FAIL=1 "$ROOT/bin/omarchy-bluetooth-device" "$action" AA:BB:CC:DD:EE:FF "$device"; then
    fail "$action reports a selected-adapter power failure"
  fi
  head -n 3 "$scratch/expected" >"$scratch/failed-power-expected"
  diff -u "$scratch/failed-power-expected" "$ADAPTER_LOG" || fail "$action stops before device operations when selected-adapter power fails"
  pass "$action preserves selected-adapter power errors"
done

for invalid in /org/bluez/hci1 /org/bluez/hci1/dev_11_22_33_44_55_66 '/org/bluez/hci1/dev_AA_BB_CC_DD_EE_FF;true'; do
  : >"$ADAPTER_LOG"
  if "$ROOT/bin/omarchy-bluetooth-device" connect AA:BB:CC:DD:EE:FF "$invalid" >/dev/null 2>&1; then
    fail "invalid or mismatched paths are rejected"
  fi
  [[ ! -s $ADAPTER_LOG ]] || fail "invalid paths never reach Bluetooth"
done
pass "invalid or mismatched paths never reach Bluetooth"

: >"$ADAPTER_LOG"
if BUSCTL_FAIL=1 "$ROOT/bin/omarchy-bluetooth-device" connect AA:BB:CC:DD:EE:FF "$device"; then
  fail "a missing adapter reports failure"
fi
[[ $(wc -l <"$ADAPTER_LOG") == 1 ]] || fail "a missing adapter never falls back or changes power"
pass "a missing adapter never falls back to the default controller"
