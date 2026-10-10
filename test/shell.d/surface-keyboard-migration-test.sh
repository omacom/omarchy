#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791345415.sh"
[[ -f $migration ]] || fail "Surface upgrades provide a boot-image migration"
[[ $(stat -c '%a' "$migration") == 644 ]] || fail "Surface migration has mode 0644"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
conf="$test_tmp/etc/mkinitcpio.conf.d/surface_device_modules.conf"
marker="$test_tmp/var/lib/omarchy/migrations/1791345415"
boot_modules="$test_tmp/boot-modules"
calls="$test_tmp/rebuilds"
fixture_path="$test_tmp/omarchy"
mkdir -p "$stub_bin" "$test_tmp/dmi" "$fixture_path/install/hardware"
printf 'Surface Laptop 3\n' >"$test_tmp/dmi/product_name"

cat >"$stub_bin/omarchy-hw-surface" <<'SH'
#!/bin/bash
[[ $SURFACE_DEVICE == "yes" ]]
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "limine-mkinitcpio" && $SURFACE_REBUILD_AVAILABLE == "yes" ]]
SH
cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash
printf 'Module                  Size  Used by\n'
if [[ $SURFACE_PINCTRL == "yes" ]]; then
  printf 'pinctrl_icelake         32768  0\n'
fi
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
set -euo pipefail
echo rebuild >>"$SURFACE_REBUILD_LOG"
if [[ ${SURFACE_REBUILD_FAIL:-no} == "yes" ]]; then
  exit 17
fi
case ${SURFACE_REBUILD_MODE:-uki} in
  skipped)
    echo "==> Unified kernel image generation successful"
    printf '\e[31mERROR: mkinitcpio failed for kernel 6.19.13, skipping.\e[0m\n' >&2
    exit 0
    ;;
  partial)
    echo "==> Unified kernel image generation successful"
    echo "ERROR: mkinitcpio failed for kernel 6.18.28-lts, skipping."
    exit 0
    ;;
  warning)
    echo "WARNING: failed to process kernel from /usr/lib/modules/6.19.13/pkgbase: mkinitcpio failed" >&2
    exit 0
    ;;
  empty) exit 0 ;;
esac
source "$SURFACE_CONF"
printf '%s\n' "${MODULES[*]}" >"$SURFACE_BOOT_MODULES"
if [[ ${SURFACE_REBUILD_MODE:-uki} == "regular" ]]; then
  echo "==> Initcpio image generation successful"
else
  echo "==> WARNING: Possibly missing firmware for module: 'qat_4xxx'" >&2
  echo "==> Unified kernel image generation successful"
fi
SH
chmod +x "$stub_bin"/*

sed -e "s|/sys/class/dmi/id/product_name|$test_tmp/dmi/product_name|g" \
    -e "s|/etc/mkinitcpio.conf.d|$test_tmp/etc/mkinitcpio.conf.d|g" \
    "$ROOT/install/hardware/fix-surface-keyboard.sh" >"$fixture_path/install/hardware/fix-surface-keyboard.sh"
sed -e "s|/etc/mkinitcpio.conf.d|$test_tmp/etc/mkinitcpio.conf.d|g" \
    -e "s|/var/lib/omarchy/migrations|$test_tmp/var/lib/omarchy/migrations|g" \
    "$migration" >"$test_tmp/migration.sh"

run_migration() {
  SURFACE_DEVICE="$1" SURFACE_PINCTRL="$2" SURFACE_REBUILD_AVAILABLE="$3" \
    SURFACE_CONF="$conf" SURFACE_BOOT_MODULES="$boot_modules" SURFACE_REBUILD_LOG="$calls" \
    OMARCHY_PATH="$fixture_path" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$test_tmp/migration.sh" >/dev/null
}

run_migration no no yes
[[ ! -e $conf && ! -e $calls && ! -e $marker ]] || fail "non-Surface upgrades skip the repair"
pass "non-Surface upgrades skip the repair"
run_migration yes yes yes
[[ ! -e $conf && ! -e $calls && ! -e $marker ]] || fail "Surface upgrades with pinctrl skip the fallback repair"
pass "Surface upgrades with pinctrl skip the fallback repair"
run_migration yes no no
[[ ! -e $conf && ! -e $calls && ! -e $marker ]] || fail "Surface upgrades without Limine skip the repair"
pass "Surface upgrades without Limine skip the repair"

# Fresh-install setup writes the config without requiring a bootloader rebuild.
SURFACE_DEVICE=yes SURFACE_PINCTRL=no PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$fixture_path/install/hardware/fix-surface-keyboard.sh" >/dev/null
[[ -f $conf && ! -e $calls ]] || fail "fresh Surface setup leaves rebuilding to the installer"
pass "fresh Surface setup leaves rebuilding to the installer"
rm "$conf"

run_migration yes no yes
expected="surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd hid_multitouch 8250_dw"
[[ -f $conf && $(<"$boot_modules") == "$expected" && -f $marker ]] ||
  fail "Surface upgrades write the fallback config and rebuild before marking completion"
pass "Surface upgrades write the fallback config and rebuild before marking completion"
run_migration yes no yes
[[ $(wc -l <"$calls") == 1 ]] || fail "another user's migration skips a completed machine-wide rebuild"
pass "another user's migration skips a completed machine-wide rebuild"

rm "$marker"
printf 'MODULES+=(custom_module)\n' >>"$conf"
cp "$conf" "$test_tmp/saved.conf"
printf 'stale_boot_modules\n' >"$boot_modules"
run_migration yes no yes
cmp -s "$conf" "$test_tmp/saved.conf" || fail "the migration preserves existing Surface module configuration"
[[ $(<"$boot_modules") == "$expected custom_module" ]] || fail "existing Surface config still triggers a stale-image rebuild"
pass "the migration preserves existing config and rebuilds a stale boot image"

rm "$marker"
set +e
SURFACE_REBUILD_FAIL=yes run_migration yes no yes
status=$?
set -e
[[ $status == 17 && ! -e $marker ]] || fail "a failed Surface rebuild remains pending" "$status"
pass "a failed Surface rebuild remains pending"
run_migration yes no yes
[[ -f $marker && $(wc -l <"$calls") == 4 ]] || fail "Surface migration retries a failed rebuild"
pass "Surface migration retries a failed rebuild"

for mode in skipped partial warning empty; do
  rm "$marker"
  printf 'stale_boot_modules\n' >"$boot_modules"
  set +e
  SURFACE_REBUILD_MODE="$mode" run_migration yes no yes 2>"$test_tmp/$mode.stderr"
  status=$?
  set -e
  [[ $status != 0 && ! -e $marker && $(<"$boot_modules") == "stale_boot_modules" ]] ||
    fail "Surface rebuild mode $mode remains pending" "$status"
  pass "Surface rebuild mode $mode remains pending"
  run_migration yes no yes
  [[ -f $marker && $(<"$boot_modules") == "$expected custom_module" ]] ||
    fail "Surface migration retries rebuild mode $mode"
  pass "Surface migration retries rebuild mode $mode"
done

rm "$marker"
SURFACE_REBUILD_MODE=regular run_migration yes no yes
[[ -f $marker && $(<"$boot_modules") == "$expected custom_module" ]] ||
  fail "a successful regular initramfs rebuild completes the migration"
pass "a successful regular initramfs rebuild completes the migration"
