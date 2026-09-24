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
exec "$@"
STUB

cat >"$tmp_dir/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$STUB_CALLS"
[[ $1 == "restart" && $STUB_CONTROLLER_AFTER == "restart" ]] && touch "$STUB_STATE/controller"
exit 0
STUB

cat >"$tmp_dir/bin/modprobe" <<'STUB'
#!/bin/bash
printf 'modprobe %s\n' "$*" >>"$STUB_CALLS"
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
if [[ $1 == "list" && -f $STUB_STATE/controller ]]; then
  echo "Controller AA:BB:CC:DD:EE:FF omarchy [default]"
fi
exit 0
STUB

# Keep the polling loops from spending their real budget, and let the timeout
# guard around bluetoothctl resolve to the stub instead of the real binary.
cat >"$tmp_dir/bin/sleep" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$tmp_dir/bin/timeout" <<'STUB'
#!/bin/bash
shift
exec "$@"
STUB

chmod +x "$tmp_dir"/bin/*

run_restart_bluetooth() {
  STUB_STATE="$tmp_dir/state" \
    STUB_CALLS="$tmp_dir/calls" \
    STUB_CONTROLLER_AFTER="$1" \
    STUB_BTUSB_LOADED="${2:-yes}" \
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

# A firmware handshake that timed out leaves an hci device BlueZ will not adopt.
# Only a driver reload re-runs the upload, so the daemon restart has to escalate.
reset_stubs
run_restart_bluetooth btusb >/dev/null
grep -qx 'modprobe -r btusb' "$tmp_dir/calls" || fail "restart bluetooth reloads btusb when no controller answers"
grep -qx 'modprobe btusb' "$tmp_dir/calls" || fail "restart bluetooth loads btusb back after unloading it"
pass "restart bluetooth reloads btusb when no controller answers"

# An unload that fails on a busy module must not take the load with it.
reset_stubs
run_restart_bluetooth btusb >/dev/null
unload_line=$(grep -n '^modprobe -r btusb$' "$tmp_dir/calls" | cut -d: -f1)
load_line=$(grep -n '^modprobe btusb$' "$tmp_dir/calls" | cut -d: -f1)
(( unload_line < load_line )) || fail "restart bluetooth loads btusb back after the unload"
pass "restart bluetooth loads btusb back after the unload"

# Nothing to reload on an adapter that is not a USB one.
reset_stubs
run_restart_bluetooth never no >/dev/null 2>&1 && fail "restart bluetooth reports a controller it never recovered"
grep -q '^modprobe' "$tmp_dir/calls" && fail "restart bluetooth only reloads btusb when btusb is loaded"
pass "restart bluetooth only reloads btusb when btusb is loaded"

# A dead adapter has to stay visibly dead; the menu action must not claim success.
reset_stubs
status_output=$(run_restart_bluetooth never 2>&1) && fail "restart bluetooth fails when no controller comes back"
grep -q 'No Bluetooth controller is available' <<<"$status_output" || fail "restart bluetooth explains an adapter that stayed wedged"
pass "restart bluetooth fails when no controller comes back"
