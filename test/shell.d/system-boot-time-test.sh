#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
notify_args="$test_tmp/notify-args"
state_file="$test_home/.local/state/omarchy/boot-time"
real_boot_id=$(</proc/sys/kernel/random/boot_id)
mkdir -p "$stub_bin" "$test_home"

# The figures from one real EFI boot: 26.86s before the kernel (of which 7.89s
# in the loader), userspace at 11.58s, systemd finished at 16.03s.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
case "$*" in
  *FirmwareTimestampMonotonic*) echo 26859570 ;;
  *LoaderTimestampMonotonic*) echo 7888987 ;;
  *UserspaceTimestampMonotonic*) echo 11583406 ;;
  *FinishTimestampMonotonic*) echo 16029129 ;;
  *) echo 0 ;;
esac
SH

cat >"$stub_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFY_ARGS"
SH
chmod +x "$stub_bin"/*

run_boot_time() {
  HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_NOTIFY_ARGS="$notify_args" \
    "$ROOT/bin/omarchy-system-boot-time" "$@"
}

write_state() {
  mkdir -p "$(dirname "$state_file")"
  cat >"$state_file" <<STATE
boot_id=$1
firmware_us=26859570
loader_us=7888987
userspace_us=11583406
finish_us=16029129
desktop_uptime=18.14
notified=${2:-0}
STATE
}

# --record stamps the current boot once.
rm -f "$state_file"
run_boot_time --record
[[ -f $state_file ]] || fail "record writes the state file"
grep -qx "boot_id=$real_boot_id" "$state_file" || fail "record stores the running kernel's boot id" "$(cat "$state_file")"
grep -qx "firmware_us=26859570" "$state_file" || fail "record stores systemd's firmware timestamp"
grep -qE '^desktop_uptime=[0-9]+(\.[0-9]+)?$' "$state_file" || fail "record stores the desktop uptime as seconds" "$(cat "$state_file")"
pass "record stamps the desktop start for this boot"

sed -i 's/^desktop_uptime=.*/desktop_uptime=18.14/' "$state_file"
run_boot_time --record
grep -qx "desktop_uptime=18.14" "$state_file" || fail "a second record in the same boot keeps the first stamp" "$(cat "$state_file")"
pass "record keeps the first stamp of a boot across later compositor starts"

write_state "00000000-0000-0000-0000-000000000000"
run_boot_time --record
grep -qx "boot_id=$real_boot_id" "$state_file" || fail "record replaces a stamp left by a previous boot" "$(cat "$state_file")"
pass "record replaces the stamp from a previous boot"

# --notify stamps the boot itself when nothing has, so a single autostart line
# is enough and there is no record it could race against.
rm -f "$state_file" "$notify_args"
run_boot_time --notify
grep -qx "boot_id=$real_boot_id" "$state_file" || fail "notify stamps the current boot when no record exists" "$(cat "$state_file")"
grep -qx "notified=1" "$state_file" || fail "notify marks its own stamp as announced" "$(cat "$state_file")"
grep -q "^Time taken to boot: [0-9]*s$" "$notify_args" || fail "notify announces the boot it stamped" "$(cat "$notify_args")"
pass "notify stamps the boot itself when nothing has yet"

# --notify sends the headline and breakdown once for the recorded boot.
write_state "$real_boot_id"
rm -f "$notify_args"
run_boot_time --notify
[[ -s $notify_args ]] || fail "notify sends a notification for a recorded boot"
grep -qx "Time taken to boot: 45s" "$notify_args" || fail "notify headline is the rounded power-on to desktop total" "$(cat "$notify_args")"
grep -qx "firmware 19.0s · loader 7.9s · kernel 11.6s · system 4.4s · desktop 2.1s" "$notify_args" || fail "notify body breaks the total down by phase" "$(cat "$notify_args")"
grep -qx "notified=1" "$state_file" || fail "notify marks the boot as announced" "$(cat "$state_file")"
pass "notify announces the boot time with a per-phase breakdown"

rm -f "$notify_args"
run_boot_time --notify
[[ ! -e $notify_args ]] || fail "a second notify in the same boot stays silent" "$(cat "$notify_args")"
pass "notify shows once per boot"

write_state "00000000-0000-0000-0000-000000000000" 1
rm -f "$notify_args"
run_boot_time --notify
grep -qx "boot_id=$real_boot_id" "$state_file" || fail "notify replaces a stamp from a previous boot" "$(cat "$state_file")"
[[ -s $notify_args ]] || fail "notify announces a new boot over a stale stamp"
pass "notify treats a stamp left by a previous boot as a new boot"

# No arguments prints the same report to the terminal.
write_state "$real_boot_id" 1
output=$(run_boot_time)
[[ $output == "Time taken to boot: 45s"$'\n'* ]] || fail "plain invocation prints the headline" "$output"
pass "plain invocation prints the recorded boot time"

# Without firmware timestamps (BIOS boot, or a loader that passes none) the
# total can only be counted from kernel start, and the headline says so.
sed -i 's/^firmware_us=.*/firmware_us=0/; s/^loader_us=.*/loader_us=0/' "$state_file"
output=$(run_boot_time)
[[ $output == "Time taken to boot: 18s (since kernel start)"$'\n'"kernel 11.6s · system 4.4s · desktop 2.1s" ]] || fail "missing firmware timestamps are reported as counted from kernel start" "$output"
pass "reports from kernel start when firmware timestamps are unavailable"

# With no stamp for this boot the report stops where systemd finished starting.
rm -f "$state_file"
output=$(run_boot_time)
[[ $output == "Time taken to boot: 43s (to system startup; desktop not recorded)"$'\n'"firmware 19.0s · loader 7.9s · kernel 11.6s · system 4.4s" ]] || fail "an unrecorded boot reports up to systemd finish" "$output"
pass "reports to system startup when the desktop start was not recorded"
