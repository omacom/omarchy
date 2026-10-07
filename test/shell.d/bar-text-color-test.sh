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
dark_band="$TMPDIR/dark-band.png"

magick -size 100x100 xc:'#202020' -fill '#f5f5f5' -draw 'rectangle 0,0 99,19' "$light_top"
magick -size 100x100 xc:'#f5f5f5' -fill '#202020' -draw 'rectangle 0,0 99,19' "$dark_top"
# Light everywhere but the band a bottom bar covers once it is inset by 20.
magick -size 100x100 xc:'#f5f5f5' -fill '#202020' -draw 'rectangle 0,60 99,79' "$dark_band"

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

# A detached bar covers a strip the screen edge does not. Same wallpaper, same
# bar size: only the offset moves the sample off the light top band and onto the
# dark one below it, which has to flip the answer.
result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100 --inset "20 0 0 0")
[[ $result == "#ffffff" ]] || fail "a detached top bar samples the strip it covers" "expected #ffffff, got $result"
pass "a detached top bar samples the strip it covers"

result=$(HOME="$TMPDIR" omarchy-bar-text-color bottom 20 '#ffffff' '#101010' --background "$dark_band" --screen 100x100)
[[ $result == "#101010" ]] || fail "a flush bottom bar samples the screen edge" "expected #101010, got $result"
pass "a flush bottom bar samples the screen edge"

result=$(HOME="$TMPDIR" omarchy-bar-text-color bottom 20 '#ffffff' '#101010' --background "$dark_band" --screen 100x100 --inset "0 0 20 0")
[[ $result == "#ffffff" ]] || fail "a detached bottom bar samples back from its own edge" "expected #ffffff, got $result"
pass "a detached bottom bar samples back from its own edge"

# The gap on the axis the bar spans moves the sample sideways, which is the half
# of a per-edge inset the vertical cases above cannot show.
split="$TMPDIR/split.png"
magick -size 100x100 xc:'#f5f5f5' -fill '#202020' -draw 'rectangle 0,0 49,99' "$split"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$split" --screen 100x100 --inset "0 0 0 50")
[[ $result == "#101010" ]] || fail "a bar inset from the left samples past the dark half" "expected #101010, got $result"
pass "a bar inset from the left samples past the dark half"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$split" --screen 100x100 --inset "0 50 0 0")
[[ $result == "#ffffff" ]] || fail "a bar inset from the right stops before the light half" "expected #ffffff, got $result"
pass "a bar inset from the right stops before the light half"

# A floating bar and a translucent pill together: sample the strip the bar
# covers, then composite the pill over it.
result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100 --inset "20 0 0 0" --blend '#f5f5f5' 0.9)
[[ $result == "#101010" ]] || fail "a light pill on a floating bar over a dark strip picks dark text" "expected #101010, got $result"
pass "a light pill on a floating bar over a dark strip picks dark text"
