#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/devices/0000:01:00.0"

# Execute the real installer with only its absolute configuration destination
# relocated. Package installation and PCI config-space access are stubbed.
sed "s|/etc/|$tmp/etc/|g" "$ROOT/install/hardware/nvidia.sh" >"$tmp/nvidia.sh"
cat >"$tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_NVIDIA_PKGS"
SH
cat >"$tmp/bin/lspci" <<'SH'
#!/bin/bash
echo called >>"$OMARCHY_TEST_NVIDIA_LSPCI"
echo 'NVIDIA VGA controller'
SH
chmod +x "$tmp/bin/"*

run_layout() {
  local vendor=$1 device=$2 class=$3
  printf '%s\n' "$vendor" >"$tmp/devices/0000:01:00.0/vendor"
  printf '%s\n' "$device" >"$tmp/devices/0000:01:00.0/device"
  printf '%s\n' "$class" >"$tmp/devices/0000:01:00.0/class"
  rm -rf "$tmp/etc"
  : >"$tmp/pkgs"
  : >"$tmp/lspci"
  OMARCHY_PCI_DEVICES_PATH="$tmp/devices" \
    OMARCHY_TEST_NVIDIA_PKGS="$tmp/pkgs" OMARCHY_TEST_NVIDIA_LSPCI="$tmp/lspci" \
    PATH="$tmp/bin:$ROOT/bin:$PATH" \
    bash -e "$tmp/nvidia.sh" >"$tmp/output"
  [[ ! -s $tmp/lspci ]] || fail "installer never queries PCI config space"
}

run_layout 0x8086 0x1e04 0x030000
[[ ! -s $tmp/pkgs && ! -s $tmp/output && ! -e $tmp/etc ]] ||
  fail "non-NVIDIA displays skip the driver block"
pass "non-NVIDIA displays do not enter NVIDIA installation"

run_layout 0x10de 0x1e04 0x040300
[[ ! -s $tmp/pkgs && ! -s $tmp/output && ! -e $tmp/etc ]] ||
  fail "NVIDIA audio functions skip the driver block"
pass "NVIDIA audio functions do not install graphics drivers"

run_layout 0x10de 0x1e04 0x030000
[[ $(cat "$tmp/pkgs") == $'nvidia-open-dkms\nnvidia-utils\nlib32-nvidia-utils\nlibva-nvidia-driver' ]] ||
  fail "GSP displays install the open driver package set"
[[ $(cat "$tmp/etc/modprobe.d/nvidia.conf") == 'options nvidia_drm modeset=1' ]] ||
  fail "NVIDIA KMS config is written"
[[ $(cat "$tmp/etc/mkinitcpio.conf.d/nvidia.conf") == 'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' ]] ||
  fail "NVIDIA early-loading config is written"
pass "GSP displays install the open driver and its configuration"

run_layout 0x10de 0x1b80 0x030000
[[ $(cat "$tmp/pkgs") == $'nvidia-580xx-dkms\nnvidia-580xx-utils\nlib32-nvidia-580xx-utils' ]] ||
  fail "pre-GSP displays install the 580xx package set"
pass "pre-GSP displays install the 580xx driver"

run_layout 0x10de 0x1180 0x030000
[[ ! -s $tmp/pkgs && ! -e $tmp/etc ]] || fail "unsupported GPUs install no packages"
grep -Fq 'No compatible driver' "$tmp/output" || fail "unsupported GPU reports the driver limitation"
pass "unsupported NVIDIA displays report the driver limitation"
