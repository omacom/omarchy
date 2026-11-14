// Replayed history cards are forgotten only when dismissed or clicked.
// The service functions run against a fake model; persistence is the real Store.
const assert = require('node:assert')
const fs = require('node:fs')
const vm = require('node:vm')
const load = require('./loader.cjs')
const Store = load('Store')
const Security = load('Security')
const Delivery = load('Delivery')
const Markup = load('Markup')

const source = fs.readFileSync(load.dir + '/Service.qml', 'utf8')

function fn(name) {
  const m = source.match(new RegExp('^( *)function ' + name + '\\(.*$', 'm'))
  if (!m) throw new Error('Service.qml has no function ' + name)
  let text = m[0]
  const opens = text.split('{').length - 1
  if (!opens || opens > text.split('}').length - 1) {
    const end = source.indexOf('\n' + m[1] + '}', m.index)
    if (end < 0) throw new Error('Service.qml function ' + name + ' never closes')
    text = source.slice(m.index, end + m[1].length + 2)
  }
  return text.replace(/^( *function \w+\([^)]*\))\s*:\s*\w+/, '$1')
}

const names = [
  'durationFor', 'liveCount', 'reserveLive', 'releaseLive', 'nextKey', 'rowIndexFor',
  'keyForOriginal', 'handleNotification', 'watchNotification', 'showRow', 'release',
  'closeToast', 'closeToasts', 'unmarkLeaving', 'finishLeaving', 'finishClose', 'clearAll',
  'restoreRows', 'activate', 'invokeSenderAction',
  'storePut', 'storeClose', 'storeDrop', 'storeRecord', 'saveSoon',
  'currentHistory', 'replayHistory'
]

function scope() {
  const toasts = {
    rows: [],
    get count() { return this.rows.length },
    get(i) { return this.rows[i] },
    insert(i, row) { this.rows.splice(i, 0, { ...row }) },
    setProperty(i, role, value) { this.rows[i][role] = value },
    remove(i) { this.rows.splice(i, 1) }
  }
  const later = []
  const s = {
    toasts, refs: {}, refsRevision: 0, keySeed: 0, liveKeys: Object.create(null),
    maxLiveNotifications: 100, heights: {}, fresh: {}, leaving: {}, departures: {}, layoutRevision: 0,
    arriving: '', jumping: false, travel: 24, arriveDuration: 250, leaveDuration: 200, placements: {},
    held: [], doNotDisturb: false, replayCount: 6,
    liveEntries: [], historyEntries: [], replayedFromHistory: Object.create(null),
    unsaved: {}, liveLoaded: true, historyLoaded: true,
    saveTimer: { running: false, start() { this.running = true } },
    argvCalls: [],
    lowDuration: 5000, normalDuration: 8000, maxDuration: 30000,
    Security, Delivery, Store, Markup,
    NotificationUrgency: { Critical: 2, Normal: 1, Low: 0 },
    Qt: { callLater: f => later.push(f) },
    Util: { execArgv: argv => s.argvCalls.push(argv.slice()) },
    windowForPid: () => null,
    windowForSource: () => null,
    pinDeckDisplay() {},
    holding: () => false,
    snapshot: () => ({}),
    deckHeight: 0,
    retarget() {},
    land() {},
    layout: { placements: {} }
  }
  s.service = s
  vm.createContext(s)
  vm.runInContext(names.map(fn).join('\n'), s)
  s.drain = () => { while (later.length) later.shift()() }
  s.fakeNotification = (id = 0, summary = 'Synthetic', urgency = 1) => {
    let tracked = false, destroyed = false
    const signal = () => {
      const listeners = []
      return { connect: f => listeners.push(f), emit: () => listeners.slice().forEach(f => f()) }
    }
    const close = reason => {
      n.closeAttempts++
      if (destroyed) return
      destroyed = true
      tracked = false
      if (reason === 'expired') n.expiries++
      else n.dismissals++
      n.closed.emit()
    }
    const n = {
      id, summary, body: 'Synthetic body: ' + summary, urgency, appName: 'Fixture',
      actions: [], dismissals: 0, expiries: 0, closeAttempts: 0, closed: signal(),
      get tracked() { return tracked },
      set tracked(value) { if (value) tracked = true; else close('dismissed') },
      dismiss() { close('dismissed') },
      expire() { close('expired') }
    }
    for (const field of ['summary', 'body', 'appName', 'appIcon', 'image', 'urgency', 'expireTimeout', 'hints', 'actions'])
      n[field + 'Changed'] = signal()
    return n
  }
  s.admit = (...notes) => { for (const n of notes) s.handleNotification(n); s.drain() }
  return s
}

const plain = value => JSON.parse(JSON.stringify(value))
const now = Math.floor(Date.now() / 1000)

function row(partial) {
  return Object.assign({
    key: 'hist-old', originalId: 7, app: 'Signal', summary: 'Replayed',
    body: 'Test notification', urgency: 1, ts: 1000
  }, partial)
}

function closed(partial, reason, closedTs) {
  return Store.closedEntry(row(partial), reason || 'expired', closedTs)
}

function listed(entries) {
  return plain(entries).map(entry => ({
    key: entry.key, summary: entry.summary, closed_reason: entry.closed_reason,
    closed_ts: entry.closed_ts, originalId: entry.originalId
  }))
}

function cardFor(s, closedTs) {
  for (const card of s.toasts.rows) {
    const marker = s.replayedFromHistory[card.key]
    if (marker && marker.closed_ts === closedTs) return card.key
  }
  assert.fail('no replayed card for closed_ts ' + closedTs)
}

function replay(s, entries) {
  s.historyEntries = entries
  s.replayHistory()
  s.drain()
}

{ // Identity is key plus closed_ts, never the sender id on its own.
  const older = closed({ summary: 'Older' }, 'expired', now - 100)
  const later = closed({ summary: 'Later' }, 'expired', now - 10)
  const other = closed({ key: 'hist-other', summary: 'Other', ts: 500 }, 'dismissed', now - 50)
  const kept = Store.dropHistory([later, other, older], { key: 'hist-old', closed_ts: now - 100 })
  assert.deepEqual(listed(kept), listed([later, other]))
  const same = [other]
  assert.strictEqual(Store.dropHistory(same, { key: 'nope' }), same, 'a miss returns the same array')
  assert.strictEqual(Store.dropHistory(same, { key: 'hist-old', closed_ts: now - 100 }), same,
    'a different key is not removed')
}

{ // Dismissing a replayed card removes that history entry and nothing else.
  const s = scope()
  const older = closed({ summary: 'Replayed' }, 'expired', now - 100)
  const later = closed({ summary: 'Same key later' }, 'expired', now - 10)
  const other = closed({ key: 'hist-other', summary: 'Other closing', ts: 500 }, 'dismissed', now - 50)
  replay(s, [later, other, older])
  const fresh = s.fakeNotification(7, 'Fresh')
  s.admit(fresh)
  const freshKey = s.keyForOriginal(7)
  assert.notStrictEqual(freshKey, 'hist-old')
  assert.strictEqual(fresh.dismissals, 0)

  const card = cardFor(s, now - 100)
  assert.strictEqual(card, 'hist-old', 'the first replay keeps the history key')
  assert.ok(s.replayedFromHistory[card])
  s.finishClose(card, 'dismissed')

  assert.deepEqual(listed(s.historyEntries), listed([later, other]))
  assert.strictEqual(s.unsaved.history, true, 'the deletion is queued on the history save')
  assert.strictEqual(fresh.dismissals, 0, 'a live notification that reused the sender id is not closed')
  assert.deepEqual(s.liveEntries.map(entry => entry.summary), ['Fresh'])
  assert.ok(s.toasts.rows.some(card => card.summary === 'Fresh'))
  assert.ok(s.toasts.rows.some(card => card.summary === 'Same key later'))
  assert.strictEqual(s.replayedFromHistory[card], undefined)

  // A later close of the fresh notification must not write the forgotten entry back.
  s.finishClose(freshKey, 'dismissed')
  assert.strictEqual(fresh.dismissals, 1)
  const summaries = listed(s.historyEntries).map(entry => entry.summary)
  assert.ok(summaries.includes('Fresh'))
  assert.ok(!summaries.includes('Replayed'))
  assert.ok(summaries.includes('Same key later'))
  assert.ok(summaries.includes('Other closing'))
}

{ // Clicking a replayed card runs its command and removes the history entry.
  const s = scope()
  const entry = closed({
    summary: 'Open it',
    execArgv: JSON.stringify(['test-action', 'a b'])
  }, 'expired', now - 30)
  replay(s, [entry])
  const card = cardFor(s, now - 30)
  s.activate(card, true)
  s.drain()
  assert.deepEqual(s.argvCalls, [['test-action', 'a b']])
  assert.deepEqual(s.historyEntries, [])
}

{ // A replayed card with no command still leaves history when clicked.
  const s = scope()
  const entry = closed({ summary: 'Focus', app: 'Signal' }, 'expired', now - 30)
  replay(s, [entry])
  s.activate(cardFor(s, now - 30), true)
  s.drain()
  assert.deepEqual(s.argvCalls, [['omarchy-hyprland-focus-app', 'Signal']])
  assert.deepEqual(s.historyEntries, [])
}

{ // Expiry and a sender close leave the replayed history entry where it is.
  for (const reason of ['expired', 'closed']) {
    const s = scope()
    const entry = closed({ summary: 'Stays' }, 'expired', now - 30)
    replay(s, [entry])
    const before = JSON.stringify(s.historyEntries)
    const card = cardFor(s, now - 30)
    s.finishClose(card, reason)
    assert.strictEqual(JSON.stringify(s.historyEntries), before, reason)
    assert.strictEqual(s.replayedFromHistory[card], undefined, reason)
    assert.strictEqual(s.unsaved.history, undefined, reason)
  }
}

{ // Asking for history again does not throw the entry away, and dismissing
  // either copy then does. The second copy does not write it back.
  const s = scope()
  const entry = closed({ summary: 'Twice' }, 'dismissed', now - 30)
  replay(s, [entry])
  s.replayHistory()
  s.drain()
  assert.strictEqual(s.toasts.count, 2)
  assert.strictEqual(JSON.stringify(listed(s.historyEntries)), JSON.stringify(listed([entry])))
  s.finishClose(s.toasts.get(0).key, 'dismissed')
  assert.deepEqual(s.historyEntries, [])
  assert.strictEqual(s.toasts.count, 1)
  s.finishClose(s.toasts.get(0).key, 'dismissed')
  assert.deepEqual(s.historyEntries, [])
}

{ // A normal dismiss or click still moves the toast into history.
  const s = scope()
  const shown = s.fakeNotification(1, 'Shown')
  s.admit(shown)
  s.finishClose(s.keyForOriginal(1), 'dismissed')
  assert.strictEqual(shown.dismissals, 1)
  assert.deepEqual(s.liveEntries, [])
  assert.strictEqual(s.historyEntries[0].summary, 'Shown')
  assert.strictEqual(s.historyEntries[0].closed_reason, 'dismissed')

  const clicked = s.fakeNotification(2, 'Clicked')
  clicked.hints = { 'omarchy-exec-argv': JSON.stringify(['true']) }
  s.admit(clicked)
  s.activate(s.keyForOriginal(2), true)
  s.drain()
  assert.deepEqual(s.argvCalls, [['true']])
  assert.strictEqual(clicked.dismissals, 1)
  assert.strictEqual(s.historyEntries[0].summary, 'Clicked')
  assert.strictEqual(s.historyEntries[0].closed_reason, 'activated')
  assert.ok(s.historyEntries.some(entry => entry.summary === 'Shown'))
}

{ // Expiry of a normal toast still records history.
  const s = scope()
  const shown = s.fakeNotification(1, 'Timed out')
  s.admit(shown)
  s.finishClose(s.keyForOriginal(1), 'expired')
  assert.strictEqual(shown.expiries, 1)
  assert.strictEqual(shown.dismissals, 0)
  assert.strictEqual(s.historyEntries[0].closed_reason, 'expired')
}

{ // A toast restored after a shell restart is not a replay: dismissing it,
  // clicking it, or dismissing the whole stack still records history.
  const s = scope()
  const other = closed({ key: 'already', originalId: 9, summary: 'Already closed', ts: 500 }, 'expired', now - 40)
  s.historyEntries = [other]
  const restored = Store.persistable({
    key: 'restarted', originalId: 9, app: 'Mail', summary: 'From before', urgency: 1, ts: now - 5
  })
  s.liveEntries = [restored]
  s.restoreRows([restored], false)
  s.drain()
  assert.strictEqual(s.replayedFromHistory.restarted, undefined)
  s.finishClose('restarted', 'dismissed')
  assert.deepEqual(listed(s.historyEntries).map(entry => entry.summary + ':' + entry.closed_reason),
    ['From before:dismissed', 'Already closed:expired'])

  const clicked = Store.persistable({
    key: 'restart-click', originalId: 9, app: 'Mail', summary: 'Click after restart',
    execArgv: JSON.stringify(['restart-click']), urgency: 1, ts: now - 4
  })
  s.liveEntries = [clicked]
  s.restoreRows([clicked], false)
  s.drain()
  s.activate('restart-click', true)
  s.drain()
  assert.deepEqual(s.argvCalls, [['restart-click']])
  assert.ok(s.historyEntries.some(entry => entry.summary === 'Click after restart' && entry.closed_reason === 'activated'))
  assert.ok(s.historyEntries.some(entry => entry.summary === 'Already closed'))

  const stacked = Store.persistable({
    key: 'restart-all', originalId: 4, app: 'Mail', summary: 'Dismiss all', urgency: 1, ts: now - 3
  })
  s.liveEntries = s.liveEntries.concat([stacked])
  s.restoreRows([stacked], false)
  s.drain()
  s.clearAll('dismissed', true)
  s.drain()
  assert.ok(s.historyEntries.some(entry => entry.summary === 'Dismiss all' && entry.closed_reason === 'dismissed'))
  assert.ok(s.historyEntries.some(entry => entry.summary === 'Already closed'))
}

{ // Dismiss-all archives ordinary toasts, and forgets only a replayed card among them.
  const s = scope()
  s.admit(s.fakeNotification(1, 'One'), s.fakeNotification(2, 'Two'))
  s.clearAll('dismissed', true)
  s.drain()
  assert.deepEqual(s.liveEntries, [])
  assert.deepEqual(listed(s.historyEntries).map(entry => entry.summary + ':' + entry.closed_reason).sort(),
    ['One:dismissed', 'Two:dismissed'])

  const again = scope()
  const entry = closed({ summary: 'Brought back' }, 'expired', now - 15)
  replay(again, [entry])
  again.admit(again.fakeNotification(3, 'Still live'))
  again.clearAll('dismissed', true)
  again.drain()
  assert.deepEqual(listed(again.historyEntries).map(entry => entry.summary), ['Still live'])
  assert.strictEqual(again.historyEntries[0].closed_reason, 'dismissed')
}

{ // Do Not Disturb still records a silenced notification and drops an ephemeral one.
  const s = scope()
  s.doNotDisturb = true
  s.handleNotification(s.fakeNotification(1, 'While quiet'))
  const ephemeral = s.fakeNotification(2, 'Noise')
  ephemeral.appName = 'notify-send'
  s.handleNotification(ephemeral)
  s.drain()
  assert.deepEqual(s.toasts.rows, [])
  assert.deepEqual(listed(s.historyEntries).map(entry => entry.summary + ':' + entry.closed_reason),
    ['While quiet:silenced'])
}

console.log('notification dismissal: passed')
