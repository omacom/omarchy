#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/install/hardware/vulkan.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "$TEST_LSPCI"
SH

cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

run_script() {
  : >"$test_tmp/calls.log"
  PATH="$test_tmp/bin:$PATH" \
    TEST_LSPCI="$1" \
    CALL_LOG="$test_tmp/calls.log" \
    bash "$script"
  cat "$test_tmp/calls.log"
}

virtio='00:02.0 VGA compatible controller: Red Hat, Inc. Virtio 1.0 GPU (rev 01)'
got=$(run_script "$virtio")
[[ $got == vulkan-virtio ]] || fail "virtio GPU installs vulkan-virtio, got: $got"
pass "virtio GPU installs vulkan-virtio"

virtio3d='00:02.0 3D controller: Red Hat, Inc. Virtio 1.0 GPU (rev 01)'
got=$(run_script "$virtio3d")
[[ $got == vulkan-virtio ]] || fail "virtio 3D controller installs vulkan-virtio, got: $got"
pass "virtio 3D controller installs vulkan-virtio"

intel='00:02.0 VGA compatible controller: Intel Corporation Device 46a6'
got=$(run_script "$intel")
[[ $got == vulkan-intel ]] || fail "Intel GPU still installs vulkan-intel, got: $got"
pass "Intel GPU still installs vulkan-intel"

none='00:00.0 Host bridge: Intel Corporation Device 1234'
got=$(run_script "$none")
[[ -z $got ]] || fail "no display controller installs nothing, got: $got"
pass "no display controller installs nothing"

bus='3d:00.0 Non-Volatile memory controller: Intel Corporation Device abcd'
got=$(run_script "$bus")
[[ -z $got ]] || fail "PCI bus id 3d must not select a Vulkan driver, got: $got"
pass "PCI bus id 3d does not select a Vulkan driver"