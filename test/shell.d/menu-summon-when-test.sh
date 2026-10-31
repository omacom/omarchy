#!/bin/bash

# A direct summon (`omarchy menu summon <alias>`) must not run an action row or
# open a submenu that the menu's `when` guards have hidden. #15742

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

const items = {
  root: menu.normalizeItem('root', { label: 'Go' }),
  style: menu.normalizeItem('style', { label: 'Style' }),
  'style.theme': menu.normalizeItem('style.theme', { label: 'Themes', aliases: 'theme', action: 'omarchy-theme-set' }),
  'record.stop': menu.normalizeItem('record.stop', { label: 'Stop recording', aliases: 'screenrecord-stop', when: 'recording-active', action: 'omarchy-screenrecord-stop' }),
  vm: menu.normalizeItem('vm', { label: 'Virtualization', when: 'has-vm' }),
  'vm.apps': menu.normalizeItem('vm.apps', { label: 'Apps', action: 'list-vms' }),
  'jump': menu.normalizeItem('jump', { label: 'Jump', target: 'style' }),
  'jump.hidden': menu.normalizeItem('jump.hidden', { label: 'Hidden jump', target: 'vm', when: 'recording-active' })
}
const order = Object.keys(items)

assertEqual(
  menu.routeTarget(items, order, { 'record.stop': false }, 'screenrecord-stop'),
  null,
  'summon refuses an action its when guard hid'
)
assertEqual(
  menu.routeTarget(items, order, { 'record.stop': true }, 'screenrecord-stop'),
  'record.stop',
  'summon runs the same action when its when guard allows it'
)
assertEqual(
  menu.routeTarget(items, order, { vm: false }, 'vm'),
  null,
  'summon refuses a submenu its when guard hid'
)
assertEqual(
  menu.routeTarget(items, order, { vm: true }, 'vm'),
  'vm',
  'summon opens the same submenu when its when guard allows it'
)
assertEqual(
  menu.routeTarget(items, order, { 'jump.hidden': false }, 'jump.hidden'),
  null,
  'summon refuses a hidden link'
)
assertEqual(
  menu.routeTarget(items, order, { 'jump.hidden': true }, 'jump.hidden'),
  'jump.hidden',
  'summon follows a link its when guard allows'
)
assertEqual(
  menu.routeTarget(items, order, {}, 'screenrecord-stop'),
  'record.stop',
  'summon still runs before the when guards have evaluated'
)
assertEqual(
  menu.routeTarget(items, order, {}, 'theme'),
  'style.theme',
  'summon keeps resolving a visible alias'
)
assertEqual(
  menu.routeTarget(items, order, {}, 'nope'),
  'nope',
  'summon keeps the unknown-id fallthrough'
)
assertEqual(
  menu.routeTarget(items, order, {}, ''),
  'root',
  'summon keeps opening root for an empty route'
)

const rootOnly = { root: menu.normalizeItem('root', { label: 'Go' }) }
assertEqual(
  menu.routeTarget(rootOnly, Object.keys(rootOnly), {}, 'root'),
  'root',
  'summon opens root before the default rows have loaded'
)

const guardedRoot = { root: menu.normalizeItem('root', { label: 'Go', when: 'false', action: 'example' }) }
assertEqual(
  menu.routeTarget(guardedRoot, Object.keys(guardedRoot), { root: false }, 'root'),
  null,
  'summon still refuses a root its own when guard hid'
)

const vm = require('vm')

function extract(signature) {
  const start = menuQml.indexOf(`  ${signature}`)
  assert(start >= 0, `found ${signature} in Menu.qml`)
  const end = menuQml.indexOf('\n  }', start)
  assert(end > start, `found the end of ${signature} in Menu.qml`)
  return menuQml.slice(start, end + '\n  }'.length)
}

const guardStart = menuQml.indexOf('    id: guardProc')
const guardExitedMatch = menuQml.slice(guardStart).match(/onExited: function\(exitCode, exitStatus\) \{([\s\S]*?)\n    \}/)
assert(guardExitedMatch, 'found guardProc.onExited in Menu.qml')
const harnessSource = `${extract('function setFilter(')}\n${extract('function applySelected(')}\n${extract('function openRoute(')}\n${extract('function evaluateGuards(')}\nfunction onGuardExited(exitCode, exitStatus) {${guardExitedMatch[1]}\n}`

function createHarness(initialWhen) {
  const actions = []
  const openedMenus = []
  let cancels = 0
  const deferred = []
  const guardProc = { running: false, collected: '', command: null }
  const host = {
    items,
    itemOrder: order,
    whenResults: { ...initialWhen },
    checkedResults: {},
    disabledResults: {},
    guardsPending: false,
    pendingRoute: '',
    pendingInitialMenu: 'root',
    opened: false,
    cancel() {
      host.pendingRoute = ''
      cancels += 1
    },
    runAction(action) {
      actions.push(action)
    },
    openExistingMenu(id, skipGuards) {
      host.pendingRoute = ''
      openedMenus.push(id)
      if (!skipGuards) host.evaluateGuards()
    },
    rebuildDisplay() {},
    disarmPointer() {},
    loadProvidersForSearch() {},
    dmenuActive: false,
    mode: 'menu',
    filterText: ''
  }
  const scope = {
    root: host,
    MenuModel: menu,
    guardProc,
    requestSerial: 0,
    applySerial: 0,
    opened: false,
    filterText: '',
    cancel: () => host.cancel(),
    Qt: { callLater: fn => deferred.push(fn) },
    panel: { freezeCardTop() {} }
  }
  vm.createContext(scope)
  vm.runInContext(harnessSource, scope)
  host.setFilter = scope.setFilter
  host.applySelected = scope.applySelected
  host.openRoute = scope.openRoute
  host.evaluateGuards = scope.evaluateGuards
  const finishGuards = (lines, exitCode = 0, exitStatus = 0) => {
    guardProc.collected = lines.join('\n')
    scope.onGuardExited(exitCode, exitStatus)
    guardProc.running = false
    while (deferred.length) deferred.shift()()
  }
  return { host, guardProc, actions, openedMenus, cancels: () => cancels, finishGuards }
}

{
  const h = createHarness({ 'record.stop': false })
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'hidden action summon refreshes guards before deciding')
  assert(h.guardProc.running, 'hidden action summon starts a guard evaluation')
  assertDeepEqual(h.actions, [], 'hidden action does not run while guard refresh is in flight')
  assertDeepEqual(h.openedMenus, [], 'hidden action does not open a menu while guard refresh is in flight')
  assertEqual(h.cancels(), 0, 'hidden action waits for guard refresh before cancelling')
  h.finishGuards(['record.stop:w:0'])
  assertEqual(h.cancels(), 1, 'hidden action cancels once refreshed guard is still false')
  assertDeepEqual(h.actions, [], 'hidden action never runs its command when refreshed guard is false')
  assertDeepEqual(h.openedMenus, [], 'hidden action never opens a menu when refreshed guard is false')
}

{
  const h = createHarness({ vm: false })
  assertEqual(h.host.openRoute('vm'), 'pending', 'hidden submenu summon refreshes guards before deciding')
  h.finishGuards(['vm:w:0'])
  assertEqual(h.cancels(), 1, 'hidden submenu cancels once refreshed guard is still false')
  assertDeepEqual(h.openedMenus, [], 'hidden submenu never opens when refreshed guard is false')
  assertDeepEqual(h.actions, [], 'hidden submenu runs no action when refreshed guard is false')
}

{
  const h = createHarness({ 'record.stop': false })
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'stale false action guard triggers a refresh on summon')
  h.finishGuards(['record.stop:w:1'])
  assertDeepEqual(h.actions, ['omarchy-screenrecord-stop'], 'action summon runs once refreshed guard becomes true')
  assertDeepEqual(h.openedMenus, [], 'action summon does not open a submenu when running the action')
  assertEqual(h.cancels(), 1, 'action summon closes the menu before running the action')
}

{
  const h = createHarness({ vm: false })
  assertEqual(h.host.openRoute('vm'), 'pending', 'stale false submenu guard triggers a refresh on summon')
  h.finishGuards(['vm:w:1'])
  assertDeepEqual(h.openedMenus, ['vm'], 'submenu summon opens the menu once refreshed guard becomes true')
  assertDeepEqual(h.actions, [], 'submenu summon runs no action')
  assertEqual(h.cancels(), 0, 'submenu summon does not cancel when refreshed guard becomes true')
  assert(!h.guardProc.running, 'opening after a guard refresh does not immediately spawn a duplicate guard batch')
}

{
  const h = createHarness({ 'jump.hidden': false, vm: false })
  assertEqual(h.host.openRoute('jump.hidden'), 'pending', 'stale false link guard triggers a refresh on summon')
  h.finishGuards(['jump.hidden:w:1', 'vm:w:1'])
  assertDeepEqual(h.openedMenus, ['vm'], 'link summon follows its target once refreshed guards become true')
  assertEqual(h.cancels(), 0, 'link summon does not cancel when refreshed guards become true')
}

{
  const h = createHarness({ 'record.stop': false })
  h.guardProc.running = true
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'summon during an in-flight guard batch waits for a fresh evaluation')
  assert(h.host.guardsPending, 'summon queues a fresh guard evaluation behind the in-flight batch')
  h.finishGuards(['record.stop:w:0'])
  assertEqual(h.cancels(), 0, 'stale in-flight batch does not cancel the pending summon')
  assert(h.guardProc.running, 'queued guard evaluation starts after the in-flight batch exits')
  h.finishGuards(['record.stop:w:1'])
  assertDeepEqual(h.actions, ['omarchy-screenrecord-stop'], 'queued guard evaluation lets the newly valid summon through')
}

{
  const h = createHarness({ 'record.stop': false })
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'summon waits for guard refresh while menu stays interactive')
  h.host.applySelected('style.theme', 'omarchy-theme-set')
  assertEqual(h.host.pendingRoute, '', 'selecting another row clears the waiting summon route')
  h.finishGuards(['record.stop:w:1'])
  assertDeepEqual(h.actions, ['omarchy-theme-set'], 'pending summon does not run its action after the user selects another row')
  assertDeepEqual(h.openedMenus, [], 'pending summon does not reopen a menu after the user selects another row')
  assertEqual(h.cancels(), 0, 'completed guard refresh does not cancel again after another selection')
}

{
  const h = createHarness({ 'record.stop': false })
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'summon waits for guard refresh while the user types')
  h.host.setFilter('the')
  assertEqual(h.host.pendingRoute, '', 'typing a search clears the waiting summon route')
  h.finishGuards(['record.stop:w:1'])
  assertDeepEqual(h.actions, [], 'pending summon does not run after the user starts a search')
}

const unguarded = {}
for (const id of order) unguarded[id] = { ...items[id], when: '' }

{
  const h = createHarness({ 'record.stop': false })
  assertEqual(h.host.openRoute('screenrecord-stop'), 'pending', 'summon waits while the menu reloads')
  h.host.items = unguarded
  h.host.guardsPending = true
  h.finishGuards(['record.stop:w:0'])
  assertEqual(h.host.pendingRoute, '', 'a reload that leaves no guards still settles the waiting summon')
  assertDeepEqual(h.actions, ['omarchy-screenrecord-stop'], 'a reload that leaves no guards runs the waiting summon once')
}

{
  const h = createHarness({})
  h.host.items = { ...unguarded, empty: menu.normalizeItem('empty', { label: 'Empty' }) }
  h.host.itemOrder = order.concat(['empty'])
  assertEqual(h.host.openRoute('empty'), 'hidden', 'a summon with no guards to refresh settles at once')
  h.finishGuards([])
  assertEqual(h.cancels(), 1, 'the deferred retry does not settle a summon the synchronous path already settled')
  assertDeepEqual(h.openedMenus, [], 'the deferred retry opens nothing after the summon settled')
}
JS
