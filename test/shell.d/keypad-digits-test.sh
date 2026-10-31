#!/bin/bash

# Keypad digits arrive as Home/End/arrows with KeypadModifier and empty text when
# Qt's NumLock disagrees with the compositor. The mapping lives in
# Commons/KeypadDigits.js so menu, FilterInput, and tests share one table.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const keypad = requireFromRoot('shell/Commons/KeypadDigits.js')
const menuQml = fs.readFileSync(root + '/shell/plugins/menu/Menu.qml', 'utf8')
const filterInputQml = fs.readFileSync(root + '/shell/Ui/FilterInput.qml', 'utf8')

const K = keypad.KEYPAD_MODIFIER
const expected = {
  0x01000006: '0', 0x01000011: '1', 0x01000015: '2', 0x01000017: '3', 0x01000012: '4',
  0x0100000b: '5', 0x01000014: '6', 0x01000010: '7', 0x01000013: '8', 0x01000016: '9',
  0x01000007: '.'
}
for (const [key, digit] of Object.entries(expected)) {
  assertEqual(keypad.digitFor(Number(key), K, ''), digit,
    `keypad key ${Number(key).toString(16)} types ${JSON.stringify(digit)}`)
}

assertEqual(keypad.digitFor(0x01000010, 0, ''), null,
  'without the keypad modifier nothing is translated')
assertEqual(keypad.digitFor(0x01000010, K, '7'), null,
  'a key carrying its own text (synced NumLock) is left alone')
assertEqual(keypad.digitFor(0x41, K, ''), null,
  'an ordinary key is left alone')

assert(/KeypadDigits\.digitFor\(event\.key, event\.modifiers, event\.text\)/.test(menuQml),
  'the menu maps desynced keypad keys before Delete / Up / Down')
assert(/KeypadDigits\.digitFor\(event\.key, event\.modifiers, event\.text\)/.test(filterInputQml),
  'FilterInput maps desynced keypad keys the panel left unaccepted')
assert(
  menuQml.indexOf('KeypadDigits.digitFor') < menuQml.indexOf('event.key === Qt.Key_Delete'),
  'menu keypad mapping runs before Delete so KP_Delete does not uninstall'
)
JS
