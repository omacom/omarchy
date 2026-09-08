#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise package selection without installing packages or reaching the /etc
# writes below it. The final driver transaction exits the child shell.
assert_packages() {
  local description="$1" architecture="$2" kernel="$3" driver="$4" expected="$5"
  local actual
  actual=$(TEST_ARCH="$architecture" TEST_KERNEL="$kernel" TEST_DRIVER="$driver" \
    bash -euo pipefail -c '
      lspci() { printf "%s\n" "3D controller: NVIDIA Corporation"; }
      uname() { printf "%s\n" "$TEST_ARCH"; }
      pacman() {
        [[ $# == 2 && $1 == "-Qqs" ]] || exit 1
        printf "%s\n" "$TEST_KERNEL" | grep -E -- "$2"
      }
      omarchy-hw-nvidia-gsp() { [[ $TEST_DRIVER == "gsp" ]]; }
      omarchy-hw-nvidia-without-gsp() { [[ $TEST_DRIVER == "legacy" ]]; }
      omarchy-pkg-add() {
        printf "%s\n" "$*"
        if [[ $1 != *-headers ]]; then
          exit 0
        fi
      }
      source "$ROOT/install/hardware/nvidia.sh"
    ')
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; actual: $actual"
  pass "$description"
}

assert_packages "ARM generic kernel gets matching headers and native GSP packages" aarch64 linux-aarch64 gsp \
  $'linux-aarch64-headers\nnvidia-open-dkms nvidia-utils libva-nvidia-driver'
assert_packages "Spark kernel gets matching headers and native GSP packages" aarch64 linux-dgx-spark gsp \
  $'linux-dgx-spark-headers\nnvidia-open-dkms nvidia-utils libva-nvidia-driver'
assert_packages "ARM legacy selection omits x86 multilib" aarch64 linux-aarch64 legacy \
  $'linux-aarch64-headers\nnvidia-580xx-dkms nvidia-580xx-utils'

for kernel in linux linux-zen linux-lts linux-hardened linux-t2 linux-ptl; do
  assert_packages "x86 GSP packages and $kernel headers stay unchanged" x86_64 "$kernel" gsp \
    "$kernel-headers"$'\nnvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver'
done
assert_packages "x86 legacy packages stay unchanged" x86_64 linux legacy \
  $'linux-headers\nnvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils'
assert_packages "Unrecognized kernel does not invent a headers package" aarch64 linux-custom gsp \
  'nvidia-open-dkms nvidia-utils libva-nvidia-driver'
