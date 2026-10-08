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

migration="$ROOT/migrations/1791403252.sh"
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
