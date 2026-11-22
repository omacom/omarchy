#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/nvidia/dgx-spark-boot.sh"
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

# omarchy apply hardware sources this leaf the way run_logged does: bash -eE,
# without pipefail.
apply_hardware() {
  run "$1" "$2" bash -eE -c 'source "$1"' bash "$setup"
}
apply_hardware spark "$scratch/apply-spark" >/dev/null
grep -Fxqs "ENABLE_UKI=no" "$scratch/apply-spark/limine-entry-tool.d/$config_name" ||
  fail "omarchy apply hardware turns off the UKI on a Spark"
apply_hardware other "$scratch/apply-other" >/dev/null
[[ ! -e $scratch/apply-other ]] || fail "omarchy apply hardware leaves other machines on their UKI"
mkdir -p "$scratch/apply-other-keep/limine-entry-tool.d"
printf 'ENABLE_UKI=no\n' >"$scratch/apply-other-keep/limine-entry-tool.d/$config_name"
apply_hardware other "$scratch/apply-other-keep" >/dev/null
grep -Fxqs 'ENABLE_UKI=no' "$scratch/apply-other-keep/limine-entry-tool.d/$config_name" ||
  fail "omarchy apply hardware leaves another machine's UKI setting in place"
pass "omarchy apply hardware turns off the UKI only on a Spark"
