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

cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  cat "${HYPRCTL_ACTIVEWINDOW:-/dev/null}"
  exit 0
fi

# Force the wtype fallback path so unit tests can assert the chord without a live compositor.
exit 1
SH

chmod +x "$TMPDIR/bin/wl-copy" "$TMPDIR/bin/wtype" "$TMPDIR/bin/sleep" "$TMPDIR/bin/hyprctl"

run_emoji_insert() {
  local activewindow="$1"
  local wtype_out="$2"

  printf '%s\n' "$activewindow" >"$TMPDIR/activewindow.json"
  rm -f "$wtype_out"

  WL_COPY_OUT="$TMPDIR/copy" WL_COPY_EMOJI_OUT="$TMPDIR/emoji" WTYPE_OUT="$wtype_out" \
    HYPRCTL_ACTIVEWINDOW="$TMPDIR/activewindow.json" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-menu-emoji-insert" "😀"
}

run_emoji_insert '{"tags":["terminal*"]}' "$TMPDIR/wtype-terminal"

[[ $(<"$TMPDIR/emoji") == "😀" ]] || fail "emoji insert helper copies emoji transiently"
pass "emoji insert helper copies emoji transiently"

[[ $(<"$TMPDIR/emoji.args") == "--type text/plain --sensitive --foreground" ]] || fail "emoji insert helper serves sensitive transient clipboard in foreground"
pass "emoji insert helper serves transient clipboard in foreground"

[[ $(<"$TMPDIR/wtype-terminal") == "-M shift -k Insert -m shift" ]] || fail "emoji insert helper pastes into terminals with shift insert"
pass "emoji insert helper pastes into terminals with shift insert"

run_emoji_insert '{"tags":["chromium-based-browser*"]}' "$TMPDIR/wtype-browser"

[[ $(<"$TMPDIR/wtype-browser") == "-M ctrl -k v -m ctrl" ]] || fail "emoji insert helper pastes into browsers with ctrl+v"
pass "emoji insert helper pastes into browsers with ctrl+v"

run_emoji_insert '{"tags":[]}' "$TMPDIR/wtype-default"

[[ $(<"$TMPDIR/wtype-default") == "-M ctrl -k v -m ctrl" ]] || fail "emoji insert helper defaults to ctrl+v outside terminals"
pass "emoji insert helper defaults to ctrl+v outside terminals"
