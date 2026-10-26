#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

cat >"$work/bin/wpctl" <<'SH'
#!/bin/bash
printf 'wpctl %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALLS"
SH

cat >"$work/bin/omarchy-audio-tuning" <<'SH'
#!/bin/bash
case ${1:-} in
  fronted-sink) exit 1 ;;
  *) exit 0 ;;
esac
SH

cat >"$work/bin/pactl" <<'SH'
#!/bin/bash
printf '%s pactl %s\n' "${LC_ALL:-unset}" "$*" >>"$CALLS"
case "$*" in
  "list sink-inputs")
    cat <<'OUT'
Sink Input #42
	Sink: 10
	Properties:
		application.name = "Firefox"
		node.name = "Firefox"
OUT
    ;;
  "-f json list sinks")
    cat <<'OUT'
[
  {
    "index": 1,
    "name": "alsa_output.speakers",
    "description": "Speakers",
    "ports": [{"name": "analog-output-speakers", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "50%"}}
  },
  {
    "index": 2,
    "name": "alsa_output.headphones",
    "description": "Headphones",
    "ports": [{"name": "analog-output-headphones", "availability": "available"}],
    "volume": {"front-left": {"value_percent": "70%"}}
  }
]
OUT
    ;;
  "get-default-sink")
    echo "alsa_output.speakers"
    ;;
  "get-sink-volume "*)
    echo "Volume: front-left: 32768 /  50% / -18.06 dB"
    ;;
  "get-sink-mute "*)
    echo "Mute: no"
    ;;
  "list sinks short")
    printf '1\talsa_output.speakers\tPipeWire\ts32le 2ch 48000Hz\tRUNNING\n'
    ;;
esac
exit 0
SH
chmod +x "$work/bin"/*

export CALLS="$work/calls"

# 1. omarchy-audio-output-set-default
: >"$CALLS"
LC_ALL=en_US.UTF-8 PATH="$work/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-audio-output-set-default" 42 alsa_output.speakers 2>/dev/null || true
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-set-default reads sink-inputs in the C locale' "$(cat "$CALLS")"
grep -q 'pactl move-sink-input 42 alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-set-default moves streams' "$(cat "$CALLS")"
pass 'audio-output-set-default reads sink-inputs in the C locale'

# 2. omarchy-audio-output-sink
: >"$CALLS"
res=$(LC_ALL=en_US.UTF-8 PATH="$work/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-audio-output-sink" "virtual_sink" 2>/dev/null)
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-output-sink reads sink-inputs in the C locale' "$(cat "$CALLS")"
pass 'audio-output-sink reads sink-inputs in the C locale'

# 3. omarchy-audio-output-switch
: >"$CALLS"
LC_ALL=en_US.UTF-8 PATH="$work/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-audio-output-switch" 2>/dev/null || true
grep -qx 'C pactl -f json list sinks' "$CALLS" ||
  fail 'audio-output-switch reads sinks in the C locale' "$(cat "$CALLS")"
grep -qx 'C pactl get-sink-volume alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink volume in the C locale' "$(cat "$CALLS")"
grep -qx 'C pactl get-sink-mute alsa_output.headphones' "$CALLS" ||
  fail 'audio-output-switch reads sink mute in the C locale' "$(cat "$CALLS")"
pass 'audio-output-switch reads pactl outputs in the C locale'

# 4. omarchy-audio-output-volume
: >"$CALLS"
LC_ALL=en_US.UTF-8 PATH="$work/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-audio-output-volume" +5 2>/dev/null || true
grep -qx 'C pactl get-sink-volume alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink volume in the C locale' "$(cat "$CALLS")"
grep -qx 'C pactl get-sink-mute alsa_output.speakers' "$CALLS" ||
  fail 'audio-output-volume reads sink mute in the C locale' "$(cat "$CALLS")"
pass 'audio-output-volume reads pactl outputs in the C locale'

# 5. omarchy-audio-tuning app_streams
: >"$CALLS"
(
  eval "$(sed -n '/^app_streams() {/,/^}/p' "$ROOT/bin/omarchy-audio-tuning")"
  LC_ALL=en_US.UTF-8 PATH="$work/bin:$ROOT/bin:$PATH" app_streams 2>/dev/null >/dev/null
)
grep -qx 'C pactl list sink-inputs' "$CALLS" ||
  fail 'audio-tuning app_streams reads sink-inputs in the C locale' "$(cat "$CALLS")"
pass 'audio-tuning app_streams reads sink-inputs in the C locale'
