#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# KeypadDigits maps desynced keypad nav keys to digits only while compositor
# NumLock is on, and never for Alt/Ctrl/Super chords.
run_node_test <<'JS'
const keypad = requireFromRoot('shell/Commons/KeypadDigits.js')
const K = keypad.KEYPAD_MODIFIER
const Alt = 0x08000000
const Meta = 0x10000000
const Ctrl = 0x04000000

const expected = {
  0x01000006: '0', 0x01000011: '1', 0x01000015: '2', 0x01000017: '3', 0x01000012: '4',
  0x0100000b: '5', 0x01000014: '6', 0x01000010: '7', 0x01000013: '8', 0x01000016: '9',
  0x01000007: '.'
}
for (const [key, digit] of Object.entries(expected)) {
  assertEqual(keypad.digitFor(Number(key), K, '', true), digit,
    `with NumLock on, keypad key ${Number(key).toString(16)} types ${JSON.stringify(digit)}`)
  assertEqual(keypad.digitFor(Number(key), K, '', false), null,
    `with NumLock off, keypad key ${Number(key).toString(16)} stays navigation`)
}

assertEqual(keypad.digitFor(0x01000010, K | Alt, '', true), null, 'Alt+keypad does not type')
assertEqual(keypad.digitFor(0x01000010, K | Meta, '', true), null, 'Super+keypad does not type')
assertEqual(keypad.digitFor(0x01000010, K | Ctrl, '', true), null, 'Ctrl+keypad does not type')
assertEqual(keypad.digitFor(0x01000010, K, '7', true), null, 'synced NumLock text is left alone')
assertEqual(keypad.digitFor(0x01000010, 0, '', true), null, 'non-keypad Home is left alone')

assertEqual(keypad.numLockFromDevices({ keyboards: [{ main: true, numLock: false }] }), false,
  'numLockFromDevices reads the main keyboard')
assertEqual(keypad.numLockFromDevices({ keyboards: [{ main: false, numLock: false }, { main: true, numLock: true }] }), true,
  'numLockFromDevices prefers the main keyboard over others')
assertEqual(keypad.numLockFromDevices('{"keyboards":[]}'), true,
  'numLockFromDevices defaults to on when the seat is empty')
JS

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping filter input qml tests"
  exit 0
fi

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$SHELL_TEST_DIR/filter-input/qml" -o -,txt 2>&1) ||
  fail "filter input types only what its panel leaves alone" "$output"
pass "filter input types only what its panel leaves alone"
