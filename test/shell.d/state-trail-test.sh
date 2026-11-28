#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command python3

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# The recorder driven through its real sources with stubbed producers: each
# stub prints what the session would and then ends, which ends the recorder.
stub_bin="$TMPDIR/bin"
runtime="$TMPDIR/runtime"
trail="$TMPDIR/trail.log"
mkdir -p "$stub_bin" "$runtime/hypr/test-instance"

python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' \
  "$runtime/hypr/test-instance/.socket2.sock"

# As journalctl -o short-unix prints them, with Quickshell's level and category
# ahead of the message.
cat >"$stub_bin/journalctl" <<'SH'
#!/bin/bash
cat <<'LOG'
1762336800.000100 host omarchy-shell[42]:  DEBUG qml: omarchy lock 2026-11-05T10:00:00.000Z lock-requested
1762336800.100000 host omarchy-shell[42]:  DEBUG qml: Loaded the bar on DP-1
1762336801.000200 host omarchy-shell[42]:  DEBUG qml: omarchy idle 2026-11-05T10:00:01.000Z screensaver-start
1762336802.123456 host omarchy-shell[42]:   WARN: The Wayland connection experienced a fatal error: Invalid argument
LOG
SH

cat >"$stub_bin/socat" <<'SH'
#!/bin/bash
sleep 0.2
printf '%s\n' 'workspacev2>>2,2' 'monitorremovedv2>>1,DP-1,Dell U2720Q'
SH

cat >"$stub_bin/dbus-monitor" <<'SH'
#!/bin/bash
sleep 0.4
printf '%s\n' '   boolean true' '   boolean false'
SH

# Answers only once the idle event queued behind the query is on disk, as a
# shell in trouble answers late: a loop that waits for the answer before
# reading on times the query out first and records it ahead of the event.
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
for _ in {1..150}; do
  grep -Fq 'screensaver-start' "$OMARCHY_STATE_TRAIL" 2>/dev/null && break
  sleep 0.02
done
echo '{"locked":true,"realScreens":0}'
SH

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "instances" ]]; then
  echo '[{"instance":"stale-instance","time":1},{"instance":"test-instance","time":2}]'
else
  echo '[{"name":"eDP-1","disabled":false,"dpmsStatus":true,"width":2880,"height":1800,"refreshRate":120.0}]'
fi
SH

chmod +x "$stub_bin"/*

run_trail() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  XDG_RUNTIME_DIR="$runtime" \
  HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_SIGNATURE-test-instance}" \
  OMARCHY_STATE_TRAIL="$trail" \
  OMARCHY_STATE_TRAIL_MAX_BYTES="${1:-524288}" \
    "$ROOT/bin/omarchy-state-trail"
}

run_trail
events=$(cut -d' ' -f2- "$trail")

grep -Fxq 'lock src=2026-11-05T10:00:00.000Z lock-requested' <<<"$events" ||
  fail "a lock transition is recorded with the time the shell saw it"
grep -Fxq 'lock-status {"locked":true,"realScreens":0}' <<<"$events" ||
  fail "a lock transition is followed by the lock state it left"
grep -Fxq 'idle src=2026-11-05T10:00:01.000Z screensaver-start' <<<"$events" ||
  fail "an idle transition is recorded with the time the shell saw it"
grep -Fxq 'shell src=2025-11-05T10:00:02.123456Z WARN: The Wayland connection experienced a fatal error: Invalid argument' <<<"$events" ||
  fail "the Wayland fatal error that ends a locked shell is recorded with journald's time"
! grep -Fq 'Loaded the bar' <<<"$events" ||
  fail "shell lines that are not transitions stay out of the trail"
(( $(grep -n -F 'screensaver-start' <<<"$events" | cut -d: -f1) < $(grep -n -m1 '^lock-status' <<<"$events" | cut -d: -f1) )) ||
  fail "an event arriving during a lock status query is recorded without waiting for it"
! cut -d' ' -f1 "$trail" | grep -qvE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}Z$' ||
  fail "every line is stamped with the time it was read, in UTC to the microsecond"
pass "shell lock and idle transitions are recorded with their own time and the lock state they leave"

grep -Fxq 'monitor monitorremovedv2>>1,DP-1,Dell U2720Q' <<<"$events" ||
  fail "a monitor removal is recorded"
grep -Fxq 'monitor-status [{"name":"eDP-1","disabled":false,"dpms":true,"mode":"2880x1800@120"}]' <<<"$events" ||
  fail "a monitor change is followed by the monitors' modes"
! grep -Fq 'workspacev2' <<<"$events" ||
  fail "Hyprland events other than monitor changes stay out of the trail"
pass "monitor changes are recorded with the modes they leave"

rm -f "$trail"
HYPRLAND_SIGNATURE="" run_trail
grep -Fq 'monitor monitorremovedv2' "$trail" ||
  fail "monitor events are recorded when the service's environment has no Hyprland instance signature"
pass "monitor events find the newest running Hyprland instance without its signature"

grep -Fxq 'sleep entering' <<<"$events" && grep -Fxq 'sleep resumed' <<<"$events" ||
  fail "sleep entry and resume are recorded"
[[ $(grep -A1 -Fx 'sleep resumed' <<<"$events" | tail -1) == lock-status* ]] ||
  fail "a resume is followed by the lock state it woke into"
pass "sleep entry and resume are recorded"

rm -f "$trail" "$trail.1"
run_trail 200
[[ -s $trail.1 ]] && (( $(stat -c %s "$trail" 2>/dev/null || echo 0) <= 400 )) ||
  fail "the trail rotates once it passes its size limit instead of growing without bound"
pass "the trail rotates at its size limit"
