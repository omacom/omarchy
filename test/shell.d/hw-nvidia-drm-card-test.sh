#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a DRM entry as "name:driver", e.g. "card1:nvidia". The
# card's device/driver link points at a directory named after the driver, which
# is all the detector reads. Connector entries ("card1-DP-1") get no driver.
write_drm() {
  rm -rf "$tmp_dir/drm" "$tmp_dir/drivers"
  mkdir -p "$tmp_dir/drm" "$tmp_dir/drivers"

  local spec
  for spec in "$@"; do
    local name=${spec%%:*} driver=${spec#*:}
    mkdir -p "$tmp_dir/drm/$name/device"
    if [[ $driver != "$name" ]]; then
      mkdir -p "$tmp_dir/drivers/$driver"
      ln -s "$tmp_dir/drivers/$driver" "$tmp_dir/drm/$name/device/driver"
    fi
  done
}

hw_nvidia_drm_card() {
  OMARCHY_DRM_CLASS_PATH="$tmp_dir/drm" "$ROOT/bin/omarchy-hw-nvidia-drm-card"
}

assert_card() {
  local description="$1" expected="$2" actual=""
  actual=$(hw_nvidia_drm_card) || actual=""
  [[ $actual == "$expected" ]] || fail "$description" "expected: '$expected', actual: '$actual'"
  pass "$description"
}

write_drm card0:simple-framebuffer card1:nvidia card1-DP-1 card1-eDP-1
assert_card "NVIDIA beside simpledrm is pinned, connectors are ignored" /dev/dri/card1

write_drm card0:nvidia card1:efi-framebuffer
assert_card "any firmware framebuffer driver counts" /dev/dri/card0

write_drm card0:nvidia
assert_card "NVIDIA alone keeps autodetection" ""

write_drm card0:simple-framebuffer card1:amdgpu card2:nvidia
assert_card "a hybrid machine keeps autodetection" ""

write_drm card0:amdgpu card1:nvidia
assert_card "a hybrid machine without a firmware framebuffer keeps autodetection" ""

write_drm card0:simple-framebuffer card1:i915
assert_card "no NVIDIA card keeps autodetection" ""

write_drm
assert_card "no DRM cards at all keeps autodetection" ""
