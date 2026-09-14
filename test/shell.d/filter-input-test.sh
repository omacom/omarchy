#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Every searchable panel decides "does this keystroke type into the filter?"
# the same way, and the decision has a trap: Qt stamps KeypadModifier on every
# keypad key while NumLock is on and GroupSwitchModifier on AltGr characters,
# so a check for "no modifier" drops numpad digits and AltGr symbols while the
# number row types fine. Run the shared helper's own JavaScript against the
# real Qt modifier values.
run_node_test <<'JS'
const fs = require('fs')
const utilQml = fs.readFileSync(path.join(root, 'shell/Commons/Util.qml'), 'utf8')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const pickerQml = fs.readFileSync(path.join(root, 'shell/plugins/image-picker/ImagePicker.qml'), 'utf8')

const Qt = {
  NoModifier: 0x00000000,
  ShiftModifier: 0x02000000,
  ControlModifier: 0x04000000,
  AltModifier: 0x08000000,
  MetaModifier: 0x10000000,
  KeypadModifier: 0x20000000,
  GroupSwitchModifier: 0x40000000
}

const helper = utilQml.match(/function extendsFilter\(event\) \{[\s\S]*?\n {2}\}/)
assert(helper, 'Util exposes extendsFilter for the searchable panels')
eval(helper[0])

const key = (text, modifiers) => ({ text, modifiers })

assert(extendsFilter(key('6', Qt.NoModifier)), 'a number-row digit extends the filter')
assert(extendsFilter(key('5', Qt.KeypadModifier)), 'a numpad digit with NumLock on extends the filter')
assert(extendsFilter(key('A', Qt.ShiftModifier)), 'a shifted letter extends the filter')
assert(extendsFilter(key('*', Qt.ShiftModifier | Qt.KeypadModifier)), 'a shifted keypad key still extends the filter')
assert(extendsFilter(key(' ', Qt.NoModifier)), 'a space extends the filter')
assert(extendsFilter(key('+', Qt.GroupSwitchModifier)), 'an AltGr character extends the filter')
assert(extendsFilter(key('+', Qt.ShiftModifier | Qt.GroupSwitchModifier)), 'a shifted AltGr character extends the filter')

assert(!extendsFilter(key('u', Qt.ControlModifier)), 'a Ctrl chord is left to the panel')
assert(!extendsFilter(key('u', Qt.ControlModifier | Qt.KeypadModifier)), 'a Ctrl chord on the keypad is left to the panel')
assert(!extendsFilter(key('U', Qt.ControlModifier | Qt.ShiftModifier)), 'a Ctrl+Shift chord is left to the panel')
assert(!extendsFilter(key('a', Qt.AltModifier)), 'an Alt chord is left to the panel')
assert(!extendsFilter(key('a', Qt.MetaModifier)), 'a Super chord is left to the panel')
assert(!extendsFilter(key('', Qt.NoModifier)), 'a key with no text does not extend the filter')
assert(!extendsFilter(key(String.fromCharCode(127), Qt.NoModifier)), 'Delete does not extend the filter')
assert(!extendsFilter(key(String.fromCharCode(9), Qt.NoModifier)), 'a control character does not extend the filter')
assert(!extendsFilter(key('ab', Qt.NoModifier)), 'multi-character text does not extend the filter')

// The panels must route through the helper rather than carry their own copy
// of the check, or the next exact modifier comparison brings the bug back.
assert(/Util\.extendsFilter\(event\)/.test(menuQml), 'menu types into its filter through Util.extendsFilter')
assert(/root\.filterable && Util\.extendsFilter\(event\)/.test(pickerQml), 'image picker types into its filter through Util.extendsFilter')
assert(!/event\.modifiers === Qt\.NoModifier/.test(menuQml + pickerQml), 'no panel filter compares modifiers for equality with Qt.NoModifier')
JS
