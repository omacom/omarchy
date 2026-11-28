#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The MacBook Pro 11,2 resume hook on a made-up sysfs: which cores "pre"
# takes offline before suspend, and which ones "post" puts back.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
hook=$ROOT/default/systemd/system-sleep/macbookpro11-cpu-resume
unset SYSTEMD_SLEEP_ACTION

# cpu0 is the boot CPU and has no online switch. The owner took cpu2 offline.
cpus() {
  rm -rf "$tmp/cpu"
  mkdir -p "$tmp/cpu/cpu0" "$tmp/cpu/cpu1" "$tmp/cpu/cpu2" "$tmp/cpu/cpu3"
  echo 1 >"$tmp/cpu/cpu1/online"
  echo 0 >"$tmp/cpu/cpu2/online"
  echo 1 >"$tmp/cpu/cpu3/online"
}

state() {
  echo "$(<"$tmp/cpu/cpu1/online")$(<"$tmp/cpu/cpu2/online")$(<"$tmp/cpu/cpu3/online")"
}

run_hook() {
  OMARCHY_MBP11_CPU_DIR=$tmp/cpu OMARCHY_MBP11_CPU_MARKER=$1 bash "$hook" "$2" "$3"
}

cpus
run_hook "$tmp/marker" pre suspend
[[ $(state) == 000 ]] || fail "pre takes the online cores offline" "$(state)"
run_hook "$tmp/marker" pre suspend
run_hook "$tmp/marker" post suspend
[[ $(state) == 101 && ! -e $tmp/marker ]] || fail "post puts back only the cores pre took offline" "$(state)"
pass "a repeated pre still restores online cores and leaves the owner's offline core alone"

cpus
run_hook "$tmp/marker" pre hibernate
[[ $(state) == 101 && ! -e $tmp/marker ]] || fail "hibernate changes the cores" "$(state)"
pass "hibernate leaves the cores alone"

# Without a record resume could not bring a core back, so none goes offline.
cpus
run_hook "$tmp/missing/marker" pre suspend
[[ $(state) == 101 ]] || fail "pre takes cores offline with nowhere to record them" "$(state)"
cpus
run_hook /dev/full pre suspend
[[ $(state) == 101 ]] || fail "pre leaves a core offline when its line can't be written" "$(state)"
pass "a core that can't be recorded stays online"
