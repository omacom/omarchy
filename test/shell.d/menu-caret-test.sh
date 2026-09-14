#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const MenuModel = require(path.join(root, 'shell/plugins/menu/MenuModel.js'))
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

// --- the arithmetic behind the caret --------------------------------------

// Typing in the middle of a query is the case that did not exist before: the
// header only ever appended, so a wrong digit meant deleting back to it.
const typed = MenuModel.caretInsert('1234*5', 2, '0')   // 12|34*5 -> 120|34*5
assertEqual(typed.text, '12034*5', 'typing inserts at the caret instead of at the end')
assertEqual(typed.caret, 3, 'the caret follows the character it just inserted')

assertEqual(
  MenuModel.caretDelete('1234', 2, false).text,
  '134',
  'backspace takes the character behind the caret, not the last one'
)

assertEqual(
  MenuModel.caretDelete('1234', 0, false).text,
  '1234',
  'backspace at the start of the query takes nothing'
)

assertEqual(
  MenuModel.caretDelete('100 usd to sek', 14, true).text,
  '100 usd to ',
  'ctrl+backspace takes the word behind the caret'
)

// A caret that came to rest inside a run of spaces would need two presses to
// get anywhere, so a word jump crosses the spaces and the word together.
assertEqual(
  MenuModel.caretStep('one  two', 5, -1, true),
  0,
  'a word jump left crosses the spaces and the word behind them'
)

assertEqual(
  MenuModel.caretStep('one two', 0, 1, true),
  3,
  'a word jump right lands at the end of the word ahead'
)

assertEqual(MenuModel.caretStep('abc', 0, -1, false), 0, 'the caret stops at the start of the query')
assertEqual(MenuModel.caretStep('abc', 3, 1, false), 3, 'the caret stops at the end of the query')

// filterText is reset from several places, so an index can outlive its text.
assertEqual(MenuModel.clampCaret('abc', -5), 0, 'a negative caret clamps to the start')
assertEqual(MenuModel.clampCaret('abc', 99), 3, 'a caret past the end clamps to the end')
assertEqual(MenuModel.caretInsert('abc', 99, 'x').text, 'abcx', 'a stale caret still inserts somewhere sane')

// --- the wiring that puts it on screen ------------------------------------

const header = menuQml.slice(menuQml.indexOf('id: headerRow'), menuQml.indexOf('id: promptText'))

assert(
  /id: queryHead[\s\S]*?text: root\.filterText\.slice\(0, root\.caretPos\)/.test(header)
    && /id: queryTail[\s\S]*?text: root\.filterText\.slice\(root\.caretPos\)/.test(header)
    && header.indexOf('id: queryHead') < header.indexOf('id: caret')
    && header.indexOf('id: caret') < header.indexOf('id: queryTail'),
  'the header draws the caret between the two halves of the query'
)

assert(
  /function onFilterTextChanged\(\) \{ caret\.relight\(\) \}/.test(header)
    && /function onCaretPosChanged\(\) \{ caret\.relight\(\) \}/.test(header),
  'the caret goes solid on a keystroke and on a move, so neither is read against a blinked-off caret'
)

assert(
  /property bool blinking: root\.opened && !root\.deleteConfirmOpen/.test(header)
    && /visible: !root\.deleteConfirmOpen/.test(header),
  'the caret stands down while the delete confirmation owns the keys'
)

// Left still goes back on an empty query, and Right still activates once the
// caret has nothing left to walk through -- both reflexes predate the caret.
assert(
  /event\.key === Qt\.Key_Backspace \|\| event\.key === Qt\.Key_Left\) && !root\.filterText[\s\S]*?root\.goBack\(\)/.test(menuQml),
  'Left still leaves the menu when there is no query to walk back through'
)

assert(
  /event\.key === Qt\.Key_Right && root\.caretPos < root\.filterText\.length[\s\S]*?root\.moveCaret\(event, 1\)/.test(menuQml)
    && /Qt\.Key_Return \|\| event\.key === Qt\.Key_Enter \|\| event\.key === Qt\.Key_Right/.test(menuQml),
  'Right walks the query while there is more of it, and activates the row at its end'
)

JS
