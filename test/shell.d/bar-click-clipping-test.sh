#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const util = fs.readFileSync(root + '/shell/Commons/Util.qml', 'utf8')
const body = util.match(/function itemContainsPoint\(target, source, x, y\) \{([\s\S]*?)\n  \}/)[1]
const hit = new Function('target', 'source', 'x', 'y', body)

function item(x, width, parent = null, clip = false) {
  return {
    x, width, parent, clip, visible: true, enabled: true, opacity: 1,
    mapFromItem(source, x, y) {
      for (let node = this; node; node = node.parent) x -= node.x
      return { x, y }
    },
    contains(p) { return p.x >= 0 && p.x < this.width && p.y >= 0 && p.y < 24 }
  }
}

const drawer = item(100, 75, null, true)
const slidingRow = item(75, 75, drawer)
const hiddenButton = item(25, 25, slidingRow)
const agents = item(200, 25)
assert(!hit(hiddenButton, null, 210, 12), 'collapsed tray button cannot intercept a click on agents')
assert(hit(agents, null, 210, 12), 'visible agent button receives the click')
slidingRow.x = 0
assert(hit(hiddenButton, null, 135, 12), 'expanded drawer button remains clickable')
slidingRow.x = 40
assert(hit(hiddenButton, null, 170, 12), 'revealed portion of an animating drawer button is clickable')
assert(!hit(hiddenButton, null, 180, 12), 'clipped portion of an animating drawer button is not clickable')
drawer.visible = false
assert(!hit(hiddenButton, null, 170, 12), 'hidden ancestors prevent forwarded clicks')
drawer.visible = true
drawer.enabled = false
assert(!hit(hiddenButton, null, 170, 12), 'disabled ancestors prevent forwarded clicks')

// A third-party panel's bar facade lists only its own plugin's targets, so a
// click on another module must reach the host bar, which presses it only while
// that plugin's panel is the open one.
const panelSource = fs.readFileSync(root + '/shell/Ui/KeyboardPanel.qml', 'utf8')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const panelForward = new Function('root', 'Qt', 'pressTargetAt', 'barPoint', 'px', 'py', 'button',
  panelSource.match(/function forwardBarClick\(px, py, button\) \{([\s\S]*?)\n    \}/)[1])
const hostForward = new Function('root', 'clickTargets', 'Util', 'Qt', 'pluginId', 'window', 'x', 'y', 'button',
  barSource.match(/function forwardPluginBarClick\(pluginId, window, x, y, button\) \{([\s\S]*?)\n  \}/)[1])
const Qt = { LeftButton: 1, RightButton: 2, MiddleButton: 4 }
const barWindow = { contentItem: {} }
const pressed = []
const network = Object.assign(item(200, 25), { mapToItem() {}, triggerPress(button) { pressed.push(button) } })
const panelOwner = {}
const host = {
  activePopout: panelOwner,
  pluginOwnsBarObject: (id, target) => id === 'user.audio' && target === panelOwner,
  targetBelongsToWindow: (target, window) => window === barWindow
}
const facade = {
  forwardBarClick: (window, x, y, button) =>
    hostForward(host, [network], { itemContainsPoint: hit }, Qt, 'user.audio', window, x, y, button)
}
const clickBar = () => panelForward({ anchorWindow: barWindow, bar: facade }, Qt, () => null,
  (x, y) => ({ x, y }), 210, 12, Qt.LeftButton)
assert(clickBar() && pressed.length === 1, 'third-party panel hands a bar click to another module')
host.activePopout = {}
assert(!clickBar() && pressed.length === 1, 'host forwards a plugin click only while its panel is open')

for (const file of ['shell/plugins/bar/Bar.qml', 'shell/Ui/KeyboardPanel.qml']) {
  assert(fs.readFileSync(root + '/' + file, 'utf8').includes('Util.itemContainsPoint(target,'),
    file + ' checks clipping when forwarding bar clicks')
}
JS
