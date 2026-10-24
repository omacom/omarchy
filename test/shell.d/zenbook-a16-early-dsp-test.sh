#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/support" "$scratch/doc/linux-omarchy" "$scratch/modules/7.2.10-3-omarchy"
echo 7.2.10-3-omarchy > "$scratch/doc/linux-omarchy/kernel-release"
echo 1 > "$scratch/modules/7.2.10-3-omarchy/omarchy-a16-dsp-abi"
echo '# package-owned profile' > "$scratch/support/mkinitcpio.conf"
echo 'blacklist qcom_q6v5_pas' > "$scratch/support/remoteproc-blacklist.conf"
echo '# packaged A16 audio policy' > "$scratch/support/51-glymur-ucm.conf"
echo 'root=/dev/mapper/root rw rootflags=subvol=@' > "$scratch/cmdline"
omarchy-hw-aarch64-qualcomm() { return 0; }
omarchy-hw-match-device-tree() { return 0; }
omarchy-pkg-present() { [[ $* == 'linux-omarchy omarchy-a16-support' ]]; }
systemctl() { printf '%s\n' "$*" >> "$scratch/systemctl.log"; }
export OMARCHY_ZENBOOK_KERNEL_DOC_ROOT="$scratch/doc"
export OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT="$scratch/modules"
export OMARCHY_INSTALL="$ROOT/install"
export OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$scratch/modules-load.d"
export OMARCHY_ZENBOOK_MKINITCPIO_DIR="$scratch/mkinitcpio.conf.d"
export OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$scratch/limine-entry-tool.d"
export OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$scratch/sleep.conf.d"
export OMARCHY_ZENBOOK_SUPPORT_DIR="$scratch/support"
export OMARCHY_ZENBOOK_CMDLINE_FILE="$scratch/cmdline"
export OMARCHY_ZENBOOK_BOOT_HOOKS_DIR="$scratch/boot-hooks"
limine-entry-tool() {
  [[ $* == "--get-cmdline default" ]] || return 1
  cat "$OMARCHY_ZENBOOK_CMDLINE_FILE"
}
export -f limine-entry-tool
export OMARCHY_ZENBOOK_WIREPLUMBER_DIR="$scratch/wireplumber.conf.d"
export OMARCHY_QUALCOMM_MODPROBE_DIR="$scratch/modprobe.d"
export OMARCHY_IMAGE_BOOT_REBUILD="$scratch/rebuild"
mkdir -p "$scratch/sleep.conf.d"
echo '# previous A16 sleep policy' > "$scratch/sleep.conf.d/zenbook-a16.conf"
echo '# unrelated policy' > "$scratch/sleep.conf.d/local.conf"
mkdir -p "$scratch/limine-entry-tool.d"
echo 'KERNEL_CMDLINE[default]+=" old-a16-params"' > "$scratch/limine-entry-tool.d/zenbook-a16.conf"
source "$ROOT/install/hardware/asus/zenbook-a16.sh"
[[ ! -e $scratch/limine-entry-tool.d/zenbook-a16.conf ]] || fail 'redundant A16 default parameters not retired'
OMARCHY_SLEEP_CONFIG_DIR="$scratch/sleep.conf.d" bash "$ROOT/bin/omarchy-sleep-disabled" || fail 'Omarchy does not recognize disabled A16 sleep'
[[ ! -e $scratch/sleep.conf.d/zenbook-a16.conf ]] || fail 'old A16 sleep policy not retired'
grep -Fxq '# unrelated policy' "$scratch/sleep.conf.d/local.conf" || fail 'unrelated sleep policy changed'
cmp "$scratch/support/51-glymur-ucm.conf" "$scratch/wireplumber.conf.d/51-omarchy-a16-keep-awake.conf" || fail 'A16 audio policy not activated'
[[ -L $scratch/wireplumber.conf.d/51-omarchy-a16-keep-awake.conf ]] || fail 'audio policy will become stale after package updates'
echo '# updated A16 audio policy' > "$scratch/support/51-glymur-ucm.conf"
grep -Fxq '# updated A16 audio policy' "$scratch/wireplumber.conf.d/51-omarchy-a16-keep-awake.conf" || fail 'audio package update did not reach active configuration'
cmp "$scratch/support/mkinitcpio.conf" "$scratch/mkinitcpio.conf.d/zz-zenbook-a16-dsp.conf" || fail 'early profile not installed'
[[ -L $scratch/mkinitcpio.conf.d/zz-zenbook-a16-dsp.conf ]] || fail 'profile will become stale after package updates'
echo '# updated package-owned profile' > "$scratch/support/mkinitcpio.conf"
grep -Fxq '# updated package-owned profile' "$scratch/mkinitcpio.conf.d/zz-zenbook-a16-dsp.conf" || fail 'package update did not reach active configuration'
grep -Fxq 'blacklist qcom_q6v5_pas' "$scratch/modprobe.d/qualcomm-adsp-nofw.conf" || fail 'late load guard missing'
# The live installer reads these files through /mnt, outside the target chroot.
mkdir "$scratch/mounted-target"
cp -a "$scratch/support" "$scratch/mkinitcpio.conf.d" "$scratch/modprobe.d" "$scratch/wireplumber.conf.d" "$scratch/mounted-target/"
echo '# profile under the mounted target' > "$scratch/mounted-target/support/mkinitcpio.conf"
echo '# blacklist under the mounted target' > "$scratch/mounted-target/support/remoteproc-blacklist.conf"
echo '# audio policy under the mounted target' > "$scratch/mounted-target/support/51-glymur-ucm.conf"
grep -Fxq '# profile under the mounted target' "$scratch/mounted-target/mkinitcpio.conf.d/zz-zenbook-a16-dsp.conf" || fail 'profile link escapes the mounted target'
grep -Fxq '# blacklist under the mounted target' "$scratch/mounted-target/modprobe.d/qualcomm-adsp-nofw.conf" || fail 'blacklist link escapes the mounted target'
grep -Fxq '# audio policy under the mounted target' "$scratch/mounted-target/wireplumber.conf.d/51-omarchy-a16-keep-awake.conf" || fail 'audio policy link escapes the mounted target'
grep -Fxq 'disable zenbook-a16-remoteprocs.service' "$scratch/systemctl.log" || fail 'late service not disabled'
! grep -q '^enable ' "$scratch/systemctl.log" || fail 'late service reenabled'
[[ -e $scratch/rebuild ]] || fail 'first-boot image rebuild not requested'
(
  declare -A KERNEL_CMDLINE=([default]='root=/dev/mapper/root rw')
  source "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf"
  [[ $BOOT_ORDER == 'linux-omarchy, linux-omarchy-fallback, *, Snapshots' ]] || fail 'wrong boot order'
  [[ $MKINITCPIO_FALLBACK == linux-omarchy ]] || fail 'rescue initramfs not maintained'
  for argument in root=/dev/mapper/root rootflags=subvol=@ omarchy.a16.dsp=off systemd.unit=multi-user.target; do
    [[ " ${KERNEL_CMDLINE[fallback]} " == *" $argument "* ]] || fail "rescue missing $argument"
  done
  [[ ${KERNEL_CMDLINE[fallback]} == *'module_blacklist=qcom_q6v5_pas,'* ]] || fail 'rescue can load DSP driver'
  for argument in root=/dev/mapper/root rootflags=subvol=@ glymur_pci_skip=5 iommu.passthrough=0; do
    [[ " ${KERNEL_CMDLINE[linux-omarchy]} " == *" $argument "* ]] || fail "shared kernel missing $argument"
  done
  [[ " ${KERNEL_CMDLINE[linux-omarchy]} " != *" cma="* ]] || fail 'shared kernel overrides the board CMA pool'
)
before=$(cat "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf")
source "$ROOT/install/hardware/asus/zenbook-a16.sh"
[[ $(cat "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf") == "$before" ]] || fail 'setup not idempotent'

# A readable old hook must not hide a failed attempt to replace it.
if (( EUID != 0 )); then
  (
    chmod 444 "$OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline"
    status=0
    source "$ROOT/install/hardware/asus/zenbook-a16.sh" || status=$?
    chmod 755 "$OMARCHY_ZENBOOK_BOOT_HOOKS_DIR/20-zenbook-a16-cmdline"
    [[ $status != 0 ]] || fail 'setup ignored a failed boot-hook replacement'
  )
fi

# A new shared kernel with the same audited ABI keeps the board profile without
# a version pin or another hardware-specific kernel package.
mkdir -p "$scratch/doc/linux-omarchy" "$scratch/modules/7.2.11-1-omarchy"
echo '7.2.11-1-omarchy' > "$scratch/doc/linux-omarchy/kernel-release"
echo 1 > "$scratch/modules/7.2.11-1-omarchy/omarchy-a16-dsp-abi"
export OMARCHY_ZENBOOK_KERNEL_DOC_ROOT="$scratch/doc"
export OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT="$scratch/modules"
omarchy-pkg-present() { [[ $* == 'linux-omarchy omarchy-a16-support' ]]; }
source "$ROOT/install/hardware/asus/zenbook-a16.sh"
(
  declare -A KERNEL_CMDLINE=([default]='root=/dev/mapper/root rw')
  source "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf"
  [[ $BOOT_ORDER == 'linux-omarchy, linux-omarchy-fallback, *, Snapshots' ]] || fail 'shared kernel not selected'
  [[ $MKINITCPIO_FALLBACK == linux-omarchy ]] || fail 'shared kernel rescue profile missing'
  [[ " ${KERNEL_CMDLINE[linux-omarchy]} " == *' root=/dev/mapper/root '* ]] || fail 'shared kernel lost root arguments'
)
(
  omarchy-hw-match-device-tree() { return 1; }
  omarchy-hw-match() { return 1; }
  OMARCHY_ZENBOOK_WIREPLUMBER_DIR="$scratch/other-board-audio" \
    source "$ROOT/install/hardware/asus/zenbook-a16.sh"
  [[ ! -e $scratch/other-board-audio ]] || fail 'another Snapdragon board inherited A16 audio policy'
)
# Missing or incompatible prerequisites must preserve the known boot policy
# and guard; never fall back to starting DSPs after USB root is mounted.
for missing in package profile release abi incompatible-abi; do
  (
    case $missing in
      package) omarchy-pkg-present() { return 1; } ;;
      profile) export OMARCHY_ZENBOOK_SUPPORT_DIR="$scratch/absent-support" ;;
      release) export OMARCHY_ZENBOOK_KERNEL_DOC_ROOT="$scratch/absent-doc" ;;
      abi) export OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT="$scratch/absent-modules" ;;
      incompatible-abi)
        mkdir -p "$scratch/incompatible/7.2.11-1-omarchy"
        echo 2 > "$scratch/incompatible/7.2.11-1-omarchy/omarchy-a16-dsp-abi"
        export OMARCHY_ZENBOOK_KERNEL_MODULES_ROOT="$scratch/incompatible"
        ;;
    esac
    systemctl() { fail 'unsupported kernel changed service state'; }
    before=$(cat "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf")
    if source "$ROOT/install/hardware/asus/zenbook-a16.sh" > "$scratch/error" 2>&1; then
      fail "setup accepted missing/incompatible prerequisite: $missing"
    fi
    grep -Fq 'requires linux-omarchy with DSP ABI 1 and omarchy-a16-support' "$scratch/error" || fail "missing actionable prerequisite error: $missing"
    [[ $(cat "$scratch/limine-entry-tool.d/zz-zenbook-a16-boot.conf") == "$before" ]] || fail 'failed setup changed boot parameters'
    cmp "$scratch/support/mkinitcpio.conf" "$scratch/mkinitcpio.conf.d/zz-zenbook-a16-dsp.conf" || fail 'failed setup changed early profile'
    cmp "$scratch/support/remoteproc-blacklist.conf" "$scratch/modprobe.d/qualcomm-adsp-nofw.conf" || fail 'failed setup removed late-load guard'
    cmp "$scratch/support/51-glymur-ucm.conf" "$scratch/wireplumber.conf.d/51-omarchy-a16-keep-awake.conf" || fail 'failed setup changed audio policy'
  )
done
(
  export OMARCHY_ZENBOOK_MODULES_LOAD_DIR="$scratch/fresh/modules-load.d"
  export OMARCHY_ZENBOOK_MKINITCPIO_DIR="$scratch/fresh/mkinitcpio.conf.d"
  export OMARCHY_ZENBOOK_LIMINE_CONFIG_DIR="$scratch/fresh/limine-entry-tool.d"
  export OMARCHY_ZENBOOK_SLEEP_CONFIG_DIR="$scratch/fresh/sleep.conf.d"
  omarchy-pkg-present() { return 1; }
  if source "$ROOT/install/hardware/asus/zenbook-a16.sh"; then fail 'fresh setup accepted unsupported kernel'; fi
  [[ ! -e $scratch/fresh ]] || fail 'prerequisite failure partially configured a fresh system'
)
echo quiet > "$scratch/cmdline"
if source "$ROOT/install/hardware/asus/zenbook-a16.sh"; then fail 'setup accepted a rootless rescue entry'; fi
pass 'A16 setup stages early DSP startup, exposes disabled sleep, and rejects unsupported kernels safely'
