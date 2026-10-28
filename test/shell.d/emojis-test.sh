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
