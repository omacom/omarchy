#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const emojis = requireFromRoot('shell/plugins/emojis/EmojiSearch.js')

const raw = fs.readFileSync(path.join(root, 'shell/plugins/emojis/emojis.json'), 'utf8')
const data = emojis.parseEmojis(raw)

assert(data.length > 1000, 'emoji dataset parses')
assertDeepEqual(emojis.parseEmojis('{'), [], 'invalid emoji JSON parses as empty list')
assertDeepEqual(emojis.parseEmojis('{"e":"nope"}'), [], 'non-array emoji JSON parses as empty list')

const fixture = [
  { e: 'a', k: 'grinning face smile happy' },
  { e: 'b', k: 'face with tears of joy joy tears' },
  { e: 'c', k: 'flag: united states us america' }
]

assertDeepEqual(
  emojis.filterEmojis(fixture, '  JOY  ').map(item => item.e),
  ['b'],
  'emoji filtering trims and lowercases query'
)

assertDeepEqual(
  emojis.filterEmojis(fixture, '', 2).map(item => item.e),
  ['a', 'b'],
  'emoji filtering honors result limit'
)

assertDeepEqual(
  emojis.filterEmojis(fixture, '', 0),
  [],
  'emoji filtering supports zero result limit'
)

assertEqual(
  emojis.filterEmojis(data, 'face with tears')[0].e,
  '\u{1F602}',
  'emoji filtering finds face with tears of joy'
)

const named = name => data.find(item => item.n === name)
const groupIds = emojis.GROUPS.map(group => group.id)
assert(data.every(item => item.e && item.n && groupIds.includes(item.g)), 'every emoji has a name and a known group')
assert(data.every(item => !item.t || item.t.length === 5), 'skin-tone variants come as a full set')
assert(groupIds.every(id => data.some(item => item.g === id)), 'every group has emoji')

assertEqual(emojis.rankEmojis(data, 'pickle')[0].n, 'pickle', 'ranking puts the exact name first')
assertEqual(emojis.rankEmojis(data, 'thumbs up')[0].e, '\u{1F44D}', 'ranking matches every word of the query')
assert(emojis.rankEmojis(data, 'dill').some(item => item.n === 'pickle'), 'ranking searches keywords too')
assertDeepEqual(emojis.rankEmojis(data, 'pickle zebra'), [], 'ranking needs every word to match')

const thumbs = named('thumbs up')
assertEqual(emojis.displayEmoji(thumbs, 3), '\u{1F44D}\u{1F3FD}', 'a skin tone picks its variant')
assertEqual(emojis.displayEmoji(named('pickle'), 3), named('pickle').e, 'emoji without tones ignore the tone')
assertEqual(emojis.buildLookup(data)['\u{1F44D}\u{1F3FD}'], thumbs, 'toned emoji look up their entry')

const title = (id, count) => id + ':' + count
const empty = { recent: [], favorites: [], tone: 0 }
let built = emojis.buildRows(data, empty, '', 8, 0, title)
assertDeepEqual(built.sections.map(s => s.id), groupIds, 'empty favorites and recents get no section')
assert(built.rows.every(row => row.cells.length >= 1 && row.cells.length <= 8), 'rows hold at most a row of emoji')

built = emojis.buildRows(data, { recent: ['\u{1FAE0}'], favorites: ['\u{1F44D}', '\u{1F355}'], tone: 0 }, '', 8, 0, title)
assertDeepEqual(built.sections.slice(0, 2).map(s => s.title), ['favorites:2', 'recent:1'], 'favorites then recents lead the grid')
assertDeepEqual(built.rows[0].cells, ['\u{1F44D}', '\u{1F355}'], 'favorites keep their order')

built = emojis.buildRows(data, empty, 'thumbs', 8, 5, title)
assertDeepEqual(built.sections.map(s => s.id), [emojis.RESULTS_ID], 'searching shows one results section')
assert(built.rows[0].cells.includes('\u{1F44D}\u{1F3FF}'), 'results follow the skin tone')

let prefs = empty
for (let i = 0; i < 40; i++) prefs = emojis.withRecent(prefs, data[i].e)
prefs = emojis.withRecent(prefs, data[39].e)
assertEqual(prefs.recent.length, emojis.RECENT_LIMIT, 'recents are capped')
assertEqual(prefs.recent[0], data[39].e, 'the newest recent comes first')
assertEqual(new Set(prefs.recent).size, prefs.recent.length, 'recents hold no duplicates')

prefs = emojis.withFavoriteToggled(empty, '\u{1F355}')
assertDeepEqual(prefs.favorites, ['\u{1F355}'], 'favoriting adds')
assertDeepEqual(emojis.withFavoriteToggled(prefs, '\u{1F355}').favorites, [], 'favoriting again removes')

assertDeepEqual(emojis.parsePrefs('{'), empty, 'unreadable prefs start empty')
assertDeepEqual(emojis.parsePrefs('{"recent":[1,"\u{1F355}"],"tone":9}'), { recent: ['\u{1F355}'], favorites: [], tone: 0 }, 'prefs drop junk')
const saved = { recent: ['\u{1F355}'], favorites: ['\u{1F44D}\u{1F3FD}'], tone: 3 }
assertDeepEqual(emojis.parsePrefs(emojis.serializePrefs(saved)), saved, 'prefs round-trip')
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"

# wl-copy publishes the clipboard (args first, then the data, renamed into
# place so a reader never sees half of it). The helper's sleep before pasting
# waits for that, so the result doesn't depend on which background process
# the scheduler runs first.
cat >"$TMPDIR/bin/wl-copy" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WL_COPY_OUT.args"
cat >"$WL_COPY_OUT.tmp"
mv "$WL_COPY_OUT.tmp" "$WL_COPY_OUT"
SH

cat >"$TMPDIR/bin/wtype" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WTYPE_OUT"
SH

cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
for (( i = 0; i < 500; i++ )); do
  [[ -e $WL_COPY_OUT ]] && exit 0
  /usr/bin/sleep 0.01
done
SH

chmod +x "$TMPDIR/bin/wl-copy" "$TMPDIR/bin/wtype" "$TMPDIR/bin/sleep"

WL_COPY_OUT="$TMPDIR/emoji" WTYPE_OUT="$TMPDIR/wtype" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-menu-emoji-insert" "😀"

[[ $(<"$TMPDIR/emoji") == "😀" ]] || fail "emoji insert helper copies emoji transiently"
pass "emoji insert helper copies emoji transiently"

copy_args=" $(<"$TMPDIR/emoji.args") "
[[ $copy_args == *" --type text/plain "* ]] || fail "emoji insert helper offers the emoji as plain text"
pass "emoji insert helper offers the emoji as plain text"

[[ $copy_args == *" --sensitive "* ]] || fail "emoji insert helper keeps the emoji out of clipboard history"
pass "emoji insert helper keeps the emoji out of clipboard history"

[[ $copy_args == *" --foreground "* ]] || fail "emoji insert helper serves the clipboard from a process it can stop"
pass "emoji insert helper serves the clipboard from a process it can stop"

[[ $(<"$TMPDIR/wtype") == "-M shift -k Insert -m shift" ]] || fail "emoji insert helper pastes with shift insert"
pass "emoji insert helper pastes with shift insert"
