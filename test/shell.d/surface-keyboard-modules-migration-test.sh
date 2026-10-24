#!/bin/bash
#
# The migration that turns an installer-written surface_device_modules.conf
# from a MODULES reset into an append, so the NVIDIA modules sorted before it
# stay in the initramfs, and rebuilds once per machine.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792129609.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
surface_conf="$test_dir/surface_device_modules.conf"
marker="$test_dir/rebuild-marker"
calls="$test_dir/calls.log"
mkdir -p "$stub_bin"

# sudo records what it was asked to run; limine-mkinitcpio records that it
# ran, and fails when told to.
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
[[ -z ${REBUILD_FAILS:-} ]]
SH
chmod +x "$stub_bin"/*

installer_modules="surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw"
nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

run_migration() {
  : >"$calls"
  PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_SURFACE_MKINITCPIO_CONF="$surface_conf" \
    OMARCHY_SURFACE_REBUILD_MARKER="$marker" \
    bash -euo pipefail "$migration" >/dev/null
}

# What MODULES comes to with nvidia.conf sourced before the Surface drop-in, as
# mkinitcpio orders them.
resolved_modules() {
  bash -c 'MODULES=(); MODULES+=('"$nvidia_modules"'); source "$1"; echo "${MODULES[*]}"' _ "$surface_conf"
}

printf 'MODULES=(pinctrl_tigerlake %s)\n' "$installer_modules" >"$surface_conf"
[[ $(resolved_modules) == "pinctrl_tigerlake $installer_modules" ]] ||
  fail "the installer's old drop-in drops the NVIDIA modules" "actual: $(resolved_modules)"

run_migration
[[ $(<"$surface_conf") == "MODULES+=(pinctrl_tigerlake $installer_modules)" ]] ||
  fail "the migration makes an installer-written file append" "$(<"$surface_conf")"
[[ $(resolved_modules) == "$nvidia_modules pinctrl_tigerlake $installer_modules" ]] ||
  fail "a migrated install keeps the NVIDIA modules" "actual: $(resolved_modules)"
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "the migration rebuilds the initramfs"
[[ -f $marker ]] || fail "the migration records the machine-wide rebuild"
pass "the migration repairs an existing Surface drop-in and rebuilds"

run_migration
[[ ! -s $calls ]] || fail "a repaired machine is left alone" "$(<"$calls")"
pass "the rebuild runs once per machine, not once per user"

# A failed rebuild leaves the repaired file and no marker, so the next run
# retries the rebuild alone.
printf 'MODULES=(pinctrl_tigerlake %s)\n' "$installer_modules" >"$surface_conf"
rm -f "$marker"
if REBUILD_FAILS=1 run_migration; then
  fail "a rebuild that failed was reported as a success"
fi
[[ ! -e $marker ]] || fail "a failed rebuild was marked as done"
run_migration
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "the migration retries an interrupted rebuild"
! grep -q $'^sudo\tsed$' "$calls" || fail "a retried rebuild leaves the repaired file alone" "$(<"$calls")"
[[ -f $marker ]] || fail "a retried rebuild records the machine-wide rebuild"
pass "a rebuild that fails leaves the migration pending, and the retry only rebuilds"

printf 'MODULES=(pinctrl_tigerlake\npinctrl_alderlake %s)\n' "$installer_modules" >"$surface_conf"
rm -f "$marker"
run_migration
[[ $(<"$surface_conf") == "MODULES+=(pinctrl_tigerlake"$'\n'"pinctrl_alderlake $installer_modules)" ]] ||
  fail "the migration repairs a file listing several pinctrl modules" "$(<"$surface_conf")"
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "a file listing several pinctrl modules is rebuilt"
pass "the migration repairs a file listing several pinctrl modules"

# Omarchy 3 installers wrote the file even when no pinctrl module was found.
printf 'MODULES=( %s)\n' "$installer_modules" >"$surface_conf"
rm -f "$marker"
run_migration
[[ $(<"$surface_conf") == "MODULES+=( $installer_modules)" ]] ||
  fail "the migration repairs a file written without a pinctrl module" "$(<"$surface_conf")"
grep -Fxq 'limine-mkinitcpio' "$calls" || fail "a file written without a pinctrl module is rebuilt"
pass "the migration repairs a file written without a pinctrl module"

hand_written=(
  'MODULES=(pinctrl_tigerlake surface_kbd)'
  "MODULES=(pinctrl_tigerlake custom_driver $installer_modules)"
  "MODULES=(custom_driver)"$'\n'"# $installer_modules"
  "MODULES=(pinctrl_tigerlake $installer_modules)"$'\n'"MODULES=(custom_driver)"
)
for content in "${hand_written[@]}"; do
  rm -f "$marker"
  printf '%s\n' "$content" >"$surface_conf"
  run_migration
  [[ $(<"$surface_conf") == "$content" ]] ||
    fail "a hand-written Surface drop-in is left as written" "$(<"$surface_conf")"
  [[ ! -s $calls ]] || fail "a hand-written Surface drop-in triggers nothing" "$(<"$calls")"
done
pass "the migration leaves a hand-written drop-in alone"

rm -f "$surface_conf" "$marker"
run_migration
[[ ! -s $calls && ! -e $marker ]] || fail "a machine without the Surface drop-in is left alone"
pass "a machine without the Surface drop-in is left alone"
