#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick
require_command ffmpeg

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

export PATH="$ROOT/bin:$PATH"

light_top="$TMPDIR/light-top.png"
dark_top="$TMPDIR/dark-top.png"

magick -size 100x100 xc:'#202020' -fill '#f5f5f5' -draw 'rectangle 0,0 99,19' "$light_top"
magick -size 100x100 xc:'#f5f5f5' -fill '#202020' -draw 'rectangle 0,0 99,19' "$dark_top"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#101010" ]] || fail "transparent bar text switches to background color on light wallpaper" "expected #101010, got $result"
pass "transparent bar text switches to background color on light wallpaper"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$dark_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "transparent bar text keeps text color on dark wallpaper" "expected #ffffff, got $result"
pass "transparent bar text keeps text color on dark wallpaper"

# Pills: the text sits on the pill, so a pill is composited over the sampled
# strip before the pick. The wallpaper here is dark.
result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$dark_top" --screen 100x100 --blend '#f5f5f5' 0.9)
[[ $result == "#101010" ]] || fail "bar text follows a light translucent pill over a dark wallpaper" "expected #101010, got $result"
pass "bar text follows a light translucent pill over a dark wallpaper"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$dark_top" --screen 100x100 --blend '#f5f5f5' 0.1)
[[ $result == "#ffffff" ]] || fail "bar text follows the wallpaper through a faint pill" "expected #ffffff, got $result"
pass "bar text follows the wallpaper through a faint pill"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$TMPDIR/missing.png" --screen 100x100 --blend '#f5f5f5' 1)
[[ $result == "#101010" ]] || fail "an opaque pill decides the bar text without sampling the wallpaper" "expected #101010, got $result"
pass "an opaque pill decides the bar text without sampling the wallpaper"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100 --blend 'nope' 0.5)
[[ $result == "#ffffff" ]] || fail "a malformed pill colour falls back to the text color" "expected #ffffff, got $result"
pass "a malformed pill colour falls back to the text color"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$TMPDIR/missing.png" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "transparent bar text falls back to text color when sampling fails" "expected #ffffff, got $result"
pass "transparent bar text falls back to text color when sampling fails"

# A video background must be sampled one frame at a time. Reading the whole file
# emits a value per frame, which parses as nothing and silently falls back —
# and decodes the entire wallpaper to find that out.
light_top_video="$TMPDIR/light-top.mp4"
ffmpeg -y -f lavfi -i "testsrc=size=640x360:rate=10:duration=2" \
  -vf "drawbox=x=0:y=0:w=640:h=40:color=0xf5f5f5:t=fill" \
  -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$light_top_video" -loglevel error

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 40 '#ffffff' '#101010' --background "$light_top_video" --screen 640x360)
[[ $result == "#101010" ]] || fail "transparent bar text samples one frame of a video wallpaper" "expected #101010, got $result"
pass "transparent bar text samples one frame of a video wallpaper"
