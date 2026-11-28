#!/bin/bash

# #15443: without measured values, loudnorm runs in dynamic mode (100 ms frames, a 3 s lookahead) and
# at EOF flushes that buffer with gain steps it never smooths, which mis-gains the tail — the report
# measured it as a -1.0 dBFS spike 3.0 s before the end, and the same mechanism shows up here as a
# quiet tail that comes out ~8 dB down. Padding lets the flush happen on silence.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command ffmpeg
require_command ffprobe

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# The finalize pass, extracted from the script under test.
source <(sed -n '/^finalize_recording() {/,/^}/p' "$ROOT/bin/omarchy-capture-screenrecording")

recording="$work/recording.mp4"
# 10 s of video, and audio with a loud passage and a quiet tail: the quiet level is what the EOF
# flush gets wrong, and a steady tone does not trigger it.
ffmpeg -loglevel error -f lavfi -i "testsrc=size=64x64:rate=30:d=10" \
  -f lavfi -i "aevalsrc='0.02*sin(2*PI*300*t)+0.9*sin(2*PI*300*t)*between(t,6,7.5)':d=10" \
  -t 10 -c:v libx264 -c:a aac -ar 48000 "$recording"
RECORDING_FILE="$work/latest"
echo "$recording" >"$RECORDING_FILE"
finalize_recording

tail_peak() {
  ffmpeg -sseof -2 -i "$1" -af volumedetect -f null - 2>&1 |
    awk '/max_volume/ { print $(NF-1) }'
}

# The input's quiet tail is 0.02 amplitude, ~-34 dBFS; the finalized tail has to stay there.
peak=$(tail_peak "$recording")
awk -v p="$peak" 'BEGIN { exit !(p > -39) }' ||
  fail "the loudness pass leaves the quiet tail where it was" "tail peak ${peak} dB (input ~-34 dB)"

# The 3 s of padding is trimmed again: the recording keeps its length.
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$recording")
awk -v d="$duration" 'BEGIN { exit !(d < 10 && d > 9.5) }' ||
  fail "the padded pass trims the padding back to the video" "$duration"

pass "the loudness pass does not mis-gain the tail"
