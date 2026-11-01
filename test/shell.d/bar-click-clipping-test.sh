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

// Every bar surface registers into one clickTargets list, so a click must
// resolve against its own surface even when another output's bar overlaps it.
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
const barFunctions = ['moduleTargetClickable', 'targetWindow', 'targetBelongsToWindow', 'slotWindow', 'moduleClickTargetAt']
  .map(name => barSource.match(new RegExp('  function ' + name + '\\([^)]*\\) \\{[\\s\\S]*?\\n  \\}'))[0])
const clickTargetAt = new Function('clickTargets', 'Util', barFunctions.join('\n') + '\nreturn moduleClickTargetAt')

function surfaceButton(window) {
  return Object.assign(item(200, 25), { QsWindow: { window }, triggerPress() {} })
}

const leftWindow = {}
const rightWindow = {}
const leftButton = surfaceButton(leftWindow)
const rightButton = surfaceButton(rightWindow)
const resolve = clickTargetAt([leftButton, rightButton], { itemContainsPoint: hit })
assertEqual(resolve({ activeItem: leftButton }, 210, 12), leftButton, 'a click resolves to the button on its own bar surface')
assertEqual(resolve({ activeItem: rightButton }, 210, 12), rightButton, 'a click on the later surface still resolves to its own button')
JS
