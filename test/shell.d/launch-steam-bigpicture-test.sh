#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export OMARCHY_TEST_CALLS="$test_tmp/calls"
export OMARCHY_TEST_STEAM_PRESENT=1
export PATH="$test_tmp/bin:$PATH"
export HYPRLAND_INSTANCE_SIGNATURE=test WAYLAND_DISPLAY=wayland-test

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
[[ $1 == "--" ]] || exit 91
shift
exec "$@"
SH
cat >"$test_tmp/bin/steam" <<'SH'
#!/bin/bash
printf 'steam %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH
chmod +x "$test_tmp/bin/"*
launcher="$ROOT/bin/omarchy-launch-steam-bigpicture"

# A request must reach Steam every time, including when the client already runs.
# Its singleton forwarding is Steam's responsibility, not simulated by this test.
"$launcher"
"$launcher"
mapfile -t calls <"$OMARCHY_TEST_CALLS"
[[ ${calls[0]} == "steam steam://open/bigpicture" && ${calls[1]} == "${calls[0]}" ]] ||
  fail "each invocation requests Big Picture through the session launcher"
pass "repeated invocation forwards Big Picture without a focus-only shortcut"

: >"$OMARCHY_TEST_CALLS"
export OMARCHY_TEST_STEAM_PRESENT=0
"$launcher" --help >"$test_tmp/output"
[[ ! -s $OMARCHY_TEST_CALLS ]] || fail "help must not launch Steam or notify"
if "$launcher" >"$test_tmp/output" 2>&1; then
  fail "missing Steam must fail without installation"
fi
[[ $(<"$OMARCHY_TEST_CALLS") == notification* ]] || fail "missing Steam must notify the desktop"
pass "help needs no Steam, and missing Steam reports a desktop error"

: >"$OMARCHY_TEST_CALLS"
export OMARCHY_TEST_STEAM_PRESENT=1
if "$launcher" unexpected >"$test_tmp/output" 2>&1; then
  fail "unexpected arguments must fail"
fi
[[ ! -s $OMARCHY_TEST_CALLS ]] || fail "invalid arguments must not launch"
if WAYLAND_DISPLAY="" "$launcher" >"$test_tmp/output" 2>&1; then
  fail "a missing desktop session must fail"
fi
[[ $(<"$OMARCHY_TEST_CALLS") == notification* ]] || fail "missing session must not reach Steam"
pass "invalid invocation and missing desktop never reach Steam"
