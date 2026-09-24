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

# A GSP card (Turing or newer) is the one Omarchy points at nvidia-vaapi-driver;
# anything below 0x1e00 takes the other branch and keeps hardware decode.
fake_gpu() {
  local name="$1" device="$2"
  local dir="$TMPDIR/pci-$name/0000:01:00.0"

  mkdir -p "$dir"
  echo "0x10de" > "$dir/vendor"
  echo "0x030000" > "$dir/class"
  echo "$device" > "$dir/device"
  printf '%s\n' "$TMPDIR/pci-$name"
}

gsp_devices=$(fake_gpu gsp 0x2206)
pre_gsp_devices=$(fake_gpu pre-gsp 0x1380)
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
force_decode "$home" "$gsp_devices" "$home/.config/chromium-flags.conf"
grep -qxF -- "$flag" "$home/.config/chromium-flags.conf" ||
  fail "a named flags file is written"
pass "a named flags file is written"

home=$(flags_for missing)
rm "$home/.config/chromium-flags.conf"
force_decode "$home" "$gsp_devices"
if [[ -f $home/.config/chromium-flags.conf ]]; then
  fail "a flags file the user does not have is not created"
fi
pass "a flags file the user does not have is not created"
