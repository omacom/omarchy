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

assertDeepEqual(emojis.parseUsage('{"a":2}'), { a: 2 }, 'emoji usage parses')
assertDeepEqual(emojis.parseUsage('{'), {}, 'invalid emoji usage parses as empty')
assertDeepEqual(emojis.parseUsage('[1]'), {}, 'non-object emoji usage parses as empty')
assertDeepEqual(emojis.parseUsage('{"a":2,"b":"5","c":0}'), { a: 2 }, 'emoji usage keeps only positive numeric counts')

assertDeepEqual(
  emojis.mostUsed(fixture, { c: 1, b: 3 }, 2),
  ['b', 'c'],
  'most used emojis rank by use count'
)

assertDeepEqual(
  emojis.mostUsed(fixture, { c: 1 }, 3),
  ['c', 'a', 'b'],
  'most used emojis top up from the catalog without duplicates'
)

assertDeepEqual(
  emojis.mostUsed(fixture, { typo: 9, a: 1 }, 1),
  ['a'],
  'most used emojis ignore keys outside the catalog'
)

assertDeepEqual(
  emojis.mostUsed(data, {}, 3),
  ['\u{1F602}', '\u{2764}\u{FE0F}', '\u{1F60D}'],
  'most used emojis start out with the popular ones'
)

assertDeepEqual(
  emojis.mostUsed(data, { '\u{1F60D}': 1 }, 3),
  ['\u{1F60D}', '\u{1F602}', '\u{2764}\u{FE0F}'],
  'most used emojis rank picks ahead of the popular ones'
)

assertEqual(
  emojis.filterEmojis(data, 'face with tears')[0].e,
  '\u{1F602}',
  'emoji filtering finds face with tears of joy'
)
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
