#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-micron-2400-nvme"
leaf="$ROOT/install/hardware/fix-micron-2400-apst.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-micron-2400-apst" "$ROOT"/migrations/*.sh | head -1)
parameter='KERNEL_CMDLINE[default]+=" nvme_core.default_ps_max_latency_us=0"'
micron="Micron_2400_MTFDKBA1T0QFM"
other="Samsung SSD 990 PRO 1TB"

grep -q 'run_logged .*hardware/fix-micron-2400-apst.sh' "$all" ||
  fail "the APST workaround runs during hardware setup"
pass "the APST workaround runs during hardware setup"

[[ -n $migration ]] || fail "a migration applies the workaround on existing installs"
pass "a migration applies the workaround on existing installs"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$test_tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
exit "${TEST_REBUILD_STATUS:-0}"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${TEST_MISSING_CMD:-} != "$1" ]]
SH

chmod +x "$test_tmp/bin"/*

nvme_class="$test_tmp/nvme"
dropin_dir="$test_tmp/limine-entry-tool.d"
limine_conf="$test_tmp/limine"
running_cmdline="$test_tmp/cmdline"
rebuild_marker="$test_tmp/rebuild-marker"
call_log="$test_tmp/calls.log"

# An empty model stands for a machine without an NVMe controller.
set_model() {
  rm -rf "$nvme_class"
  if [[ -n $1 ]]; then
    mkdir -p "$nvme_class/nvme0"
    printf '%s\n' "$1" >"$nvme_class/nvme0/model"
  fi
}

run_detector() {
  set_model "${1-$micron}"
  OMARCHY_NVME_CLASS="$nvme_class" bash "$detector"
}

run_detector || fail "the detector matches a Micron 2400"
pass "the detector matches a Micron 2400"

run_detector "$other" && fail "the detector rejects another drive"
pass "the detector rejects another drive"

run_detector "" && fail "the detector fails closed without an NVMe controller"
pass "the detector fails closed without an NVMe controller"

# Sourced the way run_logged runs it.
run_leaf() {
  set_model "${1-$micron}"
  rm -rf "$dropin_dir"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    OMARCHY_NVME_CLASS="$nvme_class" \
    OMARCHY_LIMINE_DROPIN_DIR="$dropin_dir" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf writes the drop-in on a Micron 2400"
grep -Fxq "$parameter" "$dropin_dir/micron-2400-apst.conf" ||
  fail "the leaf writes the drop-in on a Micron 2400"
pass "the leaf writes the drop-in on a Micron 2400"

run_leaf "$other" || fail "the leaf no-ops on another drive"
[[ -e $dropin_dir ]] && fail "the leaf no-ops on another drive"
pass "the leaf no-ops on another drive"

# Fresh state unless a case seeds it: no drop-in, an empty /etc/default/limine,
# a kernel booted without the parameter, no rebuild marker.
reset_machine() {
  : >"$call_log"
  rm -rf "$dropin_dir" "$rebuild_marker"
  : >"$limine_conf"
  printf 'root=/dev/mapper/omarchy_root rw\n' >"$running_cmdline"
}

run_migration() {
  set_model "${1-$micron}"
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_NVME_CLASS="$nvme_class" \
    OMARCHY_LIMINE_DROPIN_DIR="$dropin_dir" \
    OMARCHY_KERNEL_LIMINE_CONF="$limine_conf" \
    OMARCHY_RUNNING_CMDLINE="$running_cmdline" \
    OMARCHY_LIMINE_REBUILD_MARKER="$rebuild_marker" \
    TEST_REBUILD_STATUS="${2:-0}" \
    TEST_MISSING_CMD="${3:-}" \
    bash -euo pipefail "$migration" >/dev/null
}

reset_machine
run_migration || fail "the migration applies the workaround and asks for a reboot"
grep -Fxq "$parameter" "$dropin_dir/micron-2400-apst.conf" ||
  fail "the migration writes the drop-in"
grep -q '^limine-mkinitcpio$' "$call_log" ||
  fail "the migration rebuilds the boot image"
[[ -e $rebuild_marker ]] || fail "the migration records the rebuild"
grep -q 'state set reboot-required' "$call_log" ||
  fail "the migration asks for a reboot"
pass "the migration applies the workaround and asks for a reboot"

# The running kernel keeps its old command line until reboot, so a second user
# must not rebuild again before then.
: >"$call_log"
run_migration || fail "the migration no-ops once the rebuild is recorded"
[[ -s $call_log ]] && fail "the migration no-ops once the rebuild is recorded"
pass "the migration no-ops once the rebuild is recorded"

# The migration runner only records a migration that exits clean, so a failed
# rebuild has to fail the migration and leave the retry able to rebuild.
reset_machine
run_migration "$micron" 1 && fail "a failing rebuild leaves the migration pending"
[[ -e $rebuild_marker ]] && fail "a failing rebuild is not recorded"
grep -q 'state set reboot-required' "$call_log" &&
  fail "a failing rebuild does not mark reboot-required"
pass "a failing rebuild leaves the migration pending without marking reboot-required"

: >"$call_log"
run_migration || fail "the retry rebuilds even though the drop-in already exists"
grep -q '^limine-mkinitcpio$' "$call_log" ||
  fail "the retry rebuilds even though the drop-in already exists"
pass "the retry rebuilds even though the drop-in already exists"

# A machine that already boots the parameter from its own drop-in must not
# get a second copy, a boot image rebuild, or a reboot prompt.
reset_machine
mkdir -p "$dropin_dir"
printf '%s\n' "$parameter" >"$dropin_dir/nvme-apst.conf"
printf 'root=/dev/mapper/omarchy_root rw nvme_core.default_ps_max_latency_us=0\n' >"$running_cmdline"
run_migration || fail "the migration no-ops when the parameter is already booted"
[[ -e $dropin_dir/micron-2400-apst.conf ]] &&
  fail "the migration does not duplicate an existing drop-in"
[[ -s $call_log ]] && fail "the migration no-ops when the parameter is already booted"
pass "the migration no-ops when the parameter is already booted"

# /etc/default/limine outranks every drop-in, so a parameter set there counts
# as configured; it still needs the rebuild it has not had.
reset_machine
printf '%s\n' "$parameter" >"$limine_conf"
run_migration || fail "the migration honours a parameter set in /etc/default/limine"
[[ -e $dropin_dir ]] && fail "the migration does not add a drop-in beside /etc/default/limine"
grep -q '^limine-mkinitcpio$' "$call_log" ||
  fail "the migration still rebuilds for an unbooted /etc/default/limine parameter"
pass "the migration honours a parameter set in /etc/default/limine"

reset_machine
run_migration "$other" || fail "the migration no-ops on another drive"
[[ -e $dropin_dir ]] && fail "the migration no-ops on another drive"
[[ -s $call_log ]] && fail "the migration no-ops on another drive"
pass "the migration no-ops on another drive"

reset_machine
run_migration "$micron" 0 limine-mkinitcpio ||
  fail "the migration no-ops without limine-mkinitcpio"
[[ -e $dropin_dir ]] && fail "the migration no-ops without limine-mkinitcpio"
pass "the migration no-ops without limine-mkinitcpio"
