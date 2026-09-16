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
# logical line -- plus the output path on its own out= line. They create the
# output file only under FAKE_OUT_BYTES (truncate -s the last positional, the
# output path for both encoder argv shapes): realpath tolerates a missing
# final component, and an unconditional touch would leak files into $TMPDIR
# and make dedupe rows self-collide -- rows that set the knob own the file
# and rm -f it after asserting. FAKE_ENCODE_RC exits the stub non-zero to
# prove the done notification never fires on encode failure.
for command in ffmpeg magick; do
  cat >"$STUB_DIR/$command" <<'SH'
#!/bin/bash
{
  printf '%s' "${0##*/}"
  printf ' %q' "$@"
  printf '\n'
  printf 'out=%q\n' "${!#}"
} >>"$CALLS"
if [[ -n ${FAKE_OUT_BYTES:-} ]]; then
  truncate -s "$FAKE_OUT_BYTES" "${!#}"
fi
exit "${FAKE_ENCODE_RC:-0}"
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

# omarchy-menu-file stays a pure tripwire: no row below goes through the file
# pick, so an invocation means the run went interactive where it must not --
# exiting 1 fails the run under set -e.
for command in omarchy-menu-file; do
  cat >"$STUB_DIR/$command" <<'SH'
#!/bin/bash
printf 'menu invoked: %s\n' "${0##*/}" >>"$CALLS"
exit 1
SH
done

# omarchy-menu-select is dual-mode. With FAKE_PICK unset it keeps the tripwire
# semantics for the rows that must never go interactive (all-four-positional
# video runs, picture rows, qualities rejected pre-prompt). With FAKE_PICK set
# it records the argv it was offered and answers with that pick -- rows that
# omit the quality positional legitimately fire the quality menu and must set
# it. An empty FAKE_PICK is Esc, matching the real script's exit-1 on an empty
# selection; printf '%s' not '%s\n' because the real script cats the selection
# file with no trailing newline.
cat >"$STUB_DIR/omarchy-menu-select" <<'SH'
#!/bin/bash
printf 'menu-select: %s\n' "$*" >>"$CALLS"
if [[ -z ${FAKE_PICK+x} ]]; then
  exit 1
fi
[[ -n $FAKE_PICK ]] || exit 1
printf '%s' "$FAKE_PICK"
SH

# ffprobe dispatches on argv: the audio-presence probe carries
# `stream=codec_type` glued to `-show_entries`, so ` stream=codec_type ` in
# " $* " selects that arm -- a bare ` codec_type ` glob never matches the real
# argv. That arm exits 0 with empty output on a successful no-stream probe,
# which must stay distinguishable from probe failure or the conservative-192
# rule cannot be exercised. Any other call is the duration probe: FAKE_DURATION
# unset fails hard with no output; FAKE_PROBE_RC overrides the exit status.
cat >"$STUB_DIR/ffprobe" <<'SH'
#!/bin/bash
printf 'ffprobe: %s\n' "$*" >>"$CALLS"
case " $* " in
*" stream=codec_type "*)
  if [[ ${FAKE_AUDIO:-yes} == "yes" ]]; then
    echo audio
  fi
  exit 0
  ;;
*)
  if [[ -n ${FAKE_DURATION+x} ]]; then
    printf '%s\n' "$FAKE_DURATION"
    exit "${FAKE_PROBE_RC:-0}"
  fi
  exit 1
  ;;
esac
SH

chmod +x "$STUB_DIR"/*

# Runs the real script against the stubs. Truncating $calls is the only
# per-run reset -- stubs write outputs only under FAKE_OUT_BYTES, so any row
# that pre-creates a collision fixture (or sets the knob) owns those files and
# must rm -f them right after asserting. ffmpeg argv lines also accumulate in
# $ffmpeg_calls for the no-overwrite-flag pin.
run_transcode() {
  local status=0

  : >"$calls"
  HOME="$TMPDIR/home" PATH="$STUB_DIR:$PATH" CALLS="$calls" \
    "$ROOT/bin/omarchy-transcode" "$@" >"$TMPDIR/stdout" 2>"$TMPDIR/stderr" || status=$?

  grep '^ffmpeg' "$calls" >>"$ffmpeg_calls" 2>/dev/null || true
  return "$status"
}

# A sized fixture: stat reports 120 MiB, above the largest pinned estimate
# (~107 MiB at dur=157/1080p/high), so estimate rows render numbers instead of
# degrading to larger-than-source. Sparse, so it costs no real blocks.
truncate -s 120M "$TMPDIR/in.mov"
touch "$TMPDIR/img.png"

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

FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/in.mov" mp4 1080p
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
FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/in.mov" mp4 1080p
grep -Fx "out=$TMPDIR/in-1080p-2.mp4" "$calls" >/dev/null ||
  fail "an existing output dedupes to -2" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4"
pass "an existing output dedupes to -2"

# The deduped path must be resolved -- and the encode started -- only after
# the "Transcoding" notification, so failure states are never orphaned.
notify_line=$(grep -n 'Transcoding' "$calls" | head -n1 | cut -d: -f1 || true)
ffmpeg_line=$(grep -n '^ffmpeg ' "$calls" | head -n1 | cut -d: -f1 || true)
[[ -n $notify_line && -n $ffmpeg_line ]] ||
  fail "the Transcoding notification and ffmpeg call both recorded" "$(cat "$calls")"
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
FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/in.mov" mp4 1080p
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
FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/in.mov" mp4 1080p
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
FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/in.mov" mp4 1080p ""
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
FAKE_PICK=$'medium\tBalanced' run_transcode "$TMPDIR/my clip.mov" mp4 1080p
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

# An unset video quality fires the Select quality menu end to end: tab-joined
# rows (leading tab = empty glyph field) carrying CRF N · ~N MB subtexts at the
# locked 1080p midpoints plus the 192k audio term, and --default-index 1
# pre-highlighting medium.
FAKE_DURATION=60 FAKE_PICK=$'medium\tCRF 23 · ~23 MB' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
grep -F 'Select quality' "$calls" >/dev/null ||
  fail "an unset video quality fires the Select quality menu" "$(cat "$calls")"
grep -F -- '--default-index 1' "$calls" >/dev/null ||
  fail "the quality menu pre-highlights medium" "$(cat "$calls")"
for row in $'\thigh\tCRF 18 · ~41 MB' $'\tmedium\tCRF 23 · ~23 MB' $'\tlow\tCRF 28 · ~11 MB'; do
  grep -F "$row" "$calls" >/dev/null ||
    fail "the quality menu offers a $row row" "$(cat "$calls")"
done
pass "the quality menu fires with CRF N · ~N MB rows and medium pre-highlighted"

# The Enter-default pick is the medium row: the recorded ffmpeg argv is
# byte-identical to positional medium and lands on the unsuffixed name.
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-menu-medium" ||
  fail "a medium menu pick records an ffmpeg line" "$(cat "$calls")"
if ! cmp -s "$TMPDIR/argv-menu-medium" "$TMPDIR/expected-medium-argv"; then
  fail "a medium menu pick produces the literal medium ffmpeg argv" \
    "$(diff -u "$TMPDIR/expected-medium-argv" "$TMPDIR/argv-menu-medium")"
fi
grep -Fx "out=$TMPDIR/in-1080p.mp4" "$calls" >/dev/null ||
  fail "a medium menu pick writes the unsuffixed output name" "$(cat "$calls")"
pass "a medium menu pick equals positional medium byte-for-byte"

# The label<TAB>subtext return is stripped at the first tab before the tier
# case -- a `low\t...` pick selects crf 28 and the -low suffix.
FAKE_DURATION=60 FAKE_PICK=$'low\tCRF 28 · ~11 MB' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
grep '^ffmpeg ' "$calls" | grep -F -- '-crf 28' >/dev/null ||
  fail "a low menu pick selects x264 crf 28" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/in-1080p-low.mp4" "$calls" >/dev/null ||
  fail "a low menu pick appends -low to the output name" "$(cat "$calls")"
pass "a menu pick strips the subtext before tier matching"

# The four-positional path never goes interactive: no menu, no probe -- and
# the same medium argv as always.
run_transcode "$TMPDIR/in.mov" mp4 1080p medium
if grep -q '^menu-select:' "$calls" || grep -q '^ffprobe:' "$calls"; then
  fail "a four-positional run never prompts or probes" "$(cat "$calls")"
fi
grep '^ffmpeg ' "$calls" >"$TMPDIR/argv-noninteractive" ||
  fail "a four-positional run records an ffmpeg line" "$(cat "$calls")"
if ! cmp -s "$TMPDIR/argv-noninteractive" "$TMPDIR/expected-medium-argv"; then
  fail "a four-positional medium produces the literal medium argv" \
    "$(diff -u "$TMPDIR/expected-medium-argv" "$TMPDIR/argv-noninteractive")"
fi
pass "a four-positional run never prompts or probes"

# Esc semantics: an empty pick exits the menu stub with 1, which propagates
# through the command substitution and aborts the run silently -- before the
# Transcoding notification, same as the sibling prompts.
if FAKE_PICK="" FAKE_DURATION=60 run_transcode "$TMPDIR/in.mov" mp4 1080p; then
  fail "an empty menu pick aborts the run"
fi
if grep -q 'notification:' "$calls" || grep -q '^ffmpeg ' "$calls"; then
  fail "an empty menu pick aborts before the notification" "$(cat "$calls")"
fi
pass "an empty menu pick aborts before the notification"

# Sig-fig rendering: a 157 s clip at 1080p rounds each estimate to 1-2
# significant figures (~110 / ~60 / ~30 MB) -- never a decimal point.
FAKE_DURATION=157 FAKE_PICK=$'medium\tCRF 23 · ~60 MB' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
for row in 'CRF 18 · ~110 MB' 'CRF 23 · ~60 MB' 'CRF 28 · ~30 MB'; do
  grep -F "$row" "$calls" >/dev/null ||
    fail "a 157 s clip offers a $row row" "$(cat "$calls")"
done
if grep '^menu-select: ' "$calls" | grep -E '~[0-9]*\.[0-9]' >/dev/null; then
  fail "estimates never render a decimal point" "$(cat "$calls")"
fi
pass "estimates render at 1-2 significant figures with no decimals"

# A 15 MiB source sits between the low (~11 MB) and medium (~23 MB) estimates
# at 60 s/1080p, so only the exceeding tiers degrade -- per-row, never the
# whole menu.
truncate -s 15M "$TMPDIR/small.mov"
FAKE_DURATION=60 FAKE_PICK=$'low\tCRF 28 · ~11 MB' \
  run_transcode "$TMPDIR/small.mov" mp4 1080p
grep -F $'\thigh\tCRF 18 · larger than source' "$calls" >/dev/null ||
  fail "the high row degrades when its estimate exceeds the source" "$(cat "$calls")"
grep -F $'\tmedium\tCRF 23 · larger than source' "$calls" >/dev/null ||
  fail "the medium row degrades when its estimate exceeds the source" "$(cat "$calls")"
grep -F $'\tlow\tCRF 28 · ~11 MB' "$calls" >/dev/null ||
  fail "the low row keeps its estimate under the source size" "$(cat "$calls")"
rm -f "$TMPDIR/small.mov"
pass "larger than source degrades per row, not per menu"

# Below every tier estimate, all three rows degrade together.
truncate -s 1024 "$TMPDIR/tiny.mov"
FAKE_DURATION=60 FAKE_PICK=$'medium\tCRF 23 · larger than source' \
  run_transcode "$TMPDIR/tiny.mov" mp4 1080p
for row in $'\thigh\tCRF 18 · larger than source' $'\tmedium\tCRF 23 · larger than source' $'\tlow\tCRF 28 · larger than source'; do
  grep -F "$row" "$calls" >/dev/null ||
    fail "a tiny source degrades the $row row" "$(cat "$calls")"
done
rm -f "$TMPDIR/tiny.mov"
pass "a tiny source degrades all three rows to larger than source"

# An N/A duration fails the numeric gate, so all three rows fall back to the
# qualitative vocabulary -- never a subtext/no-subtext mix, never an abort.
FAKE_DURATION=N/A FAKE_PICK=$'medium\tBalanced' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
for subtext in 'Best quality' 'Balanced' 'Smallest file'; do
  grep -F "$subtext" "$calls" >/dev/null ||
    fail "an N/A duration offers the $subtext fallback" "$(cat "$calls")"
done
if grep '^menu-select: ' "$calls" | grep -F '~' >/dev/null; then
  fail "an N/A duration renders no estimates" "$(cat "$calls")"
fi
grep '^ffmpeg ' "$calls" >/dev/null ||
  fail "an N/A duration still transcodes the pick" "$(cat "$calls")"
pass "an N/A duration falls back to qualitative rows and still transcodes"

# A probe that dies outright degrades identically -- cosmetic fallback, and
# the run still reaches ffmpeg.
FAKE_PROBE_RC=1 FAKE_PICK=$'medium\tBalanced' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
for subtext in 'Best quality' 'Balanced' 'Smallest file'; do
  grep -F "$subtext" "$calls" >/dev/null ||
    fail "a failed probe offers the $subtext fallback" "$(cat "$calls")"
done
if grep '^menu-select: ' "$calls" | grep -F '~' >/dev/null; then
  fail "a failed probe renders no estimates" "$(cat "$calls")"
fi
grep '^ffmpeg ' "$calls" >/dev/null ||
  fail "a failed probe still transcodes the pick" "$(cat "$calls")"
pass "a failed probe degrades to qualitative rows without aborting"

# A proven-audio-less source drops the 192k term: 60 s at 1080p renders
# ~39/~21/~10 MB instead of ~41/~23/~11.
FAKE_AUDIO=no FAKE_DURATION=60 FAKE_PICK=$'medium\tCRF 23 · ~21 MB' \
  run_transcode "$TMPDIR/in.mov" mp4 1080p
for row in $'\thigh\tCRF 18 · ~39 MB' $'\tmedium\tCRF 23 · ~21 MB' $'\tlow\tCRF 28 · ~10 MB'; do
  grep -F "$row" "$calls" >/dev/null ||
    fail "a source with no audio stream offers a $row row" "$(cat "$calls")"
done
pass "a source with no audio stream drops the 192k estimate term"

# gif rows carry fps subtexts, never size estimates, and the gif path never
# spawns ffprobe.
FAKE_PICK=$'low\t5 fps' run_transcode "$TMPDIR/in.mov" gif 720p
for subtext in '15 fps' '10 fps' '5 fps'; do
  grep -F "$subtext" "$calls" >/dev/null ||
    fail "the gif menu offers a $subtext row" "$(cat "$calls")"
done
if grep '^menu-select: ' "$calls" | grep -F '~' >/dev/null; then
  fail "gif rows never carry size estimates" "$(cat "$calls")"
fi
if grep -q '^ffprobe:' "$calls"; then
  fail "the gif path never probes the input" "$(cat "$calls")"
fi
grep '^ffmpeg ' "$calls" | grep -F 'fps=5\,' >/dev/null ||
  fail "a low gif pick selects fps=5" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/in-720p-low.gif" "$calls" >/dev/null ||
  fail "a low gif pick writes in-720p-low.gif" "$(cat "$calls")"
pass "gif rows carry fps subtexts and never probe the input"

# Pictures stop after the resolution prompt: no quality menu, no probe.
run_transcode "$TMPDIR/img.png" jpg medium
if grep -q '^menu-select:' "$calls" || grep -q '^ffprobe:' "$calls"; then
  fail "a picture run never prompts for quality or probes" "$(cat "$calls")"
fi
grep '^magick ' "$calls" | grep -F -- '-resize 2160x\>' >/dev/null ||
  fail "a picture run still resizes" "$(cat "$calls")"
grep -Fx "out=$TMPDIR/img-medium.jpg" "$calls" >/dev/null ||
  fail "a picture run writes img-medium.jpg" "$(cat "$calls")"
pass "a picture run never prompts for quality or probes"

# A pick outside the tier vocabulary is re-validated inside select_quality and
# dies there -- the menu and probes ran, but nothing reached the notification.
if FAKE_DURATION=60 FAKE_PICK=$'bogus\tjunk' run_transcode "$TMPDIR/in.mov" mp4 1080p; then
  fail "a foreign-label menu pick is rejected"
fi
grep -F 'Invalid video quality' "$TMPDIR/stderr" >/dev/null ||
  fail "a foreign-label pick reports Invalid video quality" "$(cat "$TMPDIR/stderr")"
grep -q '^menu-select:' "$calls" ||
  fail "a foreign-label pick still records the menu call" "$(cat "$calls")"
if grep -q 'notification:' "$calls" || grep -q '^ffmpeg ' "$calls"; then
  fail "a foreign-label pick dies before the notification" "$(cat "$calls")"
fi
pass "a foreign-label menu pick is rejected before the notification"

# An unknown format still fires the (all-qualitative) quality menu, then fails
# in transcode_video after the notification -- the pre-existing orphan, pinned
# so it cannot silently change.
if FAKE_PICK=$'low\tSmallest file' run_transcode "$TMPDIR/in.mov" avi 1080p; then
  fail "an unknown video format is rejected"
fi
grep -F 'Smallest file' "$calls" >/dev/null ||
  fail "an unknown format offers qualitative rows" "$(cat "$calls")"
grep -F 'Invalid video format' "$TMPDIR/stderr" >/dev/null ||
  fail "an unknown video format reports Invalid video format" "$(cat "$TMPDIR/stderr")"
pass "an unknown format prompts with qualitative rows then fails Invalid video format"

# The done notification reports the output's real size: FAKE_OUT_BYTES makes
# the stub write a 38.00 MiB file, the script's own stat+awk chain measures
# it, and the body lands as "(38 MB)" -- the same MiB scale the ~N MB menu
# estimates use. Assertions filter on 'Transcoded to' because the start
# notification body carries its own parenthetical. The knob-created output
# is this row's fixture -- rm -f it after asserting.
FAKE_OUT_BYTES=39845888 run_transcode "$TMPDIR/in.mov" mp4 1080p medium
grep 'notification:' "$calls" | grep -F 'Transcoded to 1080p mp4' |
  grep -F 'Saved and copied to clipboard (38 MB).' >/dev/null ||
  fail "the video done notification reports the output size" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4"
pass "the video done notification reports the output size"

FAKE_OUT_BYTES=39845888 run_transcode "$TMPDIR/img.png" jpg medium
grep 'notification:' "$calls" | grep -F 'Transcoded to medium jpg' |
  grep -F 'Saved and copied to clipboard (38 MB).' >/dev/null ||
  fail "the picture done notification reports the output size" "$(cat "$calls")"
rm -f "$TMPDIR/img-medium.jpg"
pass "the picture done notification reports the output size"

# With no FAKE_OUT_BYTES the stub creates nothing, stat fails inside
# output_size_label, and the body degrades to the plain sentence -- the run
# still exits 0 and no size is ever fabricated.
run_transcode "$TMPDIR/in.mov" mp4 1080p medium
grep 'notification:' "$calls" | grep -F 'Transcoded to 1080p mp4' |
  grep -E 'Saved and copied to clipboard\.$' >/dev/null ||
  fail "a missing output degrades the done notification to the plain body" "$(cat "$calls")"
if grep 'notification:' "$calls" | grep -F 'Transcoded to' | grep -F ' MB)' >/dev/null; then
  fail "a missing output never fabricates a size" "$(cat "$calls")"
fi
pass "a missing output degrades to the plain body without lying"

# A failed encode aborts before the done notification under set -e. The
# Transcoding start notification is a pre-existing orphan (pinned, not
# fixed), but zero "Transcoded to" lines may appear -- the notification can
# never claim a size for an output that does not exist.
if FAKE_ENCODE_RC=1 run_transcode "$TMPDIR/in.mov" mp4 1080p medium; then
  fail "a failed encode exits non-zero"
fi
grep -F 'Transcoding video' "$calls" >/dev/null ||
  fail "a failed encode still records the start notification" "$(cat "$calls")"
if grep 'notification:' "$calls" | grep -F 'Transcoded to' >/dev/null; then
  fail "a failed encode never sends the done notification" "$(cat "$calls")"
fi
pass "a failed encode sends zero done notifications"

# The gif arm shares main()'s video tail, so the size reaches it too -- a
# cheap pin that no arm is left on the plain body.
FAKE_OUT_BYTES=39845888 run_transcode "$TMPDIR/in.mov" gif 720p low
grep 'notification:' "$calls" | grep -F 'Transcoded to 720p gif' |
  grep -F 'Saved and copied to clipboard (38 MB).' >/dev/null ||
  fail "the gif done notification reports the output size" "$(cat "$calls")"
rm -f "$TMPDIR/in-720p-low.gif"
pass "the gif done notification reports the output size"

# A deduped output reports the size of the file actually written: $output
# resolved to -2 before the notifications, so stat measures in-1080p-2.mp4 --
# never the pre-existing collision fixture.
touch "$TMPDIR/in-1080p.mp4"
FAKE_OUT_BYTES=39845888 run_transcode "$TMPDIR/in.mov" mp4 1080p medium
grep -Fx "out=$TMPDIR/in-1080p-2.mp4" "$calls" >/dev/null ||
  fail "an existing output dedupes to -2 with FAKE_OUT_BYTES set" "$(cat "$calls")"
grep 'notification:' "$calls" | grep -F 'Transcoded to 1080p mp4' |
  grep -F 'Saved and copied to clipboard (38 MB).' >/dev/null ||
  fail "a deduped output reports its own size" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4" "$TMPDIR/in-1080p-2.mp4"
pass "a deduped output reports the size of the file actually written"

# A non-empty output under 1 MiB reads "(<1 MB)", never "(0 MB)" -- a zero
# size on a real file would read as a lie next to the ~1 MB estimate floor.
FAKE_OUT_BYTES=200000 run_transcode "$TMPDIR/in.mov" mp4 1080p medium
grep 'notification:' "$calls" | grep -F 'Transcoded to 1080p mp4' |
  grep -F 'Saved and copied to clipboard (<1 MB).' >/dev/null ||
  fail "a sub-1 MiB output reports <1 MB, not 0 MB" "$(cat "$calls")"
rm -f "$TMPDIR/in-1080p.mp4"
pass "a sub-1 MiB output reports <1 MB"

# Sub-10 MiB estimates round instead of flooring (WR-01): 18 s at 720p with
# 192k audio is 5.8/3.6/1.9 MiB -- %.0f renders ~6/~4/~2 where the old %d
# floored to ~5/~3/~1. All three sit far below the 120 MiB fixture, so no
# larger-than-source degrade interferes.
FAKE_DURATION=18 FAKE_PICK=$'medium\tCRF 23 · ~4 MB' \
  run_transcode "$TMPDIR/in.mov" mp4 720p
for row in $'\thigh\tCRF 18 · ~6 MB' $'\tmedium\tCRF 23 · ~4 MB' $'\tlow\tCRF 28 · ~2 MB'; do
  grep -F "$row" "$calls" >/dev/null ||
    fail "an 18 s 720p clip offers a $row row" "$(cat "$calls")"
done
pass "sub-10 MiB estimates round instead of flooring"
