#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command ffmpeg
require_command ffprobe
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Keep the desktop quiet. The command under test notifies and copies the
# result; neither is what this check is about.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$test_tmp/bin/wl-copy" <<'STUB'
#!/bin/bash
cat >/dev/null
STUB
chmod +x "$test_tmp/bin/omarchy-notification-send" "$test_tmp/bin/wl-copy"

# An iPhone recording marks spatial audio as the default track and keeps a
# stereo AAC track beside it. FFmpeg has no apple_apac decoder, so a real
# file aborts before any video is written. This fixture is that shape: the
# first audio sample entry wears the apac fourcc and its AAC descriptor is
# blank, so probing reports apple_apac, while the second track stays AAC.
python3 - "$test_tmp/spatial.mov" <<'PY'
import subprocess
import sys

destination = sys.argv[1]
source = destination + ".src.mov"
subprocess.check_call([
    "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
    "-f", "lavfi", "-i", "color=c=black:s=32x32:r=30:d=1",
    "-f", "lavfi", "-i", "sine=frequency=440:sample_rate=48000:duration=1",
    "-f", "lavfi", "-i", "sine=frequency=880:sample_rate=48000:duration=1",
    "-map", "0:v:0", "-map", "1:a:0", "-map", "2:a:0",
    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a:0", "aac", "-c:a:1", "aac",
    "-disposition:a:0", "default", "-disposition:a:1", "0",
    source,
])
data = bytearray(open(source, "rb").read())
starts = []
cursor = 0
while True:
    found = data.find(b"stsd", cursor)
    if found < 0:
        break
    starts.append(found)
    cursor = found + 4
audio = starts[1]
data[audio + 16:audio + 20] = b"apac"
descriptor = data.find(b"esds", audio)
size = int.from_bytes(data[descriptor - 4:descriptor], "big")
body = descriptor + 8
end = descriptor - 4 + size
data[body:end] = b"\x00" * (end - body)
open(destination, "wb").write(data)
PY

probe=$(ffprobe -v error -select_streams a -show_entries stream=codec_name:stream_disposition=default -of csv=p=0 "$test_tmp/spatial.mov")
[[ $probe == $'apple_apac,1\naac,0' ]] || fail "fixture matches an iPhone spatial recording" "$probe"

output="$test_tmp/spatial-720p.mp4"
if ! PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-transcode" "$test_tmp/spatial.mov" mp4 720p >"$test_tmp/log" 2>&1; then
  fail "transcode finishes when the default audio track has no decoder" "$(cat "$test_tmp/log")"
fi
[[ -f $output ]] || fail "transcode writes the mp4 beside the recording" "$(cat "$test_tmp/log")"

codec=$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$output")
[[ $codec == "aac" ]] || fail "transcode uses the AAC track when spatial audio is the default" "$codec"
pass "transcode uses the AAC track when spatial audio is the default"

# ffprobe calls this codec "dts". The decoder list names it "dca" and only
# mentions dts in "(codec dts)", so a name-only check rejects a track ffmpeg
# can convert.
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "color=c=black:s=32x32:r=30:d=1" \
  -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=1" \
  -map 0:v:0 -map 1:a:0 \
  -c:v libx264 -pix_fmt yuv420p -c:a dca -strict experimental \
  "$test_tmp/dts.mkv"
dts_codec=$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$test_tmp/dts.mkv")
[[ $dts_codec == "dts" ]] || fail "fixture reports DTS under the name ffprobe uses" "$dts_codec"
if ! PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-transcode" "$test_tmp/dts.mkv" mp4 720p >"$test_tmp/log" 2>&1; then
  fail "transcode keeps DTS audio when its decoder has another name" "$(cat "$test_tmp/log")"
fi
codec=$(ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$test_tmp/dts-720p.mp4")
[[ $codec == "aac" ]] || fail "transcode converts the DTS track to AAC" "$codec"
pass "transcode keeps DTS audio when its decoder has another name"

# The reviewer's file has DTS and no picture. file(1) still calls it a video,
# and ffmpeg writes an AAC mp4 from it. The command has to do the same.
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "sine=frequency=440:sample_rate=48000:duration=1" \
  -c:a dca -strict -2 \
  "$test_tmp/dts-only.mkv"
if ! PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-transcode" "$test_tmp/dts-only.mkv" mp4 720p >"$test_tmp/log" 2>&1; then
  fail "transcode converts a DTS-only file to AAC" "$(cat "$test_tmp/log")"
fi
streams=$(ffprobe -v error -show_entries stream=codec_type,codec_name -of csv=p=0 "$test_tmp/dts-only-720p.mp4")
[[ $streams == "aac,audio" ]] || fail "a DTS-only file becomes an AAC mp4 with no video track" "$streams"
pass "a DTS-only file becomes an AAC mp4 with no video track"

# No default disposition, so ffmpeg's own choice is the larger frame, even
# though the small one comes first. scale=-2:720 turns 80x40 into 1440x720
# and 16x16 into 720x720.
ffmpeg -y -hide_banner -loglevel error \
  -f lavfi -i "color=c=red:s=16x16:r=10:d=1" \
  -f lavfi -i "color=c=blue:s=80x40:r=10:d=1" \
  -map 0:v:0 -map 1:v:0 -disposition:v:0 0 -disposition:v:1 0 \
  -c:v libx264 -pix_fmt yuv420p \
  "$test_tmp/preview.mkv"
if ! PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-transcode" "$test_tmp/preview.mkv" mp4 720p >"$test_tmp/log" 2>&1; then
  fail "transcode keeps the larger video track" "$(cat "$test_tmp/log")"
fi
width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$test_tmp/preview-720p.mp4")
[[ $width == "1440" ]] || fail "transcode keeps the larger video track when it is not first" "$width"
pass "transcode keeps the larger video track when it is not first"
