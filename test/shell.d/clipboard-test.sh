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
    pinned: false,
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
export XDG_STATE_HOME="$TMPDIR/home/.local/state"
PIDS_TO_KILL=()

cleanup() {
  local pid

  for pid in "${PIDS_TO_KILL[@]}"; do
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done

  rm -rf "$TMPDIR"
}
trap cleanup EXIT

process_gone() {
  local pid=$1
  local stat

  for _ in {1..40}; do
    stat=$(ps -o stat= -p "$pid" 2>/dev/null || true)
    if [[ -z $stat || $stat == Z* ]]; then
      return 0
    fi
    sleep 0.1
  done

  return 1
}

process_alive() {
  local pid=$1
  local stat

  stat=$(ps -o stat= -p "$pid" 2>/dev/null || true)
  [[ -n $stat && $stat != Z* ]]
}

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

# The editor case also verifies history lookup with a custom state directory.
cp "$TMPDIR/home/.local/state/omarchy/clipboard-history.json" "$TMPDIR/state/omarchy/clipboard-history.json"

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

# Clipboard pin checks run in a subshell to isolate their fixtures and cleanup.
(
run_node_test <<'JS'
const clipboard = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const pin = { type: 'text', text: 'keep\nthis\n', pinned: true }
const image = { type: 'image', path: '/state/clipboard-images/hash.png', mime: 'image/png', pinned: true }
const history = [{ type: 'text', text: 'recent' }, pin, image]
assertDeepEqual(clipboard.parseHistory(JSON.stringify(history)), history, 'text and image pins survive serialization and restart')
assertDeepEqual(clipboard.parseHistory(JSON.stringify(['legacy text', { type: 'text', text: 'legacy object' }])),
  [{ type: 'text', text: 'legacy text' }, { type: 'text', text: 'legacy object' }], 'legacy history remains readable')
assertDeepEqual(clipboard.addEntry(history, 'new', 1), [{ type: 'text', text: 'new' }, pin, image], 'ordinary history eviction preserves every pin')
assertDeepEqual(clipboard.addEntry(history, 'new', 0), [pin, image], 'zero ordinary quota still preserves pins')
assertDeepEqual(clipboard.addEntry(history, 'keep\nthis\n', 1), [pin, history[0], image], 'copying pinned text keeps its pin and deduplicates')
assertDeepEqual(clipboard.addEntry(history, { type: 'image', path: image.path }, 1).filter(e => e.type === 'image'), [image], 'recapturing pinned images keeps their pin')
assertDeepEqual(clipboard.displayRows(history, '', 2).map(r => [r.index, r.pinned]), [[1, true], [2, true]], 'pins come first before the result limit with original indexes')
assertDeepEqual(clipboard.displayRows(history, 'keep', 50).map(r => r.index), [1], 'search finds pins and preserves indexes')
assertDeepEqual(clipboard.displayRows([{type: 'text', text: 'a'.repeat(10000), pinned: true}], '', 50).map(r => r.pinned), [true], 'large pinned text retains its pin in capped display rows')

let full = []
for (let i = 0; i < 10; i++) full = clipboard.pinEntry(full, 'pin ' + i, 500).history
assertEqual(clipboard.pinnedCount(full), 10, 'ten entries can be pinned')
assertEqual(clipboard.pinEntry(full, 'pin 0', 500).status, 'already-pinned', 'repinning an existing entry succeeds even at the limit')
const rejected = clipboard.pinEntry(full, 'eleventh', 500)
assertEqual(rejected.status, 'limit', 'the eleventh pin is rejected')
assertDeepEqual(rejected.history, full, 'limit rejection leaves existing pins untouched')
const unpinned = clipboard.togglePinnedAt(full, 0, 500)
assertEqual(unpinned.status, 'unpinned', 'toggle unpins an entry')
assertEqual(clipboard.pinnedCount(unpinned.history), 9, 'unpin frees one slot')
assertEqual(clipboard.pinEntry(unpinned.history, 'replacement', 500).status, 'pinned', 'a freed slot can be reused')
assertEqual(clipboard.pinEntry(full, ' ', 500).status, 'invalid', 'whitespace cannot be pinned')
assertEqual(clipboard.togglePinnedAt(full, 0.5, 500).status, 'invalid', 'fractional indexes are rejected')

const ordinary = Array.from({ length: 500 }, (_, i) => ({ type: 'text', text: 'copy ' + i }))
for (const releasedPin of [pin, image]) {
  const retainedPin = releasedPin === pin ? image : pin
  const saturated = ordinary.concat([retainedPin, releasedPin])
  const original = JSON.stringify(saturated)
  const released = clipboard.togglePinnedAt(saturated, 501, 500)
  const expected = { ...releasedPin }
  delete expected.pinned
  assertEqual(released.status, 'unpinned', 'unpin succeeds with full ordinary history')
  assertDeepEqual(released.history, [expected, ...ordinary.slice(0, 499), retainedPin],
    'unpin retains released ' + releasedPin.type + ', evicts only the oldest ordinary entry and preserves other pins')
  assertDeepEqual(clipboard.parseHistory(JSON.stringify(released.history)), released.history,
    'released ' + releasedPin.type + ' survives serialization and restart')
  assertEqual(JSON.stringify(saturated), original, 'unpin does not mutate the original history before saving')
}
JS

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home" "$work/state"
export HOME="$work/home" XDG_STATE_HOME="$work/state" OMARCHY_PATH="$ROOT"
export PATH="$work/bin:$PATH" TMPDIR="$work" PIN_TEST_WORK="$work"

cat >"$work/bin/wl-paste" <<'SH'
#!/bin/bash
touch "$PIN_TEST_WORK/paste-requested"
if [[ $1 == "--list-types" ]]; then
  printf '%b' "${PIN_TEST_TYPES:-text/plain\n}"
else
  printf '%s' 'current clipboard'
fi
SH
cat >"$work/bin/wl-copy" <<'SH'
#!/bin/bash
cat >"$PIN_TEST_WORK/copied"
SH
cat >"$work/bin/omarchy-shell" <<'SH'
#!/bin/bash
[[ $1 == shell && $2 == call && $3 == omarchy.clipboard && $4 == pinClipboardFile ]] || exit 1
[[ $(stat -c '%a' "$5") == 600 ]] || exit 1
cat "$5" >"$PIN_TEST_WORK/request.json"
printf '%s' "$5" >"$PIN_TEST_WORK/request-path"
echo "${PIN_TEST_RESULT:-pinned}"
SH
chmod +x "$work/bin/"*

"$ROOT/bin/omarchy-clipboard-pin" >/dev/null
jq -e '.text == "current clipboard"' "$work/request.json" >/dev/null || fail "pin command snapshots the current clipboard"
[[ ! -e $(<"$work/request-path") ]] || fail "pin command removes its private request"
pass "pin command snapshots the clipboard through a private request and cleans up"

printf 'copied\nexactly\n\n' >"$work/input"
rm "$work/paste-requested"
"$ROOT/bin/omarchy-clipboard-pin" --copy <"$work/input" >/dev/null
jq -e '.text == "copied\nexactly\n\n"' "$work/request.json" >/dev/null || fail "copy and pin preserves all text"
cmp "$work/input" "$work/copied" || fail "copy and pin copies the exact pinned payload"
[[ ! -e $work/paste-requested ]] || fail "copy and pin must not inspect the current clipboard"
pass "copy and pin preserves multiline text and trailing newlines"

PIN_TEST_TYPES='text/plain\nx-kde-passwordManagerHint\n' CLIPBOARD_STATE=sensitive \
  "$ROOT/bin/omarchy-clipboard-pin" --copy <"$work/input" >/dev/null
cmp "$work/input" "$work/copied" || fail "a sensitive old clipboard must not block stdin"
[[ ! -e $work/paste-requested ]] || fail "copy and pin must not query sensitive markers from the old clipboard"
pass "copy and pin accepts stdin independently of sensitive markers on the old clipboard"

rm "$work/copied"
if PIN_TEST_RESULT=limit "$ROOT/bin/omarchy-clipboard-pin" --copy <"$work/input" >"$work/out" 2>&1; then
  fail "full pin slots must fail the command"
fi
[[ ! -e $work/copied ]] || fail "rejected copy and pin must leave the clipboard alone"
pass "full pin slots fail without changing the clipboard"

if PIN_TEST_RESULT=save-failed "$ROOT/bin/omarchy-clipboard-pin" --copy <"$work/input" >"$work/out" 2>&1; then
  fail "a failed history save must fail the command"
fi
[[ ! -e $work/copied ]] || fail "a failed history save must leave the clipboard alone"
rg -q 'Could not save clipboard history' "$work/out" || fail "a failed history save must explain the error"
if rg -q 'Clipboard pinned' "$work/out"; then
  fail "a failed history save must not claim success"
fi
[[ ! -e $(<"$work/request-path") ]] || fail "a failed history save must clean up its private request"
pass "failed history saves report failure without copying text or claiming success"

rm "$work/request.json"
if PIN_TEST_TYPES='text/plain\nx-kde-passwordManagerHint\n' "$ROOT/bin/omarchy-clipboard-pin" >"$work/out" 2>&1; then
  fail "sensitive clipboard must not be pinned"
fi
[[ ! -e $work/request.json ]] || fail "sensitive clipboard must not reach IPC"
pass "pin command respects sensitive clipboard markers"

if PIN_TEST_RESULT=unknown "$ROOT/bin/omarchy-clipboard-pin" >"$work/out" 2>&1; then
  fail "an older installed shell must not report success"
fi
pass "pin command reports an unsupported installed shell"

if "$ROOT/bin/omarchy-clipboard-pin" --copy </dev/null >"$work/out" 2>&1; then
  fail "empty stdin must not be pinned"
fi
pass "copy and pin rejects empty stdin"

)

# Clipboard pin checks run in a subshell to isolate their fixtures and cleanup.
(
preview_display=${WAYLAND_DISPLAY:-}
if [[ -n $preview_display && $preview_display != /* ]]; then
  preview_display="${XDG_RUNTIME_DIR:-/run/user/$UID}/$preview_display"
fi

work=$(mktemp -d)
shell_base="${CLIPBOARD_PIN_SHELL_BASE:-$ROOT/shell}"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/config/Ui" "$work/bin" "$work/home" "$work/state" "$work/runtime"
mkdir -p "$work/omarchy/default" "$work/home/.config/omarchy"
cp -a "$ROOT/default/i18n" "$work/omarchy/default/"
ln -s "$ROOT/shell" "$work/omarchy/shell"
for entry in "$ROOT/default/"*; do
  [[ ${entry##*/} == "i18n" ]] || ln -s "$entry" "$work/omarchy/default/"
done
jq '. + {"clipboard.pinLimit": "Limite %1", "clipboard.saveFailed": "Erreur", "clipboard.saveFailedRetry": "Erreur, réessayez"}' \
  "$work/omarchy/default/i18n/fr/shell.json" >"$work/fr.json"
mv "$work/fr.json" "$work/omarchy/default/i18n/fr/shell.json"
printf 'en\n' >"$work/home/.config/omarchy/language"
chmod 700 "$work/runtime"
cp "$SHELL_TEST_DIR/fixtures/clipboard-pins/shell.qml" "$work/config/shell.qml"
cp "$ROOT/shell/plugins/clipboard/ClipboardHistory.js" "$work/config/"
# Disable capture startup in the fixture only. Never reap or start real
# clipboard watchers, and render the otherwise unchanged UI in a test window.
sed -e 's/Component.onCompleted: initProc.running = true/Component.onCompleted: {}/' \
  -e '/WlrLayershell.namespace: "omarchy-clipboard"/d' \
  "$ROOT/shell/plugins/clipboard/Clipboard.qml" >"$work/config/Clipboard.qml"
ln -s "$shell_base/Commons" "$work/config/Commons"
for file in "$shell_base/Ui/"*; do
  [[ ${file##*/} == "OverlayWindow.qml" ]] || ln -s "$file" "$work/config/Ui/"
done
cat >"$work/config/Ui/OverlayWindow.qml" <<'QML'
import QtQuick
import Quickshell
FloatingWindow {
  property bool shown: false
  visible: shown
  implicitWidth: 1100
  implicitHeight: 800
  title: "Omarchy clipboard pin preview (isolated)"
  onShownChanged: if (!shown) Qt.quit()
}
QML
cp "$work/config/Ui/OverlayWindow.qml" "$work/config/OverlayWindow.qml"
# Even keyboard actions in preview mode cannot copy into the real clipboard,
# launch real apps, or query the active compositor.
for command in wl-copy wl-paste wtype hyprctl omasnap omarchy-launch-browser omarchy-launch-editor; do
  printf '#!/bin/bash\nexit 0\n' >"$work/bin/$command"
  chmod +x "$work/bin/$command"
done
printf '%s\n' '{"type":"text","text":"Pinned from a private request"}' >"$work/request.json"
printf '%s\n' 'A file prevents creation of a history directory here.' >"$work/blocked-state"

# Interactive previews copy only appearance settings into the scratch home.
# The panel then uses the same theme/font bindings as the installed clipboard.
if [[ ${1:-} == "--preview" || ${CLIPBOARD_PIN_DESKTOP_STYLE:-0} == "1" ]]; then
  mkdir -p "$work/home/.config/omarchy" "$work/home/.local/state/omarchy/current/theme" "$work/home/.local/share"
  if [[ -d $HOME/.config/fontconfig ]]; then
    cp -aL "$HOME/.config/fontconfig" "$work/home/.config/"
  fi
  if [[ -d $HOME/.local/share/fonts ]]; then
    ln -s "$HOME/.local/share/fonts" "$work/home/.local/share/fonts"
  fi
  if [[ -f $HOME/.config/omarchy/shell.toml ]]; then
    cp "$HOME/.config/omarchy/shell.toml" "$work/home/.config/omarchy/shell.toml"
  fi
  for appearance_file in colors.toml shell.toml; do
    if [[ -f $HOME/.local/state/omarchy/current/theme/$appearance_file ]]; then
      cp "$HOME/.local/state/omarchy/current/theme/$appearance_file" "$work/home/.local/state/omarchy/current/theme/"
    fi
  done
  export OMARCHY_MENU_FONT="${OMARCHY_MENU_FONT:-$(fc-match -f '%{family[0]}' monospace)}"
fi

export HOME="$work/home" XDG_STATE_HOME="$work/state" XDG_CONFIG_HOME="$work/home/.config"
export OMARCHY_LANGUAGE_FILE="$work/home/.config/omarchy/language"
export XDG_CACHE_HOME="$work/home/.cache" XDG_RUNTIME_DIR="$work/runtime"
export OMARCHY_PATH="$work/omarchy" PATH="$work/bin:$PATH"
export QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software
export CLIPBOARD_PIN_REQUEST="$work/request.json"
export CLIPBOARD_PIN_BLOCKED_HISTORY="$work/blocked-state/clipboard-history.json"
export CLIPBOARD_PIN_RETRY_HISTORY="$work/state/retry/clipboard-history.json"
export CLIPBOARD_PIN_SCREENSHOT="${CLIPBOARD_PIN_SCREENSHOT:-$work/preview.png}"
export CLIPBOARD_PIN_CONFIRM_SCREENSHOT="${CLIPBOARD_PIN_CONFIRM_SCREENSHOT:-$work/confirm.png}"
ulimit -c 0

if [[ ${1:-} == "--preview" ]]; then
  # An ordinary window on the current display; no shell restart or dev link.
  export CLIPBOARD_PIN_PREVIEW=1
  export WAYLAND_DISPLAY="$preview_display"
  quickshell -p "$work/config" --no-color
else
  unset WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
  export QT_QPA_PLATFORM=offscreen CLIPBOARD_PIN_PREVIEW=0
  if ! timeout 20 quickshell -p "$work/config" --no-color >"$work/log" 2>&1; then
    cat "$work/log" >&2
    fail "isolated clipboard QML lifecycle runs"
  fi
  if ! rg -q 'CLIPBOARD_PINS_QML_PASS' "$work/log" || rg -q 'CLIPBOARD_PINS_QML_FAIL|TypeError|ReferenceError|Unable to assign' "$work/log"; then
    cat "$work/log" >&2
    fail "isolated clipboard QML pin lifecycle and persistence"
  fi
  [[ -s $CLIPBOARD_PIN_SCREENSHOT ]] || fail "isolated UI preview was rendered"
  [[ -s $CLIPBOARD_PIN_CONFIRM_SCREENSHOT ]] || fail "clear-history confirmation was rendered"
  pass "isolated clipboard controls, save failures, retries, deletion, restart persistence, limits and UI rendering"
fi

)
