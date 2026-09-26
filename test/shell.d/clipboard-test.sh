#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const clipboard = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const clipboardQml = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')

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

assert(
  /function select\(delta\)[\s\S]*root\.disarmPointer\(\)[\s\S]*selectedIndex =/.test(clipboardQml),
  'clipboard keyboard navigation disarms pointer selection'
)
assert(
  /function selectAbsolute\(index\)[\s\S]*root\.disarmPointer\(\)[\s\S]*root\.selectedIndex = Math\.max\(0, Math\.min\(index, displayModel\.count - 1\)\)/.test(clipboardQml),
  'clipboard absolute navigation disarms pointer selection'
)
assert(
  /event\.key === Qt\.Key_Home[\s\S]*root\.selectAbsolute\(0\)[\s\S]*event\.accepted = true/.test(clipboardQml),
  'clipboard Home selects the first entry'
)
assert(
  /event\.key === Qt\.Key_End[\s\S]*root\.selectAbsolute\(displayModel\.count - 1\)[\s\S]*event\.accepted = true/.test(clipboardQml),
  'clipboard End selects the last entry'
)
assert(
  /PointerMoveGate\s*\{[\s\S]*id: pointerGate[\s\S]*referenceItem: card[\s\S]*\}/.test(clipboardQml),
  'clipboard uses shared pointer movement gate in card coordinates'
)
assert(
  /function disarmPointer\(\)[\s\S]*pointerGate\.reset\(\)/.test(clipboardQml),
  'clipboard resets pointer movement gate when pointer selection is disarmed'
)
assert(
  /function selectFromPointer\(index, item, mouse\)[\s\S]*pointerGate\.moved\(item, mouse\)[\s\S]*root\.selectedIndex = index/.test(clipboardQml),
  'clipboard only selects from pointer after real movement'
)
assert(
  /onPositionChanged: function\(mouse\) \{\s*root\.selectFromPointer\(row\.index, row, mouse\)\s*\}/.test(clipboardQml),
  'clipboard row hover routes through pointer movement gate'
)
assert(
  !/onContainsMouseChanged:[\s\S]*root\.selectedIndex/.test(clipboardQml),
  'clipboard does not select rows from containsMouse'
)
assert(
  clipboardQml.includes('command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "text", "--watch", root.captureScript, "text"]'),
  'clipboard text watcher dies with the shell via pdeathsig'
)
assert(
  clipboardQml.includes('command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "image/png", "--watch", root.captureScript, "image/png"]'),
  'clipboard image watcher dies with the shell via pdeathsig'
)
assert(
  clipboardQml.includes('command: ["pkill", "-f", "wl-paste .*--watch .*/shell/plugins/clipboard/capture\\\\.sh"]'),
  'clipboard init reaps stale watchers before starting new ones'
)
assertEqual(
  (clipboardQml.match(/onExited: watchRestartTimer\.restart\(\)/g) || []).length,
  2,
  'clipboard respawns both watchers when they die'
)
assert(
  clipboardQml.includes('import Quickshell.Hyprland'),
  'clipboard imports Hyprland to read the focused toplevel'
)
assert(
  /property string targetWindow: ""/.test(clipboardQml),
  'clipboard tracks one explicit origin target'
)
assert(
  !/lastToplevelAddress/.test(clipboardQml),
  'clipboard does not fall back to a stale previous toplevel'
)
assert(
  /function open\(payloadJson\)[\s\S]*ClipboardHistory\.originAddress\(Hyprland\.activeToplevel, Hyprland\.focusedWorkspace\)/.test(clipboardQml),
  'clipboard only captures an origin eligible on the focused workspace'
)
assertEqual(
  clipboard.originAddress({ address: '0xabc', workspace: { id: 2 } }, { id: 2 }),
  '0xabc',
  'clipboard accepts the active toplevel on the focused workspace'
)
assertEqual(
  clipboard.originAddress({ address: '0xabc', workspace: { id: 1 } }, { id: 2 }),
  '',
  'clipboard rejects a stale toplevel from another workspace'
)
assertEqual(
  clipboard.originAddress(null, { id: 2 }),
  '',
  'clipboard keeps an empty workspace copy-only instead of inventing an origin'
)
assert(
  /if \(!root\.targetWindow\) fileArgs\.push\("--copy-only"\)/.test(clipboardQml),
  'clipboard image selection is copy-only when there is no eligible origin'
)
assert(
  /if \(!root\.targetWindow\) textArgs\.push\("--copy-only"\)/.test(clipboardQml),
  'clipboard text selection is copy-only when there is no eligible origin'
)
assert(
  /var textArgs = \[root\.omarchyPath \+ "\/bin\/omarchy-clipboard-paste-text"[\s\S]*if \(root\.targetWindow\) textArgs\.push\(root\.targetWindow\)/.test(clipboardQml),
  'clipboard passes the origin window address to the text paste helper'
)
assert(
  /var fileArgs = \[root\.omarchyPath \+ "\/bin\/omarchy-clipboard-paste-file"[\s\S]*if \(root\.targetWindow\) fileArgs\.push\(root\.targetWindow\)/.test(clipboardQml),
  'clipboard passes the origin window address to the file paste helper'
)

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

cat >"$TMPDIR/bin/wl-copy" <<'SH'
#!/bin/bash
cat >"$WL_COPY_OUT"
SH

cat >"$TMPDIR/bin/wl-paste" <<'SH'
#!/bin/bash
if [[ $1 == "--list-types" ]]; then
  printf '%b' "${WL_PASTE_TYPES:-text/plain\n}"
elif [[ $1 == "--type" && $2 == "text" ]]; then
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

cat >"$TMPDIR/bin/wl-paste" <<'SH'
#!/bin/bash
printf '%s\t%s\n' "$BASHPID" "$*" >>"${WL_PASTE_LOG:-/dev/null}"
sleep_pid=""

cleanup() {
  [[ -n $sleep_pid ]] && kill "$sleep_pid" 2>/dev/null || true
  exit 0
}
trap cleanup HUP INT TERM

while true; do
  sleep 10 &
  sleep_pid=$!
  wait "$sleep_pid"
done
SH
chmod +x "$TMPDIR/bin/wl-paste"

clipboard_lifecycle_dir="$TMPDIR/clipboard-lifecycle"
current_script="$clipboard_lifecycle_dir/current/shell/plugins/clipboard/capture.sh"
mkdir -p "$(dirname "$current_script")"
cp "$ROOT/shell/plugins/clipboard/capture.sh" "$current_script"
chmod +x "$current_script"

PATH="$TMPDIR/bin:$PATH" wl-paste --type text --watch "$current_script" text &
stale_pid=$!
PIDS_TO_KILL+=("$stale_pid")
sleep 0.2
pgrep -f 'wl-paste .*--watch .*/shell/plugins/clipboard/capture\.sh' | grep -x "$stale_pid" >/dev/null || fail "clipboard reaper pattern matches running watchers"
kill "$stale_pid" 2>/dev/null || true
wait "$stale_pid" 2>/dev/null || true
pass "clipboard reaper pattern matches running watchers"

watch_owner="$clipboard_lifecycle_dir/watch-owner.sh"
watch_pid_file="$clipboard_lifecycle_dir/watch.pid"
cat >"$watch_owner" <<SH
#!/bin/bash
PATH="$TMPDIR/bin:\$PATH" setpriv --pdeathsig TERM wl-paste --type text --watch "$current_script" text &
printf '%s\n' "\$!" >"$watch_pid_file"
wait
SH
chmod +x "$watch_owner"

"$watch_owner" &
owner_pid=$!
PIDS_TO_KILL+=("$owner_pid")

for _ in {1..40}; do
  [[ -s $watch_pid_file ]] && break
  sleep 0.1
done

watch_pid=$(<"$watch_pid_file")
[[ -n $watch_pid ]] && process_alive "$watch_pid" || fail "clipboard watcher starts under setpriv"
PIDS_TO_KILL+=("$watch_pid")

kill "$owner_pid" 2>/dev/null || true
process_gone "$watch_pid" || fail "clipboard watcher dies with its owner via pdeathsig"
pass "clipboard watcher dies with its owner via pdeathsig"

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

cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SLEEP_OUT"
SH

cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HYPRCTL_OUT"
case "$*" in
  *activewindow*)
    if [[ -n ${HYPRCTL_ACTIVE:-} ]]; then
      printf '%s\n' "$HYPRCTL_ACTIVE"
    elif [[ -n ${HYPRCTL_STATE_FILE:-} && -s $HYPRCTL_STATE_FILE ]]; then
      printf '{"address": "%s"}\n' "$(<"$HYPRCTL_STATE_FILE")"
    else
      printf '{"address": "%s"}\n' "${HYPRCTL_ADDRESS:-0x0}"
    fi
    ;;
  *dsp.focus*|*focuswindow*)
    if [[ -n ${HYPRCTL_STATE_FILE:-} ]]; then
      address=$(sed -n 's/.*address:\(0x[0-9A-Fa-f]*\).*/\1/p' <<<"$*")
      [[ -n $address ]] && printf '%s\n' "$address" >"$HYPRCTL_STATE_FILE"
    fi
    ;;
esac
SH

chmod +x "$TMPDIR/bin/sleep" "$TMPDIR/bin/hyprctl"

focus_env=(
  WL_COPY_OUT="$TMPDIR/copied-focus"
  WTYPE_OUT="$TMPDIR/wtype-focus"
  SLEEP_OUT="$TMPDIR/sleep-focus"
  HYPRCTL_OUT="$TMPDIR/hyprctl-focus"
  HYPRCTL_STATE_FILE="$TMPDIR/hyprctl-state"
  HOME="$TMPDIR/home"
  PATH="$TMPDIR/bin:$PATH"
)

: >"$TMPDIR/hyprctl-focus"
: >"$TMPDIR/sleep-focus"
rm -f "$TMPDIR/hyprctl-state" "$TMPDIR/wtype-focus"
env "${focus_env[@]}" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1 "0xdeadbeef"

[[ $(<"$TMPDIR/wtype-focus") == "-M shift -k Insert -m shift" ]] || fail "clipboard paste helper still pastes after refocusing the origin window"
pass "clipboard paste helper still pastes after refocusing the origin window"

grep -qF 'hl.dsp.focus({ window = "address:0xdeadbeef" })' "$TMPDIR/hyprctl-focus" || fail "clipboard paste helper refocuses the origin window by address"
pass "clipboard paste helper refocuses the origin window by address"

[[ -s "$TMPDIR/sleep-focus" ]] || fail "clipboard paste helper waits for focus to settle before pasting"
pass "clipboard paste helper waits for focus to settle before pasting"

: >"$TMPDIR/hyprctl-focus"
rm -f "$TMPDIR/hyprctl-state"
env "${focus_env[@]}" WTYPE_OUT="$TMPDIR/wtype-focus-bare" SLEEP_OUT="$TMPDIR/sleep-focus-bare" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1 "deadbeef"
grep -qF 'address:0xdeadbeef' "$TMPDIR/hyprctl-focus" || fail "clipboard paste helper normalises a bare window address"
pass "clipboard paste helper normalises a bare window address"

: >"$TMPDIR/hyprctl-focus"
env "${focus_env[@]}" WTYPE_OUT="$TMPDIR/wtype-focus-active" SLEEP_OUT="$TMPDIR/sleep-focus-active" \
  HYPRCTL_ACTIVE='{"address": "0xdeadbeef"}' \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1 "0xdeadbeef"
! grep -q "address:" "$TMPDIR/hyprctl-focus" || fail "clipboard paste helper stops refocusing once the origin window is active"
pass "clipboard paste helper stops refocusing once the origin window is active"

env "${focus_env[@]}" WTYPE_OUT="$TMPDIR/wtype-no-target" HYPRCTL_OUT="$TMPDIR/hyprctl-no-target" \
  SLEEP_OUT="$TMPDIR/sleep-no-target" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1
[[ $(<"$TMPDIR/wtype-no-target") == "-M shift -k Insert -m shift" ]] || fail "clipboard paste helper still pastes without a window address"
pass "clipboard paste helper still pastes without a window address"
[[ ! -e "$TMPDIR/hyprctl-no-target" ]] || ! grep -qE 'dsp\.focus|dispatch focuswindow' "$TMPDIR/hyprctl-no-target" || fail "clipboard paste helper skips refocus without a window address"
pass "clipboard paste helper skips refocus without a window address"

# If the captured origin never becomes active, preserve clipboard data but do not inject.
: >"$TMPDIR/hyprctl-focus-fail"
rm -f "$TMPDIR/wtype-focus-fail" "$TMPDIR/hyprctl-state-fail"
env WL_COPY_OUT="$TMPDIR/copied-focus-fail" WTYPE_OUT="$TMPDIR/wtype-focus-fail" \
  SLEEP_OUT="$TMPDIR/sleep-focus-fail" HYPRCTL_OUT="$TMPDIR/hyprctl-focus-fail" \
  HYPRCTL_ADDRESS="0xother" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --shift-insert --history-index 1 "0xdeadbeef"
[[ -s "$TMPDIR/copied-focus-fail" ]] || fail "clipboard text helper still copies when origin refocus fails"
[[ ! -e "$TMPDIR/wtype-focus-fail" ]] || fail "clipboard text helper must not inject into a different focused window"
pass "clipboard text helper aborts injection when origin cannot be restored"

printf 'image-data' >"$TMPDIR/image-focus.png"
: >"$TMPDIR/hyprctl-file"
: >"$TMPDIR/sleep-file"
rm -f "$TMPDIR/wtype-file"
rm -f "$TMPDIR/hyprctl-file-state"
env WL_COPY_OUT="$TMPDIR/copied-file" WTYPE_OUT="$TMPDIR/wtype-file" SLEEP_OUT="$TMPDIR/sleep-file" \
  HYPRCTL_OUT="$TMPDIR/hyprctl-file" HYPRCTL_STATE_FILE="$TMPDIR/hyprctl-file-state" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-file" image/png "$TMPDIR/image-focus.png" "0xcafebabe"

[[ $(<"$TMPDIR/copied-file") == "image-data" ]] || fail "clipboard file paste helper copies file content before refocus"
pass "clipboard file paste helper copies file content before refocus"

[[ $(<"$TMPDIR/wtype-file") == "-M shift -k Insert -m shift" ]] || fail "clipboard file paste helper pastes after refocusing the origin window"
pass "clipboard file paste helper pastes after refocusing the origin window"

grep -qF 'hl.dsp.focus({ window = "address:0xcafebabe" })' "$TMPDIR/hyprctl-file" || fail "clipboard file paste helper refocuses the origin window by address"
pass "clipboard file paste helper refocuses the origin window by address"

: >"$TMPDIR/hyprctl-file-bare"
rm -f "$TMPDIR/hyprctl-file-bare-state"
env WL_COPY_OUT="$TMPDIR/copied-file-bare" WTYPE_OUT="$TMPDIR/wtype-file-bare" SLEEP_OUT="$TMPDIR/sleep-file-bare" \
  HYPRCTL_OUT="$TMPDIR/hyprctl-file-bare" HYPRCTL_STATE_FILE="$TMPDIR/hyprctl-file-bare-state" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-file" image/png "$TMPDIR/image-focus.png" "cafebabe"
grep -qF 'address:0xcafebabe' "$TMPDIR/hyprctl-file-bare" || fail "clipboard file paste helper normalises a bare window address"
pass "clipboard file paste helper normalises a bare window address"

: >"$TMPDIR/hyprctl-file-fail"
rm -f "$TMPDIR/wtype-file-fail"
env WL_COPY_OUT="$TMPDIR/copied-file-fail" WTYPE_OUT="$TMPDIR/wtype-file-fail" \
  SLEEP_OUT="$TMPDIR/sleep-file-fail" HYPRCTL_OUT="$TMPDIR/hyprctl-file-fail" \
  HYPRCTL_ADDRESS="0xother" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-file" image/png "$TMPDIR/image-focus.png" "0xcafebabe"
[[ $(<"$TMPDIR/copied-file-fail") == "image-data" ]] || fail "clipboard file helper still copies when origin refocus fails"
[[ ! -e "$TMPDIR/wtype-file-fail" ]] || fail "clipboard file helper must not inject into a different focused window"
pass "clipboard file helper aborts injection when origin cannot be restored"

env WL_COPY_OUT="$TMPDIR/copied-file-none" WTYPE_OUT="$TMPDIR/wtype-file-none" SLEEP_OUT="$TMPDIR/sleep-file-none" \
  HYPRCTL_OUT="$TMPDIR/hyprctl-file-none" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-file" image/png "$TMPDIR/image-focus.png"
[[ $(<"$TMPDIR/wtype-file-none") == "-M shift -k Insert -m shift" ]] || fail "clipboard file paste helper still pastes without a window address"
pass "clipboard file paste helper still pastes without a window address"
[[ ! -e "$TMPDIR/hyprctl-file-none" ]] || ! grep -qE 'dsp\.focus|dispatch focuswindow' "$TMPDIR/hyprctl-file-none" || fail "clipboard file paste helper skips refocus without a window address"
pass "clipboard file paste helper skips refocus without a window address"

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

[[ $(<"$TMPDIR/omasnap") == "$TMPDIR/image.png" ]] || fail "clipboard open helper opens image entries in Omasnap"
pass "clipboard open helper opens image entries in Omasnap"
