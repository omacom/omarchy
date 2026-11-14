#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
state_home="$test_tmp/state"
runtime_dir="$test_tmp/runtime"
mkdir -p "$mock_bin" "$state_home" "$runtime_dir"

# The take binds only fire while slurp is up, so pgrep answers yes and pkill is
# a no-op. slurp exits empty, optionally leaving the marker a bind would.
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/slurp" <<'SH'
#!/bin/bash
[[ -n ${SLURP_LOG:-} ]] && printf 'slurp\n' >>"$SLURP_LOG"
[[ -n ${SLURP_TOUCH:-} ]] && touch "$SLURP_TOUCH"
exit 0
SH

cat >"$mock_bin/hyprpicker" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

case "$1" in
monitors)
  printf '%s\n' '[{"name":"DP-1","focused":true,"x":0,"y":0,"width":1920,"height":1080,"scale":1.0,"transform":0,"activeWorkspace":{"id":1}}]'
  ;;
clients)
  printf '%s\n' '[]'
  ;;
esac
SH

chmod +x "$mock_bin"/*

state_marker="$state_home/omarchy/omarchy-capture-region-fullscreen"
window_marker="$state_home/omarchy/omarchy-capture-region-window"
runtime_marker="$runtime_dir/omarchy-capture-region-fullscreen"
slurp_log="$test_tmp/slurp-log"

run_region() {
  HOME="$test_tmp/home" XDG_STATE_HOME="$state_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-capture-region" "$@"
}

# Without a session runtime dir the take binds flag their intent in the
# private state directory, not at fixed names in world-writable /tmp.
XDG_RUNTIME_DIR= run_region --take-fullscreen
[[ -e $state_marker ]] || fail "the fullscreen marker falls back to the state directory without a session runtime dir"
[[ $(stat -c '%a' "$state_home/omarchy") == "700" ]] || fail "the fallback marker directory is private"
pass "the fullscreen marker falls back to a private state directory without a session runtime dir"

XDG_RUNTIME_DIR= run_region --take-window
[[ -e $window_marker ]] || fail "the window marker falls back to the state directory without a session runtime dir"
pass "the window marker falls back to the same private state directory"

# The picker reads the marker back through the same fallback: slurp exits
# empty while the marker appears, as the bind would have left it.
geometry=$(SLURP_TOUCH="$state_marker" XDG_RUNTIME_DIR= run_region smart)
[[ $geometry == "0,0 1920x1080" ]] || fail "the picker does not consume a marker from the fallback directory" "actual: $geometry"
pass "the picker consumes a marker from the fallback directory"

# The session runtime dir still wins when it is there.
rm -f "$state_marker"
XDG_RUNTIME_DIR="$runtime_dir" run_region --take-fullscreen
[[ -e $runtime_marker ]] || fail "the session runtime dir still holds the marker when it is set"
[[ ! -e $state_marker ]] || fail "the state directory is not touched when a session runtime dir is set"
pass "the session runtime dir takes precedence over the state directory"

blocked="$test_tmp/blocked"
: >"$blocked"

# Marker-free modes do not need the fallback directory at all: a read-only or
# full state filesystem must not break a plain fullscreen request.
geometry=$(HOME="$test_tmp/home" XDG_STATE_HOME="$blocked" XDG_RUNTIME_DIR= PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-capture-region" fullscreen)
[[ $geometry == "0,0 1920x1080" ]] || fail "fullscreen fails although it uses no markers" "actual: $geometry"
pass "marker-free fullscreen mode works without a usable fallback directory"

# A fallback directory that cannot be created must fail before the picker
# opens: a take bind would otherwise kill slurp without leaving a marker, and
# the empty result would read as a cancelled capture.
: >"$slurp_log"
picker_rc=0
error=$(HOME="$test_tmp/home" XDG_STATE_HOME="$blocked" XDG_RUNTIME_DIR= SLURP_LOG="$slurp_log" PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-capture-region" smart 2>&1 >/dev/null) || picker_rc=$?
(( picker_rc != 0 )) || fail "an unusable fallback state directory does not stop the picker"
[[ $error == *"Cannot create"* ]] || fail "the unusable fallback state directory is not reported" "actual: $error"
[[ ! -s $slurp_log ]] || fail "the picker opens slurp although its state directory is unusable"
pass "an unusable fallback state directory fails before the picker opens"
