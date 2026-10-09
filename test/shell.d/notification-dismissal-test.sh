#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const vm = require('vm')
const { execFileSync } = require('child_process')
const notifications = requireFromRoot('shell/plugins/notifications/NotificationLogic.js')
const source = fs.readFileSync(path.join(root, 'shell/plugins/notifications/Service.qml'), 'utf8')
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-notification-dismissal-'))

// Run the service's actual lifecycle functions and file jobs against scratch
// directories. Only the ListModel, live notification objects and Process
// scheduler are substituted; persistence commands run unchanged.
function lifecycle(label, operation, options = {}) {
  const directory = path.join(scratch, label)
  const popup = path.join(directory, 'live popups')
  const history = path.join(popup, 'history')
  const images = path.join(popup, 'images')
  fs.mkdirSync(history, { recursive: true })
  fs.mkdirSync(images, { recursive: true })
  const row = { id: 7, originalId: 7, timestamp: 1000, app: 'Signal', appIcon: '',
    summary: 'New message', body: 'Test notification', image: '', glyph: '',
    execArgv: options.action === 'argv' ? JSON.stringify(['test-action', 'a b']) : '',
    urgency: 1, expireTimeout: 8000 }
  const name = notifications.popupFileName(row)
  fs.writeFileSync(path.join(options.restored ? history : popup, name), JSON.stringify(row))
  const image = path.join(images, notifications.imageStem(row) + '-appIcon')
  fs.writeFileSync(image, 'persisted image')

  // A current notification reusing the restored popup's ID must survive.
  const unrelated = { ...row, timestamp: 2000 }
  const unrelatedName = notifications.popupFileName(unrelated)
  if (options.restored) fs.writeFileSync(path.join(popup, unrelatedName), JSON.stringify(unrelated))

  const rows = [row]
  const jobs = []
  const calls = { dismiss: 0, expire: 0, action: 0, focus: 0, argv: [] }
  const ref = { tracked: true, actions: [],
    dismiss() { calls.dismiss++ }, expire() { calls.expire++ } }
  if (options.action === 'default')
    ref.actions.push({ identifier: 'default', invoke() { calls.action++ } })
  const context = {
    NotificationLogic: notifications, NotificationUrgency: { Normal: 1, Low: 0 },
    popupStateDir: popup + '/', historyDir: history + '/', imagesDir: images + '/',
    historyLimit: 10, liveRefs: { 7: ref },
    restoredPopups: options.restored ? { [name]: true } : {},
    replayCarryOver: [row],
    popupModel: {
      get count() { return rows.length }, get(index) { return rows[index] },
      remove(index) { rows.splice(index, 1) }, insert(index, value) { rows.splice(index, 0, value) },
      append(value) { rows.push(value) }
    },
    enqueuePopupFileJob(command, done) { jobs.push({ command, done }) },
    focusApp() { calls.focus++ }, Util: { execArgv(argv) { calls.argv.push(argv) } },
    console
  }
  context.service = context
  vm.createContext(context)
  for (const property of ['trimHistoryScript', 'copyImagesScript']) {
    const match = source.match(new RegExp(`readonly property string ${property}:\\s*([\\s\\S]*?)\\n\\n`))
    context[property] = vm.runInContext(match[1], context)
  }
  for (const name of ['isRestoredRow', 'removePopup', 'dismissPopup', 'expirePopup',
    'clearPopups', 'forgetPopupFileFor', 'archivePopupFileFor', 'invokePopupDefault',
    'persistPopupFile', 'writeHistoryFile', 'replayHistory']) {
    const match = source.match(new RegExp(`^  function ${name}\\([^\\n]*\\) \\{[\\s\\S]*?^  \\}`, 'm'))
    if (!match) throw new Error('Missing service function: ' + name)
    vm.runInContext(match[0], context)
  }

  if (options.queuedWrite) context.persistPopupFile(row)
  if (operation === 'dismiss') context.dismissPopup(0)
  else if (operation === 'click') context.invokePopupDefault(0)
  else if (operation === 'all') context.clearPopups()
  else if (operation === 'replay') context.replayHistory('')
  else if (operation === 'silenced') context.writeHistoryFile(row)
  else context.expirePopup(0)

  while (jobs.length) {
    const { command, done } = jobs.shift()
    execFileSync(command[0], command.slice(1))
    if (done) done()
  }

  const keep = ['expire', 'replay', 'silenced'].includes(operation)
  assertEqual(fs.existsSync(path.join(history, name)), keep, label + ': history retention')
  assertEqual(fs.existsSync(image), keep, label + ': copied image retention')
  if (operation !== 'silenced')
    assert(!fs.existsSync(path.join(popup, name)), label + ': live persistence removed')
  if (options.restored) {
    assertEqual(calls.dismiss + calls.expire + calls.action, 0, label + ': unrelated live notification untouched')
    assert(fs.existsSync(path.join(popup, unrelatedName)), label + ': unrelated persistence untouched')
  } else if (operation !== 'silenced') {
    assertEqual(calls.expire, operation === 'expire' ? 1 : 0, label + ': server expiry')
    assertEqual(calls.dismiss, operation === 'expire' ? 0 : 1, label + ': server dismissal')
  }
  if (options.action === 'argv')
    assertDeepEqual(calls.argv, [['test-action', 'a b']], label + ': click argv preserved')
  if (options.action === 'default') assertEqual(calls.action, 1, label + ': default action invoked')
  if (operation === 'replay') {
    assertEqual(rows.length, 1, label + ': notification replayed')
    assert(context.restoredPopups[name], label + ': replay marked as restored')
  }
}

try {
  lifecycle('manual close', 'dismiss')
  lifecycle('click with focus fallback', 'click')
  lifecycle('click with argv action', 'click', { action: 'argv' })
  lifecycle('click with libnotify action', 'click', { action: 'default' })
  lifecycle('automatic timeout', 'expire')
  lifecycle('restored manual close', 'dismiss', { restored: true })
  lifecycle('restored click', 'click', { restored: true })
  lifecycle('restored timeout', 'expire', { restored: true })
  lifecycle('close before persistence completes', 'dismiss', { queuedWrite: true })
  lifecycle('dismiss all', 'all')
  lifecycle('history replay preserves live notification', 'replay')
  lifecycle('DND history remains available', 'silenced')
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}
JS
