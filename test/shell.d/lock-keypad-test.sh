#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const lock = requireFromRoot('shell/plugins/lock/LockModel.js')

const desynced = [
  [0x01000006, "0", "Insert"],
  [0x01000011, "1", "End"],
  [0x01000015, "2", "Down"],
  [0x01000017, "3", "PageDown"],
  [0x01000012, "4", "Left"],
  [0x0100000b, "5", "Clear"],
  [0x01000014, "6", "Right"],
  [0x01000010, "7", "Home"],
  [0x01000013, "8", "Up"],
  [0x01000016, "9", "PageUp"],
]
for (const [key, digit, name] of desynced) {
  assertEqual(lock.keypadDigit(key), digit, `keypad ${digit} arrives as ${name} when NumLock is desynced`)
}

assertEqual(lock.keypadDigit(0x34), "", "a digit that already carries text is not remapped")
assertEqual(lock.keypadDigit(0x01000007), "", "the keypad decimal (Delete) is left to the field: dot and comma layouts differ")
assertEqual(lock.keypadDigit(0x01000004), "", "Return is not a keypad digit")
assertEqual(lock.keypadDigit(0x01000000), "", "Escape is not a keypad digit")
JS
