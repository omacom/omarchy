#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
state_home="$test_tmp/state"
runtime_dir="$test_tmp/runtime"
mkdir -p "$mock_bin" "$state_home" "$runtime_dir"

cat >"$mock_bin/ddcutil" <<'SH'
#!/bin/bash

printf 'ddcutil %s\n' "$*" >>"$CALL_LOG"

if [[ $* == *" detect --brief"* ]]; then
  printf '   I2C bus:             /dev/i2c-7\n'
  printf '   DRM connector:       card1-DP-1\n'
elif [[ $* == *" getvcp 10 "* ]]; then
  printf 'VCP 10 C 40 80\n'
fi
SH

chmod +x "$mock_bin/ddcutil"

call_log="$test_tmp/calls"
: >"$call_log"

state_cache="$state_home/omarchy/omarchy-brightness-display-ddc/DP-1.bus"
runtime_cache="$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"

# Without a session runtime dir the cache falls back to the user's state
# directory, which is private, not to a fixed name in world-writable /tmp.
brightness=$(
  CALL_LOG="$call_log" HOME="$test_tmp/home" XDG_STATE_HOME="$state_home" XDG_RUNTIME_DIR= \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-display-ddc" DP-1
)
[[ $brightness == "50" ]] || fail "the fallback cache still serves the brightness" "actual: $brightness"
[[ -f $state_cache ]] || fail "the DDC cache falls back to the state directory without a session runtime dir"
[[ $(cut -d' ' -f1,2 "$state_cache") == "7 80" ]] || fail "the fallback cache keeps the detected bus and range"
[[ $(stat -c '%a' "$state_home/omarchy/omarchy-brightness-display-ddc") == "700" ]] || fail "the fallback cache directory is private"
pass "the DDC cache falls back to a private state directory without a session runtime dir"

# A cache written before a reboot must not survive it: I2C bus numbers can be
# reassigned, and a stale bus would steer brightness at another display.
if [[ -r /proc/sys/kernel/random/boot_id ]]; then
  printf 'previous-boot\n' >"$state_home/omarchy/omarchy-brightness-display-ddc/boot-id"
  printf '9 80 9999999999\n' >"$state_cache"
  : >"$call_log"
  CALL_LOG="$call_log" HOME="$test_tmp/home" XDG_STATE_HOME="$state_home" XDG_RUNTIME_DIR= \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-display-ddc" DP-1 >/dev/null
  grep -Fq 'ddcutil --skip-ddc-checks detect --brief' "$call_log" || fail "a bus cache from a previous boot is reused"
  [[ $(cut -d' ' -f1 "$state_cache") == "7" ]] || fail "the bus is not re-detected after a reboot"
  [[ $(<"$state_home/omarchy/omarchy-brightness-display-ddc/boot-id") != "previous-boot" ]] || fail "the boot marker is not refreshed"
  pass "a bus cache from a previous boot is discarded"
else
  skip "a bus cache from a previous boot is discarded (no boot id on this host)"
fi

# The session runtime dir still wins when it is there.
rm -f "$state_cache"
CALL_LOG="$call_log" HOME="$test_tmp/home" XDG_STATE_HOME="$state_home" XDG_RUNTIME_DIR="$runtime_dir" \
  PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-brightness-display-ddc" DP-1 >/dev/null
[[ -f $runtime_cache ]] || fail "the session runtime dir still holds the cache when it is set"
[[ ! -e $state_cache ]] || fail "the state directory is not touched when a session runtime dir is set"
pass "the session runtime dir takes precedence over the state directory"
