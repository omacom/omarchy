#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

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
