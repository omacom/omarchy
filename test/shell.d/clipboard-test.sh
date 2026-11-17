#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const clipboard = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')

assertDeepEqual(
  clipboard.normalizeEntry('hello'),
  { type: 'text', text: 'hello' },
  'clipboard normalizes string entries'
)

assertDeepEqual(
  clipboard.normalizeEntry({ kind: 'image', path: '/tmp/a.png' }),
  { type: 'image', path: '/tmp/a.png', mime: 'image/png' },
  'clipboard normalizes image entries with default mime'
)

assertDeepEqual(
  clipboard.normalizeEntry({ type: 'image', path: '/tmp/a.png', mime: 'image/png', capturedAt: 'Friday 14:42' }),
  { type: 'image', path: '/tmp/a.png', mime: 'image/png', capturedAt: 'Friday 14:42' },
  'clipboard keeps image capture timestamps'
)

assertDeepEqual(
  clipboard.parseHistory(JSON.stringify(['one', '', { type: 'text', text: 'two' }, { type: 'image', path: '/tmp/a.jpg', mime: 'image/jpeg' }])),
  [
    { type: 'text', text: 'one' },
    { type: 'text', text: 'two' },
    { type: 'image', path: '/tmp/a.jpg', mime: 'image/jpeg' }
  ],
  'clipboard history parser drops invalid entries'
)

assertDeepEqual(clipboard.parseHistory(JSON.stringify([' ', '\n', { type: 'text', text: '\t' }])), [], 'clipboard history parser drops whitespace-only text')

const history = [
  { type: 'text', text: 'old' },
  { type: 'text', text: 'new' },
  { type: 'image', path: '/tmp/a.png', mime: 'image/png' }
]

assertDeepEqual(
  clipboard.addEntry(history, { type: 'text', text: 'new' }, 100),
  [
    { type: 'text', text: 'new' },
    { type: 'text', text: 'old' },
    { type: 'image', path: '/tmp/a.png', mime: 'image/png' }
  ],
  'clipboard addEntry moves duplicate text to front'
)

assertDeepEqual(
  clipboard.removeEntryAt(history, 1),
  [
    { type: 'text', text: 'old' },
    { type: 'image', path: '/tmp/a.png', mime: 'image/png' }
  ],
  'clipboard removeEntryAt removes the requested entry'
)

assertDeepEqual(clipboard.removeEntryAt(history, 10), history, 'clipboard removeEntryAt ignores invalid indexes')
assertDeepEqual(clipboard.clearHistory(), [], 'clipboard clearHistory returns an empty history')

assertDeepEqual(
  clipboard.displayRows(history, 'image', 50).map(row => ({ type: row.entryType, preview: row.previewText, mime: row.mime })),
  [{ type: 'image', preview: 'Image', mime: 'image/png' }],
  'clipboard display rows search image metadata'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'image', path: '/tmp/a.png', mime: 'image/png', capturedAt: 'Friday 14:42' }], '', 50)[0].previewText,
  'Screenshot from Friday 14:42',
  'clipboard labels timestamped png image entries as screenshots'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'image', path: '/tmp/a.jpg', mime: 'image/jpeg', capturedAt: 'Friday 14:42' }], '', 50)[0].previewText,
  'Image from Friday 14:42',
  'clipboard labels timestamped non-png image entries as images'
)

assertDeepEqual(
  clipboard.displayRows(history, 'image', 50).map(row => row.index),
  [2],
  'clipboard display rows preserve original history indexes'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'line one\nline two' }], '', 50)[0].previewText,
  'line one line two',
  'clipboard display rows collapse text whitespace'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'file:///home/dhh/Videos/screenrecording-2026-05-29_13-56-43-720p.gif\n' }], '', 50)[0],
  {
    entryType: 'file',
    fullText: '/home/dhh/Videos/screenrecording-2026-05-29_13-56-43-720p.gif',
    previewText: 'screenrecording-2026-05-29_13-56-43-720p.gif',
    previewImage: '/home/dhh/Videos/screenrecording-2026-05-29_13-56-43-720p.gif',
    path: '/home/dhh/Videos/screenrecording-2026-05-29_13-56-43-720p.gif',
    mime: 'text/plain',
    index: 0
  },
  'clipboard display rows show file uri entries as files'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'file:///home/dhh/One.txt\nfile:///home/dhh/Two.txt\n' }], '', 50)[0].previewText,
  '2 files',
  'clipboard display rows summarize multiple file uri entries'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'file:///home/dhh/Videos/demo.mp4\n' }], '', 50)[0].previewImage,
  '',
  'clipboard display rows do not preview video file uri entries inline'
)

assertDeepEqual(clipboard.displayRows(history, '', 0), [], 'clipboard display rows supports zero result limit')
assertDeepEqual(clipboard.addEntry(history, 'next', 0), [], 'clipboard addEntry supports zero history limit')

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'a'.repeat(8192) + 'needle' }], 'needle', 50),
  [],
  'clipboard display rows do not search text past the cap'
)

assertDeepEqual(
  clipboard.displayRows([{ type: 'text', text: 'needle' + 'a'.repeat(100000) }], 'needle', 50).map(row => row.index),
  [0],
  'clipboard display rows search text up to the cap'
)

const hugeTextRow = clipboard.displayRows([{ type: 'text', text: 'z'.repeat(100000) }], '', 50)[0]
assert(
  hugeTextRow.fullText.length === 8192 && hugeTextRow.previewText.length === 8192,
  'clipboard display rows cap what a huge text entry renders'
)

const hugeFileList = []
for (let i = 0; i < 5000; i++) hugeFileList.push('file:///home/dhh/clip-' + i + '.mp4')
const hugeFileRow = clipboard.displayRows([{ type: 'text', text: hugeFileList.join('\n') + '\n' }], '', 50)[0]
assert(
  hugeFileRow.entryType === 'file' && hugeFileRow.fullText.split('\n').every(path => path.endsWith('.mp4')),
  'clipboard display rows cap a huge file list without truncating a path'
)
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/home/.local/state/omarchy"

# capture.sh bounds its reads at 2s; the stall scenarios shorten that bound
# here instead of waiting it out. Other durations pass through untouched.
cat >"$TMPDIR/bin/timeout" <<'SH'
#!/bin/bash
args=()
for arg in "$@"; do
  [[ $arg == "2s" ]] && arg="0.3s"
  args+=("$arg")
done
exec /usr/bin/timeout "${args[@]}"
SH
chmod +x "$TMPDIR/bin/timeout"

cat >"$TMPDIR/bin/wl-copy" <<'SH'
#!/bin/bash
cat >"$WL_COPY_OUT"
SH

cat >"$TMPDIR/bin/wl-paste" <<'SH'
#!/bin/bash
if [[ $1 == "--list-types" ]]; then
  [[ ${WL_PASTE_STALL:-} == "list-types" ]] && sleep 10
  printf '%b' "${WL_PASTE_TYPES:-text/plain\n}"
elif [[ $1 == "--type" && $2 == "text" ]]; then
  [[ ${WL_PASTE_STALL:-} == "text" ]] && sleep 10
  if [[ ${WL_PASTE_STALL:-} == "text-midway" ]]; then
    printf 'first half '
    sleep 10
  fi
  printf '%s' "${WL_PASTE_TEXT:-terminal copy}"
fi
SH

cat >"$TMPDIR/bin/wtype" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WTYPE_OUT"
SH

cat >"$TMPDIR/bin/omarchy-launch-browser" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$BROWSER_OUT"
SH

cat >"$TMPDIR/bin/omarchy-launch-editor" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$EDITOR_PATH_OUT"
cat "$1" >"$EDITOR_TEXT_OUT"
SH

cat >"$TMPDIR/bin/omasnap" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMASNAP_OUT"
SH

chmod +x "$TMPDIR/bin/wl-copy" "$TMPDIR/bin/wl-paste" "$TMPDIR/bin/wtype" "$TMPDIR/bin/omarchy-launch-browser" "$TMPDIR/bin/omarchy-launch-editor" "$TMPDIR/bin/omasnap"

capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh")
[[ $capture_output == '{"type":"text","text":"terminal copy"}' ]] || fail "clipboard capture records normal text events"
pass "clipboard capture records normal text events"

capture_output=$(printf 'closing app copy' | WL_PASTE_TEXT="stale read" XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"closing app copy"}' ]] || fail "clipboard capture records watched text from stdin"
pass "clipboard capture records watched text from stdin"

# The stall scenarios below rely on the timeout stub shortening capture.sh's
# 2s read bounds; the outer 4s timeout only guards against them not firing.
if capture_output=$(printf 'watched copy after stalled types' | WL_PASTE_STALL="list-types" XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" timeout --preserve-status 4s "$ROOT/shell/plugins/clipboard/capture.sh" text); then
  capture_status=0
else
  capture_status=$?
fi
[[ $capture_status -eq 0 ]] || fail "clipboard watched text survives a stalled type query" "capture exited with status $capture_status"
[[ $capture_output == '{"type":"text","text":"watched copy after stalled types"}' ]] || fail "clipboard watched text remains intact after a stalled type query"
pass "clipboard watched text survives a stalled type query"
pass "clipboard watched text remains intact after a stalled type query"

if capture_output=$(WL_PASTE_STALL="text" XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" timeout --preserve-status 4s "$ROOT/shell/plugins/clipboard/capture.sh"); then
  capture_status=0
else
  capture_status=$?
fi
[[ $capture_status -eq 124 ]] || fail "clipboard snapshot text read uses its internal timeout" "capture exited with status $capture_status"
[[ -z $capture_output ]] || fail "clipboard snapshot timeout emits no partial entry" "actual: $capture_output"
pass "clipboard snapshot text read uses its internal timeout"
pass "clipboard snapshot timeout emits no partial entry"

if capture_output=$(WL_PASTE_STALL="text-midway" XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" timeout --preserve-status 4s "$ROOT/shell/plugins/clipboard/capture.sh"); then
  capture_status=0
else
  capture_status=$?
fi
[[ $capture_status -eq 124 ]] || fail "clipboard snapshot text read stalled midway uses its internal timeout" "capture exited with status $capture_status"
[[ -z $capture_output ]] || fail "clipboard snapshot stalled midway emits no partial entry" "actual: $capture_output"
pass "clipboard snapshot text read stalled midway uses its internal timeout"
pass "clipboard snapshot stalled midway emits no partial entry"

for watched_mime in text image/png; do
  if capture_output=$({ printf 'copy whose owner never closes'; sleep 1; } | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" timeout --preserve-status 4s "$ROOT/shell/plugins/clipboard/capture.sh" "$watched_mime"); then
    capture_status=0
  else
    capture_status=$?
  fi
  [[ $capture_status -eq 0 ]] || fail "clipboard watched $watched_mime read is bounded when the owner stalls" "capture exited with status $capture_status"
  [[ -z $capture_output ]] || fail "clipboard watched $watched_mime cut off by a stalled owner emits no entry" "actual: $capture_output"
  pass "clipboard watched $watched_mime read is bounded when the owner stalls"
  pass "clipboard watched $watched_mime cut off by a stalled owner emits no entry"
done

leftover=$(find "$TMPDIR/state/omarchy" -name 'clipboard.*' -print)
[[ -z $leftover ]] || fail "clipboard capture removes copies it dropped" "left: $leftover"
pass "clipboard capture removes copies it dropped"

capture_output=$(printf '%s' 'UTF-16 clipboard - fixed' | iconv -f UTF-8 -t UTF-16LE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"UTF-16 clipboard - fixed"}' ]] || fail "clipboard capture decodes UTF-16LE text"
pass "clipboard capture decodes UTF-16LE text"

capture_output=$(printf '%s' 'https://example.com/image — preview …' | iconv -f UTF-8 -t UTF-16LE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"https://example.com/image — preview …"}' ]] || fail "clipboard capture decodes mostly ASCII UTF-16LE text with Unicode punctuation"
pass "clipboard capture decodes mostly ASCII UTF-16LE text with Unicode punctuation"

capture_output=$(printf '%s' 'Text with 日本 and 😀' | iconv -f UTF-8 -t UTF-16BE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"Text with 日本 and 😀"}' ]] || fail "clipboard capture decodes mostly ASCII UTF-16BE text with Unicode characters"
pass "clipboard capture decodes mostly ASCII UTF-16BE text with Unicode characters"

capture_output=$(printf '%s' 'ABC—' | iconv -f UTF-8 -t UTF-16LE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"ABC—"}' ]] || fail "clipboard capture decodes UTF-16LE text at the padding threshold"
pass "clipboard capture decodes UTF-16LE text at the padding threshold"

printf '%s' 'ABCDEFGH————' | iconv -f UTF-8 -t UTF-16LE >"$TMPDIR/below-utf16-threshold"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/below-utf16-threshold")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/below-utf16-threshold")
[[ $capture_output == "$expected" ]] || fail "clipboard capture leaves UTF-16LE text below the padding threshold undecoded" "expected: $expected\nactual: $capture_output"
pass "clipboard capture leaves UTF-16LE text below the padding threshold undecoded"

printf '%s' 'ABCĀ' | iconv -f UTF-8 -t UTF-16LE >"$TMPDIR/opposite-nul-threshold"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/opposite-nul-threshold")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/opposite-nul-threshold")
[[ $capture_output == "$expected" ]] || fail "clipboard capture leaves UTF-16LE text at the opposite-byte NUL threshold undecoded" "expected: $expected\nactual: $capture_output"
pass "clipboard capture leaves UTF-16LE text at the opposite-byte NUL threshold undecoded"

capture_output=$(printf 'a\fb' | iconv -f UTF-8 -t UTF-16LE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"a\fb"}' ]] || fail "clipboard capture preserves UTF-16LE form feeds"
pass "clipboard capture preserves UTF-16LE form feeds"

# BOM-less UTF-16LE "A" is byte-identical to UTF-8 "A\0". The padding
# heuristic intentionally resolves that ambiguity as UTF-16.
capture_output=$(printf 'A' | iconv -f UTF-8 -t UTF-16LE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"A"}' ]] || fail "clipboard capture decodes exact NUL-padded UTF-16LE text"
pass "clipboard capture decodes exact NUL-padded UTF-16LE text"

capture_output=$(printf 'BE text' | iconv -f UTF-8 -t UTF-16BE | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"BE text"}' ]] || fail "clipboard capture decodes exact NUL-padded UTF-16BE text"
pass "clipboard capture decodes exact NUL-padded UTF-16BE text"

capture_output=$({ printf '\377\376'; printf '%s' 'Little endian 日本 😀' | iconv -f UTF-8 -t UTF-16LE; } | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"Little endian 日本 😀"}' ]] || fail "clipboard capture decodes BOM-tagged UTF-16LE text"
pass "clipboard capture decodes BOM-tagged UTF-16LE text"

capture_output=$({ printf '\376\377'; printf '%s' 'Big endian 日本 😀' | iconv -f UTF-8 -t UTF-16BE; } | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ $capture_output == '{"type":"text","text":"Big endian 日本 😀"}' ]] || fail "clipboard capture decodes BOM-tagged UTF-16BE text"
pass "clipboard capture decodes BOM-tagged UTF-16BE text"

assert_ambiguous_utf16_falls_back() {
  local description="$1" value="$2" expected capture_output
  printf '%s' "$value" | iconv -f UTF-8 -t UTF-16LE >"$TMPDIR/ambiguous-utf16"
  expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/ambiguous-utf16")
  capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/ambiguous-utf16")
  [[ $capture_output == "$expected" ]] || fail "$description" "expected: $expected\nactual: $capture_output"
  pass "$description"
}

assert_ambiguous_utf16_falls_back "clipboard capture leaves BOM-less UTF-16 punctuation undecoded" '—'
assert_ambiguous_utf16_falls_back "clipboard capture leaves BOM-less UTF-16 CJK undecoded" '日本'
assert_ambiguous_utf16_falls_back "clipboard capture leaves BOM-less UTF-16 surrogate pairs undecoded" '😀'

printf 'foo\0bar\0' >"$TMPDIR/nul-separated-utf8"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/nul-separated-utf8")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/nul-separated-utf8")
[[ $capture_output == "$expected" ]] || fail "clipboard capture leaves sparse NUL-separated UTF-8 undecoded" "expected: $expected\nactual: $capture_output"
pass "clipboard capture leaves sparse NUL-separated UTF-8 undecoded"

printf 'Hello\0\0\0\0\0\0\0\0\0\0\0' >"$TMPDIR/nul-padded-utf8"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/nul-padded-utf8")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/nul-padded-utf8")
[[ $capture_output == "$expected" ]] || fail "clipboard capture leaves NUL-padded UTF-8 undecoded" "expected: $expected\nactual: $capture_output"
pass "clipboard capture leaves NUL-padded UTF-8 undecoded"

printf '\001\000\001\000\001\000\001\000' >"$TMPDIR/ambiguous-control-text"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/ambiguous-control-text")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/ambiguous-control-text")
[[ $capture_output == "$expected" ]] || fail "clipboard capture leaves endian-ambiguous control text undecoded" "expected: $expected\nactual: $capture_output"
pass "clipboard capture leaves endian-ambiguous control text undecoded"

printf '\377\376\075\330' >"$TMPDIR/malformed-utf16"
expected=$(jq -cRs '{type:"text", text:.}' <"$TMPDIR/malformed-utf16")
capture_output=$(XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text <"$TMPDIR/malformed-utf16")
[[ $capture_output == "$expected" ]] || fail "clipboard capture falls back from malformed UTF-16" "expected: $expected\nactual: $capture_output"
pass "clipboard capture falls back from malformed UTF-16"

capture_output=$(printf 'png-data' | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" image/png)
image_path=$(jq -r '.path' <<<"$capture_output")
jq -e '.type == "image" and .mime == "image/png" and (.capturedAt | type == "string")' <<<"$capture_output" >/dev/null || fail "clipboard capture records watched png images"
[[ -s $image_path && $(<"$image_path") == "png-data" ]] || fail "clipboard capture stores watched png image data"
pass "clipboard capture records watched png images"

capture_output=$(printf 'jpg-data' | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" image/jpeg)
image_path=$(jq -r '.path' <<<"$capture_output")
jq -e '.mime == "image/jpeg"' <<<"$capture_output" >/dev/null && [[ $image_path == *.jpg ]] || fail "clipboard capture stores watched jpeg images with jpg extension"
pass "clipboard capture stores watched jpeg images with jpg extension"

capture_output=$(printf 'secret' | CLIPBOARD_STATE=sensitive XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" text)
[[ -z $capture_output ]] || fail "clipboard capture ignores sensitive watched text"
pass "clipboard capture ignores sensitive watched text"

capture_output=$(CLIPBOARD_STATE=sensitive XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh")
[[ -z $capture_output ]] || fail "clipboard capture ignores sensitive clipboard events"
pass "clipboard capture ignores sensitive clipboard events"

capture_output=$(WL_PASTE_TYPES="text/plain\nx-kde-passwordManagerHint\n" XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh")
[[ -z $capture_output ]] || fail "clipboard capture ignores password manager hint"
pass "clipboard capture ignores password manager hint"

jq -n --arg text "$(printf 'large block line 1\nlarge block line 2\n')" '[{type:"text", text:"ignored"}, {type:"text", text:$text}]' >"$TMPDIR/home/.local/state/omarchy/clipboard-history.json"

WL_COPY_OUT="$TMPDIR/copied" WTYPE_OUT="$TMPDIR/wtype" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1

[[ $(<"$TMPDIR/copied") == "$(printf 'large block line 1\nlarge block line 2')" ]] || fail "clipboard paste helper copies history entry text"
pass "clipboard paste helper copies history entry text"

[[ $(<"$TMPDIR/wtype") == "-M shift -k Insert -m shift" ]] || fail "clipboard paste helper pastes history entries with shift insert"
pass "clipboard paste helper pastes history entries with shift insert"

rm -f "$TMPDIR/wtype"
WL_COPY_OUT="$TMPDIR/copied" WTYPE_OUT="$TMPDIR/wtype" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --copy-only --history-index 1

[[ $(<"$TMPDIR/copied") == "$(printf 'large block line 1\nlarge block line 2')" ]] || fail "clipboard paste helper copy-only copies history entry text"
pass "clipboard paste helper copy-only copies history entry text"

[[ ! -e "$TMPDIR/wtype" ]] || fail "clipboard paste helper copy-only skips typing"
pass "clipboard paste helper copy-only skips typing"

printf 'image-data' >"$TMPDIR/image.png"
rm -f "$TMPDIR/wtype"
WL_COPY_OUT="$TMPDIR/copied" WTYPE_OUT="$TMPDIR/wtype" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-file" --copy-only image/png "$TMPDIR/image.png"

[[ $(<"$TMPDIR/copied") == "image-data" ]] || fail "clipboard file paste helper copy-only copies file content"
pass "clipboard file paste helper copy-only copies file content"

[[ ! -e "$TMPDIR/wtype" ]] || fail "clipboard file paste helper copy-only skips paste keystroke"
pass "clipboard file paste helper copy-only skips paste keystroke"

jq -n --arg url 'https://example.com/docs' --arg text "$(printf 'plain text\nsecond line')" --arg image "$TMPDIR/image.png" \
  '[{type:"text", text:$url}, {type:"text", text:$text}, {type:"image", mime:"image/png", path:$image}]' >"$TMPDIR/home/.local/state/omarchy/clipboard-history.json"

BROWSER_OUT="$TMPDIR/browser" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-open" --history-index 0

[[ $(<"$TMPDIR/browser") == "https://example.com/docs" ]] || fail "clipboard open helper opens URL entries in browser"
pass "clipboard open helper opens URL entries in browser"

EDITOR_PATH_OUT="$TMPDIR/editor-path" EDITOR_TEXT_OUT="$TMPDIR/editor-text" HOME="$TMPDIR/home" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-open" --history-index 1

[[ $(<"$TMPDIR/editor-text") == "$(printf 'plain text\nsecond line')" ]] || fail "clipboard open helper opens text entries in editor"
pass "clipboard open helper opens text entries in editor"

[[ $(<"$TMPDIR/editor-path") == "$TMPDIR"/state/omarchy/clipboard-open/clipboard.*.txt ]] || fail "clipboard open helper writes text entries to a temporary file"
pass "clipboard open helper writes text entries to a temporary file"

OMASNAP_OUT="$TMPDIR/omasnap" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-open" --history-index 2

[[ $(<"$TMPDIR/omasnap") == "--notify $TMPDIR/image.png" ]] || fail "clipboard open helper opens image entries in Omasnap"
pass "clipboard open helper opens image entries in Omasnap"
