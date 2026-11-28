#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# default/splash/hold keeps the boot splash's displays open from its stop until
# a session's compositor has them. Its functions run here against a fixture
# /proc and /dev/dri, with the splash's sway, logind and the event stream as the
# test sets them.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

hold=$ROOT/default/splash/hold
source "$hold"
proc=$test_tmp/proc
dri=$test_tmp/dev/dri

mkdir -p "$dri"
touch "$dri/card0" "$dri/card1" "$dri/card2" "$dri/renderD128" "$test_tmp/other"

# Process $1, in cgroup $2, with fd $3 open on $4, fd $5 on $6, and so on.
process() {
  local pid=$1
  mkdir -p "$proc/$pid/fd"
  echo "$2" >"$proc/$pid/cgroup"
  shift 2
  while (( $# )); do
    ln -sfn "$2" "$proc/$pid/fd/$1"
    shift 2
  done
}

pidof() {
  [[ $1 == "sway" ]] && echo "100 200"
}

# The splash's sway, started by the initramfs in the root cgroup, which systemd
# moves into init.scope as it starts, has both GPUs open (one twice) and a
# render node; a sway some unit started has the third card.
process 200 "0::/system.slice/kiosk.service" 3 "$dri/card2"
for cgroup in "0::/" "0::/init.scope"; do
  process 100 "$cgroup" 3 "$dri/card1" 4 "$dri/card0" 5 "$dri/card1" 6 "$dri/renderD128" 7 "$test_tmp/other"
  found=$(splash_devices | tr '\n' ' ')
  [[ $found == "$dri/card0 $dri/card1 " ]] ||
    fail "every card the splash's sway draws on is held, and only those" "splash in $cgroup, found: $found"
done
pass "every card the splash's sway draws on is held, and only those"

# The one DROP_MASTER error the holder goes on from is EINVAL, a file that isn't
# the master. On any other, as a plain file's ENOTTY, it gives up rather than
# keep a file that may be.
exec {fd}<"$dri/card0"
if drop_master "$fd:$dri/card0" 2>/dev/null; then
  fail "a file whose DRM master can't be dropped is not held"
fi
exec {fd}<&-
pass "a file whose DRM master can't be dropped is not held"

adopt=$test_tmp/adopt

# The holder waiting for a session to take card0 and card1 from logind (pid
# 300), its events read from $1 and its time limit $2 seconds, in a process of
# its own given 5 seconds.
holder_waits() {
  timeout 5 bash -c '. "$1"; proc=$2; nodes=("$3" "$4"); logind=300 adopt=$5 cap=$6; exec {events}<>"$7"; wait_for_session' \
    _ "$hold" "$proc" "$dri/card0" "$dri/card1" "$adopt" "${2:-20}" "$1"
}

# A session's compositor takes the GPUs one at a time: the first one ends the
# adoption, but the holder keeps the other until it is taken too.
process 300 "0::/system.slice/systemd-logind.service" 20 "$dri/card0"
touch "$adopt"
echo "$dri/card0 OPEN" >"$test_tmp/one-event"
out=$(holder_waits "$test_tmp/one-event") || fail "the holder lets go when its watch ends" "$out"
[[ ! -e $adopt ]] || fail "the first display a session takes ends the adoption" "$out"
[[ $out == *"a session has taken $dri/card0"* && $out != *"every display"* ]] ||
  fail "the holder keeps the displays a session hasn't taken yet" "$out"
pass "the first display a session takes ends the adoption, and the others stay held"

process 300 "0::/system.slice/systemd-logind.service" 21 "$dri/card1"
out=$(holder_waits /dev/null) || fail "the holder lets go once a session has every display" "$out"
[[ $out == *"letting go: a session has every display"* ]] || fail "the holder lets go once a session has every display" "$out"
pass "the holder lets go once a session has every display"

# With no session coming, and no event, it lets go at its time limit.
rm -f "$proc/300/fd/"*
mkfifo "$test_tmp/events"
out=$(holder_waits "$test_tmp/events" 1) || fail "the holder lets go at its time limit when no session comes" "still holding after 5 s"
[[ $out == *"no session took"* ]] || fail "the holder lets go at its time limit when no session comes" "$out"
pass "the holder lets go at its time limit when no session comes"
