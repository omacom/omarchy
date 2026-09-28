#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
instance_dir="$runtime_dir/hypr/test-instance"
hyprctl_log="$test_tmp/hyprctl.log"
udevadm_log="$test_tmp/udevadm.log"
mkdir -p "$fake_bin" "$instance_dir"

cat >"$fake_bin/omarchy-hw-vmware" <<'SH'
#!/bin/bash

[[ ${OMARCHY_TEST_VMWARE:-1} == "1" ]]
SH

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"
SH

# A resize of the VMware window lands as a burst of hotplugs; a lone push
# lands as one. Real udevadm leads with a two-line banner and a blank line.
# The daemon restarts udevadm when it ends while the compositor is still
# there, so the second run stands in for the compositor going away: it takes
# the socket with it and prints nothing.
cat >"$fake_bin/udevadm" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_UDEVADM_LOG"
if (( $(grep -c . "$OMARCHY_TEST_UDEVADM_LOG") > 1 )); then
  rm -f "$OMARCHY_TEST_SOCKET"
  exit 0
fi
printf 'monitor will print the received events for:\n'
printf 'UDEV - the event which udev sends out after rule processing\n'
printf '\n'
for i in 1 2 3; do
  printf 'UDEV  [1000.00000%s] change   /devices/pci0000:00/0000:00:0f.0/drm/card0 (drm)\n' "$i"
done
sleep 0.6
printf 'UDEV  [1001.000001] change   /devices/pci0000:00/0000:00:0f.0/drm/card0 (drm)\n'
SH

# The restart is announced through the journal; keep it out of the real one.
cat >"$fake_bin/logger" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_LOGGER_LOG"
SH

chmod +x "$fake_bin"/*
logger_log="$test_tmp/logger.log"

# The daemon checks the socket is a socket, not merely a file.
bind_socket() {
  rm -f "$instance_dir/.socket.sock"
  python3 -c 'import socket,sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$instance_dir/.socket.sock"
}

run_sync() {
  : >"$hyprctl_log"
  : >"$udevadm_log"
  : >"$logger_log"
  PATH="$fake_bin:$PATH" \
  OMARCHY_TEST_SOCKET="$instance_dir/.socket.sock" \
  OMARCHY_TEST_LOGGER_LOG="$logger_log" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  HYPRLAND_INSTANCE_SIGNATURE=test-instance \
  OMARCHY_TEST_HYPRCTL_LOG="$hyprctl_log" \
  OMARCHY_TEST_UDEVADM_LOG="$udevadm_log" \
  OMARCHY_TEST_VMWARE="${1:-1}" \
    timeout 10 "$ROOT/bin/omarchy-hyprland-monitor-vmware-sync"
}

bind_socket
status=0
run_sync || status=$?
(( status == 0 )) || fail "the daemon exits cleanly when the hotplug stream ends" "exit $status"
pass "the daemon exits cleanly when the hotplug stream ends"

[[ $(<"$udevadm_log") == $'monitor -u -s drm\nmonitor -u -s drm' ]] || fail "DRM hotplugs are watched on the udev side" "$(<"$udevadm_log")"
pass "DRM hotplugs are watched on the udev side"

grep -q "udevadm monitor ended" "$logger_log" || fail "a udevadm that ends is restarted and logged" "$(<"$logger_log")"
pass "a udevadm that ends while the compositor lives is restarted and logged"

# One resync at start for anything pushed since the config loaded, one for the
# burst once it settled, one for the lone push, and nothing else.
expected=$(printf '%s\n' \
  "eval o.vmware_layout.sync()" \
  "eval o.vmware_layout.sync()" \
  "eval o.vmware_layout.sync()")
[[ $(<"$hyprctl_log") == "$expected" ]] || fail "a burst of hotplugs is settled into one resync" "$(<"$hyprctl_log")"
pass "a burst of hotplugs is settled into one resync"

# The compositor it was started for is gone; whatever instance comes next is
# not its business.
rm -f "$instance_dir/.socket.sock"
status=0
run_sync || status=$?
(( status == 0 )) || fail "the daemon exits cleanly without its compositor" "exit $status"
[[ ! -s $hyprctl_log ]] || fail "a daemon without its compositor pokes nothing" "$(<"$hyprctl_log")"
pass "a daemon without its compositor exits without poking anything"

# Not a VMware guest: nothing to watch.
bind_socket
status=0
run_sync 0 || status=$?
(( status == 0 )) || fail "the daemon exits cleanly off VMware" "exit $status"
[[ ! -s $udevadm_log && ! -s $hyprctl_log ]] || fail "off VMware nothing is watched or poked" "$(cat "$udevadm_log" "$hyprctl_log")"
pass "off VMware the daemon exits without watching or poking anything"
