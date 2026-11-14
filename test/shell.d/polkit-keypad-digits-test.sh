#!/bin/bash

# #15424: the polkit overlay is a layer surface with exclusive keyboard focus, and its keypad arrives
# as navigation keys (KeypadModifier, empty text) while the compositor reports NumLock on, so keypad
# digits typed nothing until NumLock was toggled twice. The mapping and its guards live in
# KeypadDigits.js, so they can be checked without a compositor.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const keypad = requireFromRoot('shell/plugins/polkit/KeypadDigits.js')
const source = fs.readFileSync(root + '/shell/plugins/polkit/PolkitAgent.qml', 'utf8')

const K = keypad.KEYPAD_MODIFIER
// The standard numpad layout, which the report's verified patch used.
const expected = {
  0x01000006: '0', 0x01000011: '1', 0x01000015: '2', 0x01000017: '3', 0x01000012: '4',
  0x0100000b: '5', 0x01000014: '6', 0x01000010: '7', 0x01000013: '8', 0x01000016: '9',
  0x01000007: '.'
}
for (const [key, digit] of Object.entries(expected)) {
  assertEqual(keypad.digitFor(Number(key), K, '', false), digit,
    `keypad key ${Number(key).toString(16)} types ${JSON.stringify(digit)}`)
}

// Guards: everything else stays Qt's business.
assertEqual(keypad.digitFor(0x01000010, K, '', true), null,
  'a submitted or erroring field is left alone')
assertEqual(keypad.digitFor(0x01000010, 0, '', false), null,
  'without the keypad modifier nothing is translated')
assertEqual(keypad.digitFor(0x01000010, K, '7', false), null,
  'a key carrying its own text (the working NumLock case) is left alone')
assertEqual(keypad.digitFor(0x41, K, '', false), null,
  'an ordinary key is left alone')

assert(/KeypadDigits\.digitFor\(event\.key, event\.modifiers, event\.text, readOnly\)/.test(source),
  'the password field uses the shared mapping, so the rule cannot drift back into the QML')
JS
