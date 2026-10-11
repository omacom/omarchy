#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command ffmpeg
require_command ffprobe

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# loudnorm declares 192 kHz output, so without a pinned rate the finalize pass
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
