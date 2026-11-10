#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command ffmpeg

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
for command in omarchy-i18n omarchy-notification-send wl-copy; do
  printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/$command"
done
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"
ffmpeg -hide_banner -loglevel error -f lavfi -i color=size=16x16:rate=1 -t 1 -c:v mpeg4 "$scratch/local.mp4"
for format in mp4 gif; do
  bash "$ROOT/bin/omarchy-transcode" "$scratch/local.mp4" "$format" 720p >"$scratch/convert.log" 2>&1 || fail "a local video still converts to $format" "$(cat "$scratch/convert.log")"
done
pass "local MP4 and GIF conversions still work"

# A path named http:/... is a real local directory tree. Redundant slashes
# still find that file, but FFmpeg reads the argument as a network URL.
mkdir -p "$scratch/http:/127.0.0.1:9"
cp "$scratch/local.mp4" "$scratch/http:/127.0.0.1:9/clip.mp4"
cp "$scratch/local.mp4" "$scratch/-clip.ts"
for input in 'http://127.0.0.1:9/clip.mp4' '-clip.ts'; do
  (cd "$scratch"; bash "$ROOT/bin/omarchy-transcode" -- "$input" mp4 720p) >"$scratch/literal.log" 2>&1 ||
    fail "a URL-like or leading-dash local filename converts as a local file" "$(cat "$scratch/literal.log")"
done
[[ -s $scratch/http:/127.0.0.1:9/clip-720p.mp4 && -s $scratch/-clip-720p.mp4 ]] || fail "literal filenames produce their local outputs"
pass "URL-like and leading-dash local filenames convert without being interpreted as URLs or options"

newline_input="$scratch/"$'newline.mp4\n'
cp "$scratch/local.mp4" "$newline_input"
bash "$ROOT/bin/omarchy-transcode" "$newline_input" mp4 720p >"$scratch/newline.log" 2>&1 ||
  fail "a filename ending in a newline still converts" "$(cat "$scratch/newline.log")"
[[ -s $scratch/newline-720p.mp4 ]] || fail "conversion writes the newline input's output"
pass "conversion preserves a trailing newline in the decoder input"

selected_dir="$scratch/"$'selected\n'
mkdir "$selected_dir"
ln -s "$scratch/local.mp4" "$selected_dir/link.mp4"
rm "$scratch/local-720p.mp4"
bash "$ROOT/bin/omarchy-transcode" "$selected_dir/link.mp4" mp4 720p >"$scratch/link.log" 2>&1 ||
  fail "a linked video still converts" "$(cat "$scratch/link.log")"
[[ -s $selected_dir/link-720p.mp4 && ! -e $scratch/local-720p.mp4 ]] ||
  fail "conversion writes next to the selected symlink"
pass "a linked input produces output beside the selected file"
