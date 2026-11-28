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

runtime_dir="$test_tmp/run-systemd-user"
graphical_cap="$runtime_dir/app-graphical.slice.d/10-omarchy-high-memory.conf"

run_high_memory() {
  OMARCHY_MEMINFO="$meminfo" \
    OMARCHY_USER_RUNTIME_DIR="$runtime_dir" \
    "$ROOT/bin/omarchy-apply-high-memory" "$@"
}

# Just below the 56 GiB threshold stays uncapped.
printf 'MemTotal:       58720255 kB\n' >"$meminfo"
run_high_memory
[[ ! -e $graphical_cap ]] ||
  fail "just below 56 GiB stays uncapped"
pass "just below 56 GiB stays uncapped"

# 56 GiB exact threshold writes cap reserving 11 GiB (57344 - 11264 = 46080M).
printf 'MemTotal:       58720256 kB\n' >"$meminfo"
run_high_memory
grep -Fqx 'MemoryMax=46080M' "$graphical_cap" ||
  fail "56 GiB boundary reserves 11 GiB outside app-graphical.slice" "$(cat "$graphical_cap" 2>/dev/null || true)"
pass "56 GiB boundary writes app-graphical.slice MemoryMax with 11 GiB reserve"

# 128 GiB machine (~125 GiB MemTotal) reserves 11 GiB -> 116736M.
printf 'MemTotal:      131072000 kB\n' >"$meminfo"
run_high_memory
grep -Fqx 'MemoryMax=116736M' "$graphical_cap" ||
  fail "128 GiB machine reserves 11 GiB outside app-graphical.slice" "$(cat "$graphical_cap" 2>/dev/null || true)"
pass "128 GiB machine reserves 11 GiB outside app-graphical.slice"

# Corrupt or missing /proc/meminfo on a fresh directory exits cleanly and writes nothing.
printf 'corrupt\n' >"$meminfo"
rm -rf "$runtime_dir"
run_high_memory
[[ ! -e $runtime_dir ]] ||
  fail "unreadable MemTotal writes no runtime app-graphical.slice cap"
rm -f "$meminfo"
run_high_memory
[[ ! -e $runtime_dir ]] ||
  fail "missing meminfo exits cleanly without writing app-graphical.slice cap"
pass "corrupt or missing meminfo exits cleanly without writing app-graphical.slice cap"

# Unknown arguments fail without touching the runtime directory.
printf 'MemTotal:      131072000 kB\n' >"$meminfo"
if run_high_memory --bogus >/dev/null 2>&1; then
  fail "unknown arguments must be rejected"
fi
[[ ! -e $runtime_dir ]] ||
  fail "unknown arguments must not write a drop-in"
pass "unknown arguments are rejected cleanly"
