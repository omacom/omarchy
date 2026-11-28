#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

zram_dir="$test_tmp/zram-generator.conf.d"
sysctl_dir="$test_tmp/sysctl.d"
meminfo="$test_tmp/meminfo"

run_low_memory() {
  OMARCHY_MEMINFO="$meminfo" \
    OMARCHY_ZRAM_DIR="$zram_dir" \
    OMARCHY_SYSCTL_DIR="$sysctl_dir" \
    bash "$ROOT/install/hardware/low-memory.sh"
}

printf 'MemTotal:        8000000 kB\n' >"$meminfo"
run_low_memory
[[ -f $zram_dir/95-omarchy-low-memory.conf && -f $sysctl_dir/zz-omarchy-low-memory.conf ]] ||
  fail "8 GiB install writes low-memory zram and sysctl overrides"
pass "8 GiB installs write low-memory zram and swappiness overrides"

printf 'MemTotal:       12000000 kB\n' >"$meminfo"
run_low_memory
[[ ! -e $zram_dir/95-omarchy-low-memory.conf && ! -e $sysctl_dir/zz-omarchy-low-memory.conf ]] ||
  fail "12 GiB and larger installs remove stale low-memory overrides"
pass "12 GiB and larger installs keep the default profile and clean up stale overrides"

printf 'MemTotal:        4000000 kB\n' >"$meminfo"
run_low_memory
[[ -f $zram_dir/95-omarchy-low-memory.conf && -f $sysctl_dir/zz-omarchy-low-memory.conf ]] ||
  fail "4 GiB install writes low-memory overrides"
pass "4 GiB installs write low-memory overrides"

printf 'corrupt\n' >"$meminfo"
rm -rf "$zram_dir" "$sysctl_dir"
run_low_memory
[[ ! -e $zram_dir && ! -e $sysctl_dir ]] ||
  fail "unreadable MemTotal writes no overrides"
pass "unreadable MemTotal exits cleanly without writing overrides"
