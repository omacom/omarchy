#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"

# Build fake sysfs devices from class:driver specs (an empty driver means unbound).
set_devices() {
  rm -rf "$tmp_dir/devices" "$tmp_dir/drivers"
  mkdir -p "$tmp_dir/devices"
  local slot=0 spec class driver
  for spec in "$@"; do
    IFS=: read -r class driver <<<"$spec"
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "$class" >"$tmp_dir/devices/$slot/class"
    if [[ -n $driver ]]; then
      mkdir -p "$tmp_dir/drivers/$driver"
      ln -s "$tmp_dir/drivers/$driver" "$tmp_dir/devices/$slot/driver"
    fi
    slot=$((slot + 1))
  done
}

while IFS='|' read -r description expected devices; do
  set_devices $devices
  status=0
  omarchy-hw-radeon || status=$?
  [[ $status == "$expected" ]] || fail "hw-radeon: $description" "expected $expected, got $status"
  pass "hw-radeon: $description"
done <<'CASES'
Radeon HD 6770M with Intel HD 3000|0|0x038000:i915 0x030000:radeon
TeraScale display only|0|0x030000:radeon
GCN on amdgpu|1|0x030000:amdgpu
Intel only|1|0x030000:i915
Unbound display device|1|0x030000:
Radeon audio function only|1|0x040300:radeon
No PCI devices|1|
CASES

flags="$tmp_dir/chromium-flags.conf"
printf '%s\n' '--ozone-platform=wayland' >"$flags"

set_devices 0x030000:radeon
omarchy-install-chromium-legacy-gpu "$flags" >/dev/null
grep -qxF -- '--disable-gpu-compositing' "$flags" || fail "legacy radeon disables Chromium GPU compositing"
pass "legacy radeon disables Chromium GPU compositing"

omarchy-install-chromium-legacy-gpu "$flags" >/dev/null
(( $(grep -cxF -- '--disable-gpu-compositing' "$flags") == 1 )) || fail "legacy GPU flag is added once"
pass "legacy GPU flag is added once"

HOME="$tmp_dir/home" omarchy-install-chromium-legacy-gpu >/dev/null
[[ ! -e $tmp_dir/home/.config/chromium-flags.conf ]] || fail "legacy GPU setup does not create a missing flags file"
pass "legacy GPU setup does not create a missing flags file"

printf '%s\n' '--ozone-platform=wayland' >"$flags"
set_devices 0x030000:amdgpu
omarchy-install-chromium-legacy-gpu "$flags" >/dev/null
if grep -q -- '--disable-gpu-compositing' "$flags"; then
  fail "legacy GPU setup leaves other drivers on GPU compositing"
fi
pass "legacy GPU setup leaves other drivers on GPU compositing"
