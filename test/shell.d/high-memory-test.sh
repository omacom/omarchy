#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

user_systemd_dir="$test_tmp/systemd/user"
dropin="$user_systemd_dir/app.slice.d/20-omarchy-high-memory.conf"
meminfo="$test_tmp/meminfo"

run_high_memory() {
  OMARCHY_MEMINFO="$meminfo" \
    OMARCHY_USER_SYSTEMD_DIR="$user_systemd_dir" \
    bash "$ROOT/install/hardware/high-memory.sh"
}

# 32 GiB machine (~31 GiB MemTotal): reserves 10% (3100 MiB) -> 27900M.
printf 'MemTotal:       31744000 kB\n' >"$meminfo"
run_high_memory
[[ -f $dropin ]] && grep -Fqx 'MemoryMax=27900M' "$dropin" ||
  fail "32 GiB install writes 10%-reserved app.slice MemoryMax" "$(cat "$dropin" 2>/dev/null || true)"
pass "32 GiB installs reserve 10% outside app.slice"

# 128 GiB machine (~125 GiB MemTotal): reserve caps at 11 GiB (11264 MiB).
printf 'MemTotal:      131072000 kB\n' >"$meminfo"
run_high_memory
grep -Fqx 'MemoryMax=116736M' "$dropin" ||
  fail "128 GiB install caps reserve at 11 GiB" "$(cat "$dropin" 2>/dev/null || true)"
pass "128 GiB installs cap reserve at 11 GiB instead of taking a full 10%"

# 256 GiB machine: reserve stays capped at 11 GiB.
printf 'MemTotal:      262144000 kB\n' >"$meminfo"
run_high_memory
grep -Fqx 'MemoryMax=244736M' "$dropin" ||
  fail "256 GiB install keeps reserve capped at 11 GiB" "$(cat "$dropin" 2>/dev/null || true)"
pass "256 GiB installs keep reserve capped at 11 GiB"

# Moving below 28 GiB (e.g. 16 GiB) cleans up stale drop-in.
printf 'MemTotal:       15921048 kB\n' >"$meminfo"
run_high_memory
[[ ! -e $dropin ]] ||
  fail "16 GiB install removes stale high-memory app.slice drop-in"
pass "16 GiB and smaller installs stay uncapped and clean up stale overrides"

# Corrupt /proc/meminfo exits cleanly without creating a drop-in.
printf 'corrupt\n' >"$meminfo"
run_high_memory
[[ ! -e $dropin ]] ||
  fail "unreadable MemTotal writes no drop-in"
pass "unreadable MemTotal exits cleanly without writing overrides"
