#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR"
calls="$TMPDIR/calls"
ffmpeg_calls="$TMPDIR/ffmpeg-calls"

# `file` is stubbed because a real MIME probe on an empty fixture reports
# inode/x-empty and media_type would reject it; the extension decides here.
cat >"$STUB_DIR/file" <<'SH'
#!/bin/bash
case "${!#}" in
*.mov | *.mp4 | *.mkv | *.webm) echo video/mp4 ;;
*.png | *.heic | *.jpg) echo image/png ;;
*) echo application/octet-stream ;;
esac
SH

# The encoders record their argv -- %q-joined so spaced filenames stay one
# logical line -- plus the output path on its own out= line. They never create
# the output file: realpath tolerates a missing final component, and a stub
# touch would leak files into $TMPDIR and make dedupe rows self-collide.
for command in ffmpeg magick; do
  cat >"$STUB_DIR/$command" <<'SH'
#!/bin/bash
{
  printf '%s' "${0##*/}"
  printf ' %q' "$@"
  printf '\n'
  printf 'out=%q\n' "${!#}"
} >>"$CALLS"
SH
done

cat >"$STUB_DIR/wl-copy" <<'SH'
#!/bin/bash
cat >/dev/null
SH

cat >"$STUB_DIR/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notification: %s\n' "$*" >>"$CALLS"
SH

# Tripwires: every row below passes all four positionals, so a menu invocation
# means the run went interactive -- exiting 1 fails the run under set -e.
for command in omarchy-menu-file omarchy-menu-select; do
  cat >"$STUB_DIR/$command" <<'SH'
#!/bin/bash
printf 'menu invoked: %s\n' "${0##*/}" >>"$CALLS"
exit 1
SH
done

chmod +x "$STUB_DIR"/*

# Runs the real script against the stubs. Truncating $calls is the only
# per-run reset -- stubs never write outputs, so any row that pre-creates a
# collision fixture owns it and must rm -f it right after asserting. ffmpeg
# argv lines also accumulate in $ffmpeg_calls for the no-overwrite-flag pin.
run_transcode() {
  local status=0

  : >"$calls"
  HOME="$TMPDIR/home" PATH="$STUB_DIR:$PATH" CALLS="$calls" \
    "$ROOT/bin/omarchy-transcode" "$@" >"$TMPDIR/stdout" 2>"$TMPDIR/stderr" || status=$?

  grep '^ffmpeg' "$calls" >>"$ffmpeg_calls" 2>/dev/null || true
  return "$status"
}

touch "$TMPDIR/in.mov" "$TMPDIR/img.png"

# The explicit `medium` and the omitted quality must generate byte-identical
# ffmpeg argv -- and that line must equal the literal known-good invocation,
# so neither direction can hide a shared regression.
{
  printf 'ffmpeg'
  printf ' %q' -i "$TMPDIR/in.mov" -vf scale=-2:1080 -c:v libx264 -preset fast \
    -crf 23 -c:a aac -b:a 192k -movflags +faststart "$TMPDIR/in-1080p.mp4"
  printf '\n'
} >"$TMPDIR/expected-medium-argv"

run_transcode "$TMPDIR/in.mov" mp4 1080p medium
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-explicit-medium" ||
  fail "explicit medium records an ffmpeg line" "$(cat "$calls")"

run_transcode "$TMPDIR/in.mov" mp4 1080p
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-omitted-medium" ||
  fail "omitted quality records an ffmpeg line" "$(cat "$calls")"

if ! cmp -s "$TMPDIR/argv-explicit-medium" "$TMPDIR/argv-omitted-medium"; then
  fail "explicit medium and omitted quality produce identical ffmpeg argv" \
    "$(diff -u "$TMPDIR/argv-explicit-medium" "$TMPDIR/argv-omitted-medium")"
fi
pass "explicit medium and omitted quality produce identical ffmpeg argv"

if ! cmp -s "$TMPDIR/argv-omitted-medium" "$TMPDIR/expected-medium-argv"; then
  fail "medium quality produces the literal default ffmpeg argv" \
    "$(diff -u "$TMPDIR/expected-medium-argv" "$TMPDIR/argv-omitted-medium")"
fi
pass "medium quality produces the literal default ffmpeg argv"

grep -Fx "out=$TMPDIR/in-1080p.mp4" "$calls" >/dev/null ||
  fail "omitted quality writes the unsuffixed output name" "$(cat "$calls")"
pass "omitted quality writes the unsuffixed output name"

# Non-default tiers select the locked CRF values and take the quality suffix.
run_transcode "$TMPDIR/in.mov" mp4 1080p low
grep '^ffmpeg ' "$calls" | grep -F -- '-crf 28' >/dev/null ||
  fail "low quality selects x264 crf 28" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/in-1080p-low.mp4" "$calls" >/dev/null ||
  fail "low quality appends -low to the output name" "$(cat "$calls")"
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-low"
pass "low quality selects x264 crf 28 and writes in-1080p-low.mp4"

run_transcode "$TMPDIR/in.mov" mp4 1080p high
grep '^ffmpeg ' "$calls" | grep -F -- '-crf 18' >/dev/null ||
  fail "high quality selects x264 crf 18" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/in-1080p-high.mp4" "$calls" >/dev/null ||
  fail "high quality appends -high to the output name" "$(cat "$calls")"
pass "high quality selects x264 crf 18 and writes in-1080p-high.mp4"

# An existing output dedupes to -2 instead of tripping ffmpeg's overwrite
# prompt -- the stubs never create it, so the fixture is the only file.
touch "$TMPDIR/in-1080p.mp4"
run_transcode "$TMPDIR/in.mov" mp4 1080p
grep -Fx "out=$TMPDIR/in-1080p-2.mp4" "$calls" >/dev/null ||
  fail "an existing output dedupes to -2" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4"
pass "an existing output dedupes to -2"

# The deduped path must be resolved -- and the encode started -- only after
# the "Transcoding" notification, so failure states are never orphaned.
notify_line=$(grep -n 'Transcoding' "$calls" | head -n1 | cut -d: -f1)
ffmpeg_line=$(grep -n '^ffmpeg ' "$calls" | head -n1 | cut -d: -f1)
(( notify_line < ffmpeg_line )) ||
  fail "the Transcoding notification precedes the ffmpeg call" "$(cat "$calls")"
pass "the Transcoding notification precedes the ffmpeg call"

# A 4th positional on a picture fails before any notification, encoder, or
# menu -- the call log stays empty.
if run_transcode "$TMPDIR/img.png" jpg medium high; then
  fail "a picture transcode rejects a 4th positional"
fi
pass "a picture transcode rejects a 4th positional"

grep -q 'Invalid' "$TMPDIR/stderr" ||
  fail "picture quality rejection reports Invalid" "$(cat "$TMPDIR/stderr")"
pass "picture quality rejection reports Invalid"

if [[ -s $calls ]]; then
  fail "picture quality rejection precedes every side effect" "$(cat "$calls")"
fi
pass "picture quality rejection precedes every side effect"

# `medium` is rejected on pictures too -- the gate is [[ -n $quality ]], not
# a non-default check, so the locked vocabulary never leaks into slot 3.
if run_transcode "$TMPDIR/img.png" jpg medium medium; then
  fail "a picture transcode rejects quality=medium"
fi
pass "a picture transcode rejects quality=medium"

# 4k picks libx265 -preset slow; each tier pins its locked CRF (D-00a).
run_transcode "$TMPDIR/in.mov" mp4 4k high
grep '^ffmpeg ' "$calls" | grep -F -- '-c:v libx265 -preset slow -crf 20' >/dev/null ||
  fail "4k high selects x265 crf 20" "$(cat "$calls")"
pass "4k high selects x265 crf 20"

run_transcode "$TMPDIR/in.mov" mp4 4k medium
grep '^ffmpeg ' "$calls" | grep -F -- '-c:v libx265 -preset slow -crf 24' >/dev/null ||
  fail "4k medium selects x265 crf 24" "$(cat "$calls")"
pass "4k medium selects x265 crf 24"

run_transcode "$TMPDIR/in.mov" mp4 4k low
grep '^ffmpeg ' "$calls" | grep -F -- '-c:v libx265 -preset slow -crf 28' >/dev/null ||
  fail "4k low selects x265 crf 28" "$(cat "$calls")"
pass "4k low selects x265 crf 28"

# gif tiers vary fps only (D-00a, D-04) -- the palette pipeline stays put.
run_transcode "$TMPDIR/in.mov" gif 720p high
grep '^ffmpeg ' "$calls" | grep -F 'fps=15\,' >/dev/null ||
  fail "gif high selects fps=15" "$(cat "$calls")"
pass "gif high selects fps=15"

run_transcode "$TMPDIR/in.mov" gif 720p medium
grep '^ffmpeg ' "$calls" | grep -F 'fps=10\,' >/dev/null ||
  fail "gif medium selects fps=10" "$(cat "$calls")"
pass "gif medium selects fps=10"

run_transcode "$TMPDIR/in.mov" gif 720p low
grep '^ffmpeg ' "$calls" | grep -F 'fps=5\,' >/dev/null ||
  fail "gif low selects fps=5" "$(cat "$calls")"
pass "gif low selects fps=5"

# The dedupe counter climbs past every existing name and appends to the whole
# computed name, quality suffix included.
touch "$TMPDIR/in-1080p.mp4" "$TMPDIR/in-1080p-2.mp4"
run_transcode "$TMPDIR/in.mov" mp4 1080p
grep -Fx "out=$TMPDIR/in-1080p-3.mp4" "$calls" >/dev/null ||
  fail "two existing outputs dedupe to -3" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4" "$TMPDIR/in-1080p-2.mp4"
pass "two existing outputs dedupe to -3"

touch "$TMPDIR/in-1080p-low.mp4"
run_transcode "$TMPDIR/in.mov" mp4 1080p low
grep -Fx "out=$TMPDIR/in-1080p-low-2.mp4" "$calls" >/dev/null ||
  fail "an existing -low output dedupes to -low-2" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p-low.mp4"
pass "an existing -low output dedupes to -low-2"

# output_path is shared, so pictures dedupe under the same policy instead of
# magick's silent overwrite.
touch "$TMPDIR/img-medium.jpg"
run_transcode "$TMPDIR/img.png" jpg medium
grep -Fx "out=$TMPDIR/img-medium-2.jpg" "$calls" >/dev/null ||
  fail "an existing picture output dedupes to -2" "$(cat "$calls")"
rm -f "$TMPDIR/img-medium.jpg"
pass "an existing picture output dedupes to -2"

# A dangling symlink fails -e but must still dedupe -- without -L ffmpeg would
# write through the link to an unrelated target (T-05-01).
ln -s /nonexistent "$TMPDIR/in-1080p.mp4"
run_transcode "$TMPDIR/in.mov" mp4 1080p
grep -Fx "out=$TMPDIR/in-1080p-2.mp4" "$calls" >/dev/null ||
  fail "a dangling symlink still dedupes via -L" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4"
pass "a dangling symlink still dedupes via -L"

# Positive control: slot 3 on a picture is still the resolution vocabulary, so
# `img.png jpg low` resizes to 1080x> and writes img-low.jpg -- untouched.
run_transcode "$TMPDIR/img.png" jpg low
grep '^magick ' "$calls" | grep -F -- '-resize 1080x\>' >/dev/null ||
  fail "picture low still selects the 1080x resize" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/img-low.jpg" "$calls" >/dev/null ||
  fail "picture low still writes img-low.jpg" "$(cat "$calls")"
pass "picture low still selects the 1080x resize and writes img-low.jpg"

# A non-tier 4th positional fails pre-notification: non-zero, Invalid naming
# the value, and nothing recorded -- no notification, no encoder.
if run_transcode "$TMPDIR/in.mov" mp4 1080p bogus; then
  fail "a non-tier quality is rejected"
fi
grep -F 'Invalid video quality: bogus' "$TMPDIR/stderr" >/dev/null ||
  fail "a non-tier quality names the rejected value" "$(cat "$TMPDIR/stderr")"
if [[ -s $calls ]]; then
  fail "a non-tier quality fails before every side effect" "$(cat "$calls")"
fi
pass "a non-tier quality is rejected pre-notification"

# An empty 4th positional is "not specified": byte-identical medium argv and
# the unsuffixed name.
run_transcode "$TMPDIR/in.mov" mp4 1080p ""
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-empty" ||
  fail "an empty quality records an ffmpeg line" "$(cat "$calls")"
if ! cmp -s "$TMPDIR/argv-empty" "$TMPDIR/expected-medium-argv"; then
  fail "an empty quality behaves as omitted" \
    "$(diff -u "$TMPDIR/expected-medium-argv" "$TMPDIR/argv-empty")"
fi
grep -Fx "out=$TMPDIR/in-1080p.mp4" "$calls" >/dev/null ||
  fail "an empty quality writes the unsuffixed output name" "$(cat "$calls")"
pass "an empty quality behaves as omitted"

# Whitespace is not a tier and is never silently trimmed into one.
if run_transcode "$TMPDIR/in.mov" mp4 1080p " ultra "; then
  fail "a whitespace-padded quality is rejected"
fi
grep -F 'Invalid video quality' "$TMPDIR/stderr" >/dev/null ||
  fail "a whitespace-padded quality reports Invalid video quality" "$(cat "$TMPDIR/stderr")"
pass "a whitespace-padded quality is rejected"

# A 4th positional after -- lands in positional[3] identically to the bare
# form.
run_transcode -- "$TMPDIR/in.mov" mp4 1080p low
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-dashdash" ||
  fail "a -- passthrough records an ffmpeg line" "$(cat "$calls")"
if ! cmp -s "$TMPDIR/argv-dashdash" "$TMPDIR/argv-low"; then
  fail "a -- passthrough produces the bare low argv" \
    "$(diff -u "$TMPDIR/argv-low" "$TMPDIR/argv-dashdash")"
fi
pass "a -- passthrough produces the bare low argv"

# Spaced filenames survive as single argv elements end to end; %q records the
# escaped form.
touch "$TMPDIR/my clip.mov"
run_transcode "$TMPDIR/my clip.mov" mp4 1080p
grep -F -- "-i $(printf '%q' "$TMPDIR/my clip.mov")" "$calls" >/dev/null ||
  fail "a spaced input stays one argv element" "$(cat "$calls")"
grep -Fx "out=$(printf '%q' "$TMPDIR/my clip-1080p.mp4")" "$calls" >/dev/null ||
  fail "a spaced input produces the escaped output name" "$(cat "$calls")"
pass "a spaced input stays one argv element end to end"

# Dedupe is the whole collision policy: no recorded ffmpeg argv ever carries
# an overwrite-control flag.
if grep -E '(^|[[:space:]])-[yn]([[:space:]]|$)' "$ffmpeg_calls"; then
  fail "no ffmpeg invocation carries an overwrite flag" "$(cat "$ffmpeg_calls")"
fi
pass "no ffmpeg invocation carries an overwrite flag"

# --help advertises the new arg and the video-only quality vocabulary.
run_transcode --help
grep -F '[quality]' "$TMPDIR/stdout" >/dev/null ||
  fail "usage shows [quality]" "$(cat "$TMPDIR/stdout")"
grep -F 'Videos: high, medium, low' "$TMPDIR/stdout" >/dev/null ||
  fail "usage lists the video quality tiers" "$(cat "$TMPDIR/stdout")"
pass "usage documents [quality] and the video tiers"
