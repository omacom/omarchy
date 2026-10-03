#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Delete on an app row raises an uninstall confirmation that takes every key,
# with Uninstall preselected. A summon replaces the rows it was raised for, so
# it must not stay up to answer the new request. Runs the real open, delete,
# and key handling from Menu.qml and ConfirmDialog.qml under node vm, with the
# rows, the result writer, and the app library stubbed.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const confirmQml = fs.readFileSync(path.join(root, 'shell/Ui/ConfirmDialog.qml'), 'utf8')

function functionSource(qml, name) {
  const match = qml.match(new RegExp(`\\n  function ${name}\\([^)]*\\) \\{[\\s\\S]*?\\n  \\}\\n`))
  if (!match) fail(`uninstall confirmation harness finds ${name}`)
  return match[0]
}

const contexts = []

function menuHarness() {
  const names = ['open', 'openRoute', 'openExistingMenu', 'openDmenu', 'requestDeleteSelected', 'cancelDelete',
    'confirmDelete', 'activateIndex', 'applyDmenuSelection', 'cancel', 'finishRequest']
  const Qt = {
    Key_Escape: 1, Key_Tab: 2, Key_Backtab: 3, Key_Backspace: 4, Key_Return: 5, Key_Enter: 6, Key_Delete: 7, Key_Left: 8,
    Key_Up: 9, Key_Right: 10, Key_Down: 11, Key_PageUp: 12, Key_PageDown: 13, NoModifier: 0, ShiftModifier: 1, callLater(fn) { fn() }
  }
  const removed = []
  const answers = []
  let rows = []
  let opened = false
  const menu = {
    mode: 'menu', get dmenuActive() { return this.mode === 'select' || this.mode === 'input' },
    requestSerial: 0, applySerial: 0, requestActive: false, selectionFile: '', doneFile: '', dmenuPrompt: '',
    dmenuOptions: [], dmenuWidth: 300, dmenuMaxHeight: 0, activeMenu: 'root', pendingInitialMenu: 'root', navStack: [],
    filterText: '', selectedIndex: 0, cursorActive: true, fontFamily: '', deleteConfirmOpen: false, deleteTarget: null,
    items: { root: { kind: 'menu' }, apps: { kind: 'menu' } },
    appLibrary: { remove(appId) { removed.push(appId) }, refreshIcons() {} },
    item(id) { return this.items[id] || null },
    resolveRoute(input) { return input },
    rebuildDisplay() {
      rows = this.dmenuActive ? this.dmenuOptions.map(label => ({ label }))
        : this.activeMenu === 'apps' ? [{ kind: 'app', appId: 'notes.desktop', label: 'Notes' }]
        : [{ kind: 'menu', itemId: 'apps', label: 'Apps' }]
    },
    disarmPointer() {}, evaluateGuards() {}, invalidateVolatileProvider() {}, loadProviderForMenu() {},
    setActiveMenu() {}, rowSelectable() { return true }
  }
  const deleteConfirm = {
    selectedIndex: 1, get opened() { return menu.deleteConfirmOpen },
    canceled() { menu.cancelDelete() }, confirmed() { menu.confirmDelete() }
  }
  const context = {
    root: menu, deleteConfirm, Qt, JSON, Math, Number, String, Array,
    displayModel: { get count() { return rows.length }, get(index) { return rows[index] } },
    keyCatcher: { forceActiveFocus() {} },
    resultProc: { command: [], set running(value) { if (value) answers.push(this.command[2]) } },
    Util: { shellQuote: s => `'${s}'`, editsFilter: () => false }
  }
  Object.assign(menu, vm.runInNewContext(`(function() { with (root) {
    ${names.map(name => functionSource(menuQml, name)).join('\n')}
    return { ${names.join(', ')} } } })()`, context))
  const onOpenedChanged = vm.runInNewContext(`(function() { with (root) { ${menuQml.match(/onOpenedChanged: (.*)/)[1]} } })`, context)
  Object.defineProperty(menu, 'opened', {
    get() { return opened },
    set(value) { const changed = value !== opened; opened = value; if (changed) onOpenedChanged() }
  })
  deleteConfirm.handleKey = vm.runInNewContext(`(function() { with (root) {
    ${functionSource(confirmQml, 'handleKey')} return handleKey } })()`, { root: deleteConfirm, Qt })
  const keyHandler = vm.runInNewContext(`(function() { with (root) {
    return ${menuQml.match(/Keys\.onPressed: (function\(event\) \{[\s\S]*?\n        \})/)[1]} } })()`, context)
  const press = key => keyHandler({ key: Qt[key], modifiers: Qt.NoModifier, text: '' })
  contexts.push({ context, known: Object.keys(context) })

  menu.open(JSON.stringify({ menu: 'apps' }))
  press('Key_Delete')
  if (!menu.deleteConfirmOpen || menu.deleteTarget.appId !== 'notes.desktop') fail('uninstall confirmation harness raises the confirmation')
  return { menu, removed, answers, press }
}

const prompt = mode => JSON.stringify({ mode, prompt: 'Pick', options: ['apple', 'banana'], selectionFile: 'sel', doneFile: 'done' })

for (const [mode, label, typed, answer] of [['select', 'a select prompt', '', 'apple'], ['input', 'an input prompt', 'kiwi', 'kiwi']]) {
  const { menu, removed, answers, press } = menuHarness()
  menu.open(prompt(mode))
  assert(!menu.deleteConfirmOpen && menu.deleteTarget === null, `${label} summoned over an uninstall confirmation dismisses it`)
  menu.filterText = typed
  press('Key_Return')
  assertDeepEqual(removed, [], `Enter on ${label} summoned over an uninstall confirmation uninstalls nothing`)
  assertDeepEqual(answers, [`printf '%s\\n' '${answer}' > 'sel'; : > 'done'`], `Enter on ${label} summoned over an uninstall confirmation answers it`)
}

{
  const { menu, removed, press } = menuHarness()
  menu.open(JSON.stringify({ menu: 'root' }))
  assert(!menu.deleteConfirmOpen && menu.deleteTarget === null, 'a route summoned over an uninstall confirmation dismisses it')
  press('Key_Return')
  assertDeepEqual(removed, [], 'Enter on a route summoned over an uninstall confirmation uninstalls nothing')
}

{
  const { menu, removed, press } = menuHarness()
  press('Key_Return')
  assert(removed.join() === 'notes.desktop' && !menu.opened, 'Enter on the uninstall confirmation itself still uninstalls the app')
}

const strays = contexts.flatMap(({ context, known }) => Object.keys(context).filter(key => !known.includes(key)))
assertDeepEqual([...new Set(strays)], [], 'the harness leaks no unstubbed property into its scope')
JS
