#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

cat >"$tmp_dir/bin/rfkill" <<'STUB'
#!/bin/bash
printf 'rfkill %s\n' "$*" >>"$STUB_CALLS"
STUB

cat >"$tmp_dir/bin/sudo" <<'STUB'
#!/bin/bash
[[ $STUB_SUDO_FAILS == "yes" ]] && exit 1
exec "$@"
STUB

cat >"$tmp_dir/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$STUB_CALLS"

if [[ $1 == "is-active" ]]; then
  [[ $STUB_DAEMON_ACTIVE == "yes" ]] && exit 0
  exit 3
fi

[[ $1 == "restart" && $STUB_CONTROLLER_AFTER == "restart" ]] && touch "$STUB_STATE/controller"
exit 0
STUB

cat >"$tmp_dir/bin/modprobe" <<'STUB'
#!/bin/bash
printf 'modprobe %s\n' "$*" >>"$STUB_CALLS"

# A busy module keeps btusb loaded, so the unload reports failure and the driver
# never leaves the kernel.
[[ $1 == "-r" && $STUB_UNLOAD_FAILS == "yes" ]] && exit 1

[[ $1 == "btusb" && $STUB_CONTROLLER_AFTER == "btusb" ]] && touch "$STUB_STATE/controller"
exit 0
STUB

cat >"$tmp_dir/bin/lsmod" <<'STUB'
#!/bin/bash
[[ $STUB_BTUSB_LOADED == "yes" ]] && echo "btusb                  73728  0"
exit 0
STUB

cat >"$tmp_dir/bin/bluetoothctl" <<'STUB'
#!/bin/bash
printf 'bluetoothctl %s\n' "$*" >>"$STUB_CALLS"
if [[ $1 == "list" && -f $STUB_STATE/controller ]]; then
  echo "Controller AA:BB:CC:DD:EE:FF omarchy [default]"
fi
exit 0
STUB

chmod +x "$tmp_dir"/bin/*

# The waits are driven down to a second so the expiry paths stay cheap; the
# script's own defaults are what ship.
run_restart_bluetooth() {
  STUB_STATE="$tmp_dir/state" \
    STUB_CALLS="$tmp_dir/calls" \
    STUB_CONTROLLER_AFTER="$1" \
    STUB_BTUSB_LOADED="${2:-yes}" \
    STUB_DAEMON_ACTIVE="${3:-yes}" \
    STUB_SUDO_FAILS="${4:-no}" \
    STUB_UNLOAD_FAILS="${5:-no}" \
    OMARCHY_BLUETOOTH_RESTART_WAIT=1 \
    OMARCHY_BLUETOOTH_RELOAD_WAIT=1 \
    PATH="$tmp_dir/bin:$PATH" \
    "$ROOT/bin/omarchy-restart-bluetooth"
}

reset_stubs() {
  rm -rf "$tmp_dir/state"
  mkdir -p "$tmp_dir/state"
  : >"$tmp_dir/calls"
}

# The script's summary has always promised a restart, but it only ran rfkill:
# a desynced bluetoothd stayed desynced and the menu's recovery action was a
# no-op.
reset_stubs
run_restart_bluetooth restart >/dev/null
grep -qx 'rfkill unblock bluetooth' "$tmp_dir/calls" || fail "restart bluetooth unblocks the rfkill soft block"
pass "restart bluetooth unblocks the rfkill soft block"

grep -qx 'systemctl restart bluetooth.service' "$tmp_dir/calls" || fail "restart bluetooth restarts bluetooth.service"
pass "restart bluetooth restarts bluetooth.service"

grep -q '^modprobe' "$tmp_dir/calls" && fail "restart bluetooth leaves btusb alone once a controller answers"
pass "restart bluetooth leaves btusb alone once a controller answers"

# A restart the user cancelled at the password prompt must not be reported as a
# recovery, however healthy the adapter already looked.
reset_stubs
touch "$tmp_dir/state/controller"
output=$(run_restart_bluetooth restart yes yes yes 2>&1) && fail "restart bluetooth fails when the service restart fails"
grep -q 'Could not restart bluetooth.service' <<<"$output" || fail "restart bluetooth explains a restart it could not run"
pass "restart bluetooth fails when the service restart fails"

grep -q '^modprobe' "$tmp_dir/calls" && fail "restart bluetooth stops before btusb when the restart failed"
pass "restart bluetooth stops before btusb when the restart failed"

# bluetooth.service carries ConditionPathIsDirectory=/sys/class/bluetooth, so a
# machine with no stack takes a clean exit from the restart. Waiting on a daemon
# that was never started would spend the whole budget printing nothing.
reset_stubs
output=$(run_restart_bluetooth never yes no 2>&1) && fail "restart bluetooth fails when the daemon did not start"
grep -q 'bluetooth.service is not running' <<<"$output" || fail "restart bluetooth explains a daemon that did not start"
grep -q '^bluetoothctl' "$tmp_dir/calls" && fail "restart bluetooth does not poll for a controller without a daemon"
pass "restart bluetooth fails without polling when the daemon did not start"

# A firmware handshake that timed out leaves the controller in HCI_SETUP, hidden
# from bluetoothd. Only a driver reload re-runs the upload.
reset_stubs
run_restart_bluetooth btusb >/dev/null
grep -qx 'modprobe -r btusb' "$tmp_dir/calls" || fail "restart bluetooth reloads btusb when no controller answers"
grep -qx 'modprobe btusb' "$tmp_dir/calls" || fail "restart bluetooth loads btusb back after unloading it"
pass "restart bluetooth reloads btusb when no controller answers"

# An unload that fails leaves btusb loaded, so there is nothing to put back. The
# script has to say that rather than claim a reload it never performed.
reset_stubs
output=$(run_restart_bluetooth never yes yes no yes 2>&1) && true
grep -qx 'modprobe -r btusb' "$tmp_dir/calls" || fail "restart bluetooth attempts the unload"
grep -qx 'modprobe btusb' "$tmp_dir/calls" && fail "restart bluetooth does not load btusb after a failed unload"
grep -q 'Could not unload btusb' <<<"$output" || fail "restart bluetooth reports an unload it could not perform"
pass "restart bluetooth reports a failed unload instead of reloading"

# Nothing to reload on an adapter that is not a USB one.
reset_stubs
run_restart_bluetooth never no >/dev/null 2>&1 && fail "restart bluetooth reports a controller it never recovered"
grep -q '^modprobe' "$tmp_dir/calls" && fail "restart bluetooth only reloads btusb when btusb is loaded"
pass "restart bluetooth only reloads btusb when btusb is loaded"

# A dead adapter has to stay visibly dead; the menu action must not claim success.
reset_stubs
status_output=$(run_restart_bluetooth never 2>&1) && fail "restart bluetooth fails when no controller comes back"
grep -q 'No Bluetooth controller is available' <<<"$status_output" || fail "restart bluetooth explains an adapter that stayed wedged"
grep -q 'journalctl -b -k' <<<"$status_output" || fail "restart bluetooth points at the kernel log, where adapter firmware errors land"
pass "restart bluetooth fails when no controller comes back"
