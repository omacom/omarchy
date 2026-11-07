#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command ffmpeg
require_command ffprobe

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# The limiter runs at 192 kHz, so without a pinned rate the finalize pass
# writes 96 kHz AAC from a 48 kHz recording. Many editors decode such a track as
# silence, and on Apple Silicon playing it switches the speakers to 96 kHz,
# which their safety daemon answers by locking the amps.
source <(sed -n '/^finalize_recording() {/,/^}/p' "$ROOT/bin/omarchy-capture-screenrecording")
recording="$work/recording.mp4"
ffmpeg -loglevel error -f lavfi -i testsrc=size=64x64:rate=30 -f lavfi -i sine=frequency=440:sample_rate=48000 \
  -t 1 -c:v libx264 -c:a aac -ar 48000 "$recording"
RECORDING_FILE="$work/latest"
echo "$recording" >"$RECORDING_FILE"
finalize_recording

# The pass trims the first 0.1 s, so a shorter file proves it ran.
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$recording")
awk -v d="$duration" 'BEGIN { exit !(d < 0.95) }' || fail "the loudness pass processed the recording" "$duration"
rate=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 "$recording")
[[ $rate == "48000" ]] || fail "the finalized recording keeps 48 kHz audio" "$rate"
pass "the finalized recording keeps 48 kHz audio"

# Single-pass loudnorm runs in dynamic mode, so a recording that opened on silence came
# out far too quiet and climbed for about a minute. Speech has to start at its final level.
recording="$work/silent-start.mp4"
ffmpeg -loglevel error -f lavfi -i testsrc=size=64x64:rate=30 -f lavfi -i "aevalsrc='0.005*sin(2*PI*300*t)*gte(t,10)':s=48000" \
  -t 30 -c:v libx264 -c:a aac -ar 48000 "$recording"
echo "$recording" >"$RECORDING_FILE"
finalize_recording

loudness() {
  ffmpeg -hide_banner -nostats -ss "$2" -t 4 -i "$1" -af ebur128 -f null - 2>&1 | awk '/I:/ { v = $2 } END { print v }'
}
start=$(loudness "$recording" 11)
later=$(loudness "$recording" 25)
awk -v s="$start" -v l="$later" 'BEGIN { exit !(s - l > -1 && s - l < 1 && l > -15 && l < -13) }' ||
  fail "speech after a silent start is at full level right away" "$start LUFS at 11 s, $later LUFS at 25 s"
pass "speech after a silent start is at full level right away"

# A clip shorter than 3 s has no 3 s loudness reading, so it kept its raw level unless the
# gain falls back to the 400 ms readings.
recording="$work/short.mp4"
ffmpeg -loglevel error -f lavfi -i testsrc=size=64x64:rate=30 -f lavfi -i "aevalsrc='0.005*sin(2*PI*300*t)':s=48000" \
  -t 2 -c:v libx264 -c:a aac -ar 48000 "$recording"
echo "$recording" >"$RECORDING_FILE"
finalize_recording
level=$(loudness "$recording" 0.5)
awk -v l="$level" 'BEGIN { exit !(l > -15 && l < -13) }' || fail "a short clip is brought to -14 LUFS too" "$level LUFS"
pass "a short clip is brought to -14 LUFS too"
