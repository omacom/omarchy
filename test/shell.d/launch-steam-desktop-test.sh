#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export OMARCHY_TEST_CALLS="$test_tmp/calls"
export OMARCHY_TEST_STEAM_RUNNING=0 OMARCHY_TEST_STEAM_PRESENT=1
export OMARCHY_TEST_UWSM_FAIL=0
export PATH="$test_tmp/bin:$PATH"
export HYPRLAND_INSTANCE_SIGNATURE=test WAYLAND_DISPLAY=wayland-test

cat >"$test_tmp/bin/pgrep" <<'SH'
#!/bin/bash
[[ $* == "-u $UID -x steam" ]] || exit 92
[[ $OMARCHY_TEST_STEAM_RUNNING == "1" ]]
SH
cat >"$test_tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "steam" && $OMARCHY_TEST_STEAM_PRESENT == "1" ]]
SH
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notification %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
cat >"$test_tmp/bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$test_tmp/bin/uwsm-app" <<'SH'
#!/bin/bash
[[ $OMARCHY_TEST_UWSM_FAIL == "0" ]] || exit 93
[[ $1 == "--" ]] || exit 94
shift
exec "$@"
SH
cat >"$test_tmp/bin/steam" <<'SH'
#!/bin/bash
printf 'steam %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
chmod +x "$test_tmp/bin/"*
launcher="$ROOT/bin/omarchy-launch-steam-desktop"

: >"$OMARCHY_TEST_CALLS"
"$launcher"
OMARCHY_TEST_STEAM_PRESENT=0 WAYLAND_DISPLAY="" "$launcher"
[[ ! -s $OMARCHY_TEST_CALLS ]] || fail "absent Steam must never bootstrap or notify"
pass "Desktop Mode with no Steam is a harmless no-op"

export OMARCHY_TEST_STEAM_RUNNING=1
"$launcher"
"$launcher"
mapfile -t calls <"$OMARCHY_TEST_CALLS"
[[ ${#calls[@]} == 2 && ${calls[0]} == "steam -ifrunning steam://close/bigpicture" && ${calls[1]} == "${calls[0]}" ]] ||
  fail "each return must forward a no-start close request through UWSM"
pass "repeated return uses close URI and no-start flag"

: >"$OMARCHY_TEST_CALLS"
"$launcher" --help >"$test_tmp/output"
if "$launcher" unexpected >"$test_tmp/output" 2>&1; then
  fail "unexpected arguments must fail"
fi
[[ ! -s $OMARCHY_TEST_CALLS ]] || fail "help and bad arguments must not reach Steam"
pass "help and invalid arguments have no session effects"

for failure in dependency session uwsm; do
  : >"$OMARCHY_TEST_CALLS"
  case "$failure" in
    dependency) export OMARCHY_TEST_STEAM_PRESENT=0 ;;
    session) export OMARCHY_TEST_STEAM_PRESENT=1 WAYLAND_DISPLAY="" ;;
    uwsm) export WAYLAND_DISPLAY=wayland-test OMARCHY_TEST_UWSM_FAIL=1 ;;
  esac
  if "$launcher" >"$test_tmp/output" 2>&1; then
    fail "$failure failure must be visible"
  fi
  [[ $(<"$OMARCHY_TEST_CALLS") == notification* ]] || fail "$failure must notify without reaching Steam"
done
pass "missing Steam/session and failed UWSM report actionable errors"
