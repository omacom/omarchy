#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788906000.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
limine_conf="$test_tmp/macbook-t1.conf"
running_cmdline="$test_tmp/cmdline"
repair_marker="$test_tmp/t1-repair-complete"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo 'limine-mkinitcpio' >>"$TEST_LOG"
SH
chmod +x "$stub_bin"/*

run_migration() {
  PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_T1_LIMINE_CONF="$limine_conf" \
    OMARCHY_T1_RUNNING_CMDLINE="$running_cmdline" \
    OMARCHY_T1_REPAIR_MARKER="$repair_marker" \
    bash -euo pipefail "$migration" >/dev/null
}

cat >"$limine_conf" <<'EOF'
# Generated for an Intel MacBook with a T1 chip
KERNEL_CMDLINE[default]+=" quiet pcie_ports=compat apple_gmux.force_igd=y"
EOF
echo 'quiet pcie_ports=compat apple_gmux.force_igd=y' >"$running_cmdline"

run_migration

grep -Fq 'quiet pm_async=off mem_sleep_default=deep apple_gmux.force_igd=y' "$limine_conf" ||
  fail "T1 migration replaces the obsolete PCIe mode without dropping other parameters"
! grep -q 'pcie_ports=compat' "$limine_conf" ||
  fail "T1 migration removes pcie_ports=compat"
grep -Fxq 'limine-mkinitcpio' "$calls" ||
  fail "T1 migration rebuilds the boot image"
[[ -f $repair_marker ]] || fail "T1 migration records the machine-wide repair"
pass "T1 migration restores native PCIe hotplug defaults"

: >"$calls"
run_migration
[[ ! -s $calls ]] ||
  fail "T1 migration does not repeatedly rebuild before reboot" "$(cat "$calls")"
pass "T1 migration is machine-idempotent before reboot"

rm -f "$repair_marker"
: >"$calls"
run_migration

grep -Fxq 'limine-mkinitcpio' "$calls" ||
  fail "T1 migration retries an interrupted boot image rebuild"
[[ -f $repair_marker ]] || fail "retried T1 repair records completion"
! grep -Eq $'sudo\tsed(\t|$)' "$calls" ||
  fail "T1 rebuild retry leaves the repaired config unchanged" "$(cat "$calls")"
pass "T1 migration retries an interrupted boot image rebuild"

rm -f "$repair_marker" "$limine_conf"
: >"$calls"
run_migration
[[ ! -s $calls ]] ||
  fail "systems without the T1 Limine config are left unchanged" "$(cat "$calls")"
pass "T1 migration skips systems without macbook-t1.conf"

cat >"$limine_conf" <<'EOF'
KERNEL_CMDLINE[default]+=" quiet pm_async=off mem_sleep_default=deep apple_gmux.force_igd=y"
EOF
echo 'quiet pm_async=off mem_sleep_default=deep apple_gmux.force_igd=y' >"$running_cmdline"
: >"$calls"
run_migration
[[ ! -s $calls ]] ||
  fail "an already-running repaired T1 configuration is left unchanged" "$(cat "$calls")"
pass "T1 migration leaves already-current systems alone"
