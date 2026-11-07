#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

// Drive shell.toggle itself against a stand-in for the shell, where the menu
// self-closes when its route is an action (background, theme) and summons
// the image-picker, without calling shell.hide, as Menu.qml does.
const toggleBody = shellSource.match(/function toggle\(pluginId, payloadJson\) \{([\s\S]*?)\n  \}/)
assert(toggleBody, 'shell.qml defines a toggle(pluginId, payloadJson) function')

const MENU = 'omarchy.menu'
const PICKER = 'omarchy.image-picker'
const CLIPBOARD = 'omarchy.clipboard'
const route = menu => JSON.stringify({ menu })

function desktop() {
  const opened = {}
  const scope = {
    openPanelIds: {},
    lastMenuActionPayload: '',
    shell: { pluginRegistry: { resolveEnabledId: id => id } },
    isPluginOpen: id => opened[id] === true,
    hide(id) {
      opened[id] = false
      const next = Object.assign({}, scope.openPanelIds)
      delete next[id]
      scope.openPanelIds = next
      return true
    },
    summon(id, payload) {
      scope.openPanelIds = Object.assign({}, scope.openPanelIds, { [id]: true })
      const menu = id === MENU && JSON.parse(payload).menu
      if (menu === 'background' || menu === 'theme') {
        opened[MENU] = false
        opened[PICKER] = true
        scope.openPanelIds = Object.assign({}, scope.openPanelIds, { [PICKER]: true })
      } else {
        opened[id] = true
      }
      return true
    }
  }
  const run = new Function('scope', 'pluginId', 'payloadJson', `with (scope) {${toggleBody[1]}}`)
  return {
    opened,
    toggle: (id, payload) => run(scope, id, payload),
    dismiss: id => { opened[id] = false },
    openPicker() {
      opened[PICKER] = true
      scope.openPanelIds = Object.assign({}, scope.openPanelIds, { [PICKER]: true })
    }
  }
}

let d = desktop()
d.toggle(MENU, route('background'))
assert(d.opened[PICKER], 'the background shortcut opens the picker')
d.toggle(MENU, route('background'))
assert(!d.opened[PICKER] && !d.opened[MENU], 'pressing the background shortcut again closes the picker')
d.toggle(MENU, route('background'))
assert(d.opened[PICKER], 'a third press opens the picker again')

d = desktop()
d.toggle(MENU, route('background'))
d.toggle(MENU, route('theme'))
assert(d.opened[PICKER], 'the theme shortcut switches the open background picker to themes rather than closing it')

d = desktop()
d.toggle(MENU, route('background'))
d.toggle(MENU, route('root'))
assert(d.opened[MENU], 'the menu shortcut opens the menu while the picker is up')

d = desktop()
d.toggle(MENU, route('background'))
d.toggle(MENU, route('root'))
d.dismiss(MENU)
d.toggle(MENU, route('root'))
assert(d.opened[MENU] && d.opened[PICKER], 'the menu shortcut after dismissing the menu over the picker opens it again')

d = desktop()
d.toggle(MENU, route('root'))
d.dismiss(MENU)
d.openPicker()
d.toggle(MENU, route('root'))
assert(d.opened[MENU] && d.opened[PICKER], 'the menu shortcut opens the menu over a picker something else opened')

d = desktop()
d.toggle(MENU, route('root'))
d.dismiss(MENU)
d.toggle(CLIPBOARD, '')
d.toggle(MENU, route('root'))
assert(d.opened[MENU] && d.opened[CLIPBOARD], 'the menu shortcut after dismissing the menu opens it and leaves clipboard open')

d = desktop()
d.toggle(CLIPBOARD, '')
d.dismiss(CLIPBOARD)
d.toggle(MENU, route('theme'))
d.toggle(CLIPBOARD, '')
assert(d.opened[CLIPBOARD] && d.opened[PICKER], 'the clipboard shortcut opens clipboard and leaves the picker open')
JS
