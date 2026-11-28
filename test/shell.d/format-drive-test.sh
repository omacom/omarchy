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

# The failure paths need a real block device to pass the refusal; only the stub may run against it.
unset -f sudo
[[ $(PATH="$work/bin" type -t sudo) == file ]] || fail "format-drive runs the sudo stub"
device=$(find /dev -maxdepth 1 -type b -print -quit 2>/dev/null) || true
if [[ -b $device ]]; then
  : >"$SUDO_LOG"
  SUDO_FAIL_CMD=wipefs run_format "$device" POC
  (( rc != 0 )) && grep -q '^wipefs' "$SUDO_LOG" && ! grep -qE '^(dd|parted|mkfs)' "$SUDO_LOG" ||
    fail "format-drive stops when wipefs fails" "$(cat "$SUDO_LOG")"
  : >"$SUDO_LOG"
  SUDO_FAIL_CMD=mkfs run_format "$device" POC
  (( rc != 0 )) && grep -q '^mkfs.exfat' "$SUDO_LOG" && ! grep -q "formatted" "$work/out" ||
    fail "format-drive reports a failed format as a failure" "$(cat "$work/out")"
  pass "format-drive stops when wipefs fails and never reports a failed format as done"

  for case_spec in "sda:${work}/sda1" "nvme0n1:${work}/nvme0n1p1" "mmcblk0:${work}/mmcblk0p1" "loop0:${work}/loop0p1"; do
    name="${case_spec%%:*}"
    expected_part="${case_spec#*:}"
    ln -sf "$device" "$work/$name"
    : >"$SUDO_LOG"
    run_format "$work/$name" POC
    (( rc == 0 )) && grep -Fxq "mkfs.exfat -n POC $expected_part" "$SUDO_LOG" ||
      fail "format-drive uses expected partition path for $name" "$(cat "$SUDO_LOG")"
  done
  pass "format-drive uses p1 suffix for numeric-ending devices (nvme, mmcblk, loop) and 1 for letters"
else
  skip "format-drive: no block device for the failure paths"
fi
