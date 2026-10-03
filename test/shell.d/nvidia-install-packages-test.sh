#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Stop at the driver transaction, before the setup script writes to /etc.
assert_packages() {
  local description="$1" architecture="$2" driver="$3" expected="$4"
  local actual
  actual=$(TEST_ARCH="$architecture" TEST_DRIVER="$driver" \
    bash -euo pipefail -c '
      lspci() { printf "%s\n" "3D controller: NVIDIA Corporation"; }
      uname() { printf "%s\n" "$TEST_ARCH"; }
      omarchy-hw-nvidia-gsp() { [[ $TEST_DRIVER == "gsp" ]]; }
      omarchy-hw-nvidia-without-gsp() { [[ $TEST_DRIVER == "legacy" ]]; }
      omarchy-pkg-add() {
        printf "%s\n" "$*"
        exit 0
      }
      source "$ROOT/install/hardware/nvidia.sh"
    ')
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; actual: $actual"
  pass "$description"
}

assert_packages "ARM GSP selection uses native packages" aarch64 gsp \
  'nvidia-open-dkms nvidia-utils libva-nvidia-driver'
assert_packages "ARM legacy selection omits x86 multilib" aarch64 legacy \
  'nvidia-580xx-dkms nvidia-580xx-utils'
assert_packages "x86 GSP package selection stays unchanged" x86_64 gsp \
  'nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver'
assert_packages "x86 legacy package selection stays unchanged" x86_64 legacy \
  'nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils'
