#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-t2-bcm4377.sh"
fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789234234.sh"
rebind="$ROOT/bin/omarchy-t2-bcm4377-rebind"
suspend="$ROOT/bin/omarchy-t2-bcm4377-suspend"
rebind_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-rebind.service"
suspend_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-suspend.service"

grep -q 'apple/fix-t2-bcm4377.sh' "$all" ||
  fail "the BCM4377 workaround runs during hardware setup"
! grep -q 'omarchy-t2-bcm4377' "$fix_t2" ||
  fail "only the BCM4377 leaf owns the combo-chip units"
grep -q 'Class: 0x00000000' "$rebind" ||
  fail "the rebind treats an unset adapter class as hung"
grep -q 'WantedBy=sleep.target' "$suspend_unit" ||
  fail "suspend unload is a sleep.target unit, not a systemd-sleep hook"
grep -q 'Before=sleep.target' "$suspend_unit" ||
  fail "suspend unload runs before sleep.target"
grep -q 'omarchy-t2-bcm4377-rebind.service' "$suspend" ||
  fail "resume reloads Bluetooth through the rebind unit"
pass "BCM4377 setup is a dedicated leaf with a class-aware rebind"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
systemd_dir="$test_tmp/systemd"
sleep_hook="$test_tmp/system-sleep/t2-wifi-suspend"
mkdir -p "$stub_bin" "$test_tmp/system-sleep"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
if [[ -n ${BT_ID:-} ]]; then
  echo "03:00.1 Network controller [0280]: Broadcom Inc. Bluetooth [14e4:$BT_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
case "$1" in
  is-system-running) exit 1 ;;
esac
exit 0
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local wifi_id="${1:-}" bt_id="${2:-}" t2="${3:-0}"
  rm -rf "$systemd_dir"
  mkdir -p "$systemd_dir" "$(dirname "$sleep_hook")"
  printf 'legacy-hook\n' >"$sleep_hook"
  : >"$calls"

  WIFI_ID="$wifi_id" BT_ID="$bt_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_T2_BCM4377_SYSTEMD_DIR="$systemd_dir" \
    OMARCHY_T2_BCM4377_SLEEP_HOOK="$sleep_hook" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf 4488 5fa0 1 >/dev/null
[[ -f $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "a BCM4377 machine gets the rebind unit"
[[ -f $systemd_dir/omarchy-t2-bcm4377-suspend.service ]] ||
  fail "a BCM4377 machine gets the suspend unit"
cmp -s "$rebind_unit" "$systemd_dir/omarchy-t2-bcm4377-rebind.service" ||
  fail "the installed rebind unit matches the packaged file"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "the rebind unit is enabled" "$(cat "$calls")"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-suspend.service' "$calls" ||
  fail "the suspend unit is enabled" "$(cat "$calls")"
grep -Fq $'systemctl\tdisable\t--now\tt2-brcmfmac-suspend.service' "$calls" ||
  fail "leftover community suspend units are disabled" "$(cat "$calls")"
grep -Fq $'systemctl\tdisable\t--now\tbt-bcm4377-rebind.service' "$calls" ||
  fail "leftover community rebind units are disabled" "$(cat "$calls")"
[[ ! -e $sleep_hook ]] || fail "the leftover systemd-sleep hook is removed"
! grep -Fq $'systemctl\tstart\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "ISO/chroot setup does not start the rebind oneshot" "$(cat "$calls")"
pass "a BCM4377 machine gets the units and leftover workarounds are retired"

run_leaf 4464 "" 1 >/dev/null
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "a T2 Mac without BCM4377 is left alone"
[[ ! -s $calls ]] || fail "a T2 Mac without BCM4377 escalates nothing" "$(cat "$calls")"
pass "a T2 Mac without BCM4377 is left alone"

run_leaf "" "" 0 >/dev/null
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-suspend.service ]] ||
  fail "unrelated hardware is left alone"
pass "unrelated hardware is left alone"

run_migration() {
  local wifi_id="${1:-}" bt_id="${2:-}" t2="${3:-0}"
  rm -rf "$systemd_dir"
  mkdir -p "$systemd_dir" "$(dirname "$sleep_hook")"
  printf 'legacy-hook\n' >"$sleep_hook"
  : >"$calls"

  WIFI_ID="$wifi_id" BT_ID="$bt_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_T2_BCM4377_SYSTEMD_DIR="$systemd_dir" \
    OMARCHY_T2_BCM4377_SLEEP_HOOK="$sleep_hook" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration 4488 5fa0 1
[[ -f $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "the migration installs the rebind unit on existing BCM4377 installs"
grep -Fq $'sudo\tenv' "$calls" ||
  fail "the migration escalates to install machine-wide units" "$(cat "$calls")"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-suspend.service' "$calls" ||
  fail "the migration enables the suspend unit" "$(cat "$calls")"
[[ ! -e $sleep_hook ]] || fail "the migration removes the leftover sleep hook"
pass "the migration repairs an existing BCM4377 install"

run_migration 4464 "" 1
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "the migration skips T2 Macs without BCM4377"
[[ ! -s $calls ]] || fail "the migration escalates nothing on other T2 chips" "$(cat "$calls")"
pass "the migration skips T2 Macs without BCM4377"
