#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
conf_d="$test_tmp/mkinitcpio.conf.d"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$conf_d"

cat >"$stub_bin/omarchy-hw-surface" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash

echo 'Module                  Size  Used by'
echo 'pinctrl_tigerlake      28672  0'
SH

cat >"$stub_bin/cat" <<'SH'
#!/bin/bash

if [[ $1 == "/sys/class/dmi/id/product_name" ]]; then
  echo 'Surface Laptop 3'
else
  exec /usr/bin/cat "$@"
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo\t%s\n' "$1" >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash

echo 'limine-mkinitcpio' >>"$TEST_LOG"
exit "${TEST_REBUILD_STATUS:-0}"
SH

chmod +x "$stub_bin"/*

# The installer writes to /etc; point it at the fixture directory instead.
sed "s|/etc/mkinitcpio.conf.d|$conf_d|g" "$ROOT/install/hardware/fix-surface-keyboard.sh" >"$test_tmp/fix-surface-keyboard.sh"
PATH="$stub_bin:$PATH" bash -euo pipefail "$test_tmp/fix-surface-keyboard.sh" >/dev/null

echo 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' >"$conf_d/nvidia.conf"
cp "$ROOT/etc/mkinitcpio.conf.d/"*.conf "$conf_d/"

# Concatenates the drop-ins after the main config in mkinitcpio's own order
# (sort -V) and prints the MODULES they produce.
resolved_modules() {
  local conf
  {
    echo 'MODULES=()'
    echo 'FILES=()'
    for conf in $(cd "$conf_d" && printf '%s\n' *.conf | LC_ALL=C.UTF-8 sort -V); do
      cat "$conf_d/$conf"
    done
    echo 'echo " ${MODULES[*]} "'
  } >"$test_tmp/resolved.conf"

  OMARCHY_PCI_DEVICES_PATH="$test_tmp/no-devices" bash "$test_tmp/resolved.conf"
}

modules=$(resolved_modules)
[[ $modules == *" nvidia_drm "* ]] ||
  fail "the Surface keyboard modules keep NVIDIA's early-loaded modules" "actual: $modules"
[[ $modules == *" pinctrl_tigerlake surface_aggregator "* && $modules == *" 8250_dw "* ]] ||
  fail "the Surface keyboard modules are in MODULES" "actual: $modules"
[[ $modules == *" thunderbolt "* ]] ||
  fail "later drop-ins still append" "actual: $modules"
pass "the Surface keyboard drop-in appends to MODULES"

migration="$ROOT/migrations/1791403253.sh"
surface_conf="$conf_d/surface_device_modules.conf"
marker="$test_tmp/rebuild-marker"

run_migration() {
  PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_SURFACE_MKINITCPIO_CONF="$surface_conf" \
    OMARCHY_SURFACE_REBUILD_MARKER="$marker" \
    bash -euo pipefail "$migration" >/dev/null
}

sed -i 's/^MODULES+=(/MODULES=(/' "$surface_conf"
: >"$calls"
run_migration

grep -q '^MODULES+=(pinctrl_tigerlake surface_aggregator ' "$surface_conf" ||
  fail "the migration makes an installer-written file append" "$(cat "$surface_conf")"
modules=$(resolved_modules)
[[ $modules == *" nvidia_drm "* ]] ||
  fail "a migrated install keeps NVIDIA's early-loaded modules" "actual: $modules"
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "the migration rebuilds the initramfs"
[[ -f $marker ]] || fail "the migration records the machine-wide rebuild"
pass "the migration repairs an existing Surface NVIDIA install"

: >"$calls"
run_migration
[[ ! -s $calls ]] || fail "a repaired install is left alone" "$(cat "$calls")"
pass "the migration is machine-idempotent"

rm -f "$marker"
: >"$calls"
run_migration
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "the migration retries an interrupted rebuild"
! grep -q $'^sudo\tsed$' "$calls" || fail "a retried rebuild leaves the repaired file alone" "$(cat "$calls")"
pass "the migration retries an interrupted rebuild"

installer_modules="surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw"

rm -f "$marker"
printf 'MODULES=(pinctrl_tigerlake\npinctrl_alderlake %s)\n' "$installer_modules" >"$surface_conf"
: >"$calls"
run_migration
[[ $(head -1 "$surface_conf") == "MODULES+=(pinctrl_tigerlake" ]] ||
  fail "the migration repairs a file listing several pinctrl modules" "$(cat "$surface_conf")"
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "a file listing several pinctrl modules is rebuilt"
pass "the migration repairs a file listing several pinctrl modules"

hand_written=(
  'MODULES=(pinctrl_tigerlake surface_kbd)'
  "MODULES=(pinctrl_tigerlake custom_driver $installer_modules)"
  "MODULES=(custom_driver)"$'\n'"# $installer_modules"
  "MODULES=(pinctrl_tigerlake $installer_modules)"$'\n'"MODULES=(custom_driver)"
)
for content in "${hand_written[@]}"; do
  rm -f "$marker"
  printf '%s\n' "$content" >"$surface_conf"
  : >"$calls"
  run_migration
  [[ $(<"$surface_conf") == "$content" ]] ||
    fail "a hand-written Surface drop-in is left as written" "$(cat "$surface_conf")"
  [[ ! -s $calls ]] || fail "a hand-written Surface drop-in triggers nothing" "$(cat "$calls")"
done
pass "the migration leaves a hand-written drop-in alone"

# 1791403252 is already the repository-priority migration. Exercise the real
# ordered runner with a harmless stand-in for that work, the unchanged Surface
# migration, and later work. Only the host pacman-lock probe is redirected.
queue="$test_tmp/queue"
queue_state="$test_tmp/queue-state"
mkdir -p "$queue/migrations" "$test_tmp/queue-home"
cat >"$queue/migrations/1791403252.sh" <<'SH'
echo repository-priority >>"$TEST_LOG"
SH
cp "$migration" "$queue/migrations/${migration##*/}"
cat >"$queue/migrations/1791403254.sh" <<'SH'
echo later >>"$TEST_LOG"
SH
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-notification-dismiss"
chmod +x "$stub_bin/omarchy-notification-dismiss"
sed "s|local lock_file=/var/lib/pacman/db.lck|local lock_file=$test_tmp/pacman.lock|" \
  "$ROOT/bin/omarchy-migrate" >"$test_tmp/omarchy-migrate"

run_queue() {
  HOME="$test_tmp/queue-home" OMARCHY_PATH="$queue" \
    OMARCHY_MIGRATION_STATE="$queue_state" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    TEST_REBUILD_STATUS="${TEST_REBUILD_STATUS:-0}" \
    OMARCHY_SURFACE_MKINITCPIO_CONF="$surface_conf" \
    OMARCHY_SURFACE_REBUILD_MARKER="$marker" \
    bash "$test_tmp/omarchy-migrate" "$@"
}

reset_queue() {
  rm -rf "$queue_state"
  rm -f "$marker"
  printf 'MODULES=(pinctrl_tigerlake %s)\n' "$installer_modules" >"$surface_conf"
  : >"$calls"
}

reset_queue
[[ $(run_queue --pending) == $'1791403252.sh\n1791403253.sh\n1791403254.sh' ]] ||
  fail "the Surface repair has a distinct place after repository priority"
run_queue >/dev/null
[[ $(grep -v $'^sudo\t' "$calls") == $'repository-priority\nlimine-mkinitcpio\nlater' ]] ||
  fail "repository priority, Surface repair, and later work run in order" "$(cat "$calls")"
[[ -f $queue_state/1791403252.sh && -f $queue_state/1791403253.sh && -f $queue_state/1791403254.sh && -f $marker ]] ||
  fail "each migration records its own successful completion"
grep -q '^MODULES+=(pinctrl_tigerlake ' "$surface_conf" || fail "the queued Surface repair appends modules"
: >"$calls"
run_queue >/dev/null
[[ ! -s $calls ]] || fail "completed queue work is not repeated" "$(cat "$calls")"
pass "repository priority and the Surface repair retain distinct ordered completion"

reset_queue
mkdir -p "$queue_state"
touch "$queue_state/1791403252.sh"
run_queue >/dev/null
[[ $(grep -v $'^sudo\t' "$calls") == $'limine-mkinitcpio\nlater' && -f $queue_state/1791403253.sh ]] ||
  fail "completed repository priority does not hide the Surface repair" "$(cat "$calls")"
pass "a prior repository-priority marker leaves the Surface repair pending"

reset_queue
if TEST_REBUILD_STATUS=1 run_queue >"$test_tmp/queue-failure.out" 2>&1; then
  fail "a failed Surface rebuild must stop the queue"
fi
[[ -f $queue_state/1791403252.sh && ! -e $queue_state/1791403253.sh && ! -e $queue_state/1791403254.sh && ! -e $marker ]] ||
  fail "a failed Surface rebuild completes neither its repair nor later work"
! grep -Fxq later "$calls" || fail "later work does not run after a failed rebuild"
: >"$calls"
run_queue >/dev/null
[[ $(grep -v $'^sudo\t' "$calls") == $'limine-mkinitcpio\nlater' && -f $queue_state/1791403253.sh && -f $marker ]] ||
  fail "the same repaired file retries before later work" "$(cat "$calls")"
pass "a failed queued Surface rebuild remains pending and retries before later work"
