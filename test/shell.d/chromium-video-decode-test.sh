#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""

export PATH="$ROOT/bin:$PATH"

cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

TMPDIR=$(mktemp -d)

# A GSP card (Turing or newer) that drives the display is the one Omarchy points
# at nvidia-vaapi-driver; anything below 0x1e00 takes the other branch, and a
# hybrid laptop whose iGPU drives the display keeps its own VA-API driver.
fake_pci_device() {
  local tree="$1" slot="$2" vendor="$3" device="$4" boot_vga="${5:-}"
  local dir="$TMPDIR/pci-$tree/$slot"

  mkdir -p "$dir"
  echo "$vendor" > "$dir/vendor"
  echo "0x030000" > "$dir/class"
  echo "$device" > "$dir/device"
  if [[ -n $boot_vga ]]; then
    echo "$boot_vga" > "$dir/boot_vga"
  fi
}

fake_gpu() {
  local name="$1" device="$2"

  fake_pci_device "$name" 0000:01:00.0 0x10de "$device"
  printf '%s\n' "$TMPDIR/pci-$name"
}

gsp_devices=$(fake_gpu gsp 0x2206)
pre_gsp_devices=$(fake_gpu pre-gsp 0x1380)

fake_pci_device intel-hybrid 0000:00:02.0 0x8086 0xa7a0 1
fake_pci_device intel-hybrid 0000:01:00.0 0x10de 0x28a1 0
intel_hybrid_devices="$TMPDIR/pci-intel-hybrid"

fake_pci_device amd-hybrid 0000:06:00.0 0x1002 0x15bf 1
fake_pci_device amd-hybrid 0000:01:00.0 0x10de 0x2860 0
amd_hybrid_devices="$TMPDIR/pci-amd-hybrid"

fake_pci_device nvidia-display 0000:00:02.0 0x8086 0x4680 0
fake_pci_device nvidia-display 0000:01:00.0 0x10de 0x2206 1
nvidia_display_devices="$TMPDIR/pci-nvidia-display"
no_gpu_devices="$TMPDIR/pci-empty"
mkdir -p "$no_gpu_devices"

flags_for() {
  local name="$1"
  local home="$TMPDIR/home-$name"

  mkdir -p "$home/.config"
  cp "$ROOT/config/chromium-flags.conf" "$home/.config/chromium-flags.conf"
  printf '%s\n' "$home"
}

force_decode() {
  local home="$1" devices="$2"
  shift 2

  HOME="$home" OMARCHY_PCI_DEVICES_PATH="$devices" bash -c '
    source "$1/install/helpers/chromium-video-decode.sh"
    chromium_force_software_video_decode "${@:2}"
  ' bash "$ROOT" "$@"
}

flag="--disable-accelerated-video-decode"

home=$(flags_for gsp)
force_decode "$home" "$gsp_devices"
grep -qxF -- "$flag" "$home/.config/chromium-flags.conf" ||
  fail "software decode is forced on an NVIDIA GPU with GSP firmware"
pass "software decode is forced on an NVIDIA GPU with GSP firmware"

force_decode "$home" "$gsp_devices"
(( $(grep -cxF -- "$flag" "$home/.config/chromium-flags.conf") == 1 )) ||
  fail "running twice appends the flag once"
pass "running twice appends the flag once"

home=$(flags_for pre-gsp)
force_decode "$home" "$pre_gsp_devices"
if grep -qxF -- "$flag" "$home/.config/chromium-flags.conf"; then
  fail "a pre-Turing NVIDIA GPU keeps hardware decode"
fi
pass "a pre-Turing NVIDIA GPU keeps hardware decode"

home=$(flags_for intel-hybrid)
force_decode "$home" "$intel_hybrid_devices"
if grep -qxF -- "$flag" "$home/.config/chromium-flags.conf"; then
  fail "a hybrid laptop with an Intel iGPU driving the display keeps hardware decode"
fi
pass "a hybrid laptop with an Intel iGPU driving the display keeps hardware decode"

home=$(flags_for amd-hybrid)
force_decode "$home" "$amd_hybrid_devices"
if grep -qxF -- "$flag" "$home/.config/chromium-flags.conf"; then
  fail "a hybrid laptop with an AMD iGPU driving the display keeps hardware decode"
fi
pass "a hybrid laptop with an AMD iGPU driving the display keeps hardware decode"

home=$(flags_for nvidia-display)
force_decode "$home" "$nvidia_display_devices"
grep -qxF -- "$flag" "$home/.config/chromium-flags.conf" ||
  fail "software decode is forced when NVIDIA drives the display next to an iGPU"
pass "software decode is forced when NVIDIA drives the display next to an iGPU"

home=$(flags_for none)
force_decode "$home" "$no_gpu_devices"
if grep -qxF -- "$flag" "$home/.config/chromium-flags.conf"; then
  fail "a machine without an NVIDIA GPU keeps hardware decode"
fi
pass "a machine without an NVIDIA GPU keeps hardware decode"

home=$(flags_for brave)
cp "$ROOT/config/chromium-flags.conf" "$home/.config/brave-flags.conf"
force_decode "$home" "$gsp_devices"
grep -qxF -- "$flag" "$home/.config/brave-flags.conf" ||
  fail "every Chromium-family flags file the user has is covered"
pass "every Chromium-family flags file the user has is covered"

home=$(flags_for single)
cp "$ROOT/config/chromium-flags.conf" "$home/.config/custom-flags.conf"
force_decode "$home" "$gsp_devices" "$home/.config/custom-flags.conf"
grep -qxF -- "$flag" "$home/.config/custom-flags.conf" ||
  fail "a named flags file is written"
if grep -qxF -- "$flag" "$home/.config/chromium-flags.conf"; then
  fail "naming a flags file leaves the default ones alone"
fi
pass "a named flags file is written and the default ones are left alone"

home=$(flags_for no-newline)
printf '%s' "--enable-features=Foo" > "$home/.config/chromium-flags.conf"
force_decode "$home" "$gsp_devices"
grep -qxF -- "--enable-features=Foo" "$home/.config/chromium-flags.conf" &&
  grep -qxF -- "$flag" "$home/.config/chromium-flags.conf" ||
  fail "a flags file without a trailing newline keeps its last flag intact"
pass "a flags file without a trailing newline keeps its last flag intact"

home=$(flags_for missing)
rm "$home/.config/chromium-flags.conf"
force_decode "$home" "$gsp_devices"
if [[ -f $home/.config/chromium-flags.conf ]]; then
  fail "a flags file the user does not have is not created"
fi
pass "a flags file the user does not have is not created"
