#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/drives"

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
log="$work/sudo.log"

# format-drive runs every destructive step through sudo; the stub records the
# command lines so nothing real is ever written, and can fail one step by name.
sudo() {
  printf '%s\n' "$*" >>"$log"
  if [[ -n ${SUDO_FAIL_CMD:-} && $* == *"$SUDO_FAIL_CMD"* ]]; then
    printf 'stubbed failure: %s\n' "$*" >&2
    return 1
  fi
  return 0
}

# Any real block device works, since the stub keeps every command off it; skip
# the device-backed assertions on a machine that exposes none.
device=""
for candidate in /dev/loop[0-9]* /dev/zram[0-9]* /dev/vd[a-z] /dev/sd[a-z] /dev/nvme[0-9]n[0-9] /dev/mmcblk[0-9]; do
  if [[ -b $candidate ]]; then
    device=$candidate
    break
  fi
done

run_format() {
  rc=0
  printf 'y\n' | format-drive "$@" >"$work/out" 2>"$work/err" || rc=$?
}

if [[ -z $device ]]; then
  skip "format-drive: no block device on this machine for the device-backed assertions"
else

# A missing or ordinary path is refused before anything runs, instead of
# reporting success (the old dd even created a regular file under /dev).
run_format /dev/no-such-drive POC
if (( rc == 0 )); then fail "format-drive refuses a path that is not a block device"; fi
pass "format-drive refuses a path that is not a block device"

[[ ! -s $log ]] || fail "format-drive touches a non-block device before refusing it" "$(cat "$log")"
pass "format-drive touches a non-block device before refusing it"

grep -q "not a block device" "$work/out" || fail "format-drive explains the refusal" "$(cat "$work/out")"
pass "format-drive explains the refusal"

grep -q "formatted" "$work/out" && fail "format-drive reports no success for a refused device" "$(cat "$work/out")"
pass "format-drive reports no success for a refused device"

# A failing step stops the sequence instead of running on.
: >"$log"
SUDO_FAIL_CMD=wipefs run_format "$device" POC
if (( rc == 0 )); then fail "format-drive fails when wipefs fails"; fi
pass "format-drive fails when wipefs fails"

if grep -qE '^(dd|parted|mkfs)' "$log"; then fail "format-drive stops at the first failing step" "$(cat "$log")"; fi
pass "format-drive stops at the first failing step"

# A failed filesystem is never reported as formatted (the SD-card case).
: >"$log"
SUDO_FAIL_CMD=mkfs run_format "$device" POC
if (( rc == 0 )); then fail "format-drive fails when mkfs.exfat fails"; fi
pass "format-drive fails when mkfs.exfat fails"

grep -q "formatted" "$work/out" && fail "format-drive reports no success when mkfs.exfat failed" "$(cat "$work/out")"
pass "format-drive reports no success when mkfs.exfat failed"

grep -q "wipefs" "$log" || fail "format-drive still reaches mkfs.exfat on the way" "$(cat "$log")"
pass "format-drive still reaches mkfs.exfat on the way"

# The success path is unchanged: every step runs and the drive is announced.
: >"$log"
run_format "$device" POC
if (( rc != 0 )); then fail "format-drive succeeds on a real block device" "$(cat "$work/err")"; fi
pass "format-drive succeeds on a real block device"

[[ $(grep -c . "$log") -eq 8 ]] || fail "format-drive runs wipefs, dd, three parted calls, partprobe, udevadm and mkfs" "$(cat "$log")"
pass "format-drive runs wipefs, dd, three parted calls, partprobe, udevadm and mkfs"

partition="$([[ $device == *"nvme"* ]] && echo "${device}p1" || echo "${device}1")"
grep -qF "mkfs.exfat -n POC $partition" "$log" || fail "format-drive names the right partition for mkfs" "$(cat "$log")"
pass "format-drive names the right partition for mkfs"

grep -qF "Drive $device formatted as exFAT and labeled 'POC'." "$work/out" || fail "format-drive announces the finished drive" "$(cat "$work/out")"
pass "format-drive announces the finished drive"

fi
