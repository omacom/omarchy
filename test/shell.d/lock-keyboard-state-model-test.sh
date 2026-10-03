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
    { name: 'keychron', layout: 'us,dk', active_layout_index: 1, active_keymap: 'Danish', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: 'Danish' },
  'a keyboard moved off its first layout names the active keymap'
)

// omarchy-system-lock switches every keyboard to its first layout, so this is
// how every lock starts when more than one layout is configured.
assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'keychron', layout: 'us,dk', active_layout_index: 0, active_keymap: 'English (US)', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'the first layout of several shows no layout badge'
)

// Left Alt + Right Alt at the lock moves the keyboard being typed on, not the
// power button listed ahead of it.
assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'power-button', layout: 'us,dk', active_layout_index: 0, active_keymap: 'English (US)', capsLock: false, numLock: true },
    { name: 'keychron', layout: 'us,dk', active_layout_index: 1, active_keymap: 'Danish', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: 'Danish' },
  'a layout switched at the lock is read from the keyboard that switched'
)

// Hyprland keeps Num Lock per keyboard, so with numlock_by_default = false the
// buttons stay off however the real keyboard is set.
assertDeepEqual(
  model.keyboardStateFromDevices(devices([
    { name: 'power-button', layout: 'us', active_layout_index: 0, active_keymap: 'English (US)', capsLock: true, numLock: false },
    { name: 'video-bus', layout: 'us', active_layout_index: 0, active_keymap: 'English (US)', capsLock: false, numLock: false },
    { name: 'keychron', layout: 'us', active_layout_index: 0, active_keymap: 'English (US)', capsLock: false, numLock: true }
  ])),
  { capsLockOn: false, numLockOn: true, layoutLabel: '' },
  'buttons that report as keyboards do not count'
)

const untyped = source => (/var UNTYPED_KEYBOARDS = (.+)/.exec(source) || [])[1]
const readSource = path => require('fs').readFileSync(`${root}/${path}`, 'utf8')
assert(untyped(readSource('shell/plugins/lock/KeyboardStateModel.js')), 'the lock model lists the untyped keyboards')
assertDeepEqual(
  untyped(readSource('shell/plugins/lock/KeyboardStateModel.js')),
  untyped(readSource('shell/plugins/bar/widgets/KeyboardLayoutModel.js')),
  'the lock and the bar agree on which keyboards nobody types on'
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
  /running:\s*\(root\.locked\s*&&\s*!root\.displaysBlank\)\s*\|\|\s*root\.previewVisible/.test(serviceQml),
  'the keyboard state poll only runs while the lock screen is lit or its preview is up'
)
assert(
  /onKeyboardActivity:\s*root\.refreshKeyboardState\(\)/.test(serviceQml),
  'a key event at the lock refreshes the keyboard state'
)

const lockViewQml = require('fs').readFileSync(`${root}/shell/plugins/lock/LockView.qml`, 'utf8')
assert(
  /Keys\.onPressed:[\s\S]*?root\.trackModifiers\(event, true\)/.test(lockViewQml),
  'key presses in the password field track held modifiers'
)
assert(
  /Keys\.onReleased:[\s\S]*?root\.trackModifiers\(event, false\)/.test(lockViewQml),
  'key releases in the password field track held modifiers'
)
assert(
  /onActiveFocusChanged:\s*if \(!activeFocus\) root\.heldModifiers = 0/.test(lockViewQml),
  'losing focus clears the held modifiers'
)
JS
