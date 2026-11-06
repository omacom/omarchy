#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/nvidia/dgx-spark-boot.sh"
direct_boot="$ROOT/bin/omarchy-boot-direct"
config_name=zz-omarchy-dgx-spark.conf

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

# The real GB10 predicate reads fixture machines, which root never does.
require_platform_fixtures "the DGX Spark boot setting"

# An aarch64 machine with a DMI product name, and the GB10's GPU or none.
machine() {
  local dir="$scratch/hw/$1"
  mkdir -p "$dir/proc" "$dir/sys/bus/pci/devices" "$dir/bin" "$dir/dmi"
  printf '%s\n' "$2" >"$dir/dmi/product_name"
  if [[ -n ${3:-} ]]; then
    mkdir -p "$dir/sys/bus/pci/devices/000f:01:00.0"
    printf '0x10de\n' >"$dir/sys/bus/pci/devices/000f:01:00.0/vendor"
    printf '%s\n' "$3" >"$dir/sys/bus/pci/devices/000f:01:00.0/device"
  fi
  printf '#!/bin/bash\n[[ ${1:-} == -m ]] && { echo aarch64; exit 0; }\nexec /usr/bin/uname "$@"\n' >"$dir/bin/uname"
  # omarchy-hw-match reads the fixed /sys/class/dmi/id; read the fixture's instead.
  printf '#!/bin/bash\ngrep -qi -- "$1" "%s/dmi/product_name"\n' "$dir" >"$dir/bin/omarchy-hw-match"
  chmod +x "$dir/bin/uname" "$dir/bin/omarchy-hw-match"
}
machine spark NVIDIA_DGX_Spark 0x2e12
machine gx10 GX10 0x2e12
machine other "XPS 13 9350"

cat >"$scratch/bin/efibootmgr" <<'SH'
#!/bin/bash
[[ ${TEST_EFIBOOTMGR_STATUS:-0} == 0 ]] || exit "$TEST_EFIBOOTMGR_STATUS"
printf '%b\n' "${TEST_EFI_ENTRIES:-Boot0001* Limine\tHD(1,GPT,1-2,0x800,0x400000)/\\\\EFI\\\\limine\\\\limine_aa64.efi}"
SH
chmod +x "$scratch/bin"/*

run() {
  local machine=$1 state=$2
  shift 2
  PATH="$scratch/hw/$machine/bin:$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_PROC_ROOT="$scratch/hw/$machine/proc" OMARCHY_SYS_ROOT="$scratch/hw/$machine/sys" \
    OMARCHY_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" "$@"
}

run spark "$scratch/spark" bash "$setup"
config="$scratch/spark/limine-entry-tool.d/$config_name"
grep -Fxqs "ENABLE_UKI=no" "$config" || fail "the DGX Spark boots without a UKI"
before=$(sha256sum "$config")
run spark "$scratch/spark" bash "$setup"
[[ $(sha256sum "$config") == "$before" ]] || fail "rerunning the setting leaves it unchanged"
for machine in gx10 other; do
  run "$machine" "$scratch/$machine" bash "$setup"
  [[ ! -e $scratch/$machine ]] || fail "the $machine machine keeps its UKI"
done
pass "the DGX Spark setting turns off the UKI and leaves other GB10s and other machines alone"

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

# efibootmgr marks an active entry with * and an inactive one with a space. Version
# 18 prints the device path after a tab; older versions print the label alone.
uki_path='HD(3,GPT,1-2,0x800,0x400000)/\\EFI\\Linux\\omarchy_linux-aarch64.efi'

# omarchy apply hardware sources this leaf the way run_logged does: bash -eE,
# without pipefail. Executing it directly has to make the same choice.
apply_hardware() {
  run spark "$1" bash -eE -c 'source "$1"' bash "$setup"
}
for entry in "Boot0002* Omarchy\t$uki_path" 'Boot0002* Omarchy'; do
  TEST_EFI_ENTRIES="$entry" apply_hardware "$scratch/apply-direct" >/dev/null
  [[ ! -e $scratch/apply-direct/limine-entry-tool.d/$config_name ]] ||
    fail "omarchy apply hardware keeps a Direct Boot Spark on its UKI"
  rm -rf "$scratch/apply-direct"
  TEST_EFI_ENTRIES="$entry" run spark "$scratch/apply-direct-exec" bash "$setup" >/dev/null
  [[ ! -e $scratch/apply-direct-exec/limine-entry-tool.d/$config_name ]] ||
    fail "running the boot setting directly keeps a Direct Boot Spark on its UKI"
  rm -rf "$scratch/apply-direct-exec"
done
for entry in "Boot0002  Omarchy\t$uki_path" 'Boot0002* Omarchy Rescue' 'Boot0001* Omarchy - Samsung 422087P\tHD(1,GPT,1-2,0x800,0x400000)/\\EFI\\LIMINE\\LIMINE_AA64.EFI'; do
  TEST_EFI_ENTRIES="$entry" apply_hardware "$scratch/apply-other-label" >/dev/null
  grep -Fxqs "ENABLE_UKI=no" "$scratch/apply-other-label/limine-entry-tool.d/$config_name" ||
    fail "omarchy apply hardware still turns off the UKI without an active Omarchy entry"
  rm -rf "$scratch/apply-other-label"
done
mkdir -p "$scratch/apply-repair/limine-entry-tool.d"
printf 'ENABLE_UKI=no\n' >"$scratch/apply-repair/limine-entry-tool.d/$config_name"
TEST_EFI_ENTRIES='Boot0002* Omarchy' apply_hardware "$scratch/apply-repair" >/dev/null
[[ ! -e $scratch/apply-repair/limine-entry-tool.d/$config_name ]] ||
  fail "omarchy apply hardware removes a drop-in that would delete a Direct Boot UKI"
TEST_EFI_ENTRIES='Boot0002* Omarchy' run other "$scratch/apply-other" bash -eE -c 'source "$1"' bash "$setup" >/dev/null
[[ ! -e $scratch/apply-other ]] || fail "omarchy apply hardware leaves other machines on their UKI"
mkdir -p "$scratch/apply-other-keep/limine-entry-tool.d"
printf 'ENABLE_UKI=no\n' >"$scratch/apply-other-keep/limine-entry-tool.d/$config_name"
TEST_EFI_ENTRIES='Boot0002* Omarchy' run other "$scratch/apply-other-keep" bash -eE -c 'source "$1"' bash "$setup" >/dev/null
grep -Fxqs 'ENABLE_UKI=no' "$scratch/apply-other-keep/limine-entry-tool.d/$config_name" ||
  fail "omarchy apply hardware leaves another machine's UKI setting in place"
output=$(TEST_EFIBOOTMGR_STATUS=1 apply_hardware "$scratch/apply-unreadable" 2>&1) ||
  fail "an unreadable EFI configuration does not abort hardware setup"
[[ ! -e $scratch/apply-unreadable ]] || fail "an unreadable EFI configuration does not turn off the UKI"
grep -q 'leaving the DGX Spark UKI setting unchanged' <<<"$output" ||
  fail "an unreadable EFI configuration explains why the UKI setting was left"
apply_hardware "$scratch/apply-spark" >/dev/null
grep -Fxqs "ENABLE_UKI=no" "$scratch/apply-spark/limine-entry-tool.d/$config_name" ||
  fail "omarchy apply hardware still turns off the UKI on a Spark without Direct Boot"
pass "omarchy apply hardware keeps a Direct Boot Spark on its UKI"

# Direct Boot points the firmware at the UKI, which a Spark booting without one
# does not have, so the menu hides it there. Its guard reads the fixed drop-in
# path; point that at a fixture.
when=$(grep -F '"setup.direct-boot"' "$ROOT/default/omarchy/omarchy-menu.jsonc" | sed -E 's/.*"when":"([^"]*)".*/\1/')
[[ $when == *"/etc/limine-entry-tool.d/$config_name"* ]] || fail "the Direct Boot row checks the DGX Spark setting" "$when"
mkdir -p "$scratch/menu/limine-entry-tool.d"
when=${when//\/etc\/limine-entry-tool.d/$scratch/menu/limine-entry-tool.d}
printf '#!/bin/bash\nexit 1\n' >"$scratch/bin/omarchy-hw-aarch64-apple"
chmod +x "$scratch/bin/omarchy-hw-aarch64-apple"
PATH="$scratch/bin:$PATH" bash -c "$when" || fail "Direct Boot shows on a machine with a UKI"
printf 'ENABLE_UKI=no\n' >"$scratch/menu/limine-entry-tool.d/$config_name"
PATH="$scratch/bin:$PATH" bash -c "$when" && fail "Direct Boot is hidden on a Spark without a UKI"
pass "the menu hides Direct Boot on a Spark that boots without a UKI"

# Setup > Direct Boot finds the entry to remove through the same helper: any
# Omarchy entry, active or not, and no label that merely starts with Omarchy.
numbers() { TEST_EFI_ENTRIES="$1" PATH="$scratch/bin:$PATH" bash "$direct_boot" --number; }
[[ $(numbers "Boot0002* Omarchy\t$uki_path") == 0002 ]] || fail "--number names an active Omarchy entry"
[[ $(numbers "Boot0003  Omarchy\t$uki_path") == 0003 ]] || fail "--number names an inactive Omarchy entry"
for entry in 'Boot0002* Omarchy Rescue' 'Boot0001* Omarchy - Samsung 422087P\tHD(1,GPT,1-2,0x800,0x400000)/\\EFI\\LIMINE\\LIMINE_AA64.EFI'; do
  status=0
  numbers "$entry" >/dev/null || status=$?
  (( status == 1 )) || fail "--number finds no Omarchy entry in: $entry"
done
status=0
TEST_EFIBOOTMGR_STATUS=1 numbers 'Boot0002* Omarchy' >/dev/null || status=$?
(( status == 2 )) || fail "--number reports an unreadable EFI list"
pass "the Direct Boot helper names the Omarchy entry for Setup > Direct Boot"
