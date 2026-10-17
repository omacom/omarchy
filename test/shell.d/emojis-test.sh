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

assertEqual(emojis.filterEmojis(data, 'face with tears')[0].e,
  '\u{1F602}',
  'emoji filtering finds face with tears of joy'
)

assertEqual(emojis.favoritesAreValid('["a"]'), true, 'a favorites array is a file the picker may replace')
assertEqual(emojis.favoritesAreValid('[]'), true, 'an empty array is still a favorites file')
assertEqual(emojis.favoritesAreValid(''), false, 'an empty file is not')
assertEqual(emojis.favoritesAreValid('{'), false, 'a file that does not parse is not')
assertEqual(emojis.favoritesAreValid('{"a":1}'), false, 'an object is not a favorites file')
assertEqual(emojis.favoritesAreValid('"a"'), false, 'a bare string is not a favorites file')

assertDeepEqual(emojis.parseFavorites('["a","b"]'), ['a', 'b'], 'emoji favorites parse in file order')
assertDeepEqual(emojis.parseFavorites('{'), [], 'invalid emoji favorites parse as empty')
assertDeepEqual(emojis.parseFavorites('{"a":1}'), [], 'non-array emoji favorites parse as empty')
assertDeepEqual(
  emojis.parseFavorites('["a","a"," b ",7,null]'),
  ['a', 'b'],
  'emoji favorites drop duplicates, blanks and non-strings'
)

assertDeepEqual(emojis.toggleFavorite(['a'], 'b'), ['a', 'b'], 'favoriting appends so pinned cells stay put')
assertDeepEqual(emojis.toggleFavorite(['a', 'b'], 'a'), ['b'], 'unfavoriting removes the emoji')
assertDeepEqual(emojis.toggleFavorite(null, 'a'), ['a'], 'favoriting tolerates a missing list')
assertDeepEqual(emojis.toggleFavorite(['a'], ''), ['a'], 'favoriting ignores an empty emoji')

assertDeepEqual(emojis.moveFavorite(['a', 'b', 'c'], 'a', 'c'), ['b', 'c', 'a'], 'dragging a favorite forward drops it on the target cell')
assertDeepEqual(emojis.moveFavorite(['a', 'b', 'c'], 'c', 'a'), ['c', 'a', 'b'], 'dragging a favorite back drops it on the target cell')
assertDeepEqual(emojis.moveFavorite(['a', 'b'], 'a', 'a'), ['a', 'b'], 'dropping a favorite on itself changes nothing')
assertDeepEqual(emojis.moveFavorite(['a', 'b'], 'a', 'typo'), ['a', 'b'], 'dropping a favorite outside the list changes nothing')

assertDeepEqual(
  emojis.favoriteEmojis(fixture, ['c', 'a']),
  ['c', 'a'],
  'favorite emojis keep the file order rather than the catalog order'
)

assertDeepEqual(
  emojis.favoriteEmojis(fixture, ['typo', 'b']),
  ['b'],
  'favorite emojis ignore entries outside the catalog'
)

assertDeepEqual(
  emojis.favoriteEmojis(fixture, ['b']),
  ['b'],
  'a short favorite list is not padded out with emojis nobody chose'
)

// Grid layout: [Favorites heading ×8][pins][pad to row end][All heading ×8][matches]
const cells = emojis.buildCells(fixture, ['c', 'a', 'b'], '', 1000, 8)

assertEqual(cells.length, 27, 'grid layout pads a short pinned row to the row end')
assertEqual(cells[0].heading, 'Favorites', 'pinned section is headed')
assertEqual(cells[1].heading, '', 'only the first cell of a heading row carries the text')
assertDeepEqual(cells.slice(8, 11).map(cell => cell.emoji), ['c', 'a', 'b'], 'pinned cells follow in file order')
assertDeepEqual(cells.slice(11, 16).map(cell => cell.emoji), ['', '', '', '', ''], 'row end after the pins is padding, not emojis')
assertEqual(cells[16].heading, 'All', 'the rest of the picker is headed All')
assertDeepEqual(cells.slice(24, 27).map(cell => cell.emoji), ['a', 'b', 'c'], 'catalog cells follow the headings')
assertEqual(emojis.isEmojiCell(cells, 0), false, 'a heading cell cannot hold the cursor')
assertEqual(emojis.isEmojiCell(cells, 8), true, 'a pinned cell holds the cursor')

const bare = emojis.buildCells(fixture, [], '', 1000, 8)
assertEqual(bare[0].emoji, 'a', 'a picker with nothing pinned has no headings at all')
assertEqual(bare.some(cell => cell.heading !== ''), false, 'no headings without pins')

const searching = emojis.buildCells(fixture, ['c'], 'joy', 1000, 8)
assertEqual(searching[0].emoji, 'b', 'searching drops the pinned row for the matches')
assertEqual(searching.some(cell => cell.heading !== ''), false, 'searching shows no headings')

assertEqual(emojis.stepTarget(cells, 0, 1), 8, 'stepping right off a heading lands on the first pinned emoji')
assertEqual(emojis.stepTarget(cells, 11, 1), 24, 'stepping right past a padded row end crosses into the catalog')
assertEqual(emojis.stepTarget(cells, 16, -1), 10, 'stepping left off the All heading lands on the last pinned emoji')
assertEqual(emojis.stepTarget(cells, 0, -1), -1, 'stepping left off the grid reports -1 so the caller can wrap')

assertEqual(emojis.rowTarget(cells, 8, 8, 1), 24, 'down from a pinned cell lands on the catalog below it')
assertEqual(emojis.rowTarget(cells, 8, 25, -1), 9, 'up from a catalog cell lands on the pin in its own column')
assertEqual(emojis.rowTarget(cells, 8, 8, -1), -1, 'up from the top row stays put')
assertEqual(emojis.rowTarget(cells, 8, 24, 2), -1, 'a page past the end of the grid stays put')

// A full catalog band, so an "up" from a column past the pins has somewhere to land.
const wide = fixture.concat([{ e: 'd', k: 'x' }, { e: 'e', k: 'x' }, { e: 'f', k: 'x' }, { e: 'g', k: 'x' }, { e: 'h', k: 'x' }])
const wideCells = emojis.buildCells(wide, ['c', 'a', 'b'], '', 1000, 8)

assertEqual(wideCells.length, 32, 'a full catalog band follows the headings')
assertEqual(emojis.rowTarget(wideCells, 8, 26, -1), 10, 'up from a catalog column past the pins lands on the nearest pin, not sideways')
assertEqual(emojis.rowTarget(wideCells, 8, 27, -1), 10, 'and the same for the column beyond it')
assertEqual(emojis.rowTarget(wideCells, 8, 24, -1), 8, 'up from catalog column 0 lands on the pin in that column')
assertEqual(emojis.rowTarget(wideCells, 8, 31, -1), 10, 'up from the far edge of the catalog band still lands on a pin')

assertEqual(emojis.pageTarget(wideCells, 8, 8, 2), 24, 'a page down lands in the band it reaches')
assertEqual(emojis.pageTarget(wideCells, 8, 24, 9), 31, 'a page past the end of the grid clamps to its last emoji')
assertEqual(emojis.pageTarget(wideCells, 8, 31, -9), 8, 'a page past the start clamps to its first emoji')
assertEqual(emojis.pageTarget(cells, 8, 8, -9), 8, 'a page up from the top row stays on the first emoji')

// The short-result case: a search that fits in one band could not be paged at all
// when a page target of -1 left the cursor where it was.
const twoMatches = emojis.buildCells(fixture, [], 'face', 1000, 8)
assertEqual(twoMatches.length, 2, 'a narrow search still builds a plain list')
assertEqual(emojis.pageTarget(twoMatches, 8, 0, 9), 1, 'a page down a short result lands on its last emoji')
assertEqual(emojis.pageTarget(twoMatches, 8, 1, -9), 0, 'and a page up lands on its first')
JS

# The picker's favorites file is read asynchronously, so drive the QML's own
# persistence seam with the read delayed behind a pin — the same shape as the
# shell-config guard, on the plugin that writes a list of its own.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const emojis = requireFromRoot('shell/plugins/emojis/EmojiSearch.js')
const source = fs.readFileSync(path.join(root, 'shell/plugins/emojis/Emojis.qml'), 'utf8')

function extractFunction(name) {
  const start = source.indexOf('  function ' + name + '(')
  const end = source.indexOf('\n  }', start)
  if (start < 0 || end < 0) throw new Error('missing function ' + name)
  return source.slice(start, end + 4)
}

function extractHandler(signature) {
  const start = source.indexOf(signature)
  if (start < 0) throw new Error('missing ' + signature)
  const line = source.slice(start + signature.length, source.indexOf('\n', start)).trim()
  const open = line.indexOf('{')
  if (open < 0) return line // a plain expression, not a function block
  const close = line.lastIndexOf('}')
  if (close <= open) throw new Error('unterminated ' + signature)
  return line.slice(open + 1, close).trim()
}

function extractExpression(signature) {
  const start = source.indexOf(signature)
  if (start < 0) throw new Error('missing ' + signature)
  return source.slice(start + signature.length, source.indexOf('\n', start)).trim()
}

// FileViewError as the shell's FileView reports it
const errors = { Success: 0, FileNotFound: 1, PermissionDenied: 2, NotAFile: 3 }
let disk = ''
const writes = []
const reloads = []
const host = {
  EmojiSearch: emojis,
  FileViewError: errors,
  favorites: [],
  favoritesReady: false,
  favoritesLoadError: errors.Success,
  favoritesWritable: false,
  favoritesRevision: 0,
  favoritesReadRevision: -1,
  opened: false,
  rebuildDisplay: function() {},
  console: { warn: function() {} },
  // FileView's own text() accessor, which onLoaded hands to the loader
  text: function() { return disk },
  favoritesFile: {
    text: function() { return disk },
    reload: function() { reloads.push(disk) },
    setText: function(value) { writes.push(value) }
  }
}
host.root = host
vm.createContext(host)

for (const name of ['readFavorites', 'readIsCurrent', 'loadFavorites', 'favoritesLoadFailed', 'saveFavorites'])
  vm.runInContext(extractFunction(name), host)
// open() itself, and the handler the watcher calls: the read they make is the
// behaviour under test, so both are run rather than looked for in the file.
vm.runInContext('Qt = { callLater: function() {} }', host)
vm.runInContext('keyCatcher = { forceActiveFocus: function() {} }', host)
vm.runInContext(extractFunction('open'), host)
vm.runInContext('function fileLoaded() {' + extractHandler('onLoaded:') + '}', host)
vm.runInContext('function fileLoadFailed(error) {' + extractHandler('onLoadFailed: function(error)') + '}', host)
// open() and the FileView block want reading twice: open() is run against the fake
// below, and the block's declarations are checked here.
const fileViewAt = source.indexOf('id: favoritesFile')
if (fileViewAt < 0) throw new Error('missing the favorites FileView')
const fileViewBlock = source.slice(fileViewAt, source.indexOf('\n  }', fileViewAt))

// Run the picker's own binding rather than restating the rule in the test.
const savableExpression = extractExpression('readonly property bool favoritesSavable:')
function settle() { host.favoritesSavable = vm.runInContext(savableExpression, host) }

// A read the way the picker makes one: ask for it, then let it land.
function readAs(contents) { disk = contents; host.readFavorites(); host.fileLoaded(); settle() }
function failAs(error) { host.fileLoadFailed(error); settle() }

settle()
assertEqual(host.favoritesSavable, false, 'nothing may be saved before the file has been read')
host.favorites = ['👍']
assertEqual(host.saveFavorites(), false, 'a pin before the read lands cannot write')
assertEqual(writes.length, 0, 'and nothing reaches the file')

readAs('["👍","🔥"]')
assertDeepEqual(host.favorites, ['👍', '🔥'], 'the read supplies the list that was already there')
host.favorites = ['👍', '🔥', '🎉']
assertEqual(host.saveFavorites(), true, 'a save after the read is allowed')
assertDeepEqual(JSON.parse(writes[0]), ['👍', '🔥', '🎉'], 'and keeps the favorites that were already there')

for (const broken of ['["👍",', '{"a":1}', '']) {
  readAs(broken)
  const before = writes.length
  assertDeepEqual(host.favorites, [], 'a favorites file we cannot use shows as no favorites: ' + JSON.stringify(broken))
  assertEqual(host.saveFavorites(), false, 'and is never replaced by a save: ' + JSON.stringify(broken))
  assertEqual(writes.length, before, 'so the file on disk is untouched: ' + JSON.stringify(broken))
}

failAs(errors.FileNotFound)
assertEqual(host.favoritesReady, true, 'a failed read still finishes the initial read')
assertEqual(host.favoritesSavable, true, 'a missing file is a first run and stays writable')

failAs(errors.PermissionDenied)
assertEqual(host.favoritesLoadError, errors.PermissionDenied, 'the read error is kept')
assertEqual(host.saveFavorites(), false, 'an unreadable file is not replaced')

// A read after the first must not lock saving, or every pin after the first open
// would be dropped.
readAs('["👍"]')
assertEqual(host.favoritesSavable, true, 'a read after the first leaves saving enabled')
host.favorites = ['👍', '🎉']
assertEqual(host.saveFavorites(), true, 'so a pin after a later read still lands')
assertDeepEqual(JSON.parse(writes[writes.length - 1]), ['👍', '🎉'], 'with the pin applied')

// Opening reads the file, and the watcher reads it again whenever it changes: one
// covers an edit made before the picker opened, the other an edit made while it is
// open. Both go through readFavorites().
const reloadsBefore = reloads.length
host.open('{}')
assertEqual(host.opened, true, 'opening opens the picker')
assertEqual(reloads.length, reloadsBefore + 1, 'and reads the favorites file')
host.open('{}')
assertEqual(reloads.length, reloadsBefore + 2, 'and reads it again on every open, not just the first')
// The watcher's handler, run the same way.
const fileChanged = extractHandler('onFileChanged:')
if (!fileChanged) throw new Error('the favorites FileView no longer handles onFileChanged')
vm.runInContext('function favoritesFileChanged() {' + fileChanged + '}', host)
host.favoritesFileChanged()
assertEqual(reloads.length, reloadsBefore + 3, 'a change to the file is read again')
// watchChanges is a declaration rather than code, so it is asserted as text; the
// watch behaving was verified live with the picker open.
assertEqual(/watchChanges:\s*true/.test(fileViewBlock), true, 'and the file is watched while the picker is open')
readAs('["👍","🔥"]')
host.favorites = ['👍', '🔥', '🎉']
assertEqual(host.saveFavorites(), true, 'a pin after a read writes')
assertDeepEqual(JSON.parse(writes[writes.length - 1]), ['👍', '🔥', '🎉'], 'keeping the favorites that were seeded by hand')

// A read that a pin overtook must not put its older list back: the pin is what the
// user made, and its write is already on the file.
disk = '["👍"]'
const writesBeforeOvertaken = writes.length
host.readFavorites()
host.favorites = ['👍', '🎉']
assertEqual(host.saveFavorites(), true, 'a pin while a read is in flight is written')
host.fileLoaded()
settle()
assertDeepEqual(host.favorites, ['👍', '🎉'], 'and the read it overtook does not put the older list back')
assertEqual(writes.length, writesBeforeOvertaken + 1, 'and the read landing writes nothing of its own')

// A read nothing overtook is applied as before.
readAs('["🔥"]')
assertDeepEqual(host.favorites, ['🔥'], 'a read that no change overtook is still applied')

// A failed read a pin overtook must not empty the list either.
host.readFavorites()
host.favorites = ['🔥', '🎉']
assertEqual(host.saveFavorites(), true, 'a pin while a read that will fail is in flight is written')
host.fileLoadFailed(errors.FileNotFound)
settle()
assertDeepEqual(host.favorites, ['🔥', '🎉'], 'and the failed read it overtook cannot empty the list')
assertEqual(host.favoritesSavable, true, 'nor take saving away from a list that has been read')

JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"

cat >"$TMPDIR/bin/wl-copy" <<'SH'
#!/bin/bash
args="$*"
target="$WL_COPY_OUT"
if [[ $args == "--type text/plain --sensitive --foreground" ]]; then
  target="$WL_COPY_EMOJI_OUT"
fi

printf '%s\n' "$args" >"$target.args"
cat >"$target"
SH

cat >"$TMPDIR/bin/wtype" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WTYPE_OUT"
SH

cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TMPDIR/bin/wl-copy" "$TMPDIR/bin/wtype" "$TMPDIR/bin/sleep"

WL_COPY_OUT="$TMPDIR/copy" WL_COPY_EMOJI_OUT="$TMPDIR/emoji" WTYPE_OUT="$TMPDIR/wtype" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-menu-emoji-insert" "😀"

[[ $(<"$TMPDIR/emoji") == "😀" ]] || fail "emoji insert helper copies emoji transiently"
pass "emoji insert helper copies emoji transiently"

[[ $(<"$TMPDIR/emoji.args") == "--type text/plain --sensitive --foreground" ]] || fail "emoji insert helper serves sensitive transient clipboard in foreground"
pass "emoji insert helper serves transient clipboard in foreground"

[[ $(<"$TMPDIR/wtype") == "-M shift -k Insert -m shift" ]] || fail "emoji insert helper pastes with shift insert"
pass "emoji insert helper pastes with shift insert"
