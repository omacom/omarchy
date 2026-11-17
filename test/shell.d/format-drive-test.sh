#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$ROOT/default/bash/fns/drives"

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export SUDO_LOG="$work/sudo.log"
mkdir "$work/bin"

# format-drive runs every destructive step through sudo; the stub records the
# command lines and can fail one step by name.
cat >"$work/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_LOG"
if [[ -n ${SUDO_FAIL_CMD:-} && $* == *"$SUDO_FAIL_CMD"* ]]; then
  printf 'stubbed failure: %s\n' "$*" >&2
  exit 1
else
  exit 0
fi
SH
chmod +x "$work/bin/sudo"

# PATH holds only the stub, so a step that ever drops sudo finds no real command
# by name to run against the device below.
run_format() {
  rc=0
  printf 'y\n' | PATH="$work/bin" format-drive "$@" >"$work/out" 2>"$work/err" || rc=$?
}

# A missing or ordinary path is refused before anything runs, instead of
# reporting success (the old dd even created a regular file under /dev).
run_format /dev/no-such-drive POC
if (( rc == 0 )); then fail "format-drive refuses a path that is not a block device"; fi
pass "format-drive refuses a path that is not a block device"

[[ ! -s $SUDO_LOG ]] || fail "format-drive runs nothing before refusing a non-block device" "$(cat "$SUDO_LOG")"
pass "format-drive runs nothing before refusing a non-block device"

grep -q "not a block device" "$work/out" || fail "format-drive explains the refusal" "$(cat "$work/out")"
pass "format-drive explains the refusal"

grep -q "formatted" "$work/out" && fail "format-drive reports no success for a refused device" "$(cat "$work/out")"
pass "format-drive reports no success for a refused device"

# Any block device passes the check, and the stub keeps every command off it;
# skip the device-backed assertions on a machine that exposes none.
device=""
for candidate in /dev/loop[0-9]* /dev/zram[0-9]* /dev/vd[a-z] /dev/sd[a-z] /dev/nvme[0-9]n[0-9] /dev/mmcblk[0-9]; do
  if [[ -b $candidate ]]; then
    device=$candidate
    break
  fi
done

if [[ -z $device ]]; then
  skip "format-drive: no block device on this machine for the device-backed assertions"
else
  # A failing step stops the sequence instead of running on.
  : >"$SUDO_LOG"
  SUDO_FAIL_CMD=wipefs run_format "$device" POC
  if (( rc == 0 )); then fail "format-drive fails when wipefs fails"; fi
  pass "format-drive fails when wipefs fails"

  if grep -qE '^(dd|parted|mkfs)' "$SUDO_LOG"; then fail "format-drive stops at the first failing step" "$(cat "$SUDO_LOG")"; fi
  pass "format-drive stops at the first failing step"

  # A failed filesystem is never reported as formatted (the SD-card case).
  : >"$SUDO_LOG"
  SUDO_FAIL_CMD=mkfs run_format "$device" POC
  if (( rc == 0 )); then fail "format-drive fails when mkfs.exfat fails"; fi
  pass "format-drive fails when mkfs.exfat fails"

  grep -q "^mkfs.exfat -n POC " "$SUDO_LOG" || fail "format-drive reaches mkfs.exfat before failing" "$(cat "$SUDO_LOG")"
  pass "format-drive reaches mkfs.exfat before failing"

  grep -q "formatted" "$work/out" && fail "format-drive reports no success when mkfs.exfat failed" "$(cat "$work/out")"
  pass "format-drive reports no success when mkfs.exfat failed"

  # When every step succeeds, the drive is announced.
  : >"$SUDO_LOG"
  run_format "$device" POC
  if (( rc != 0 )); then fail "format-drive succeeds when every step succeeds" "$(cat "$work/err")"; fi
  pass "format-drive succeeds when every step succeeds"

  grep -qF "Drive $device formatted as exFAT and labeled 'POC'." "$work/out" || fail "format-drive announces the finished drive" "$(cat "$work/out")"
  pass "format-drive announces the finished drive"
fi
