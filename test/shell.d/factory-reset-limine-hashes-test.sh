#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Factory reset checks the hash of every boot file limine.conf names before it
# hands over a staged reset: the UKI, or the kernel and initramfs where UKIs are
# off. Snapshot copies under limine_history are not rebuilt, so not checked.
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

eval "$(sed -n '/^verify_limine_hashes() {$/,/^}$/p' "$ROOT/bin/omarchy-system-factory-reset")"
declare -F verify_limine_hashes >/dev/null || fail "factory reset defines verify_limine_hashes"
fail_reset() { echo "$*"; exit 1; }

# $1 case; then limine.conf lines, where HASH:<file> stands for that file's hash.
boot() {
  local case_dir="$scratch/$1" line file
  shift
  mkdir -p "$case_dir/boot/EFI/Linux" "$case_dir/boot/abc/linux-aarch64" "$case_dir/boot/abc/limine_history"
  printf 'uki\n' >"$case_dir/boot/EFI/Linux/omarchy_linux.efi"
  printf 'kernel\n' >"$case_dir/boot/abc/linux-aarch64/vmlinuz-linux-aarch64"
  printf 'initramfs\n' >"$case_dir/boot/abc/linux-aarch64/initramfs-linux-aarch64.img"
  printf 'old\n' >"$case_dir/boot/abc/limine_history/vmlinuz-linux-aarch64_1"
  : >"$case_dir/boot/limine.conf"
  for line in "$@"; do
    while [[ $line =~ HASH:([^[:space:]]+) ]]; do
      file=${BASH_REMATCH[1]}
      line=${line/HASH:$file/$(b2sum "$case_dir/boot$file" 2>/dev/null | cut -d' ' -f1 || echo 0)}
    done
    printf '%s\n' "$line" >>"$case_dir/boot/limine.conf"
  done
}
verify() { (fail() { fail_reset "$@"; }; verify_limine_hashes "$scratch/$1" /boot) 2>&1; }

boot uki "    path: boot():/EFI/Linux/omarchy_linux.efi#HASH:/EFI/Linux/omarchy_linux.efi"
verify uki >/dev/null || fail "a matching UKI passes"

kernel=/abc/linux-aarch64/vmlinuz-linux-aarch64
initramfs=/abc/linux-aarch64/initramfs-linux-aarch64.img
boot direct "    protocol: linux" "    module_path: boot():$initramfs#HASH:$initramfs" "    path: boot():$kernel#HASH:$kernel"
verify direct >/dev/null || fail "a matching kernel and initramfs pass"

boot stale-initramfs "    module_path: boot():$initramfs#0123abcd" "    path: boot():$kernel#HASH:$kernel"
output=$(verify stale-initramfs) && fail "a stale initramfs hash is refused"
[[ $output == *"hash for $initramfs does not match"* ]] || fail "a stale initramfs hash names the file" "$output"

boot missing-kernel "    module_path: boot():$initramfs#HASH:$initramfs" "    path: boot():/abc/linux-aarch64/vmlinuz-gone#0123abcd"
output=$(verify missing-kernel) && fail "a missing kernel is refused"
[[ $output == *"points at missing /abc/linux-aarch64/vmlinuz-gone"* ]] || fail "a missing kernel names the file" "$output"

boot history "    path: boot():$kernel#HASH:$kernel" "    path: boot():/abc/limine_history/vmlinuz-linux-aarch64_1#0123abcd"
verify history >/dev/null || fail "snapshot copies under limine_history are left alone"
pass "factory reset checks the UKI, or the kernel and initramfs, and leaves snapshot copies alone"
