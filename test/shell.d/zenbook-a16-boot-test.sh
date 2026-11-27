#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
migration="$ROOT/migrations/1795784805.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

make_machine() {
  local name=$1 qcom=$2 board=$3 dtbs_ver=${4:-7.3-75} sup_ver=${5:-1-4}
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
  printf '#!/bin/bash\nexit 0\n' >"$dir/bin/omarchy-pkg-add"
  printf '#!/bin/bash\necho "$*" >>"%s/state.log"\n' "$dir" >"$dir/bin/omarchy-state"
  printf '#!/bin/bash\nif [[ $1 == -Q && $2 == linux-omarchy-dtbs ]]; then echo "linux-omarchy-dtbs %s"; elif [[ $1 == -Q && $2 == asus-zenbook-a16-support ]]; then echo "asus-zenbook-a16-support %s"; else exit 1; fi\n' "$dtbs_ver" "$sup_ver" >"$dir/bin/pacman"
  printf '#!/bin/bash\nexec "$@"\n' >"$dir/bin/sudo"
  printf '#!/bin/bash\necho "$*" >>"%s/udevadm.log"\n' "$dir" >"$dir/bin/udevadm"
  chmod +x "$dir/bin/"*
}

make_dt() {
  local dir=$1 fixed=$2
  mkdir -p \
    "$dir/cpus/domain-idle-states/cluster-sleep-0" \
    "$dir/psci/power-domain-cpu-cluster0" \
    "$dir/gpio-keys/switch-lid"
  if [[ $fixed == "yes" ]]; then
    printf '\x3b\x9a\xca\x00' >"$dir/cpus/domain-idle-states/cluster-sleep-0/min-residency-us"
    : >"$dir/psci/power-domain-cpu-cluster0/domain-idle-states"
  else
    printf '\x00\x00\x23\x28' >"$dir/cpus/domain-idle-states/cluster-sleep-0/min-residency-us"
    : >"$dir/gpio-keys/switch-lid/wakeup-event-action"
  fi
}

make_machine a16_ready yes "UX3607OA" 7.3-75 1-4
make_machine a16_old_pkg yes "UX3607OA" 7.3-73 1-3
make_machine other yes "Surface Laptop 8" 7.3-75 1-4
make_machine x86 no "UX3607OA" 7.3-75 1-4

make_dt "$scratch/dt-fixed" yes
make_dt "$scratch/dt-old" no

# fix-asus-zenbook-a16-boot.sh leaves existing sleep drop-ins untouched and ignores other machines
state_boot="$scratch/state-boot"
mkdir -p "$state_boot/sleep.conf.d"
printf '[Sleep]\nAllowSuspend=no\n' >"$state_boot/sleep.conf.d/omarchy-sleep-disabled.conf"
PATH="$scratch/hw/a16_old_pkg/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_ZENBOOK_A16_MKINITCPIO_DIR="$state_boot/mkinitcpio.conf.d" \
  OMARCHY_ZENBOOK_A16_LIMINE_CONFIG_DIR="$state_boot/limine-entry-tool.d" \
  bash -eE -c 'source "$1"' bash "$setup"
[[ -f $state_boot/sleep.conf.d/omarchy-sleep-disabled.conf ]] ||
  fail "boot setup does not prematurely remove omarchy-sleep-disabled.conf"

for machine in other x86; do
  state="$scratch/state-$machine"
  PATH="$scratch/hw/$machine/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_ZENBOOK_A16_MKINITCPIO_DIR="$state/mkinitcpio.conf.d" \
    OMARCHY_ZENBOOK_A16_LIMINE_CONFIG_DIR="$state/limine-entry-tool.d" \
    bash -eE -c 'source "$1"' bash "$setup"
  [[ ! -e $state/mkinitcpio.conf.d ]] ||
    fail "$machine does not get Zenbook A16 initramfs config"
done
pass "boot setup preserves sleep drop-ins and leaves non-UX3607OA machines untouched"

# Migration exits 0 immediately when no legacy sleep files exist (even on old packages)
state_clean="$scratch/mig-clean"
mkdir -p "$state_clean"
PATH="$scratch/hw/a16_old_pkg/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_SLEEP_CONFIG_DIR="$state_clean" OMARCHY_DT_ROOT="$scratch/dt-old" \
  bash -euo pipefail "$migration" >/dev/null
pass "migration exits 0 immediately when no legacy sleep files exist"

# Migration defers (exit 75) when packages are behind
state_old_pkg="$scratch/mig-old-pkg"
mkdir -p "$state_old_pkg"
printf '[Sleep]\nAllowSuspend=no\n' >"$state_old_pkg/omarchy-sleep-disabled.conf"
rc=0
PATH="$scratch/hw/a16_old_pkg/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_SLEEP_CONFIG_DIR="$state_old_pkg" OMARCHY_DT_ROOT="$scratch/dt-fixed" \
  bash -euo pipefail "$migration" >/dev/null || rc=$?
(( rc == 75 )) || fail "migration defers with exit 75 when packages are behind (got $rc)"
[[ -f $state_old_pkg/omarchy-sleep-disabled.conf ]] ||
  fail "migration keeps sleep disabled while packages are behind"
pass "migration defers with exit 75 while packages are behind"

# Migration sets reboot-required and defers (exit 75) until the fixed device tree is booted
state_old_dt="$scratch/mig-old-dt"
mkdir -p "$state_old_dt"
printf '[Sleep]\nAllowSuspend=no\n' >"$state_old_dt/omarchy-sleep-disabled.conf"
rc=0
PATH="$scratch/hw/a16_ready/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_SLEEP_CONFIG_DIR="$state_old_dt" OMARCHY_DT_ROOT="$scratch/dt-old" \
  bash -euo pipefail "$migration" >/dev/null || rc=$?
(( rc == 75 )) || fail "migration defers with exit 75 while old device tree is booted (got $rc)"
[[ -f $state_old_dt/omarchy-sleep-disabled.conf ]] ||
  fail "migration keeps sleep disabled until reboot onto fixed device tree"
grep -qx 'set reboot-required' "$scratch/hw/a16_ready/state.log" ||
  fail "migration sets reboot-required when packages are installed but old device tree is running"
pass "migration sets reboot-required and defers while old device tree is booted"

# Migration removes legacy sleep drop-ins once packages and booted device tree are ready
state_ready="$scratch/mig-ready"
mkdir -p "$state_ready"
printf '[Sleep]\nAllowSuspend=no\n' >"$state_ready/omarchy-sleep-disabled.conf"
printf '[Sleep]\nMemorySleepMode=s2idle\n' >"$state_ready/zenbook-a16.conf"
PATH="$scratch/hw/a16_ready/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_SLEEP_CONFIG_DIR="$state_ready" OMARCHY_DT_ROOT="$scratch/dt-fixed" \
  bash -euo pipefail "$migration" >/dev/null
[[ ! -e $state_ready/omarchy-sleep-disabled.conf && ! -e $state_ready/zenbook-a16.conf ]] ||
  fail "migration removes legacy sleep drop-ins once fixed device tree is active"
grep -q 'trigger --subsystem-match=pci --sysname-match=0004:00:00.0' "$scratch/hw/a16_ready/udevadm.log" ||
  fail "migration triggers the PCIe4 wakeup udev rule"
pass "migration re-enables sleep once packages and booted device tree are ready"
