#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

make_machine() {
  local name=$1 qcom=$2 board=$3
  local dir="$scratch/hw/$name"
  mkdir -p "$dir/bin" "$dir/dmi"
  printf '%s\n' "$board" >"$dir/dmi/board_name"
  if [[ $qcom == "yes" ]]; then
    printf '#!/bin/bash\nexit 0\n' >"$dir/bin/omarchy-hw-aarch64-qualcomm"
  else
    printf '#!/bin/bash\nexit 1\n' >"$dir/bin/omarchy-hw-aarch64-qualcomm"
  fi
  printf '#!/bin/bash\ngrep -qi -- "$1" "%s/dmi/board_name"\n' "$dir" >"$dir/bin/omarchy-hw-match"
  printf '#!/bin/bash\necho "$*" >"%s/cmdline.log"\n' "$dir" >"$dir/bin/omarchy-boot-cmdline"
  chmod +x "$dir/bin/omarchy-hw-aarch64-qualcomm" "$dir/bin/omarchy-hw-match" "$dir/bin/omarchy-boot-cmdline"
}

make_machine a16 yes "UX3607OA"
make_machine other yes "Surface Laptop 8"
make_machine x86 no "UX3607OA"

run_setup() {
  local machine=$1 state=$2
  PATH="$scratch/hw/$machine/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_ZENBOOK_A16_MKINITCPIO_DIR="$state/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_A16_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" \
    OMARCHY_ZENBOOK_A16_SLEEP_CONFIG_DIR="$state/sleep.conf.d" \
    bash -eE -c 'source "$1"' bash "$setup"
}

# UX3607OA removes legacy sleep overrides and writes initramfs + cmdline
state_a16="$scratch/state-a16"
mkdir -p "$state_a16/sleep.conf.d"
printf '[Sleep]\nAllowSuspend=no\n' >"$state_a16/sleep.conf.d/omarchy-sleep-disabled.conf"
printf '[Sleep]\nMemorySleepMode=s2idle\n' >"$state_a16/sleep.conf.d/zenbook-a16.conf"
run_setup a16 "$state_a16"

[[ ! -e $state_a16/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
  fail "UX3607OA removes legacy omarchy-sleep-disabled.conf"
[[ ! -e $state_a16/sleep.conf.d/zenbook-a16.conf ]] ||
  fail "UX3607OA removes legacy zenbook-a16.conf"
[[ -f $state_a16/mkinitcpio.conf.d/zenbook-a16-initramfs.conf ]] ||
  fail "UX3607OA writes zenbook-a16-initramfs.conf"
grep -q 'asus_glymur_ec?' "$state_a16/mkinitcpio.conf.d/zenbook-a16-initramfs.conf" ||
  fail "UX3607OA initramfs config includes the EC driver"
[[ $(<"$scratch/hw/a16/cmdline.log") == "set zenbook-a16 console=tty0 plymouth.enable=0 msm.psr_enabled=1" ]] ||
  fail "UX3607OA sets console, plymouth and PSR kernel cmdline options"
pass "UX3607OA clears legacy sleep drop-ins and keeps initramfs + cmdline setup"

# Other machines are untouched
for machine in other x86; do
  state="$scratch/state-$machine"
  mkdir -p "$state/sleep.conf.d"
  printf '[Sleep]\nAllowSuspend=no\n' >"$state/sleep.conf.d/omarchy-sleep-disabled.conf"
  run_setup "$machine" "$state"
  [[ -f $state/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
    fail "$machine keeps its sleep config untouched"
  [[ ! -e $state/mkinitcpio.conf.d ]] ||
    fail "$machine does not get Zenbook A16 initramfs config"
done
pass "non-UX3607OA machines are left untouched"
