#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/apple-fast-resume"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cpus="$tmpdir/cpu"
state="$tmpdir/state"
mkdir -p "$cpus"/cpu{1,2,3}
echo 1 >"$cpus/cpu1/online"
echo 0 >"$cpus/cpu2/online"
echo 1 >"$cpus/cpu3/online"

run_hook() {
  OMARCHY_CPU_SYSFS="$cpus" OMARCHY_APPLE_FAST_RESUME_STATE="$state" bash "$hook" "$1" suspend
}

run_hook pre
[[ $(<"$cpus/cpu1/online") == "0" && $(<"$cpus/cpu3/online") == "0" ]] ||
  fail "sleep takes the online CPUs offline"
pass "sleep takes the online CPUs offline"

run_hook post
[[ $(<"$cpus/cpu1/online") == "1" && $(<"$cpus/cpu3/online") == "1" ]] ||
  fail "resume brings back the CPUs taken offline for sleep"
pass "resume brings back the CPUs taken offline for sleep"

[[ $(<"$cpus/cpu2/online") == "0" ]] || fail "resume leaves a CPU that was already offline off"
pass "resume leaves a CPU that was already offline off"
