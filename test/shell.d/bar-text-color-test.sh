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

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$TMPDIR/missing.png" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "transparent bar text falls back to text color when sampling fails" "expected #ffffff, got $result"
pass "transparent bar text falls back to text color when sampling fails"

# Fine detail must be averaged, not point-sampled. On a quarter-white stripe
# pattern at four times screen size, point sampling lands on the white stripes
# and switches a dark bar to the background color.
dark_stripes="$TMPDIR/dark-stripes.png"
magick -size 4x1 xc:black -fill white -draw 'point 1,0' "$TMPDIR/stripe.png"
magick -size 400x100 tile:"$TMPDIR/stripe.png" "$dark_stripes"

result=$(HOME="$TMPDIR" omarchy-bar-text-color top 10 '#ffffff' '#101010' --background "$dark_stripes" --screen 100x25)
[[ $result == "#ffffff" ]] || fail "transparent bar text averages fine wallpaper detail" "expected #ffffff, got $result"
pass "transparent bar text averages fine wallpaper detail"

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

bounded_bin="$TMPDIR/bounded-bin"
mkdir -p "$bounded_bin"
cat >"$bounded_bin/timeout" <<'SH'
#!/bin/bash
printf '%s\t%s\t%s\n' "$1" "$2" "$3" >"$TIMEOUT_LOG"
shift 2
exec "$@"
SH
cat >"$bounded_bin/magick" <<'SH'
#!/bin/bash
printf '%s\t%s\t%s\t%s\t%s\n' \
  "$MAGICK_MEMORY_LIMIT" "$MAGICK_MAP_LIMIT" "$MAGICK_DISK_LIMIT" "$MAGICK_TIME_LIMIT" "$MAGICK_THREAD_LIMIT" >"$LIMIT_LOG"
printf '%s\n' "$*" >"$ARGS_LOG"
printf '245,245,245'
SH
chmod +x "$bounded_bin/timeout" "$bounded_bin/magick"

result=$(HOME="$TMPDIR" LIMIT_LOG="$TMPDIR/limits" TIMEOUT_LOG="$TMPDIR/timeout" ARGS_LOG="$TMPDIR/args" PATH="$bounded_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#101010" ]] || fail "bounded wallpaper sample still chooses the contrasting color" "expected #101010, got $result"
[[ $(<"$TMPDIR/limits") == $'512MiB\t0\t0\t5\t2' ]] || fail "wallpaper sampling bounds ImageMagick resources" "$(<"$TMPDIR/limits")"
[[ $(<"$TMPDIR/timeout") == $'--kill-after=1s\t5s\tmagick' ]] || fail "wallpaper sampling has a hard timeout" "$(<"$TMPDIR/timeout")"
pass "transparent bar wallpaper sampling is resource bounded"

# Only the bar strip's mean color is needed, so a high-resolution screen is sampled
# on a canvas at most 1920 px wide, and JPEG decodes at about that size. Otherwise
# a 6K or 8K wallpaper exceeds the pixel-cache limit and silently falls back.
HOME="$TMPDIR" LIMIT_LOG="$TMPDIR/limits" TIMEOUT_LOG="$TMPDIR/timeout" ARGS_LOG="$TMPDIR/args" PATH="$bounded_bin:$PATH" \
  omarchy-bar-text-color bottom 64 '#ffffff' '#101010' --background "$light_top" --screen 6016x3384 >/dev/null
args=$(<"$TMPDIR/args")
[[ $args == "-define jpeg:size=1920x1080 "* ]] || fail "high-resolution screen decodes JPEG at canvas size" "$args"
[[ $args == *" -scale 1920x1080^ "* && $args == *" -crop 1920x21+0+1059 "* ]] ||
  fail "high-resolution screen samples a scaled canvas" "$args"
pass "high-resolution screen samples a scaled canvas"

# An existing wallpaper whose bounded sample fails (ImageMagick refuses it at a
# resource limit) or runs out of time must keep the configured text color, even
# on a light wallpaper where a finished sample would switch it.
failing_bin="$TMPDIR/failing-bin"
mkdir -p "$failing_bin"
cat >"$failing_bin/magick" <<'SH'
#!/bin/bash
echo "magick: cache resources exhausted" >&2
exit 1
SH
chmod +x "$failing_bin/magick"

result=$(HOME="$TMPDIR" PATH="$failing_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "failed wallpaper sample falls back to text color" "expected #ffffff, got $result"
pass "failed wallpaper sample falls back to text color"

expired_bin="$TMPDIR/expired-bin"
mkdir -p "$expired_bin"
cat >"$expired_bin/timeout" <<'SH'
#!/bin/bash
exit 124
SH
chmod +x "$expired_bin/timeout"

result=$(HOME="$TMPDIR" PATH="$expired_bin:$PATH" \
  omarchy-bar-text-color top 20 '#ffffff' '#101010' --background "$light_top" --screen 100x100)
[[ $result == "#ffffff" ]] || fail "timed-out wallpaper sample falls back to text color" "expected #ffffff, got $result"
pass "timed-out wallpaper sample falls back to text color"
