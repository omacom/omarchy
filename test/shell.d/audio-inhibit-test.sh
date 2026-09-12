#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
TEST_RUNTIME=$(mktemp -d)
BIN_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$TEST_RUNTIME" "$BIN_DIR"' EXIT

PATH="$BIN_DIR:$PATH"

STAY="$TEST_HOME/.local/state/omarchy/indicators/stay-awake"
RUNTIME="$TEST_RUNTIME/omarchy-audio-inhibit"
OWNER="$RUNTIME/owner"
HANDSOFF="$RUNTIME/hands-off"

# pactl stub that answers the sink-input query with the given JSON payload
write_pactl_stub() {
  cat >"$BIN_DIR/pactl" <<EOF
#!/bin/bash
if [[ \$1 == "--format=json" && \$2 == "list" && \$3 == "sink-inputs" ]]; then
  printf '%s\n' '$1'
  exit 0
fi
exit 1
EOF
  chmod +x "$BIN_DIR/pactl"
}

# 0 = locked, 1 = unlocked
write_lock_stub() {
  printf '#!/bin/bash\nexit %s\n' "$1" >"$BIN_DIR/omarchy-hyprland-session-locked"
  chmod +x "$BIN_DIR/omarchy-hyprland-session-locked"
}

run_inhibit() {
  HOME="$TEST_HOME" XDG_RUNTIME_DIR="$TEST_RUNTIME" \
    "$ROOT/bin/omarchy-audio-inhibit" --once
}

status_inhibit() {
  HOME="$TEST_HOME" XDG_RUNTIME_DIR="$TEST_RUNTIME" \
    "$ROOT/bin/omarchy-audio-inhibit" --status
}

PLAYING='[{"index":1,"corked":false,"mute":false,"name":"Firefox","properties":{"application.name":"Firefox"}}]'
PAUSED='[{"index":5,"corked":true,"mute":false,"name":"Spotify","properties":{"application.name":"Spotify"}}]'
BACKGROUND='[{"index":2,"corked":false,"mute":false,"properties":{"application.name":"PipeWire ALSA [voxtype-vulkan]","node.name":"alsa_playback.voxtype-vulkan"}},{"index":3,"corked":false,"mute":false,"properties":{"media.role":"event"}}]'

# 1. Active playback claims stay-awake with an ownership token
write_pactl_stub "$PLAYING"
write_lock_stub 1
run_inhibit

[[ -f $STAY ]] || fail "audio inhibitor claims stay-awake when audio is playing"
pass "audio inhibitor claims stay-awake when audio is playing"

[[ $(<"$STAY") == omarchy-audio-inhibit:* ]] ||
  fail "audio inhibitor writes an ownership token"
pass "audio inhibitor writes an ownership token"

[[ -f $OWNER ]] || fail "audio inhibitor records its ownership while claiming"
pass "audio inhibitor records its ownership while claiming"

# 2. Background daemon audio (e.g. Voxtype) and event sounds do not trigger stay-awake
write_pactl_stub "$BACKGROUND"
run_inhibit

[[ ! -f $STAY ]] ||
  fail "audio inhibitor ignores background daemons and event sounds"
pass "audio inhibitor ignores background daemons and event sounds"

# 3. User explicitly removes stay-awake while audio is playing: hands off, no re-assert
write_pactl_stub "$PLAYING"
run_inhibit

rm -f "$STAY"
run_inhibit

[[ ! -f $STAY ]] ||
  fail "audio inhibitor does not re-assert stay-awake when user explicitly dismissed it"
pass "audio inhibitor does not re-assert stay-awake when user explicitly dismissed it"

[[ $(<"$HANDSOFF") == user ]] ||
  fail "audio inhibitor records a user hands-off on dismissal"
pass "audio inhibitor records a user hands-off on dismissal"

[[ $(status_inhibit) == *"suppressed by user"* ]] ||
  fail "audio inhibitor status reflects user suppression"
pass "audio inhibitor status reflects user suppression"

# 4. Playback fully stops -> the hands-off marker is session-scoped and resets
write_pactl_stub '[]'
run_inhibit

[[ ! -f $HANDSOFF ]] ||
  fail "stopping playback clears the hands-off marker"
pass "stopping playback clears the hands-off marker"

# 5. A new playback session re-claims stay-awake automatically
write_pactl_stub "$PLAYING"
run_inhibit

[[ -f $STAY ]] ||
  fail "new audio playback session re-claims stay-awake automatically"
pass "new audio playback session re-claims stay-awake automatically"

# 6. Session lock hands the playback off: claim released, reason recorded
write_lock_stub 0
run_inhibit

[[ ! -f $STAY ]] ||
  fail "audio inhibitor releases stay-awake when the session locks"
pass "audio inhibitor releases stay-awake when the session locks"

[[ $(<"$HANDSOFF") == lock ]] ||
  fail "audio inhibitor records a lock hands-off"
pass "audio inhibitor records a lock hands-off"

[[ $(status_inhibit) == "playing (unprotected: session was locked)" ]] ||
  fail "audio inhibitor status reflects the lock hands-off"
pass "audio inhibitor status reflects the lock hands-off"

# 7. Unlocking while playback continues must NOT re-assert (regression: the
#    yield must never be misread as a user dismissal)
write_lock_stub 1
run_inhibit

[[ ! -f $STAY ]] ||
  fail "audio inhibitor does not re-assert stay-awake after unlock within the same playback"
pass "audio inhibitor does not re-assert stay-awake after unlock within the same playback"

[[ ! -f $OWNER ]] ||
  fail "audio inhibitor drops ownership after a lock hands-off"
pass "audio inhibitor drops ownership after a lock hands-off"

[[ $(status_inhibit) == "playing (unprotected: session was locked)" ]] ||
  fail "status still reports the lock hands-off after unlock"
pass "status still reports the lock hands-off after unlock"

# 8. Pausing ends the playback session: the hands-off marker resets
write_pactl_stub "$PAUSED"
run_inhibit

[[ ! -f $HANDSOFF ]] ||
  fail "pausing playback clears the lock hands-off marker"
pass "pausing playback clears the lock hands-off marker"

# 9. Resuming after a lock forfeit re-arms stay-awake (pause/resume is a
#    stop/start boundary, so the next active playback gets a fresh hold)
write_pactl_stub "$PLAYING"
run_inhibit

[[ -f $STAY ]] ||
  fail "resuming playback re-arms stay-awake after a lock forfeit"
pass "resuming playback re-arms stay-awake after a lock forfeit"

# 10. User re-enables stay-awake from the bar while the daemon owns it:
#     daemon hands off and the user's setting survives playback end
sleep 1.1
touch "$STAY"
run_inhibit

[[ $(<"$STAY") == user ]] ||
  fail "audio inhibitor rewrites the token when the user re-enables stay-awake"
pass "audio inhibitor rewrites the token when the user re-enables stay-awake"

[[ ! -f $OWNER ]] ||
  fail "audio inhibitor drops ownership when the user re-enables stay-awake"
pass "audio inhibitor drops ownership when the user re-enables stay-awake"

[[ $(status_inhibit) == "playing (stay-awake held by user)" ]] ||
  fail "audio inhibitor status reflects a user-held stay-awake"
pass "audio inhibitor status reflects a user-held stay-awake"

write_pactl_stub '[]'
run_inhibit

[[ -f $STAY ]] ||
  fail "user re-enabled stay-awake survives playback ending"
pass "user re-enabled stay-awake survives playback ending"

[[ ! -f $HANDSOFF ]] ||
  fail "hands-off marker resets when playback ends"
pass "hands-off marker resets when playback ends"

# 11. A manually set stay-awake survives locking (escape hatch): the daemon
#     owns nothing here, so the lock must not touch the user's token
printf 'user-choice\n' >"$STAY"
write_pactl_stub "$PLAYING"
write_lock_stub 0
run_inhibit

[[ $(<"$STAY") == "user-choice" ]] ||
  fail "locking does not clear a manually set stay-awake"
pass "locking does not clear a manually set stay-awake"

write_lock_stub 1
run_inhibit

[[ $(<"$STAY") == "user-choice" ]] ||
  fail "unlocking does not clear a manually set stay-awake"
pass "unlocking does not clear a manually set stay-awake"

write_pactl_stub '[]'
run_inhibit
rm -f "$STAY"

# 12. A failed audio query holds the current state (PipeWire restart must not
#     look like playback ending)
write_pactl_stub "$PLAYING"
write_lock_stub 1
run_inhibit

cat >"$BIN_DIR/pactl" <<'EOF'
#!/bin/bash
exit 1
EOF

run_inhibit

[[ -f $STAY ]] ||
  fail "audio inhibitor holds the claim while the audio system is unqueryable"
pass "audio inhibitor holds the claim while the audio system is unqueryable"

# 13. Repeated query failures release the claim: nothing audible is playing
HOME="$TEST_HOME" XDG_RUNTIME_DIR="$TEST_RUNTIME" \
  OMARCHY_AUDIO_INHIBIT_MAX_QUERY_FAILURES=2 \
  OMARCHY_AUDIO_INHIBIT_RECONNECT_SECONDS=0.2 \
  "$ROOT/bin/omarchy-audio-inhibit" & daemon_pid=$!

tries=50
while (( tries > 0 )); do
  if [[ ! -f $OWNER ]]; then
    break
  fi
  sleep 0.1
  tries=$(( tries - 1 ))
done

kill "$daemon_pid" 2>/dev/null || true
wait "$daemon_pid" 2>/dev/null || true

[[ ! -f $OWNER ]] ||
  fail "audio inhibitor releases the claim after repeated query failures"
pass "audio inhibitor releases the claim after repeated query failures"

[[ ! -f $STAY ]] ||
  fail "audio inhibitor releases stay-awake after repeated query failures"
pass "audio inhibitor releases stay-awake after repeated query failures"

# 14. SIGTERM cleanup releases the claim instead of stranding it
write_pactl_stub "$PLAYING"
HOME="$TEST_HOME" XDG_RUNTIME_DIR="$TEST_RUNTIME" \
  "$ROOT/bin/omarchy-audio-inhibit" & daemon_pid=$!

tries=30
while (( tries > 0 )); do
  if [[ -f $STAY ]]; then
    break
  fi
  sleep 0.1
  tries=$(( tries - 1 ))
done

[[ -f $STAY ]] ||
  fail "daemon run claims stay-awake while audio is playing"
pass "daemon run claims stay-awake while audio is playing"

kill -TERM "$daemon_pid"
wait "$daemon_pid" 2>/dev/null || true

[[ ! -f $STAY ]] ||
  fail "daemon releases stay-awake on SIGTERM"
pass "daemon releases stay-awake on SIGTERM"

# 15. A stranded token from a prior boot/run is cleaned up when nothing plays
BOOT_HOME=$(mktemp -d)
BOOT_RUNTIME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$TEST_RUNTIME" "$BIN_DIR" "$BOOT_HOME" "$BOOT_RUNTIME"' EXIT

mkdir -p "$BOOT_HOME/.local/state/omarchy/indicators"
echo "omarchy-audio-inhibit:99999:1234:5678" >"$BOOT_HOME/.local/state/omarchy/indicators/stay-awake"

write_pactl_stub '[]'
HOME="$BOOT_HOME" XDG_RUNTIME_DIR="$BOOT_RUNTIME" \
  "$ROOT/bin/omarchy-audio-inhibit" --once

[[ ! -f "$BOOT_HOME/.local/state/omarchy/indicators/stay-awake" ]] ||
  fail "audio inhibitor cleans up stranded tokens from previous boots on startup"
pass "audio inhibitor cleans up stranded tokens from previous boots on startup"
