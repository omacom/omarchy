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
