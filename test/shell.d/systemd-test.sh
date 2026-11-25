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
