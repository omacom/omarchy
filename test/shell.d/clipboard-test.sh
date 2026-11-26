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

const imageDir = '/state/omarchy/clipboard-images'
assertDeepEqual(
  clipboard.removedImageEntries(
    [
      { type: 'image', path: `${imageDir}/kept.png`, mime: 'image/png', inode: '10' },
      { type: 'image', path: `${imageDir}/removed.png`, mime: 'image/png', inode: '20' },
      { type: 'image', path: `${imageDir}/legacy.png`, mime: 'image/png' },
      { type: 'image', path: `${imageDir}/nested/ignored.png`, mime: 'image/png', inode: '30' },
      { type: 'image', path: `${imageDir}/../escape.png`, mime: 'image/png', inode: '40' },
      { type: 'image', path: '/home/user/Pictures/photo.png', mime: 'image/png', inode: '50' },
      { type: 'text', text: `file://${imageDir}/text-ref.png` }
    ],
    [{ type: 'image', path: `${imageDir}/kept.png`, mime: 'image/png', inode: '10' }],
    imageDir
  ),
  [{ path: `${imageDir}/removed.png`, inode: '20' }],
  'clipboard removedImageEntries deletes only unreferenced direct children of clipboard-images'
)

assertDeepEqual(
  clipboard.addEntry(
    [{ type: 'image', path: `${imageDir}/same.png`, mime: 'image/png', inode: '200', gen: 2 }],
    { type: 'image', path: `${imageDir}/same.png`, mime: 'image/png', inode: '100', gen: 1 },
    10
  ),
  [{ type: 'image', path: `${imageDir}/same.png`, mime: 'image/png', inode: '200', gen: 2 }],
  'clipboard addEntry keeps newer on-disk inode when duplicate image captures arrive out of order'
)

const fs = require('fs')
const { execFileSync } = require('child_process')
const os = require('os')
const clipboardQml = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')
const qmlFns = [
  clipboardQml.match(/function pruneRemovedImages\(previousHistory, nextHistory\) \{[\s\S]*?\n  \}/)[0],
  clipboardQml.match(/function loadHistory\(raw\) \{[\s\S]*?\n  \}/)[0],
  clipboardQml.match(/function saveHistory\(\) \{[\s\S]*?\n  \}/)[0],
  clipboardQml.match(/function addClipboardEntry\(entry\) \{[\s\S]*?\n  \}/)[0],
  clipboardQml.match(/function confirmClearHistory\(\) \{[\s\S]*?\n  \}/)[0]
].join('\n')

const savedWrites = []
const removedCalls = []
const ctx = {
  history: [],
  historyLoaded: false,
  pendingEntries: [],
  historyLimit: 2,
  opened: false,
  selectedIndex: 0,
  cursorActive: true,
  clearConfirmOpen: true,
  imageDir,
  ClipboardHistory: clipboard,
  historyFile: { setText(v) { savedWrites.push(JSON.parse(v)) } },
  Quickshell: { execDetached(argv) { removedCalls.push(argv) } },
  Qt: { callLater() {} },
  keyCatcher: { forceActiveFocus() {} },
  disarmPointer() {},
  rebuildDisplay() {}
}
ctx.root = ctx
require('vm').runInNewContext(qmlFns, ctx)

// Captures arriving before historyFile finishes loading must queue instead of
// writing [] + [new] and wiping existing history on disk.
ctx.addClipboardEntry({ type: 'text', text: 'early-copy' })
assertEqual(savedWrites.length, 0, 'clipboard does not overwrite history before disk history loads')
ctx.loadHistory(JSON.stringify([
  { type: 'text', text: 'persisted' },
  { type: 'image', path: `${imageDir}/evicted.png`, mime: 'image/png', inode: '101' }
]))
assertDeepEqual(
  ctx.history.map(e => e.text || e.path),
  ['early-copy', 'persisted'],
  'clipboard merges pre-load captures onto loaded history without data loss'
)
assertEqual(savedWrites.length, 1, 'clipboard persists merged pre-load captures once history loads')
assertDeepEqual(
  removedCalls[0].slice(-2),
  [`${imageDir}/evicted.png`, '101'],
  'clipboard schedules removal of cached image files evicted by historyLimit'
)

// Run the real prune command against a real directory to prove inode matching
// preserves a re-captured image while deleting an unchanged removed image.
const pruneDir = fs.mkdtempSync(path.join(os.tmpdir(), 'clipboard-prune-'))
try {
  const realImageDir = path.join(pruneDir, 'clipboard-images')
  fs.mkdirSync(realImageDir, { recursive: true })
  const shotPath = path.join(realImageDir, 'shot.png')
  fs.writeFileSync(shotPath, 'first')
  const firstInode = String(fs.statSync(shotPath).ino)

  ctx.imageDir = realImageDir
  ctx.addClipboardEntry({ type: 'image', path: shotPath, mime: 'image/png', inode: firstInode })
  ctx.confirmClearHistory()
  const stalePruneCmd = removedCalls[removedCalls.length - 1]

  // Simulate a concurrent re-capture replacing the file atomically with a new inode.
  const tmpPath = path.join(realImageDir, 'clipboard.new')
  fs.writeFileSync(tmpPath, 'second')
  fs.renameSync(tmpPath, shotPath)
  const secondInode = String(fs.statSync(shotPath).ino)
  assert(secondInode !== firstInode, 'atomic recapture allocates a new inode')

  execFileSync(stalePruneCmd[0], stalePruneCmd.slice(1))
  assert(fs.existsSync(shotPath), 'stale prune preserves a freshly re-captured image with a new inode')

  ctx.addClipboardEntry({ type: 'image', path: shotPath, mime: 'image/png', inode: secondInode })
  ctx.confirmClearHistory()
  const currentPruneCmd = removedCalls[removedCalls.length - 1]
  execFileSync(currentPruneCmd[0], currentPruneCmd.slice(1))
  assert(!fs.existsSync(shotPath), 'prune deletes the cached image when its inode still matches')
} finally {
  fs.rmSync(pruneDir, { recursive: true, force: true })
}
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

image_dir_mode=$(stat -c '%a' "$TMPDIR/state/omarchy/clipboard-images")
[[ $image_dir_mode == "700" ]] || fail "clipboard image directory is owner-only" "actual: $image_dir_mode"
pass "clipboard image directory is owner-only"

capture_output=$(printf 'escape-data' | XDG_RUNTIME_DIR="$TMPDIR" XDG_STATE_HOME="$TMPDIR/state" PATH="$TMPDIR/bin:$PATH" "$ROOT/shell/plugins/clipboard/capture.sh" 'image/../../escape')
[[ -z $capture_output && ! -e "$TMPDIR/state/omarchy/escape" ]] || fail "clipboard capture rejects path traversal in image mime subtype" "actual: $capture_output"
pass "clipboard capture rejects path traversal in image mime subtype"

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

# History reads happen in a single jq call so a concurrent copy shifting array
# indices between two reads cannot cause the wrong entry to be pasted or opened.
cat >"$TMPDIR/bin/jq" <<'SH'
#!/bin/bash
/usr/bin/jq "$@"
status=$?
if [[ -n ${JQ_SHIFT_HISTORY:-} && -f $JQ_SHIFT_HISTORY ]]; then
  printf '[{"type":"text","text":"shifted-wrong-entry"}]\n' >"$JQ_SHIFT_HISTORY"
fi
exit "$status"
SH
chmod +x "$TMPDIR/bin/jq"

printf '[{"type":"text","text":"original-entry"}]\n' >"$TMPDIR/home/.local/state/omarchy/clipboard-history.json"
JQ_SHIFT_HISTORY="$TMPDIR/home/.local/state/omarchy/clipboard-history.json" \
  WL_COPY_OUT="$TMPDIR/copied" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --copy-only --history-index 0
[[ $(<"$TMPDIR/copied") == "original-entry" ]] ||
  fail "clipboard paste reads and validates history entry in a single jq call" "$(<"$TMPDIR/copied")"

printf '[{"type":"text","text":"https://example.com/original"}]\n' >"$TMPDIR/home/.local/state/omarchy/clipboard-history.json"
rm -f "$TMPDIR/browser"
JQ_SHIFT_HISTORY="$TMPDIR/home/.local/state/omarchy/clipboard-history.json" \
  BROWSER_OUT="$TMPDIR/browser" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-open" --history-index 0
[[ $(<"$TMPDIR/browser") == "https://example.com/original" ]] ||
  fail "clipboard open reads and validates history entry in a single jq call" "$(<"$TMPDIR/browser")"
rm -f "$TMPDIR/bin/jq"
pass "clipboard history helpers read entries atomically in one jq call"

# Embedded NUL bytes in saved history text must survive extraction into wl-copy.
printf '[{"type":"text","text":"foo\\u0000bar\\u0000"}]\n' >"$TMPDIR/home/.local/state/omarchy/clipboard-history.json"
WL_COPY_OUT="$TMPDIR/copied-nul" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-clipboard-paste-text" --copy-only --history-index 0
[[ $(od -An -tx1 "$TMPDIR/copied-nul" | tr -d ' \n') == "666f6f0062617200" ]] ||
  fail "clipboard paste preserves embedded NUL bytes from history entries" "$(od -An -tx1 "$TMPDIR/copied-nul")"
pass "clipboard paste preserves embedded NUL bytes from history entries"

sweep_dir="$TMPDIR/sweep-images"
sweep_hist="$TMPDIR/sweep-history.json"
mkdir -p "$sweep_dir"
printf 'orphan' >"$sweep_dir/orphan.png"
printf 'kept' >"$sweep_dir/kept.png"
printf 'kept-kind' >"$sweep_dir/kept-kind.png"
printf 'recent' >"$sweep_dir/recent.png"
printf 'inflight' >"$sweep_dir/clipboard.abc123"
printf '5\n' >"$sweep_dir/.gen"
printf 'outside' >"$TMPDIR/outside.png"
ln -s "$TMPDIR/outside.png" "$sweep_dir/escape.png"
touch -d '2 minutes ago' "$sweep_dir/orphan.png" "$sweep_dir/kept.png" "$sweep_dir/kept-kind.png" "$sweep_dir/clipboard.abc123" "$sweep_dir/.gen" "$TMPDIR/outside.png"
touch -h -d '2 minutes ago' "$sweep_dir/escape.png"

# Missing or malformed history fails safe and deletes nothing.
"$ROOT/shell/plugins/clipboard/sweep.sh" "$TMPDIR/missing-history.json" "$sweep_dir"
[[ -f $sweep_dir/orphan.png ]] || fail "clipboard orphan sweep leaves images alone when history is missing"
printf 'not json {{{' >"$sweep_hist"
"$ROOT/shell/plugins/clipboard/sweep.sh" "$sweep_hist" "$sweep_dir"
[[ -f $sweep_dir/orphan.png ]] || fail "clipboard orphan sweep leaves images alone when history is malformed"
printf '{"not":"an-array"}' >"$sweep_hist"
"$ROOT/shell/plugins/clipboard/sweep.sh" "$sweep_hist" "$sweep_dir"
[[ -f $sweep_dir/orphan.png ]] || fail "clipboard orphan sweep leaves images alone when history is not an array"
pass "clipboard orphan sweep fails safe on missing or malformed history"

# Valid history removes only old unreferenced regular files.
jq -n --arg path "$sweep_dir/kept.png" --arg kind_path "$sweep_dir/kept-kind.png" \
  '[{type:"image", mime:"image/png", path:$path}, {kind:"image", path:$kind_path}]' >"$sweep_hist"
"$ROOT/shell/plugins/clipboard/sweep.sh" "$sweep_hist" "$sweep_dir"
[[ ! -e $sweep_dir/orphan.png ]] || fail "clipboard orphan sweep removes unreferenced old images"
[[ $(<"$sweep_dir/kept.png") == "kept" ]] || fail "clipboard orphan sweep keeps referenced images"
[[ $(<"$sweep_dir/kept-kind.png") == "kept-kind" ]] || fail "clipboard orphan sweep keeps legacy kind:image referenced images"
[[ $(<"$sweep_dir/recent.png") == "recent" ]] || fail "clipboard orphan sweep keeps recent unreferenced images"
[[ $(<"$sweep_dir/clipboard.abc123") == "inflight" ]] || fail "clipboard orphan sweep skips in-flight temp files"
[[ $(<"$sweep_dir/.gen") == "5" ]] || fail "clipboard orphan sweep skips dotfiles"
[[ -L $sweep_dir/escape.png && $(<"$TMPDIR/outside.png") == "outside" ]] || fail "clipboard orphan sweep skips symlinks and outside targets"
pass "clipboard orphan sweep removes only old unreferenced images"

# Cleared history ([]) sweeps remaining aged legacy images.
printf '[]\n' >"$sweep_hist"
"$ROOT/shell/plugins/clipboard/sweep.sh" "$sweep_hist" "$sweep_dir"
[[ ! -e $sweep_dir/kept.png && ! -e $sweep_dir/kept-kind.png ]] || fail "clipboard orphan sweep removes aged images after history is cleared"
[[ $(<"$sweep_dir/recent.png") == "recent" ]] || fail "clipboard orphan sweep still preserves recent images on empty history"
pass "clipboard orphan sweep cleans aged images when history is empty"
