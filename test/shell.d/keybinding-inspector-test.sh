#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')

// Qt enum values, spelled out here for the same reason MenuModel.js spells
// them out: Node has no Qt namespace to read them from.
const SHIFT = 0x02000000
const CTRL = 0x04000000
const ALT = 0x08000000
const SUPER = 0x10000000

const Key_0 = 0x30
const Key_1 = 0x31
const Key_A = 0x41
const Key_F = 0x46
const Key_K = 0x4b
const Key_Q = 0x51
const Key_W = 0x57
const Key_Space = 0x20
const Key_Exclam = 0x21
const Key_At = 0x40
const Key_Grave = 0x60
const Key_Escape = 0x01000000
const Key_Tab = 0x01000001
const Key_Backtab = 0x01000002
const Key_Backspace = 0x01000003
const Key_Return = 0x01000004
const Key_Delete = 0x01000007
const Key_Print = 0x01000009
const Key_Home = 0x01000010
const Key_Left = 0x01000012
const Key_PageUp = 0x01000016
const Key_Shift = 0x01000020
const Key_Control = 0x01000021
const Key_Meta = 0x01000022
const Key_Alt = 0x01000023
const Key_F5 = 0x01000034
const Key_F9 = 0x01000038
const Key_F13 = 0x0100003c
const Key_VolumeMute = 0x01000071
const Key_Question = 0x3f
const KEYPAD = 0x20000000
const GROUP_SWITCH = 0x40000000

// ------------------------------------------------------------- normalization

assertEqual(menu.normalizeChordFromEvent(Key_F, SUPER | SHIFT), 'SUPER+SHIFT+F',
  'a captured chord spells its modifiers in the guide order')
assertEqual(menu.normalizeChordFromEvent(Key_F, SHIFT | SUPER), 'SUPER+SHIFT+F',
  'the order modifiers arrive in does not change the chord')
assertEqual(menu.normalizeChordFromEvent(Key_Delete, CTRL | ALT), 'CTRL+ALT+DELETE',
  'a named key normalizes to the name the guide prints')
assertEqual(menu.normalizeChordFromEvent(Key_W, SUPER | SHIFT | CTRL | ALT), 'SUPER+SHIFT+CTRL+ALT+W',
  'every modifier at once still sorts into one order')
assertEqual(menu.normalizeChordFromEvent(Key_Print, 0), 'PRINT',
  'a chord with no modifier is just its key')
assertEqual(menu.normalizeChordFromEvent(Key_F9, 0), 'F9',
  'function keys resolve to their printed name')
assertEqual(menu.normalizeChordFromEvent(Key_Space, SUPER), 'SUPER+SPACE',
  'space normalizes to the word Hyprland reports')
assertEqual(menu.normalizeChordFromEvent(Key_0, SUPER | SHIFT | ALT), 'SUPER+SHIFT+ALT+0',
  'digits carry through as themselves')
assertEqual(menu.normalizeChordFromEvent(Key_1, SUPER), 'SUPER+1',
  'a bare digit key with Super still names without needing a scan code')
assertEqual(menu.normalizeChordFromEvent(Key_Question, SUPER | SHIFT), '',
  'layout-dependent shifted punctuation fails closed')
assertEqual(menu.normalizeChordFromEvent(Key_Backtab, SHIFT), 'SHIFT+TAB',
  'Backtab resolves to the shifted Tab chord Hyprland reports')
assertEqual(menu.normalizeChordFromEvent(Key_Tab, SUPER), 'SUPER+TAB',
  'Tab with Super names the workspace chord')
assertEqual(menu.normalizeChordFromEvent(Key_Backtab, SUPER | SHIFT), 'SUPER+SHIFT+TAB',
  'Backtab with Super and Shift names the reverse workspace chord')

// Shifted number-row keysyms lie; XKB scan codes 10–19 name the physical keys
assertEqual(menu.normalizeChordFromEvent(Key_Exclam, SUPER | SHIFT, 10), 'SUPER+SHIFT+1',
  'Shift+1 via Key_Exclam still names digit 1 from scan code 10')
assertEqual(menu.normalizeChordFromEvent(Key_At, SUPER | SHIFT, 11), 'SUPER+SHIFT+2',
  'Shift+2 via Key_At still names digit 2 from scan code 11')
assertEqual(menu.normalizeChordFromEvent(0x23, SUPER | SHIFT, 12), 'SUPER+SHIFT+3',
  'Shift+3 via Key_NumberSign still names digit 3 from scan code 12')
assertEqual(menu.normalizeChordFromEvent(0x24, SUPER | SHIFT, 13), 'SUPER+SHIFT+4',
  'Shift+4 via Key_Dollar still names digit 4 from scan code 13')
assertEqual(menu.normalizeChordFromEvent(0x25, SUPER | SHIFT, 14), 'SUPER+SHIFT+5',
  'Shift+5 via Key_Percent still names digit 5 from scan code 14')
assertEqual(menu.normalizeChordFromEvent(0x5e, SUPER | SHIFT, 15), 'SUPER+SHIFT+6',
  'Shift+6 via Key_AsciiCircum still names digit 6 from scan code 15')
assertEqual(menu.normalizeChordFromEvent(0x26, SUPER | SHIFT, 16), 'SUPER+SHIFT+7',
  'Shift+7 via Key_Ampersand still names digit 7 from scan code 16')
assertEqual(menu.normalizeChordFromEvent(0x2a, SUPER | SHIFT, 17), 'SUPER+SHIFT+8',
  'Shift+8 via Key_Asterisk still names digit 8 from scan code 17')
assertEqual(menu.normalizeChordFromEvent(0x28, SUPER | SHIFT, 18), 'SUPER+SHIFT+9',
  'Shift+9 via Key_ParenLeft still names digit 9 from scan code 18')
assertEqual(menu.normalizeChordFromEvent(0x29, SUPER | SHIFT, 19), 'SUPER+SHIFT+0',
  'Shift+0 via Key_ParenRight still names digit 0 from scan code 19')
assertEqual(menu.chordKeyNameFromScan(20), 'MINUS',
  'scan code 20 names MINUS')
assertEqual(menu.chordKeyNameFromScan(21), 'EQUAL',
  'scan code 21 names EQUAL')

assertEqual(menu.normalizeChordFromEvent(Key_VolumeMute, 0, 71), 'F5',
  'an odd Fn-layer keysym still names F5 from scan code 71 when stands-alone')
assertEqual(menu.normalizeChordFromEvent(Key_VolumeMute, SUPER, 71), 'SUPER+F5',
  'scan-named F5 works with Super held')
assertEqual(menu.classifyKeyEvent(Key_VolumeMute, 0, '', false, 71), 'chord',
  'scan code 71 asks for a chord even when the keysym is a media key')

// Hyprland calls the key left of 1 "grave" and the guide renders the symbol
// printed on it, so a capture has to arrive at the same spelling.
assertEqual(menu.normalizeChordFromEvent(Key_Grave, SUPER), 'SUPER+~',
  'the grave key normalizes to the symbol printed on it')

// A modifier held on its own names no chord, so nothing is looked up until a
// real key arrives.
for (const [key, name] of [[Key_Shift, 'shift'], [Key_Control, 'ctrl'], [Key_Meta, 'super'], [Key_Alt, 'alt']]) {
  assertEqual(menu.normalizeChordFromEvent(key, SUPER), '',
    `a held ${name} key names no chord by itself`)
}

// Naming the wrong action is worse than naming none.
assertEqual(menu.normalizeChordFromEvent(0x0100ffff, SUPER), '',
  'a key this side cannot name resolves to no chord at all')

assertEqual(menu.normalizeChord(['ctrl', 'Control', 'WIN'], 'k'), 'SUPER+CTRL+K',
  'modifier spellings collapse onto the canonical names')
assertEqual(menu.normalizeChord(['SUPER', 'HYPER'], 'k'), '',
  'unknown modifier names are rejected instead of silently discarded')
assertEqual(menu.normalizeChordFromEvent(Key_W, SUPER | 0x1), '',
  'unknown Qt modifier bits are rejected instead of creating a false match')

// ----------------------------------------------------------- classification

assertEqual(menu.classifyKeyEvent(Key_K, CTRL, '', false), 'chord',
  'Ctrl and a letter asks what the shortcut does')
assertEqual(menu.classifyKeyEvent(Key_F, SUPER | SHIFT, 'F', false), 'chord',
  'Super with Shift and a letter is a chord')
assertEqual(menu.classifyKeyEvent(Key_Left, SUPER, '', false), 'chord',
  'an arrow held with a modifier is a chord')
assertEqual(menu.classifyKeyEvent(Key_Delete, CTRL | ALT, '', false), 'chord',
  'Delete held with modifiers is a chord')
assertEqual(menu.classifyKeyEvent(Key_Print, 0, '', false), 'chord',
  'Print alone is a chord')
assertEqual(menu.classifyKeyEvent(Key_F9, 0, '', false), 'chord',
  'a function key alone is a chord')
assertEqual(menu.classifyKeyEvent(Key_Backtab, SHIFT, '', false), 'chord',
  'Backtab is inspected as Shift Tab')
assertEqual(menu.classifyKeyEvent(Key_Tab, SUPER, '', false), 'chord',
  'Tab with Super is captured as a chord, not menu control')
assertEqual(menu.classifyKeyEvent(Key_Exclam, SUPER | SHIFT, '!', false, 10), 'chord',
  'Shift+digit via a shifted keysym still classifies as a chord with its scan code')
assertEqual(menu.classifyKeyEvent(Key_VolumeMute, 0, '', false), 'unsupported',
  'media keys fail closed outside physical inspection')
assertEqual(menu.classifyKeyEvent(Key_F13, 0, '', false), 'unsupported',
  'function keys beyond F12 fail closed outside the strict MVP')

// Typing has to keep working, capitals included.
assertEqual(menu.classifyKeyEvent(Key_F, 0, 'f', false), 'text',
  'a bare letter is text, not a chord')
assertEqual(menu.classifyKeyEvent(Key_F, SHIFT, 'F', false), 'text',
  'Shift and a letter stays text so capitals can be searched for')
assertEqual(menu.classifyKeyEvent(Key_Q, CTRL | ALT, '@', false), 'text',
  'AltGr exposed as Ctrl Alt remains translated text')
assertEqual(menu.classifyKeyEvent(Key_Q, SUPER | CTRL | ALT, '@', false), 'chord',
  'Super prevents a real Ctrl Alt chord from being mistaken for AltGr text')
assertEqual(menu.classifyKeyEvent(Key_Q, GROUP_SWITCH, '@', false), 'text',
  'an explicit group-switch modifier remains text')
assertEqual(menu.classifyKeyEvent(Key_Q, SUPER | CTRL | ALT | GROUP_SWITCH, '@', false), 'unsupported',
  'Super plus group-switch fails closed instead of becoming AltGr text')
assertEqual(menu.classifyKeyEvent(Key_Question, SUPER | SHIFT, '?', false), 'unsupported',
  'translated shifted punctuation cannot false-match a non-US base key')
assertEqual(menu.classifyKeyEvent(Key_Q, SUPER | 0x1, '', false), 'unsupported',
  'unknown modifiers fail closed')
assertEqual(menu.classifyKeyEvent(Key_0, SUPER | KEYPAD, '', false), 'unsupported',
  'keypad context is not collapsed onto the main keyboard')
assertEqual(menu.classifyKeyEvent(Key_W, SUPER, '', true), 'repeat',
  'auto-repeat never initiates a lookup')

// Keys that steer the menu keep steering it when nothing is held.
for (const [key, name] of [[Key_Left, 'an arrow'], [Key_Return, 'Enter'], [Key_Tab, 'Tab'],
                           [Key_Backspace, 'Backspace'], [Key_Delete, 'Delete'],
                           [Key_PageUp, 'PageUp'], [Key_Home, 'Home']]) {
  assertEqual(menu.classifyKeyEvent(key, 0, '', false), 'control',
    `${name} on its own still drives the menu`)
}

// Bare Escape is the way out of an inhibited keyboard. Modified Escape is a
// real binding (SUPER+ESCAPE) and must inspect like any other chord.
assertEqual(menu.classifyKeyEvent(Key_Escape, 0, '', false), 'control',
  'bare Escape is never a chord')
assertEqual(menu.classifyKeyEvent(Key_Escape, SUPER, '', false), 'chord',
  'Super+Escape is inspected as a chord')
assertEqual(menu.normalizeChordFromEvent(Key_Escape, SUPER), 'SUPER+ESCAPE',
  'Super+Escape normalizes to the guide chord')
assertEqual(menu.classifyKeyEvent(Key_Escape, CTRL | ALT, '', false), 'chord',
  'Ctrl+Alt+Escape is inspected as a chord')

// A modifier press updates the held state but asks nothing.
for (const [key, name] of [[Key_Shift, 'shift'], [Key_Control, 'ctrl'], [Key_Meta, 'super'], [Key_Alt, 'alt']]) {
  assertEqual(menu.classifyKeyEvent(key, SUPER, '', false), 'modifier',
    `a ${name} press on its own asks nothing`)
}

// ------------------------------------------------------- structured records

const rows = [
  { chords: ['SUPER+K'], inspectable: true, reason: '' },
  { chords: ['SUPER+SHIFT+F'], inspectable: true, reason: '' },
  { chords: ['SUPER+W', 'SUPER+Q'], inspectable: true, reason: '' },
  { chords: ['CTRL+ALT+DELETE'], inspectable: true, reason: '' },
  { chords: ['PRINT'], inspectable: true, reason: '' },
  { chords: ['SUPER+LEFT MOUSE BUTTON'], inspectable: false, reason: 'non-keyboard binding' },
  { chords: ['SUPER+SHIFT+1'], inspectable: true, reason: '' },
  { chords: ['SUPER+TAB'], inspectable: true, reason: '' }
]

// -------------------------------------------------------------- looking up

assertDeepEqual(menu.findRowsForChord(rows, 'SUPER+SHIFT+F').matches, [1],
  'a chord finds the row that describes it')
assertDeepEqual(menu.findRowsForChord(rows, 'SUPER+W').matches, [2],
  'the chord leading a shared row finds it')
assertDeepEqual(menu.findRowsForChord(rows, 'SUPER+Q').matches, [2],
  'the alternative chord finds the same row')
assertDeepEqual(menu.findRowsForChord(rows, 'SUPER+SHIFT+CTRL+ALT+Y').matches, [],
  'a chord nothing is bound to finds nothing')
assertDeepEqual(menu.findRowsForChord(rows, '').matches, [],
  'an unnamed chord looks nothing up')
assertDeepEqual(
  menu.findRowsForChord(rows, menu.normalizeChordFromEvent(Key_Exclam, SUPER | SHIFT, 10)).matches,
  [6],
  'a Shift+digit capture via scan code finds the workspace row')
assertDeepEqual(
  menu.findRowsForChord(rows, menu.normalizeChordFromEvent(Key_Tab, SUPER)).matches,
  [7],
  'a Super+Tab capture finds the workspace row')

// Two actions can answer to one chord; the guide has to show both rather than
// pick one.
const duplicated = [
  { chords: ['SUPER+Y'], inspectable: true },
  { chords: ['SUPER+Y'], inspectable: true }
]
assertDeepEqual(menu.findRowsForChord(duplicated, 'SUPER+Y').matches, [0, 1],
  'a chord bound twice reports both rows')

// A capture and a rendered row have to meet: what the event normalizes to is
// what the row is found by.
assertDeepEqual(menu.findRowsForChord(rows, menu.normalizeChordFromEvent(Key_Delete, CTRL | ALT)).matches, [3],
  'a captured chord finds the row rendered for it')
assertDeepEqual(menu.findRowsForChord(rows, menu.normalizeChordFromEvent(Key_Q, SUPER)).matches, [2],
  'a captured alternative chord finds its shared row')
assert(menu.findRowsForChord(rows, 'SUPER+LEFT MOUSE BUTTON').unsupported,
  'an excluded binding is reported as unsupported, not silently absent')

// Labels are deliberately absent: presentation text is no longer an input to
// reverse lookup.
assertDeepEqual(menu.findRowsForChord([{ chords: ['SUPER+W'], inspectable: true }], 'SUPER+W').matches, [0],
  'lookup semantics do not depend on the rendered label')

// ------------------------------------------------------------- reporting it

assertEqual(menu.formatChord('SUPER+SHIFT+F'), 'SUPER SHIFT + F',
  'a chord reports itself the way the guide prints chords')
assertEqual(menu.formatChord('PRINT'), 'PRINT',
  'a bare key reports itself without a separator')
assertEqual(menu.formatChord(''), '',
  'no chord reports nothing')
JS

# ---------------------------------------------------------- request transport

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the transport test gets a temporary directory"
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash

if [[ $1 == "shell" && $2 == "summon" ]]; then
  printf '%s' "$4" >"$CAPTURE_PAYLOAD"
  if [[ ${NO_DONE_FILE:-0} != "1" ]]; then
    perl -MJSON::PP=decode_json -e '
      my $payload = decode_json($ARGV[0]);
      open(my $done, ">", $payload->{doneFile}) or die $!;
      close($done);
    ' "$4"
  fi
elif [[ $1 == "shell" && $2 == "ping" ]]; then
  exit 1
fi
SH
chmod +x "$stub_bin/omarchy-shell"

capture="$tmpdir/inspect.json"
record_safe=$'SUPER + W                           → Close window\tSUPER+W\t1\t\t0'
record_unsafe=$'SUPER + LEFT MOUSE BUTTON           → Move window\tnone\t0\tnon-keyboard binding\t0'
record_bypass=$'SUPER + P                           → Bypass inhibition\tSUPER+P\t0\tbypasses shortcut inhibition\t1'

status=0
printf '%s\n%s\n%s\n' "$record_safe" "$record_unsafe" "$record_bypass" |
  env PATH="$stub_bin:$PATH" CAPTURE_PAYLOAD="$capture" \
    "$ROOT/bin/omarchy-menu-select" Keybindings -- --inspect-keybindings ||
  status=$?
(( status == 1 )) || fail "an empty inspector selection exits as canceled"

CAPTURE_PAYLOAD="$capture" run_node_test <<'JS'
const fs = require('fs')
const payload = JSON.parse(fs.readFileSync(process.env.CAPTURE_PAYLOAD, 'utf8'))

assert(payload.inspectKeybindings === true,
  'the keybinding request explicitly enables inspection')
assertDeepEqual(payload.options, [
  'SUPER + W                           → Close window',
  'SUPER + LEFT MOUSE BUTTON           → Move window',
  'SUPER + P                           → Bypass inhibition'
], 'structured metadata is removed from display labels')
assertDeepEqual(payload.inspectionOptions[0].chords, ['SUPER+W'],
  'canonical chords travel beside the display option')
assert(payload.inspectionOptions[0].inspectable === true,
  'an ordinary keyboard row stays physically inspectable')
assert(payload.inspectionOptions[1].inspectable === false,
  'an excluded row remains text-searchable but not physically inspectable')
assertEqual(payload.inspectionBlockedReason, 'bypasses shortcut inhibition',
  'one bypassing binding disables physical capture for the whole request')
JS

capture="$tmpdir/generic.json"
status=0
env PATH="$stub_bin:$PATH" CAPTURE_PAYLOAD="$capture" \
  "$ROOT/bin/omarchy-menu-select" Format jpg png ||
  status=$?
(( status == 1 )) || fail "an empty generic selection exits as canceled"

CAPTURE_PAYLOAD="$capture" run_node_test <<'JS'
const fs = require('fs')
const payload = JSON.parse(fs.readFileSync(process.env.CAPTURE_PAYLOAD, 'utf8'))

assert(payload.inspectKeybindings === undefined,
  'generic selectors never inherit shortcut capture')
assert(payload.inspectionOptions === undefined,
  'generic selectors carry no inspection metadata')
JS

capture="$tmpdir/dead-shell.json"
status=0
printf '%s\n' "$record_safe" |
  env PATH="$stub_bin:$PATH" CAPTURE_PAYLOAD="$capture" NO_DONE_FILE=1 \
    timeout 3 "$ROOT/bin/omarchy-menu-select" Keybindings -- --inspect-keybindings ||
  status=$?
(( status == 1 )) || fail "the selector exits when the shell dies instead of waiting forever"
pass "a dead shell cannot strand the selector request"

grep -q 'if (root.chordQuery) return' "$ROOT/shell/plugins/menu/Menu.qml" ||
  fail "held chord results are guarded from dmenu activation"
pass "held chord results stay display-only until release settles selection"

grep -q 'root.chordCaptureState = "ready"' "$ROOT/shell/plugins/menu/Menu.qml" &&
  grep -q 'root.fallBackToTextOnly("Shortcut capture could not be activated")' "$ROOT/shell/plugins/menu/Menu.qml" &&
  grep -q 'if (root.opened && root.inspectKeybindings) root.cancel()' "$ROOT/shell/plugins/menu/Menu.qml" &&
  grep -q 'else if (!active && root.opened && root.chordCaptureState === "ready")' "$ROOT/shell/plugins/menu/Menu.qml" ||
  fail "the QML lifecycle does not fail closed around inhibitor readiness"
pass "inhibitor denial, cancellation, and active loss fail closed"

grep -q 'if (keyKind === "repeat")' "$ROOT/shell/plugins/menu/Menu.qml" ||
  fail "the QML input path does not drop auto-repeat"
pass "the QML input path drops auto-repeat before lookup"

grep -q 'enabled: false' "$ROOT/shell/plugins/menu/Menu.qml" &&
  grep -q 'shortcutInhibitor.enabled = true' "$ROOT/shell/plugins/menu/Menu.qml" ||
  fail "each inspector request does not explicitly reacquire inhibition"
pass "later inspector requests can reacquire inhibition after cancellation"

(( $(grep -c 'root.prepareForReplacement()' "$ROOT/shell/plugins/menu/Menu.qml") == 2 )) &&
  grep -q 'root.opened = false' "$ROOT/shell/plugins/menu/Menu.qml" &&
  grep -q 'if (shortcutInhibitor.active) chordCaptureState = "ready"' "$ROOT/shell/plugins/menu/Menu.qml" ||
  fail "reentrant requests do not finish the old caller and inherit active capture safely"
pass "reentrant menu requests finish the old caller and preserve capture readiness"

# ------------------------------------------------------- silent / release UX

qml="$ROOT/shell/plugins/menu/Menu.qml"
! grep -q 'chordStatus' "$qml" ||
  fail "Menu.qml still references removed chordStatus"
grep -q 'function resetChordState' "$qml" ||
  fail "resetChordState is not defined"
grep -q 'chordMatchIndex' "$qml" ||
  fail "chordMatchIndex is not tracked for release settle"
grep -q 'Keys.onReleased' "$qml" ||
  fail "key release does not settle the chord selection"
grep -q 'if (event.isAutoRepeat)' "$qml" ||
  fail "auto-repeat releases are not ignored before settleChordSelection"
grep -q 'chordHoldScan' "$qml" ||
  fail "chord hold scan is not tracked for Shift+digit press/release keysym mismatch"
grep -q 'function sameChordHold' "$qml" ||
  fail "sameChordHold is not defined for scan-stable hold matching"
grep -q 'chordHoldKey' "$qml" ||
  fail "chord hold key is not tracked to prevent replacement while held"
grep -q 'function settleChordSelection' "$qml" ||
  fail "settleChordSelection is not defined"
grep -q 'root.settleChordSelection()' "$qml" ||
  fail "release does not settle onto the matched row"
grep -q 'root.clearChord' "$qml" ||
  fail "clearChord is not wired for Escape / third-key abort"
! grep -q 'Unsupported shortcut' "$qml" ||
  fail "Menu.qml still sets a sticky Unsupported shortcut banner"
! grep -q 'No binding for ' "$qml" ||
  fail "Menu.qml still sets a sticky No binding banner"
grep -q 'event.nativeScanCode' "$qml" ||
  fail "nativeScanCode is not passed into model calls"
grep -q 'if (lookup.matches.length === 0)' "$qml" ||
  fail "showChord does not stay silent when nothing matches"
grep -q 'if (root.chordQuery) root.clearChord()' "$qml" ||
  fail "Escape does not clear an active chord lookup"
grep -q 'if (keyKind === "unsupported")' "$qml" ||
  fail "unsupported presses are not accepted as silent no-ops"
grep -q 'dmenu.' "$qml" && grep -q 'settleChordSelection' "$qml" ||
  fail "settleChordSelection does not reselect the matched dmenu row"
pass "silent miss, scan-code wiring, and release-to-select contracts hold in Menu.qml"

# ------------------------------------------------------- allowlist parity

# Names bash supported_key accepts (families, not every letter/digit). Must stay
# produceable by MenuModel; Backtab is listed in bash but captures as TAB+Shift.
bash_key_names=(
  A 0
  SPACE COMMA MINUS PERIOD SLASH SEMICOLON EQUAL BRACKETLEFT BACKSLASH BRACKETRIGHT '~' APOSTROPHE
  TAB BACKTAB BACKSPACE RETURN INSERT DELETE HOME END LEFT UP RIGHT DOWN PRIOR NEXT PRINT ESCAPE
  F1 F9 F12
)

supported_fn=$(sed -n '/^function supported_key/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")
[[ -n $supported_fn ]] || fail "supported_key is missing from omarchy-menu-keybindings"

for name in "${bash_key_names[@]}"; do
  awk -v key="$name" "$supported_fn"'
BEGIN { exit supported_key(key) ? 0 : 1 }
' || fail "bash supported_key rejects $name (MenuModel parity list is out of date)"
done
pass "bash supported_key accepts the shared core key-name set"

run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const SUPER = 0x10000000
const SHIFT = 0x02000000
const CTRL = 0x04000000

const Key_0 = 0x30
const Key_A = 0x41
const Key_Space = 0x20
const Key_Comma = 0x2c
const Key_Minus = 0x2d
const Key_Period = 0x2e
const Key_Slash = 0x2f
const Key_Semicolon = 0x3b
const Key_Equal = 0x3d
const Key_BracketLeft = 0x5b
const Key_Backslash = 0x5c
const Key_BracketRight = 0x5d
const Key_Apostrophe = 0x27
const Key_Grave = 0x60
const Key_Escape = 0x01000000
const Key_Tab = 0x01000001
const Key_Backtab = 0x01000002
const Key_Backspace = 0x01000003
const Key_Return = 0x01000004
const Key_Insert = 0x01000006
const Key_Delete = 0x01000007
const Key_Print = 0x01000009
const Key_Home = 0x01000010
const Key_End = 0x01000011
const Key_Left = 0x01000012
const Key_Up = 0x01000013
const Key_Right = 0x01000014
const Key_Down = 0x01000015
const Key_PageUp = 0x01000016
const Key_PageDown = 0x01000017
const Key_F1 = 0x01000030
const Key_F9 = 0x01000038
const Key_F12 = 0x0100003b

const cases = [
  ['A', menu.normalizeChordFromEvent(Key_A, SUPER), 'SUPER+A'],
  ['0', menu.normalizeChordFromEvent(Key_0, SUPER), 'SUPER+0'],
  ['SPACE', menu.normalizeChordFromEvent(Key_Space, SUPER), 'SUPER+SPACE'],
  ['COMMA', menu.normalizeChordFromEvent(Key_Comma, SUPER), 'SUPER+COMMA'],
  ['MINUS', menu.normalizeChordFromEvent(Key_Minus, SUPER, 20), 'SUPER+MINUS'],
  ['PERIOD', menu.normalizeChordFromEvent(Key_Period, SUPER), 'SUPER+PERIOD'],
  ['SLASH', menu.normalizeChordFromEvent(Key_Slash, SUPER), 'SUPER+SLASH'],
  ['SEMICOLON', menu.normalizeChordFromEvent(Key_Semicolon, SUPER), 'SUPER+SEMICOLON'],
  ['EQUAL', menu.normalizeChordFromEvent(Key_Equal, SUPER, 21), 'SUPER+EQUAL'],
  ['BRACKETLEFT', menu.normalizeChordFromEvent(Key_BracketLeft, SUPER), 'SUPER+BRACKETLEFT'],
  ['BACKSLASH', menu.normalizeChordFromEvent(Key_Backslash, SUPER), 'SUPER+BACKSLASH'],
  ['BRACKETRIGHT', menu.normalizeChordFromEvent(Key_BracketRight, SUPER), 'SUPER+BRACKETRIGHT'],
  ['~', menu.normalizeChordFromEvent(Key_Grave, SUPER), 'SUPER+~'],
  ['APOSTROPHE', menu.normalizeChordFromEvent(Key_Apostrophe, SUPER), 'SUPER+APOSTROPHE'],
  ['TAB', menu.normalizeChordFromEvent(Key_Tab, SUPER), 'SUPER+TAB'],
  // Bash lists BACKTAB; capture spells Shift+Tab as SUPER+SHIFT+TAB (same key family).
  ['BACKTAB', menu.normalizeChordFromEvent(Key_Backtab, SUPER | SHIFT), 'SUPER+SHIFT+TAB'],
  ['BACKSPACE', menu.normalizeChordFromEvent(Key_Backspace, SUPER), 'SUPER+BACKSPACE'],
  ['RETURN', menu.normalizeChordFromEvent(Key_Return, SUPER), 'SUPER+RETURN'],
  ['INSERT', menu.normalizeChordFromEvent(Key_Insert, SUPER), 'SUPER+INSERT'],
  ['DELETE', menu.normalizeChordFromEvent(Key_Delete, CTRL | 0x08000000), 'CTRL+ALT+DELETE'],
  ['HOME', menu.normalizeChordFromEvent(Key_Home, SUPER), 'SUPER+HOME'],
  ['END', menu.normalizeChordFromEvent(Key_End, SUPER), 'SUPER+END'],
  ['LEFT', menu.normalizeChordFromEvent(Key_Left, SUPER), 'SUPER+LEFT'],
  ['UP', menu.normalizeChordFromEvent(Key_Up, SUPER), 'SUPER+UP'],
  ['RIGHT', menu.normalizeChordFromEvent(Key_Right, SUPER), 'SUPER+RIGHT'],
  ['DOWN', menu.normalizeChordFromEvent(Key_Down, SUPER), 'SUPER+DOWN'],
  ['PRIOR', menu.normalizeChordFromEvent(Key_PageUp, SUPER), 'SUPER+PRIOR'],
  ['NEXT', menu.normalizeChordFromEvent(Key_PageDown, SUPER), 'SUPER+NEXT'],
  ['PRINT', menu.normalizeChordFromEvent(Key_Print, 0), 'PRINT'],
  ['ESCAPE', menu.normalizeChordFromEvent(Key_Escape, SUPER), 'SUPER+ESCAPE'],
  ['F1', menu.normalizeChordFromEvent(Key_F1, 0), 'F1'],
  ['F9', menu.normalizeChordFromEvent(Key_F9, 0), 'F9'],
  ['F12', menu.normalizeChordFromEvent(Key_F12, 0), 'F12']
]

for (const [name, actual, expected] of cases) {
  assertEqual(actual, expected,
    `MenuModel produces bash-supported key family ${name}`)
}
JS
pass "MenuModel produces chords for every bash supported_key family"
