#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/install/helpers/usb-authorization-policy.sh"
source "$ROOT/install/helpers/usb-lock.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
USB_LOCK_DIR=$scratch/runtime
USB_LOCK_ENABLED=$scratch/enabled
calls=$scratch/calls
device_inventory_file=$scratch/devices
active=1 failure="" manual=0

usbguard() {
  [[ $* == "list-devices" ]] || return 1
  [[ $failure != "inventory" ]] || return 1
  cat "$device_inventory_file"
}
systemctl() {
  printf '%s\n' "$*" >>"$calls"
  if [[ $* == "is-active --quiet usbguard.service" || $* == "is-enabled --quiet usbguard.service" ]]; then
    (( manual ))
  elif [[ $1 == "is-active" ]]; then
    (( active ))
  elif [[ $1 == "restart" ]]; then
    [[ $failure != "restart" ]] || return 1
    cp "$USB_LOCK_DIR/rules.conf" "$scratch/loaded"
  elif [[ $1 == "disable" ]]; then
    [[ $failure != "stop" ]] || return 1
    active=0
  fi
}
omarchy-usb-authorization-restore-default() { echo restore-default >>"$calls"; }

device='allow id 046d:c53a serial "" name "USB Receiver" hash "KCUFt1MumW4Pfs/8YXWzGQB6Hsnm8qkDqFVjfY0NIBY=" parent-hash "m7yTNWlczwBbYn+uRP6TRsY5AceKmAZ0Et6mgy58+/o=" via-port "3-1.1.2.1" with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "unknown"'
printf '7: %s\n8: block id 1234:5678 name "Blocked"\n' "$device" >"$device_inventory_file"
: >"$calls"
usb_lock_prepare || fail "boot preparation works"
[[ $(<"$USB_LOCK_DIR/rules.conf") == $'# unlocked\nallow' ]] || fail "new boot starts permissive"
[[ $(usb_lock_change lock) == off ]] || fail "disabled feature is a no-op"
touch "$USB_LOCK_ENABLED"
[[ $(usb_lock_change lock) == locked ]] || fail "lock acknowledges applied policy"
grep -qx block "$scratch/loaded" || fail "locked policy denies unmatched devices"
! grep -q 'Blocked\|via-port\|parent-hash' "$scratch/loaded" || fail "snapshot contains only allowed portable identities"
pass "boot is permissive; locking freezes portable identities and excludes blocked devices"

cp "$scratch/loaded" "$scratch/frozen"
printf '9: allow id 1234:5678 name "Arrived while locked"\n' >>"$device_inventory_file"
usb_lock_prepare
usb_lock_change lock >/dev/null || fail "repeat lock works"
cmp -s "$scratch/loaded" "$scratch/frozen" || fail "restart or repeated lock learned a new device"
pass "daemon preparation, shell recovery and repeat lock preserve the frozen snapshot"

usb_lock_change unlock >/dev/null || fail "unlock applies permissive policy"
[[ $(<"$scratch/loaded") == $'# unlocked\nallow' ]] || fail "unlock authorizes waiting devices through policy reload"
pass "unlock reloads a permissive policy without permanent approvals"

failure=inventory
if usb_lock_change lock >/dev/null; then fail "inventory failure must not acknowledge protection"; fi
[[ $(<"$USB_LOCK_DIR/rules.conf") == $'# unlocked\nallow' ]] || fail "inventory failure changes policy"
failure=restart
if usb_lock_change lock >/dev/null; then fail "restart failure must not acknowledge protection"; fi
grep -qx '# locked' "$USB_LOCK_DIR/rules.conf" || fail "failed restart discarded frozen policy"
cp "$USB_LOCK_DIR/rules.conf" "$scratch/frozen"
printf '10: allow id 1111:2222 name "Late arrival"\n' >>"$device_inventory_file"
failure=""
usb_lock_change lock >/dev/null || fail "retry applies the frozen policy"
cmp -s "$scratch/loaded" "$scratch/frozen" || fail "retry recaptured devices"
pass "inventory and daemon failures do not report success or widen the lock snapshot"

manual=1
if usb_lock_enable >/dev/null 2>&1; then fail "setup replaces an existing USBGuard service"; fi
if usb_lock_disable >/dev/null 2>&1; then fail "removal relaxes a different USBGuard service"; fi
manual=0 failure=stop
if usb_lock_disable >/dev/null; then fail "failed stop must fail removal"; fi
[[ -e $USB_LOCK_ENABLED ]] || fail "failed removal lost its recovery marker"
! grep -qx restore-default "$calls" || fail "failed removal relaxed kernel defaults"
failure=""
usb_lock_disable >/dev/null || fail "removal can be retried"
[[ ! -e $USB_LOCK_ENABLED && ! -e $USB_LOCK_DIR/rules.conf ]] || fail "removal leaves protection enabled"
grep -qx restore-default "$calls" || fail "removal restores connected devices and hub defaults"
pass "manual USBGuard is preserved and failed removal remains retryable"

for entry in omarchy-usb-lock-admin omarchy-usb-lock-state; do
  sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
    -e 's|source /usr/share/omarchy/install/helpers/usb-authorization-policy.sh|exit 126|' \
    "$ROOT/bin/$entry" >"$scratch/entry"
  chmod 755 "$scratch/entry"
  printf 'set -p\n' >"$scratch/decoy"
  if BASH_ENV="$scratch/decoy" /usr/bin/bash "$scratch/entry" -p; then fail "$entry accepts an unsafe launch"; fi
  printf 'touch "%s"\n' "$scratch/injected" >"$scratch/startup"
  if BASH_ENV="$scratch/startup" "$scratch/entry" >/dev/null 2>&1; then fail "$entry fixture boundary"; fi
  if /usr/bin/env 'BASH_FUNC_source%%=() { touch "$USB_TEST_INJECTED"; }' USB_TEST_INJECTED="$scratch/injected" "$scratch/entry" >/dev/null 2>&1; then fail "$entry exported function boundary"; fi
  [[ ! -e $scratch/injected ]] || fail "$entry executes untrusted startup code"
  pass "$entry rejects startup injection and an ordinary Bash launch with decoy -p"
done

run_node_test <<'JS'
const vm = require('vm')
const fs = require('fs')
const text = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const deferred = []
const state = {
  usbTarget: '', usbApplied: '', usbInFlight: '', usbFailureReported: false,
  omarchyPath: '/test', usbPolicyProc: {running: false}, usbPolicyOutput: {text: ''},
  usbPolicyRetry: {restart() {state.retry = true}}, usbFailureNotice: {running: false},
  Qt: {callLater(fn) {deferred.push(fn)}}, logEvent() {}
}
state.root = state
vm.createContext(state)
for (const name of ['requestUsbPolicy', 'startUsbPolicy']) {
  const body = text.match(new RegExp('  function ' + name + '\\([^]*?\\n  }'))[0]
  vm.runInContext(body, state)
}
const handler = text.split('id: usbPolicyProc')[1].match(/onExited: function\(exitCode\) \{([^]*?)\n    }/)[1]
vm.runInContext('function complete(exitCode) {' + handler + '\n}', state)
function finish(reply, code = 0) {
  state.usbPolicyProc.running = false
  state.usbPolicyOutput.text = reply
  state.complete(code)
  while (deferred.length) deferred.shift()()
}
state.requestUsbPolicy('lock')
state.requestUsbPolicy('unlock')
assert(state.usbInFlight === 'lock', 'unlock waits for the in-flight lock')
finish('locked')
assert(state.usbInFlight === 'unlock', 'the queued unlock runs after the lock')
state.requestUsbPolicy('lock')
finish('unlocked')
assert(state.usbInFlight === 'lock' && state.usbApplied !== 'lock', 'a late unlock cannot satisfy a newer lock')
finish('', 1)
assert(state.retry && state.usbFailureNotice.running && state.usbApplied !== 'lock', 'failed protection stays unacknowledged and reports failure')
state.startUsbPolicy()
finish('locked')
assert(state.usbApplied === 'lock' && !state.usbFailureReported, 'successful retry acknowledges the current lock')
state.requestUsbPolicy('unlock')
finish('off')
assert(state.usbApplied === 'unlock', 'disabled protection never obstructs ordinary locking')
JS
