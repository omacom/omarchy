#!/bin/bash

set -euo pipefail

# Keep volume-key repeats from opening overlapping PipeWire clients.
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command flock

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/runtime"
call_log="$test_dir/calls"
export AUDIO_VOLUME_CALL_LOG="$call_log"

cat >"$test_dir/bin/omarchy-audio-output-sink" <<'SH'
#!/bin/bash
printf '%s\n' sink >>"$AUDIO_VOLUME_CALL_LOG"
printf '%s\n' test_sink
SH

cat >"$test_dir/bin/pactl" <<'SH'
#!/bin/bash
printf 'pactl %s\n' "$*" >>"$AUDIO_VOLUME_CALL_LOG"

case "$1" in
get-sink-volume)
  printf '%s\n' 'Volume: front-left: 32768 / 50% / -18.06 dB'
  ;;
get-sink-mute)
  printf '%s\n' 'Mute: no'
  ;;
esac
SH

cat >"$test_dir/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'osd %s\n' "$*" >>"$AUDIO_VOLUME_CALL_LOG"
SH

chmod +x "$test_dir/bin/omarchy-audio-output-sink" "$test_dir/bin/pactl" "$test_dir/bin/omarchy-osd"

PATH="$test_dir/bin:$PATH" XDG_RUNTIME_DIR="$test_dir/runtime" "$ROOT/bin/omarchy-audio-output-volume" raise

grep -Fx 'pactl set-sink-volume test_sink 55%' "$call_log" >/dev/null || fail "volume raise sets the expected level"
grep -Fx 'osd -i volume-high -p 50' "$call_log" >/dev/null || fail "volume raise shows the OSD"
pass "volume raise updates the sink and shows the OSD"

: >"$call_log"
exec {volume_lock_fd}>"$test_dir/runtime/omarchy-audio-output-volume.lock"
flock -n "$volume_lock_fd" || fail "test holds the volume lock"

PATH="$test_dir/bin:$PATH" XDG_RUNTIME_DIR="$test_dir/runtime" "$ROOT/bin/omarchy-audio-output-volume" raise

[[ ! -s $call_log ]] || fail "overlapping volume events exit before opening audio clients"
pass "overlapping volume events exit before opening audio clients"

PATH="$test_dir/bin:$PATH" XDG_RUNTIME_DIR="$test_dir/runtime" "$ROOT/bin/omarchy-audio-output-volume" mute-toggle

grep -Fx 'pactl set-sink-mute test_sink toggle' "$call_log" >/dev/null || fail "mute remains responsive during a volume adjustment"
pass "mute remains responsive during a volume adjustment"
