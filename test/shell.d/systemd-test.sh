#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if grep -rlE '^(Path[A-Za-z]+|DirectoryNotEmpty)=.*/usr/share/omarchy/migrations' "$ROOT/default/systemd/user" >/dev/null 2>&1; then
  fail "a user unit watches the migration directory again; the notifier must stay login-only"
fi
pass "no unit watches the migration directory, so package updates cannot trigger the notifier"

# Hyprland lives in session.slice/wayland-wm@hyprland.desktop.service. Marking
# any ancestor of that as a kill candidate puts the compositor back in the
# victim pool, which is the crash this whole thing exists to prevent.
oomd_slice="$ROOT/default/systemd/user/app.slice.d/10-oomd.conf"
candidates=$(grep -rlE '^ManagedOOM(MemoryPressure|Swap)=kill' "$ROOT/default/systemd" "$ROOT/etc/systemd" 2>/dev/null || true)
[[ $candidates == "$oomd_slice" ]] ||
  fail "systemd-oomd kill candidacy must be set on app.slice and nowhere else: $candidates"
pass "only user app scopes are systemd-oomd kill candidates"

recover="$ROOT/bin/omarchy-system-sddm-recover"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/systemctl-calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$call_log"
if [[ \$1 == "is-active" ]]; then
  [[ \${SDDM_ACTIVE:-1} == "1" ]]
fi
SH

cat >"$mock_bin/loginctl" <<'SH'
#!/bin/bash
if [[ ${LOGINCTL_FAIL:-0} == "1" ]]; then
  exit 1
fi
printf '%s' "${LOGINCTL_SESSIONS:-}"
SH

chmod +x "$mock_bin/systemctl" "$mock_bin/loginctl"

run_recover() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" "$@" "$recover"
}

run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS=""
grep -Fxq "restart --no-block sddm.service" "$call_log" ||
  fail "active SDDM with no sessions restarts SDDM" "$(<"$call_log")"
pass "active SDDM with no sessions restarts SDDM"

seatless=$'4 1000 viktor - 2199 manager - no -\n'
run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS="$seatless"
grep -Fxq "restart --no-block sddm.service" "$call_log" ||
  fail "seatless background sessions do not block SDDM recovery" "$(<"$call_log")"
pass "seatless background sessions do not block SDDM recovery"

seat_session=$'3 1000 viktor seat0 1234 user tty1 no -\n4 1000 viktor - 2199 manager - no -\n'
run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS="$seat_session"
if grep -q "restart" "$call_log"; then
  fail "local seat session skips SDDM restart" "$(<"$call_log")"
fi
pass "local seat session skips SDDM restart"

run_recover env SDDM_ACTIVE=0 LOGINCTL_SESSIONS=""
if grep -q "restart" "$call_log"; then
  fail "inactive SDDM is left alone" "$(<"$call_log")"
fi
pass "inactive SDDM is left alone"

run_recover env SDDM_ACTIVE=1 LOGINCTL_FAIL=1
if grep -q "restart" "$call_log"; then
  fail "failed loginctl query fails closed without restarting SDDM" "$(<"$call_log")"
fi
pass "failed loginctl query fails closed without restarting SDDM"

wait_drm_src="$ROOT/bin/omarchy-system-sddm-wait-drm"
wait_drm="$tmpdir/omarchy-system-sddm-wait-drm"
simplefb_dir="$tmpdir/simple-framebuffer"
dri_dir="$tmpdir/dri"
udev_log="$tmpdir/udevadm-calls"
udev_on_removed="$tmpdir/udev-on-removed"
udev_on_monitor="$tmpdir/udev-on-monitor"

sed \
  -e "s|^SIMPLEFB_DIR=.*|SIMPLEFB_DIR=$simplefb_dir|" \
  -e "s|^DRI_DIR=.*|DRI_DIR=$dri_dir|" \
  "$wait_drm_src" >"$wait_drm"
chmod +x "$wait_drm"

cat >"$mock_bin/udevadm" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$UDEV_LOG"
if [[ $1 == "wait" && $* == *" --removed "* && -x ${UDEV_ON_REMOVED:-} ]]; then
  "$UDEV_ON_REMOVED"
fi
if [[ $1 == "monitor" ]]; then
  if [[ -x ${UDEV_ON_MONITOR:-} ]]; then
    "$UDEV_ON_MONITOR"
  fi
  printf 'UDEV - the event which udev sends out after rule processing\n'
fi
SH
chmod +x "$mock_bin/udevadm"

run_wait_drm() {
  local on_removed="${1:-}"
  : >"$udev_log"
  rm -f "$udev_on_removed"
  if [[ -n $on_removed ]]; then
    cat >"$udev_on_removed" <<SH
#!/bin/bash
$on_removed
SH
    chmod +x "$udev_on_removed"
  fi
  PATH="$mock_bin:$PATH" UDEV_LOG="$udev_log" UDEV_ON_REMOVED="$udev_on_removed" UDEV_ON_MONITOR="$udev_on_monitor" "$wait_drm"
}

# Early KMS: no simpledrm bound, waits directly for existing /dev/dri/card0.
rm -rf "$simplefb_dir" "$dri_dir"
mkdir -p "$simplefb_dir" "$dri_dir"
: >"$dri_dir/card0"
run_wait_drm
[[ $(<"$udev_log") == "wait --timeout=10 --initialized=true $dri_dir/card0" ]] ||
  fail "early-KMS boot waits only for /dev/dri/card0" "$(<"$udev_log")"
pass "early-KMS boot waits only for /dev/dri/card0"

# Late KMS: simpledrm bound, then unbound before real card1 is registered.
rm -rf "$simplefb_dir" "$dri_dir"
mkdir -p "$simplefb_dir/simple-framebuffer.0" "$dri_dir"
: >"$dri_dir/card0"
cat >"$udev_on_monitor" <<SH
#!/bin/bash
: >"$dri_dir/card1"
SH
chmod +x "$udev_on_monitor"
run_wait_drm "rm -rf '$simplefb_dir/simple-framebuffer.0' '$dri_dir/card0'"
expected_handoff=$(printf '%s\n%s\n%s' \
  "wait --timeout=5 --removed $simplefb_dir/simple-framebuffer.0" \
  "monitor --udev --subsystem-match=drm" \
  "wait --timeout=10 --initialized=true $dri_dir/card1")
[[ $(<"$udev_log") == "$expected_handoff" ]] ||
  fail "late-KMS handoff waits for simpledrm removal then card1 initialization" "$(<"$udev_log")"
pass "late-KMS handoff waits for simpledrm removal then card1 initialization"

# Mid-handoff: card1 appears after the initial empty scan.
rm -rf "$simplefb_dir" "$dri_dir"
mkdir -p "$simplefb_dir" "$dri_dir"
run_wait_drm
expected_mid_handoff=$(printf '%s\n%s' \
  "monitor --udev --subsystem-match=drm" \
  "wait --timeout=10 --initialized=true $dri_dir/card1")
[[ $(<"$udev_log") == "$expected_mid_handoff" ]] ||
  fail "mid-handoff empty /dev/dri waits for the card that appears" "$(<"$udev_log")"
pass "mid-handoff empty /dev/dri waits for the card that appears"

# Non-card0 device: waits on the existing card1 instead of timing out on card0.
rm -rf "$simplefb_dir" "$dri_dir"
mkdir -p "$simplefb_dir" "$dri_dir"
: >"$dri_dir/card1"
run_wait_drm
[[ $(<"$udev_log") == "wait --timeout=10 --initialized=true $dri_dir/card1" ]] ||
  fail "waits on existing card1 when card0 is absent" "$(<"$udev_log")"
pass "waits on existing card1 when card0 is absent"

wait_soundwire="$ROOT/bin/omarchy-hw-wait-soundwire"
sdw_dir="$tmpdir/soundwire"
sleep_log="$tmpdir/sleep-calls"

cat >"$mock_bin/sleep" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$sleep_log"
/usr/bin/sleep "\$@"
SH
chmod +x "$mock_bin/sleep"

make_sdw_device() {
  local name="$1" status="$2" dev_num="$3" bound="${4:-1}"
  mkdir -p "$sdw_dir/$name"
  printf '%s\n' "$status" >"$sdw_dir/$name/status"
  printf '%s\n' "$dev_num" >"$sdw_dir/$name/device_number"
  if (( bound )); then
    mkdir -p "$sdw_dir/$name/driver"
  else
    rm -rf "$sdw_dir/$name/driver"
  fi
}

: >"$sleep_log"
PATH="$mock_bin:$PATH" OMARCHY_SOUNDWIRE_DEVICES_PATH="$tmpdir/no-soundwire" OMARCHY_SOUNDWIRE_TRIES=5 OMARCHY_SOUNDWIRE_DELAY=0.01 "$wait_soundwire"
[[ ! -s $sleep_log ]] || fail "missing SoundWire bus exits without waiting" "$(<"$sleep_log")"
pass "missing SoundWire bus exits without waiting"

rm -rf "$sdw_dir"
make_sdw_device "sdw:0:0:025d:1321:01:0" "Unattached" "0" 0
: >"$sleep_log"
PATH="$mock_bin:$PATH" OMARCHY_SOUNDWIRE_DEVICES_PATH="$sdw_dir" OMARCHY_SOUNDWIRE_TRIES=5 OMARCHY_SOUNDWIRE_DELAY=0.01 "$wait_soundwire"
[[ ! -s $sleep_log ]] || fail "unbound SoundWire peripheral is skipped without waiting" "$(<"$sleep_log")"
pass "unbound SoundWire peripheral is skipped without waiting"

rm -rf "$sdw_dir"
make_sdw_device "sdw:0:0:025d:1321:01:0" "Attached" "2" 1
make_sdw_device "sdw:0:1:025d:0713:01" "Alert" "1" 1
: >"$sleep_log"
PATH="$mock_bin:$PATH" OMARCHY_SOUNDWIRE_DEVICES_PATH="$sdw_dir" OMARCHY_SOUNDWIRE_TRIES=5 OMARCHY_SOUNDWIRE_DELAY=0.01 "$wait_soundwire"
[[ ! -s $sleep_log ]] || fail "attached and alerting SoundWire peripherals with device numbers return immediately" "$(<"$sleep_log")"
pass "attached and alerting SoundWire peripherals with device numbers return immediately"

rm -rf "$sdw_dir"
make_sdw_device "sdw:0:0:025d:1321:01:1" "Attached" "1" 1
make_sdw_device "sdw:0:0:025d:1321:01:0" "Unattached" "0" 1
: >"$sleep_log"
(
  /usr/bin/sleep 0.05
  printf 'Attached\n' >"$sdw_dir/sdw:0:0:025d:1321:01:0/status"
  printf '2\n' >"$sdw_dir/sdw:0:0:025d:1321:01:0/device_number"
) &
updater_pid=$!
PATH="$mock_bin:$PATH" OMARCHY_SOUNDWIRE_DEVICES_PATH="$sdw_dir" OMARCHY_SOUNDWIRE_TRIES=50 OMARCHY_SOUNDWIRE_DELAY=0.01 "$wait_soundwire"
wait "$updater_pid"
sleeps=$(wc -l <"$sleep_log")
(( sleeps > 0 && sleeps < 49 )) || fail "waits for unattached SoundWire peripheral to enumerate and stops once ready" "sleeps=$sleeps"
pass "waits for unattached SoundWire peripheral to enumerate and stops once ready"

rm -rf "$sdw_dir"
make_sdw_device "sdw:0:0:025d:1321:01:0" "Attached" "0" 1
: >"$sleep_log"
PATH="$mock_bin:$PATH" OMARCHY_SOUNDWIRE_DEVICES_PATH="$sdw_dir" OMARCHY_SOUNDWIRE_TRIES=4 OMARCHY_SOUNDWIRE_DELAY=0.01 "$wait_soundwire"
sleeps=$(wc -l <"$sleep_log")
(( sleeps == 3 )) || fail "attached peripheral without a device number times out cleanly" "sleeps=$sleeps"
pass "attached peripheral without a device number times out cleanly"
