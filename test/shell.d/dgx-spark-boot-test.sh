#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/nvidia-dgx-spark-boot.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "nvidia-dgx-spark-boot.sh" "$ROOT"/migrations/*.sh | head -1 || true)
config_name=zz-omarchy-dgx-spark.conf

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

bash -n "$setup" || fail "DGX Spark boot script has valid syntax"

grep -q 'run_logged .*hardware/nvidia-dgx-spark-boot.sh' "$all" ||
  fail "the DGX Spark boot setting runs during hardware setup"
[[ -n $migration ]] || fail "a migration applies the DGX Spark boot setting to existing installs"
pass "the DGX Spark boot setting runs at install and through a migration"

dmi() {
  mkdir -p "$scratch/dmi/$1"
  printf '%s\n' "$2" >"$scratch/dmi/$1/sys_vendor"
  printf '%s\n' "$3" >"$scratch/dmi/$1/product_name"
}
dmi spark NVIDIA NVIDIA_DGX_Spark
dmi other "Dell Inc." "XPS 13 9350"

cat >"$scratch/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
[[ ${TEST_SUDO_STATUS:-0} == 0 ]] || exit "$TEST_SUDO_STATUS"
exec "$@"
SH
cat >"$scratch/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio %s\n' "$*" >>"$CALL_LOG"
exit "${TEST_MKINITCPIO_STATUS:-0}"
SH
cat >"$scratch/bin/efibootmgr" <<'SH'
#!/bin/bash
printf 'efibootmgr\n' >>"$CALL_LOG"
[[ ${TEST_EFIBOOTMGR_STATUS:-0} == 0 ]] || exit "$TEST_EFIBOOTMGR_STATUS"
printf '%b\n' "${TEST_EFI_ENTRIES:-Boot0001* Limine\tHD(1,GPT,1-2,0x800,0x400000)/\\\\EFI\\\\limine\\\\limine_aa64.efi}"
SH
chmod +x "$scratch/bin"/*

export CALL_LOG="$scratch/calls.log"
run() {
  local machine=$1 state=$2
  shift 2
  : >"$CALL_LOG"
  PATH="$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_DMI_PATH="$scratch/dmi/$machine" \
    OMARCHY_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" \
    OMARCHY_DGX_SPARK_BOOT_MARKER="$state/marker" "$@"
}

run spark "$scratch/spark" bash "$setup"
config="$scratch/spark/limine-entry-tool.d/$config_name"
grep -Fxqs "ENABLE_UKI=no" "$config" || fail "the DGX Spark boots without a UKI"
before=$(sha256sum "$config")
run spark "$scratch/spark" bash "$setup"
[[ $(sha256sum "$config") == "$before" ]] || fail "rerunning the setting leaves it unchanged"
run other "$scratch/other" bash "$setup"
[[ ! -e $scratch/other ]] || fail "other machines keep their UKI"
pass "the DGX Spark setting turns off the UKI and leaves other machines alone"

# limine-entry-tool reads its drop-ins in glob order, so the last ENABLE_UKI wins.
# The setting must follow every shipped drop-in that sets ENABLE_UKI, including
# omarchy-uki.conf, in any locale the boot tools might run under.
ordering="$scratch/ordering"
mkdir -p "$ordering"
cp "$ROOT"/etc/limine-entry-tool.d/*.conf "$ordering/"
cp "$config" "$ordering/"
grep -lq '^ENABLE_UKI=yes' "$ordering"/*.conf || fail "a shipped drop-in turns the UKI on"
for locale in C C.UTF-8 en_US.UTF-8; do
  effective=$(LC_ALL=$locale bash -c '
    value=
    for file in "$1"/*.conf; do
      line=$(grep "^ENABLE_UKI=" "$file" | tail -n 1) || continue
      value=${line#ENABLE_UKI=}
    done
    echo "$value"' -- "$ordering" 2>/dev/null)
  [[ $effective == "no" ]] || fail "the DGX Spark setting overrides the shipped UKI setting in the $locale locale"
done
pass "the DGX Spark setting sorts after the shipped UKI setting"

run spark "$scratch/migrated" bash -euo pipefail "$migration" >/dev/null
[[ -f $scratch/migrated/limine-entry-tool.d/$config_name ]] ||
  fail "the migration applies the setting on a Spark"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "the migration rebuilds the boot entries"
[[ -f $scratch/migrated/marker ]] || fail "the migration records the rebuild"
run spark "$scratch/migrated" bash -euo pipefail "$migration" >/dev/null
! grep -q '^sudo ' "$CALL_LOG" || fail "the migration skips a Spark that was already rebuilt"
pass "the migration applies the setting and rebuilds once on a Spark"

mkdir -p "$scratch/preset/limine-entry-tool.d"
printf 'ENABLE_UKI=no\n' >"$scratch/preset/limine-entry-tool.d/$config_name"
run spark "$scratch/preset" bash -euo pipefail "$migration" >/dev/null
! grep -q "nvidia-dgx-spark-boot.sh" "$CALL_LOG" || fail "the migration keeps an existing setting"
grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "the migration still rebuilds for an existing setting"
pass "the migration rebuilds without rewriting an existing setting"

# efibootmgr marks an active entry with * and an inactive one with a space. Version
# 18 prints the device path after a tab; older versions print the label alone.
uki_path='HD(3,GPT,1-2,0x800,0x400000)/\\EFI\\Linux\\omarchy_linux-aarch64.efi'
for entry in "Boot0002* Omarchy\t$uki_path" 'Boot0002* Omarchy'; do
  TEST_EFI_ENTRIES="$entry" run spark "$scratch/direct-boot" bash -euo pipefail "$migration" >/dev/null
  ! grep -q '^sudo ' "$CALL_LOG" || fail "the migration preserves Direct Boot"
  [[ ! -e $scratch/direct-boot ]] || fail "Direct Boot keeps its setting and UKI"
done
# Only an active entry with the dedicated Omarchy label implies Direct Boot; an
# inactive one or a Limine entry labelled after the disk must not skip the rebuild.
for entry in "Boot0002  Omarchy\t$uki_path" 'Boot0002* Omarchy Rescue' 'Boot0003  Omarchy Rescue' 'Boot0001* Omarchy - Samsung 422087P\tHD(1,GPT,1-2,0x800,0x400000)/\\EFI\\LIMINE\\LIMINE_AA64.EFI'; do
  output=$(TEST_EFI_ENTRIES="$entry" run spark "$scratch/other-label" bash -euo pipefail "$migration")
  grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "only an active Omarchy entry implies Direct Boot"
  # Only the inactive Omarchy entry is left without its UKI.
  if [[ $entry == "Boot0002  Omarchy"* ]]; then
    grep -q 'remove it with: sudo efibootmgr -b 0002 -B$' <<<"$output" || fail "the migration names the command that removes an inactive entry left without its UKI"
  else
    ! grep -q 'inactive Omarchy EFI entry' <<<"$output" || fail "the migration mentions only an inactive Omarchy entry"
  fi
  rm -rf "$scratch/other-label"
done
pass "the migration preserves an Omarchy Direct Boot entry"

TEST_EFIBOOTMGR_STATUS=1 run spark "$scratch/efi-failed" bash -euo pipefail "$migration" >/dev/null &&
  fail "an unreadable EFI configuration stays pending"
[[ ! -e $scratch/efi-failed ]] || fail "an unreadable EFI configuration changes no boot files"

run other "$scratch/migrated-other" bash -euo pipefail "$migration" >/dev/null
! grep -q '^sudo ' "$CALL_LOG" || fail "the migration leaves other machines alone"
[[ ! -e $scratch/migrated-other ]] || fail "the migration writes nothing on other machines"
TEST_SUDO_STATUS=1 run spark "$scratch/failed" bash -euo pipefail "$migration" >/dev/null &&
  fail "a failed migration stays pending"
[[ ! -e $scratch/failed/marker ]] || fail "a failed migration records no rebuild"
TEST_MKINITCPIO_STATUS=1 run spark "$scratch/rebuild-failed" bash -euo pipefail "$migration" >/dev/null &&
  fail "a failed rebuild stays pending"
[[ ! -e $scratch/rebuild-failed/marker ]] || fail "a failed rebuild records no marker"
pass "the migration leaves other machines alone and retries after a failure"
