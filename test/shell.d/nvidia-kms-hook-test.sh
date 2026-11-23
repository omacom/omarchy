#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

baseline_conf="$ROOT/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf"
hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
fake_platform "$tmp_dir/generic" x86

# Each argument is a PCI device as "vendor:class[:flags]", vendor and class in
# sysfs's own format. Flags, comma-separated:
#   boot_vga     - the firmware's boot display
#   module=NAME  - bound to a driver from the loadable module NAME
#   drm          - has a DRM card with no outputs
#   output       - has a DRM card with one output
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot vendor class flags flag dir
    slot=$(printf '0000:%02x:00.0' "$index")
    dir="$tmp_dir/devices/$slot"
    IFS=: read -r vendor class flags <<<"$spec"
    mkdir -p "$dir"
    printf '%s\n' "$vendor" >"$dir/vendor"
    printf '%s\n' "$class" >"$dir/class"
    for flag in ${flags//,/ }; do
      case $flag in
        boot_vga) printf '1\n' >"$dir/boot_vga" ;;
        module=*)
          mkdir -p "$dir/driver"
          ln -s "../../../module/${flag#module=}" "$dir/driver/module"
          ;;
        drm) mkdir -p "$dir/drm/card$index" ;;
        output) mkdir -p "$dir/drm/card$index/card$index-HDMI-A-1" ;;
      esac
    done
    index=$((index + 1))
  done
}

# Sources the hook config the way mkinitcpio does — after the baseline and
# the earlier drop-ins — and prints the resulting HOOKS, or MODULES with
# "modules" as the second argument. mkinitcpio does not run under set -u, but
# the config must survive it, so source under it anyway. "unset" leaves MODULES
# undeclared entirely. The third argument swaps in another copy of the hook
# config; its directory stands in for the drop-in directory the config walks.
resolved_hooks() {
  local modules_decl="" variable=HOOKS conf=${3:-$hooks_conf}
  [[ $1 == "unset" ]] || modules_decl="MODULES=($1)"
  [[ ${2:-} != "modules" ]] || variable=MODULES

  # The vconsole block sources the host's /etc/vconsole.conf, which may set
  # only KEYMAP; predefine XKBLAYOUT so its expansion survives set -u and the
  # test stays independent of the machine it runs on.
  OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_PROC_ROOT="$tmp_dir/generic/proc" \
    OMARCHY_MKINITCPIO_CONF_DIR="${conf%/*}" PATH="$tmp_dir/generic/bin:$ROOT/bin:$PATH" bash -uc "
    FILES=()
    XKBLAYOUT=us
    source '$baseline_conf'
    $modules_decl
    source '$conf'
    echo \"\${$variable[*]}\"
  "
}

nvidia_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

write_pci_devices
with_kms=$(resolved_hooks "")
without_kms=${with_kms/ kms / }

[[ $with_kms == *" kms "* ]] ||
  fail "baseline HOOKS contains the kms hook" "actual: $with_kms"
pass "baseline HOOKS contains the kms hook"

assert_hooks() {
  local description="$1" modules="$2" expected="$3"
  local actual
  actual=$(resolved_hooks "$modules")

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# NVIDIA RTX class display controller.
write_pci_devices 0x10de:0x030000
assert_hooks "nvidia-only system with early nvidia_drm drops only kms" \
  "$nvidia_modules" "$without_kms"
assert_hooks "nvidia-only system without early nvidia_drm keeps kms" \
  "" "$with_kms"
assert_hooks "unset MODULES under set -u keeps kms without erroring" \
  "unset" "$with_kms"

# AMD integrated graphics next to an NVIDIA 3D controller.
write_pci_devices 0x1002:0x030000 0x10de:0x030200
assert_hooks "hybrid system keeps kms for the iGPU" \
  "$nvidia_modules" "$with_kms"

# NVIDIA audio function only: no display controller found.
write_pci_devices 0x10de:0x040300
assert_hooks "no display controller found keeps kms" \
  "$nvidia_modules" "$with_kms"

write_pci_devices
assert_hooks "empty PCI tree keeps kms" \
  "$nvidia_modules" "$with_kms"

# A device directory missing its class/vendor attributes must not error, and
# counts as inconclusive: it could be another GPU, so kms stays.
write_pci_devices
mkdir -p "$tmp_dir/devices/0000:00:00.0"
assert_hooks "unreadable PCI device keeps kms" \
  "$nvidia_modules" "$with_kms"

# Even next to a readable NVIDIA GPU — the unreadable device may be the iGPU.
write_pci_devices 0x10de:0x030000
mkdir -p "$tmp_dir/devices/0000:01:00.0"
assert_hooks "unreadable device beside an NVIDIA GPU keeps kms" \
  "$nvidia_modules" "$with_kms"

assert_modules() {
  local description="$1" modules="$2" expected="$3" conf="${4:-}"
  local actual
  actual=$(resolved_hooks "$modules" modules "$conf")

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# Hybrid laptop with every output on the Intel iGPU: the NVIDIA card has a DRM
# node but no connectors.
offload_only=(0x8086:0x030000:boot_vga,module=i915,output 0x10de:0x030200:drm)

write_pci_devices "${offload_only[@]}"
assert_hooks "offload-only NVIDIA drops kms" \
  "$nvidia_modules" "$without_kms"
assert_modules "offload-only NVIDIA trades the nvidia modules for the iGPU driver" \
  "thunderbolt $nvidia_modules" "thunderbolt i915"

write_pci_devices 0x1002:0x030000:boot_vga,module=amdgpu,output 0x10de:0x030200:drm
assert_modules "offload-only NVIDIA beside an AMD iGPU early-loads amdgpu" \
  "$nvidia_modules" "amdgpu"

write_pci_devices 0x8086:0x030000:boot_vga,module=i915,output 0x10de:0x030200:output
assert_hooks "hybrid with an output on NVIDIA keeps kms" \
  "$nvidia_modules" "$with_kms"
assert_modules "hybrid with an output on NVIDIA keeps the nvidia modules" \
  "$nvidia_modules" "$nvidia_modules"

write_pci_devices 0x8086:0x030000:module=i915,output 0x10de:0x030200:boot_vga,drm
assert_hooks "NVIDIA as the boot display keeps kms" \
  "$nvidia_modules" "$with_kms"

# No DRM card means nvidia_drm has not bound the GPU, so its outputs are unknown.
write_pci_devices 0x8086:0x030000:boot_vga,module=i915,output 0x10de:0x030200
assert_hooks "NVIDIA without a DRM card keeps kms" \
  "$nvidia_modules" "$with_kms"

write_pci_devices 0x8086:0x030000:boot_vga,output 0x10de:0x030200:drm
assert_hooks "iGPU without a bound driver keeps kms" \
  "$nvidia_modules" "$with_kms"

write_pci_devices "${offload_only[@]}"
mkdir -p "$tmp_dir/devices/0000:0f:00.0"
assert_hooks "unreadable device beside an offload-only NVIDIA keeps kms" \
  "$nvidia_modules" "$with_kms"

write_pci_devices "${offload_only[@]}"
assert_modules "offload-only NVIDIA without early nvidia_drm leaves MODULES alone" \
  "thunderbolt" "thunderbolt"

# A drop-in sorting after the hook config that resets MODULES would strip the
# iGPU driver once kms is gone, so both stay as they were.
mkdir -p "$tmp_dir/conf.d"
cp "$hooks_conf" "$tmp_dir/conf.d/omarchy_hooks.conf"
printf 'MODULES=(pinctrl_tigerlake surface_aggregator)\n' >"$tmp_dir/conf.d/surface_device_modules.conf"
write_pci_devices "${offload_only[@]}"
assert_modules "a later MODULES reset keeps the nvidia modules" \
  "$nvidia_modules" "$nvidia_modules" "$tmp_dir/conf.d/omarchy_hooks.conf"
[[ $(resolved_hooks "$nvidia_modules" hooks "$tmp_dir/conf.d/omarchy_hooks.conf") == "$with_kms" ]] ||
  fail "a later MODULES reset keeps kms"
pass "a later MODULES reset keeps kms"

# A later drop-in that only appends to MODULES is harmless.
printf 'MODULES+=(thunderbolt)\n' >"$tmp_dir/conf.d/surface_device_modules.conf"
assert_modules "a later MODULES append still trades the nvidia modules" \
  "$nvidia_modules" "i915" "$tmp_dir/conf.d/omarchy_hooks.conf"
