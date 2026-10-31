#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export PATH="$ROOT/bin:$PATH"
source "$ROOT/install/helpers/usb-lock.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
USB_LOCK_DIR=$scratch/runtime
USB_LOCK_ENABLED=$scratch/enabled
USB_LOCK_DISABLED=$scratch/disabled
USB_LOCK_APPROVAL=$scratch/approval
USB_LOCK_TRUST=$scratch/trust
USB_LOCK_SYSFS=$scratch/sysfs
mkdir -p "$USB_LOCK_SYSFS/usb1" "$USB_LOCK_SYSFS/1-1"
echo 0 >"$USB_LOCK_SYSFS/usb1/authorized_default"
echo 0 >"$USB_LOCK_SYSFS/1-1/authorized"
calls=$scratch/calls
device_inventory_file=$scratch/devices
active=1 failure="" manual=0 limited=0

usbguard() {
  if [[ $1 == "append-rule" ]]; then
    [[ $# == 3 && $2 == "--temporary" ]] || return 1
    usbguard-rule-parser "$3" >/dev/null || return 1
    echo 20
    return
  elif [[ $1 == "allow-device" ]]; then
    local line
    while IFS= read -r line; do
      if [[ ${line#*: } == "$2" ]]; then
        printf '%s: allow %s\n' "${line%%:*}" "${2#block }"
      else
        printf '%s\n' "$line"
      fi
    done <"$device_inventory_file" >"$scratch/updated"
    mv "$scratch/updated" "$device_inventory_file"
    return
  fi
  [[ $1 == "list-devices" ]] || return 1
  (( active )) || return 1
  [[ $failure != "inventory" ]] || return 1
  case ${2:-} in
    --blocked) grep ': block ' "$device_inventory_file" || [[ $? == 1 ]] ;;
    --allowed) grep ': allow ' "$device_inventory_file" || [[ $? == 1 ]] ;;
    *) cat "$device_inventory_file" ;;
  esac
}
systemctl() {
  printf '%s\n' "$*" >>"$calls"
  if [[ ${!#} == "usbguard.service" || ${!#} == "usbguard-dbus.service" ]]; then
    (( manual ))
  elif [[ $1 == "is-active" ]]; then
    (( active ))
  elif [[ $1 == "show" ]]; then
    echo 0123456789abcdef0123456789abcdef
  elif [[ $1 == "enable" ]]; then
    active=1
  elif [[ $1 == "reset-failed" ]]; then
    limited=0
  elif [[ $1 == "restart" ]]; then
    if [[ $failure == "restart" ]]; then active=0 limited=1; return 1; fi
    (( ! limited )) || return 1
    active=1
    cp "$USB_LOCK_DIR/rules.conf" "$scratch/loaded"
  elif [[ $1 == "disable" ]]; then
    [[ $failure != "stop" ]] || return 1
    active=0
  fi
}

# omarchy-settings stages etc/ recursively. Assert both shipped files and
# refuse activation when either is missing from an installed package tree.
mkdir "$scratch/package"
cp -a "$ROOT/etc" "$scratch/package/"
USB_LOCK_UNIT=$scratch/package/etc/systemd/system/omarchy-usb-lock.service
USB_LOCK_POLKIT=$scratch/package/etc/polkit-1/rules.d/40-omarchy-usb-lock.rules
USB_LOCK_WATCH=$scratch/package/etc/systemd/user/omarchy-usb-lock-watch.service
[[ -f $USB_LOCK_UNIT && -f $USB_LOCK_POLKIT ]] || fail "the settings package needs the service and Polkit rule"
grep -Fq 'ExecStartPre=/usr/bin/omarchy-usb-lock-admin prepare' "$USB_LOCK_UNIT" || fail "the installed unit must prepare its policy"
run_node_test <<'JS'
const vm = require('vm')
const fs = require('fs')
let rule
vm.runInNewContext(fs.readFileSync(path.join(root, 'etc/polkit-1/rules.d/40-omarchy-usb-lock.rules'), 'utf8'), {
  polkit: {addRule(fn) {rule = fn}, Result: {YES: 'yes', NO: 'no'}}
})
const subject = {local: true, active: true, isInGroup: group => group === 'wheel'}
const action = {id: 'org.freedesktop.policykit.exec', lookup: key => key === 'program' ? '/usr/bin/omarchy-usb-lock-state' : ''}
assert(rule(action, subject) === 'yes', 'active local wheel users can request a policy transition through pkexec')
assert(rule({...action, id: 'org.omarchy.usb-lock.state'}, subject) === 'yes', 'preview action compatibility retains the same boundary')
assert(rule(action, {...subject, active: false}) === 'no', 'inactive sessions cannot request a transition')
assert(rule(action, {...subject, local: false}) === 'no', 'remote sessions cannot request a transition')
assert(rule(action, {...subject, isInGroup: () => false}) === 'no', 'non-administrators cannot request a transition')
assert(rule({...action, lookup: () => '/usr/bin/omarchy-usb-lock-admin'}, subject) === undefined, 'the rule cannot elevate the administrative helper')
assert(rule({...action, id: 'another.action'}, subject) === undefined, 'unrelated actions receive no grant')
JS
for path in "$USB_LOCK_UNIT" "$USB_LOCK_POLKIT" "$USB_LOCK_WATCH"; do
  mv "$path" "$path.saved"
  if usb_lock_enable >"$scratch/setup-error" 2>&1; then fail "missing package support must reject enable"; fi
  grep -q 'service or permissions are missing' "$scratch/setup-error" || fail "setup must identify incomplete packaging"
  [[ ! -e $USB_LOCK_ENABLED ]] || fail "incomplete setup must not publish an enable marker"
  mv "$path.saved" "$path"
done
pass "package tree includes service and permissions; missing files prevent enforcement"

device='allow id 046d:c53a serial "" name "USB Receiver" hash "KCUFt1MumW4Pfs/8YXWzGQB6Hsnm8qkDqFVjfY0NIBY=" parent-hash "m7yTNWlczwBbYn+uRP6TRsY5AceKmAZ0Et6mgy58+/o=" via-port "3-1.1.2.1" with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "unknown"'
portable=$(usb_lock_portable_rule "$device")
[[ $portable == "${device/ parent-hash* with-interface/ with-interface}" ]] || fail "portable policy must retain all other identity attributes"
hostile='allow id 1234:5678 name "via-port \"fake\" parent-hash \"fake\" $(touch /tmp/usb-lock-injected)" hash "identity" via-port "1-2"'
[[ $(usb_lock_portable_rule "$hostile") == "${hostile% via-port*}" ]] || fail "quoted device names must remain data"
if usb_lock_portable_rule 'allow id 1234:5678 name "unterminated' >/dev/null; then fail "malformed identity must fail"; fi
pass "portable identities preserve attributes and treat device text as data"

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

# Default-mode unlock admission must survive disconnection across later locks.
# Keep a separate runtime so this lifecycle also models expiration at reboot.
(
  USB_LOCK_DIR=$scratch/reconnect/runtime
  USB_LOCK_TRUST=$scratch/reconnect/trust
  device_inventory_file=$scratch/reconnect/devices
  usb_lock_prepare
  printf '1: allow id 1111:1111 name "Boot input"\n' >"$device_inventory_file"
  usb_lock_change lock >/dev/null
  printf '7: %s\n' "${device/allow /block }" >>"$device_inventory_file"
  usb_lock_change unlock >/dev/null
  [[ -f $USB_LOCK_DIR/session.conf ]] && grep -Fqx -- "$portable" "$USB_LOCK_DIR/session.conf" ||
    fail "default unlock lost the temporary identity of a waiting device"
  [[ ! -e $USB_LOCK_TRUST/approved.conf ]] || fail "automatic admission became permanent"
  # The admitted receiver is absent for the next entire lock/unlock cycle.
  printf '1: allow id 1111:1111 name "Boot input"\n' >"$device_inventory_file"
  usb_lock_change lock >/dev/null
  grep -Fqx -- "$portable" "$scratch/loaded" || fail "a disconnected admitted device cannot reconnect during the next lock"
  usb_lock_change unlock >/dev/null
  usb_lock_change lock >/dev/null
  grep -Fqx -- "$portable" "$scratch/loaded" || fail "an offline lock cycle discarded temporary trust"
  ! grep -Eq 'via-port|parent-hash' "$scratch/loaded" || fail "temporary identity depends on its old port or hub"
  # A repeat lock must not capture a different identity that arrives afterward.
  printf '8: %s\n' "${device/USB Receiver/Different identity}" >>"$device_inventory_file"
  usb_lock_change lock >/dev/null
  ! grep -q 'Different identity' "$scratch/loaded" || fail "a repeat lock trusted a different identity"
  rm -r "$USB_LOCK_DIR"
  usb_lock_prepare
  printf '1: allow id 1111:1111 name "Boot input"\n' >"$device_inventory_file"
  usb_lock_change lock >/dev/null
  ! grep -Fqx -- "$portable" "$scratch/loaded" || fail "a fresh boot retained temporary consent"
)
pass "default unlock consent survives disconnected lock cycles and expires with the boot runtime"

active=0
if usb_lock_change lock >/dev/null; then fail "a first lock needs a live inventory"; fi
[[ $(<"$USB_LOCK_DIR/rules.conf") == $'# unlocked\nallow' ]] || fail "an unavailable inventory must not create a trusted snapshot"
usb_lock_change unlock >/dev/null || fail "unlock can restore the unavailable daemon before another lock"
active=1
pass "an outage before the first snapshot never invents trusted devices"

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
(( active )) || fail "lock retry must restart an inactive daemon"
active=0 limited=1
usb_lock_change unlock >/dev/null || fail "unlock must recover an inactive rate-limited daemon"
[[ $(<"$scratch/loaded") == $'# unlocked\nallow' ]] || fail "recovered unlock must allow queued devices"
(( active )) || fail "unlock recovery did not start the daemon"
pass "inventory and daemon failures do not report success or widen the lock snapshot"

manual=1
if usb_lock_enable >/dev/null 2>&1; then fail "setup replaces an existing USBGuard service"; fi
if usb_lock_disable >/dev/null 2>&1; then fail "removal relaxes a different USBGuard service"; fi
manual=0 failure=stop
if usb_lock_disable >/dev/null; then fail "failed stop must fail removal"; fi
[[ -e $USB_LOCK_ENABLED ]] || fail "failed removal lost its recovery marker"
[[ $(<"$USB_LOCK_SYSFS/usb1/authorized_default") == 0 ]] || fail "failed removal relaxed kernel defaults"
failure=""
usb_lock_disable >/dev/null || fail "removal can be retried"
[[ ! -e $USB_LOCK_ENABLED && ! -e $USB_LOCK_DIR/rules.conf ]] || fail "removal leaves protection enabled"
[[ $(<"$USB_LOCK_SYSFS/usb1/authorized_default") == 1 && $(<"$USB_LOCK_SYSFS/1-1/authorized") == 1 ]] || fail "removal restores connected devices and hub defaults without legacy helpers"
pass "manual USBGuard is preserved and failed removal remains retryable"

# Each update/login respects explicit machine-wide mode and opt-out state.
usb_lock_defaults >/dev/null || fail "an opted-out default migration must succeed"
[[ ! -e $USB_LOCK_ENABLED ]] || fail "migration reenabled an opted-out machine"
rm "$USB_LOCK_DISABLED"
manual=1
usb_lock_defaults >/dev/null || fail "manual policy preservation must succeed"
[[ ! -e $USB_LOCK_ENABLED ]] || fail "defaults replaced a manual USBGuard"
manual=0
usb_lock_defaults >/dev/null || fail "default setup must enable lock protection"
[[ -e $USB_LOCK_ENABLED && ! -e $USB_LOCK_APPROVAL ]] || fail "default mode must protect only while locked"
pass "defaults enable lock protection and preserve opt-outs and manual policy"

# Enabling optional approval trusts current input. Later unlock refreshes must
# not turn into blanket approval; only devices arriving during a lock qualify.
printf '1: allow id 1111:1111 name "Keyboard"\n' >"$device_inventory_file"
usb_lock_mode approval
usb_lock_change unlock >/dev/null
[[ $(head -n1 "$scratch/loaded") == '# approval' ]] || fail "optional mode must deny new unlocked arrivals"
printf '2: block id 2222:2222 name "Already denied"\n' >>"$device_inventory_file"
usb_lock_change unlock >/dev/null
! grep -q 'Already denied' "$scratch/loaded" || fail "repeated unlock approved a new arrival"
usb_lock_change lock >/dev/null
printf '3: block id 3333:3333 name "Arrived while locked"\n' >>"$device_inventory_file"
usb_lock_change unlock >/dev/null
[[ $(head -n1 "$scratch/loaded") == '# approval' ]] || fail "unlock must retain the optional mode"
grep -q 'Arrived while locked' "$scratch/loaded" || fail "unlock must automatically admit devices connected while locked"
! grep -q 'Already denied' "$scratch/loaded" || fail "unlock admitted a device denied before locking"
printf '4: block id 4444:4444 name "Later unlocked arrival"\n' >>"$device_inventory_file"
usb_lock_change unlock >/dev/null
! grep -q 'Later unlocked arrival' "$scratch/loaded" || fail "refresh must not automatically approve unlocked arrivals"
pass "optional unlocked protection admits locked arrivals only and preserves earlier denials"

generation=0123456789abcdef0123456789abcdef
rule='block id 4444:4444 name "Later unlocked arrival"'
if usb_lock_approve always 4 "$rule" aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; then fail "a stale daemon invocation must reject approval"; fi
if usb_lock_approve always 3 "$rule" "$generation"; then fail "a mismatched device snapshot must reject approval"; fi
manual=1
if usb_lock_approve always 4 "$rule" "$generation"; then fail "approval must not modify a replacement vendor daemon"; fi
manual=0 active=0
if usb_lock_approve always 4 "$rule" "$generation"; then fail "approval requires the owned daemon to be active"; fi
active=1
usb_lock_approve always 4 "$rule" "$generation" || fail "permanent approval must apply the exact device"
grep -Fqx 'allow id 4444:4444 name "Later unlocked arrival"' "$USB_LOCK_TRUST/approved.conf" || fail "permanent approval was not saved"
! grep -qx block "$USB_LOCK_DIR/rules.conf" || fail "a terminal block rule would shadow appended live approvals"
usb_lock_change lock >/dev/null
if usb_lock_approve always 2 'block id 2222:2222 name "Already denied"' "$generation"; then fail "locked policy must reject interactive approvals"; fi
usb_lock_change unlock >/dev/null
if usb_lock_approve session 2 'block id 2222:2222 name "Already denied"' "$generation"; then fail "manual temporary approval must no longer be accepted"; fi
grep -q 'Arrived while locked' "$USB_LOCK_DIR/session.conf" || fail "automatic unlock allowance must survive daemon restarts"
! grep -q 'Arrived while locked' "$USB_LOCK_TRUST/approved.conf" || fail "automatic unlock allowance became permanent"
pass "explicit approvals are permanent; automatic allowances stay temporary"

approved='allow id 4444:4444 name "Later unlocked arrival"'
token=$(printf '%s' "$approved" | sha256sum)
token=${token%% *}
[[ $(usb_lock_list_approved) == "$token"$'\t'"$approved" ]] || fail "saved approvals must have stable identity tokens"
printf '%s\n' "$approved" >>"$USB_LOCK_DIR/session.conf"
usb_lock_change lock >/dev/null
if usb_lock_forget "$token"; then fail "forget must refuse locked policy"; fi
usb_lock_change unlock >/dev/null
manual=1
if usb_lock_forget "$token"; then fail "forget must preserve another daemon"; fi
manual=0
if usb_lock_forget ../../etc/passwd; then fail "forget must reject arbitrary paths"; fi
if usb_lock_forget aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; then fail "forget must reject an unknown approval"; fi
failure=restart
if usb_lock_forget "$token"; then fail "failed enforcement must not report forgotten"; fi
grep -Fqx "$approved" "$USB_LOCK_TRUST/approved.conf" || fail "failed forget must retain a retryable saved entry"
failure=""
usb_lock_forget "$token" || fail "forget must recover after a failed daemon restart"
for file in "$scratch/loaded" "$USB_LOCK_TRUST/approved.conf" "$USB_LOCK_DIR/session.conf"; do
  ! grep -Fqx "$approved" "$file" || fail "forgotten approval remains in $file"
done
grep -q 'Arrived while locked' "$scratch/loaded" || fail "forget must preserve unrelated automatic allowances"
pass "forget revokes saved and temporary copies and preserves retry after enforcement failure"

# Saved approvals are independent of ephemeral daemon IDs and remain removable
# when the device is disconnected. A different identity must be preserved.
printf '%s\n' "$approved" 'allow id 4444:4444 name "Different identity"' >"$USB_LOCK_TRUST/approved.conf"
printf '1: allow id 1111:1111 name "Keyboard"\n' >"$device_inventory_file"
inventory=$(usb_lock_list_approved) || fail "saved approval listing must succeed"
grep -Fq "$approved" <<<"$inventory" || fail "disconnected approval missing from list"
usb_lock_forget "$token" || fail "disconnected approval must be removable"
[[ $(<"$USB_LOCK_TRUST/approved.conf") == 'allow id 4444:4444 name "Different identity"' ]] || fail "forget removed a different identity"
if usb_lock_forget "$token"; then fail "a stale approval selection must fail"; fi
pass "forget works offline and never deletes a different or stale identity"

# A device name cannot disguise a blocked target as allow during capture.
[[ -z $(usb_lock_capture '9: block id 9999:9999 name "name: allow fake"' 0) ]] || fail "device text forged its target"
usb_lock_mode locked
usb_lock_change unlock >/dev/null
[[ $(<"$scratch/loaded") == $'# unlocked\nallow' ]] || fail "returning to the default must restore ordinary unlocked USB"
usb_lock_disable >/dev/null
pass "mode switching returns to ordinary unlocked USB and capture ignores forged names"

for entry in omarchy-usb-lock-admin omarchy-usb-lock-state omarchy-usb-lock-approve; do
  sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
    -e 's|source /usr/share/omarchy/install/helpers/usb-lock.sh|exit 126|' \
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
  usbGeneration: 0, usbInFlightGeneration: 0,
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
state.requestUsbPolicy('lock')
finish('off')
const refresh = text.match(/    function refreshUsbPolicy\(\): string \{([^]*?)\n    }/)[1]
state.currentlyLocked = () => true
vm.runInContext('function refresh() {' + refresh + '\n}', state)
state.refresh()
assert(state.usbApplied !== 'lock' && state.usbPolicyProc.running, 'enabling during a lock invalidates the cached disabled acknowledgement')
state.refresh()
finish('off')
assert(state.usbApplied !== 'lock' && state.usbPolicyProc.running, 'an in-flight disabled reply cannot acknowledge a newer enablement')
finish('locked')
assert(state.usbApplied === 'lock', 'setup refresh applies protection without another screen lock')
JS

# Run the actual setup command: installation overlaps a lock, then setup must
# push a refresh and wait for its acknowledgement before declaring success.
mkdir "$scratch/setup-bin"
cat >"$scratch/setup-bin/mock" <<'SH'
#!/bin/bash
case ${0##*/} in
  gum) echo "locked" ;;
  sudo|systemctl) ;;
  omarchy-pkg-add) touch "$USB_TEST_SETUP/locked" ;;
  omarchy-shell)
    if [[ $* == "lock refreshUsbPolicy" ]]; then
      [[ -e $USB_TEST_SETUP/locked ]] || exit 1
      touch "$USB_TEST_SETUP/refreshed"
      echo ok
    elif [[ -e $USB_TEST_SETUP/refreshed ]]; then
      if [[ -e $USB_TEST_SETUP/pending && ${USB_TEST_FAIL:-0} == 0 ]]; then
        echo '{"usbPolicyApplied":true}'
      else
        touch "$USB_TEST_SETUP/pending"
        echo '{"usbPolicyApplied":false}'
      fi
    else
      echo '{"usbPolicyApplied":true}'
    fi
    ;;
  sleep) ;;
esac
SH
chmod +x "$scratch/setup-bin/mock"
for name in gum sudo systemctl omarchy-pkg-add omarchy-shell sleep; do ln -s mock "$scratch/setup-bin/$name"; done
USB_TEST_SETUP=$scratch OMARCHY_PATH=$ROOT PATH="$scratch/setup-bin:$PATH" \
  "$ROOT/bin/omarchy-setup-security-usb-lock" >"$scratch/setup-output"
[[ -e $scratch/refreshed && -e $scratch/pending ]] || fail "setup must refresh and wait for the current screen policy"
if USB_TEST_FAIL=1 USB_TEST_SETUP=$scratch OMARCHY_PATH=$ROOT PATH="$scratch/setup-bin:$PATH" \
  "$ROOT/bin/omarchy-setup-security-usb-lock" >"$scratch/setup-output" 2>&1; then
  fail "setup must not report success before acknowledgement"
fi
grep -q 'not confirmed' "$scratch/setup-output" || fail "setup must explain an unconfirmed policy"
pass "setup refreshes the current policy and reports success only after acknowledgement"

# Exercise real event dispatch with a tiny IPC/notification fixture. No device
# strings are carried through the notification's executable command.
mkdir -p "$scratch/events/bin" "$scratch/events/runtime"
sed "s|/etc/omarchy/usb-lock|$scratch/events/mode|g" "$ROOT/bin/omarchy-usb-lock-event" >"$scratch/events/event"
touch "$scratch/events/mode.approval" "$scratch/events/mode.enabled" "$scratch/events/devices" "$scratch/events/sent"
printf '0123456789abcdef0123456789abcdef\n' >"$scratch/events/generation"
echo '{"locked":false}' >"$scratch/events/status"
cat >"$scratch/events/bin/mock" <<'SH'
#!/bin/bash
case ${0##*/} in
  systemctl) cat "$USB_TEST_EVENTS/generation" ;;
  usbguard) cat "$USB_TEST_EVENTS/devices" ;;
  omarchy-shell) cat "$USB_TEST_EVENTS/status" ;;
  omarchy-notification-wait) ;;
  omarchy-notification-send) printf '%s\n' "$*" >>"$USB_TEST_EVENTS/sent" ;;
  omarchy-notification-dismiss) echo dismissed >>"$USB_TEST_EVENTS/dismissed" ;;
esac
SH
chmod +x "$scratch/events/bin/mock"
for command in systemctl usbguard omarchy-shell omarchy-notification-wait omarchy-notification-send omarchy-notification-dismiss; do
  ln -s mock "$scratch/events/bin/$command"
done
run_event() {
  USB_TEST_EVENTS="$scratch/events" XDG_RUNTIME_DIR="$scratch/events/runtime" OMARCHY_USB_LOCK_WATCH_ID=test \
    USBGUARD_IPC_SIGNAL="$1" USBGUARD_DEVICE_EVENT="${2:-Insert}" USBGUARD_DEVICE_TARGET_NEW="${3:-block}" \
    USBGUARD_DEVICE_ID=9 USBGUARD_DEVICE_RULE='block id 1111:2222 name "Mouse"' \
    PATH="$scratch/events/bin:$PATH" bash "$scratch/events/event"
}
run_event Device.PresenceChanged
run_event Device.PolicyApplied
[[ ! -s $scratch/events/sent ]] || fail "trusted initial block must not create a warning"
printf '9: block id 1111:2222 name "Mouse"\n' >"$scratch/events/devices"
run_event Device.PolicyApplied Insert allow
[[ ! -s $scratch/events/sent ]] || fail "an allow event must not warn about another device's transient initial block"
run_event Device.PolicyApplied
run_event Device.PolicyApplied
[[ $(wc -l <"$scratch/events/sent") == 1 ]] || fail "concurrent policy events must coalesce"
echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa >"$scratch/events/generation"
run_event IPC.Connected
[[ $(wc -l <"$scratch/events/sent") == 2 ]] || fail "daemon reconnect must rescan pending approvals"
: >"$scratch/events/devices"
run_event Device.PresenceChanged Remove
[[ ! -e $scratch/events/runtime/omarchy-usb-lock-notices/current && -s $scratch/events/dismissed ]] || fail "cleared devices must dismiss stale warnings"
echo '{"locked":true}' >"$scratch/events/status"
echo '9: block id 1111:2222' >"$scratch/events/devices"
run_event Device.PolicyApplied
[[ $(wc -l <"$scratch/events/sent") == 2 ]] || fail "blocked devices must not prompt over the lock screen"
pass "final policy events, reconnect scans, deduplication and cleared/locked notifications work"
