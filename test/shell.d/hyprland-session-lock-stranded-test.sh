#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fake_bin=$(mktemp -d)
trap 'rm -rf "$fake_bin"' EXIT

cat >"$fake_bin/omarchy-hyprland-session-locked" <<'SH'
#!/bin/bash

exit "$OMARCHY_TEST_LOCKED"
SH

# The lockers running are given, so the live desktop's own shell stays out of it.
cat >"$fake_bin/pgrep" <<'SH'
#!/bin/bash

[[ $* == "-u $UID -x quickshell|qs|hyprlock" ]] || exit 3
[[ -n $OMARCHY_TEST_LOCKERS ]] || exit 1
printf '%s\n' $OMARCHY_TEST_LOCKERS
SH
chmod +x "$fake_bin"/*

assert_status() {
  local expected="$1" locked="$2" lockers="$3" description="$4" actual=0

  PATH="$fake_bin:$PATH" OMARCHY_TEST_LOCKED="$locked" OMARCHY_TEST_LOCKERS="$lockers" \
    "$ROOT/bin/omarchy-hyprland-session-lock-stranded" 100 || actual=$?

  (( actual == expected )) || fail "$description" "expected exit $expected, got $actual"
  pass "$description"
}

assert_status 0 0 "" "a lock with no locker alive is stranded"
assert_status 0 0 "100" "the asking shell does not count as another locker"
assert_status 1 1 "" "an unlocked session is not stranded"
assert_status 2 2 "" "a compositor that cannot say leaves it undetermined"
assert_status 2 0 "100 200" "a lock another locker may hold is left undetermined, so it is never taken"
