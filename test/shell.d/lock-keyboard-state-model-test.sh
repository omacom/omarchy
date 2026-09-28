#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/lock/KeyboardStateModel.js')

function devices(keyboards) {
  return JSON.stringify({ mice: [], keyboards: keyboards })
}

assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'keychron', layout: 'us', active_keymap: 'English (US)', capsLock: false, numLock: true, main: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'a plain keyboard yields the quiet state'
)

assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'power-button', layout: 'us', active_keymap: 'English (US)', capsLock: false, numLock: true },
    { name: 'keychron', layout: 'us', active_keymap: 'English (US)', capsLock: true, numLock: true }
  ])),
  { capsLockOn: true, numLockOn: true, layoutLabel: '' },
  'Caps Lock on any physical keyboard lights the badge'
)

assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'keychron', layout: 'us', active_keymap: 'English (US)', capsLock: false, numLock: false }
  ])),
  { capsLockOn: false, numLockOn: false, layoutLabel: '' },
  'Num Lock off on a physical keyboard is reported'
)

assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'hl-virtual-keyboard-fcitx5', layout: 'us', active_keymap: 'English (US)', capsLock: true, numLock: false, main: true },
    { name: 'keychron', layout: 'us', active_keymap: 'English (US)', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'virtual keyboards do not count'
)

assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'keychron', layout: 'us,dk', active_keymap: 'Danish', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: 'Danish' },
  'the active keymap is named when more than one layout is configured'
)

assertDeepEqual(
  model.keyboardStateFromDevices('not json'),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'malformed output yields the quiet state'
)

assertDeepEqual(
  model.keyboardStateFromDevices(''),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'empty output yields the quiet state'
)

const serviceQml = require('fs').readFileSync(`${root}/shell/plugins/lock/Service.qml`, 'utf8')
assert(
  /command:\s*\["hyprctl",\s*"devices",\s*"-j"\]/.test(serviceQml),
  'the lock service polls hyprctl devices for the keyboard state'
)
assert(
  /running:\s*root\.locked\s*\|\|\s*root\.previewVisible/.test(serviceQml),
  'the keyboard state poll only runs while the lock screen or its preview is up'
)
JS
