#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const lockQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// An adjacency regex (`anchor[\s\S]*?anchor`) only proves that one occurrence
// follows another. It cannot prove that a destructive call does not *precede*
// the guard meant to stop it, which is the only thing that matters here: a
// destroy hoisted above the guard leaves the guard reading as present and doing
// nothing. Every ordering claim below is therefore made against a brace-matched
// function body, comparing the index of the guard against the index of the
// first destroy in that body.
function bodyOf(src, name, label) {
  const start = src.indexOf(`function ${name}(`)
  if (start === -1) fail(`${label}: source defines ${name}()`)
  const open = src.indexOf('{', start)
  let depth = 0
  for (let i = open; i < src.length; i++) {
    if (src[i] === '{') depth += 1
    else if (src[i] === '}') {
      depth -= 1
      if (depth === 0) return src.slice(open + 1, i)
    }
  }
  fail(`${label}: ${name}() has balanced braces`)
}

// ------------------------------------------------------------- _syncServices()
// unloadPluginServices() spares a keepLoaded service, so a plugin hot-reload no
// longer destroys the lock. _syncServices destroys services inline on its own,
// without going through unloadPluginServices() and without consulting
// keepLoaded, whenever the registry stops listing a plugin as installed,
// enabled and service-declaring. It is reached straight from pluginsChanged, so
// `omarchy plugin disable omarchy.lock` gets there with no reload at all.
// Comments stripped, so a guard commented out does not still answer for the code.
const sync = bodyOf(shellQml, '_syncServices', 'sync guard').replace(/\/\/[^\n]*/g, '')
// The teardown's own destroy; the capability-change branch above it destroys too.
const syncDestroy = sync.indexOf('inst.destroy()')

// Finding the property name is not enough: `inst.sessionLockOwned !== true`
// reads as present, sits before the destroy, and continues on exactly the
// services this guard exists for. Compare the whole condition.
const syncGuardMatch = sync.match(/if \((.+?)\) continue\s*\n\s*if \(inst && typeof inst\.destroy/)
assert(syncGuardMatch, '_syncServices guards the destroy with a skip that continues')
assertEqual(
  syncGuardMatch[1].trim(),
  'inst && inst.sessionLockOwned === true',
  'the skip fires when the instance owns the session lock -- not negated, not widened'
)
const syncGuard = syncGuardMatch.index

assert(syncDestroy !== -1, '_syncServices still destroys services for plugins that went away')
assert(
  syncGuard < syncDestroy,
  'no destroy in _syncServices runs before the ownership skip',
  `skip at ${syncGuard}, first destroy at ${syncDestroy}`
)

// Duck-typed, not keyed on the first-party plugin id, so a cloned lock plugin
// is covered as well. Comments are stripped so the prose above the guard, which
// names the id as an example, does not answer for the code.
const syncCode = sync.replace(/\/\/[^\n]*/g, '')
assert(
  !/omarchy\.lock/.test(syncCode),
  '_syncServices does not key the skip on the first-party lock id'
)

// The first-party lock is an authentication service, retained in
// AuthServiceStore rather than _services, so its teardown needs the same skip.
const authSkip = sync.indexOf('if (AuthServiceStore.ownsSessionLock(authenticationId)) continue')
const authDestroy = sync.indexOf('AuthServiceStore.destroy(authenticationId)')
assert(authSkip !== -1, '_syncServices skips an authentication service that owns the session lock')
assert(authDestroy !== -1, '_syncServices still destroys authentication services that went away')
assert(authSkip < authDestroy, 'no authentication-service destroy runs before the ownership skip')

// A published service that gains the authentication capability is destroyed
// and recreated in AuthServiceStore. A lock copy that owns the session lock
// must wait for a later sync instead. The reverse move needs no skip: the store
// keeps an id trusted for the life of the process, so a service it holds never
// loses the capability.
const gainSkip = sync.match(/if \((.+?)\) continue\s*\n\s*if \(published && typeof published\.destroy/)
assert(gainSkip, '_syncServices guards the capability-change destroy with a skip that continues')
assertEqual(
  gainSkip[1].trim(),
  'published && published.sessionLockOwned === true',
  'a published service gaining the authentication capability is kept while it owns the session lock'
)
const gainDestroy = sync.indexOf('published.destroy()')
assert(gainDestroy !== -1, '_syncServices still moves a service that gains the authentication capability')
assert(gainSkip.index < gainDestroy, 'no capability-change destroy runs before the ownership skip')

const vm = require('vm')
const store = {}
vm.createContext(store)
vm.runInContext(fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8'), store)
store.put('omarchy.lock', { sessionLockOwned: true, destroy() {} })
store.put('omarchy.polkit', { sessionLockOwned: false, destroy() {} })
assert(store.ownsSessionLock('omarchy.lock'), 'the store reports a service holding the session lock')
assert(!store.ownsSessionLock('omarchy.polkit'), 'the store does not report a service without the lock')
assert(!store.ownsSessionLock('missing'), 'the store does not report a service it does not hold')

// ------------------------------------------------------- unloadPluginServices()
// keepLoaded is read from the current registry, which has already dropped a
// lock plugin removed mid-lock, so the spare must also go by ownership. Without
// it the first reload after the removal leaves the lock alone and the second
// destroys it.
const unload = bodyOf(shellQml, 'unloadPluginServices', 'unload guard').replace(/\/\/[^\n]*/g, '')
const unloadSpare = unload.match(/if \((.+?)\) \{\s*\n\s*next\[existingId\] = inst/)
assert(unloadSpare, 'unloadPluginServices spares services into the next map')
assertEqual(
  unloadSpare[1].trim(),
  'serviceKeepLoaded(existingId) || (inst && inst.sessionLockOwned === true)',
  'unloadPluginServices spares a keepLoaded service or one that owns the session lock'
)
const unloadDestroy = unload.indexOf('inst.destroy()')
assert(unloadDestroy !== -1, 'unloadPluginServices still destroys services it does not spare')
assert(unloadSpare.index < unloadDestroy, 'no destroy in unloadPluginServices runs before the spare')

const unloadAuthSkip = unload.indexOf('if (AuthServiceStore.ownsSessionLock(authenticationId)) continue')
const unloadAuthDestroy = unload.indexOf('AuthServiceStore.destroy(authenticationId)')
assert(unloadAuthSkip !== -1, 'unloadPluginServices skips an authentication service that owns the session lock')
assert(unloadAuthDestroy !== -1, 'unloadPluginServices still destroys authentication services')
assert(unloadAuthSkip < unloadAuthDestroy, 'no authentication-service destroy in unloadPluginServices runs before the skip')

// ------------------------------------------------------ re-sync after unlock
// The skips above keep an unwanted lock service alive, so something has to
// collect it once the lock is gone, or its lock IPC target keeps answering.
// The lock service signals that from its wake's exit, not from sessionLockOwned
// changing: every unlock path gives up the lock before it starts the wake, and
// destroying the service kills a wake still in flight.
const ensure = bodyOf(shellQml, 'ensureService', 'unlock re-sync').replace(/\/\/[^\n]*/g, '')
const settleConnect = ensure.search(
  /if \("unlockSettled" in inst\)\s*\n\s*inst\.unlockSettled\.connect\(function\(\) \{ shell\.syncServicesAfterUnlock\(key, authenticationService\) \}\)/
)
assert(settleConnect !== -1, 'ensureService connects unlockSettled to the re-sync with the service id and map')
assert(
  settleConnect < ensure.indexOf('if (authenticationService) {'),
  'the re-sync is connected before a service goes to either map'
)

// Run the real body: every normal unlock emits unlockSettled, and a full
// _syncServices on each one would hand every third-party service a fresh
// manifest copy, so it must re-sync only for a service no longer wanted where
// it is -- and leave a reload in flight to do it.
const resync = new Function(
  'pluginId', 'authenticationService', 'pluginRegistry', 'shell', 'Qt',
  bodyOf(shellQml, 'syncServicesAfterUnlock', 'unlock re-sync')
)
function resyncs(opts) {
  let scheduled = false
  const registry = {
    installedPlugins: opts.installed === false ? {} : { 'omarchy.lock': {} },
    isEnabled: () => opts.enabled !== false,
  }
  const host = {
    pluginReloading: opts.reloading === true,
    isAuthenticationService: () => opts.nowAuthentication !== false,
    _syncServices() {},
  }
  resync('omarchy.lock', opts.placedAsAuthentication !== false, registry, host, {
    callLater(fn) { scheduled = fn === host._syncServices },
  })
  return scheduled
}
assert(!resyncs({}), 'an unlock of a service still wanted where it is does not re-sync')
assert(resyncs({ enabled: false }), 'an unlock of a disabled lock service re-syncs')
assert(resyncs({ installed: false }), 'an unlock of a removed lock service re-syncs')
assert(resyncs({ placedAsAuthentication: false }), 'an unlock of a lock service that gained the capability re-syncs')
assert(!resyncs({ enabled: false, reloading: true }), 'an unlock during a reload leaves the re-sync to the reload')

const lockCode = lockQml.replace(/\/\/[^\n]*/g, '')
assert(/signal unlockSettled\(\)/.test(lockCode), 'the lock service declares unlockSettled')
const wake = lockCode.match(/id: wakeProcess[\s\S]*?\n  \}/)
assert(wake, 'the lock service defines wakeProcess')
const settleEmit = wake[0].match(/onExited: if \((.+?)\) root\.unlockSettled\(\)/)
assert(settleEmit, 'the wake emits unlockSettled when it exits')
assertEqual(settleEmit[1].trim(), '!root.sessionLockOwned', 'unlockSettled fires only once the lock is released')
assertEqual(
  (lockCode.match(/(?<!signal )\bunlockSettled\(\)/g) || []).length,
  1,
  'unlockSettled is emitted only from the wake exit'
)

// A destroy can still land mid-wake (a plugin change right after unlock), and
// Quickshell kills the wake with the service. The service runs it again
// detached, and only then: a detached wake on the normal path would run twice.
assert(
  lockCode.includes('Component.onDestruction: if (wakeProcess.running) wakeProcess.startDetached()'),
  'the lock service reruns an interrupted wake detached when it is destroyed'
)
assertEqual((lockCode.match(/startDetached\(/g) || []).length, 1, 'the wake runs detached only from the destruction handler')

// ------------------------------------------------ one lock service per family
// Enabling, disabling or removing a clone while locked swaps which member of
// the clone family the registry wants, while the member holding the lock is
// kept. A second lock service mounted beside it finds the lock held, takes it
// for stranded and re-locks over it, which aborts in Quickshell. So
// ensureService refuses a family member while another member holds the lock,
// and records the family before it creates anything, so a removed clone still
// matches after its manifest is gone.
const familyBlock = ensure.indexOf('if (sessionLockHeldByFamily(key, family)) return null')
const familyRecord = ensure.indexOf('_serviceFamilies[key] = family')
const createAt = ensure.indexOf('Qt.createComponent(')
assert(
  ensure.includes('var family = Util.canonicalWidgetId(String(metadata && metadata.clonedFrom || key))'),
  "ensureService derives the family from the clone source, else the plugin's own id"
)
assert(familyBlock !== -1, 'ensureService refuses a family member while another member holds the lock')
assert(familyRecord !== -1, 'ensureService records the family of every service it creates')
assert(familyBlock < familyRecord && familyRecord < createAt, 'the family is checked, then recorded, before the service is created')

const heldByFamily = new Function(
  'pluginId', 'family', '_services', 'AuthServiceStore', '_serviceFamilies',
  bodyOf(shellQml, 'sessionLockHeldByFamily', 'family guard')
)
function held(pluginId, family, opts) {
  const auth = opts.auth || {}
  const store = {
    ids: () => Object.keys(auth),
    ownsSessionLock: (id) => auth[id] === true,
  }
  return heldByFamily(pluginId, family, opts.services || {}, store, opts.families || {})
}
assert(
  held('user.lock-clone', 'omarchy.lock', { auth: { 'omarchy.lock': true }, families: { 'omarchy.lock': 'omarchy.lock' } }),
  'a clone enabled while its source holds the lock waits'
)
assert(
  held('omarchy.lock', 'omarchy.lock', { auth: { 'user.lock-clone': true }, families: { 'user.lock-clone': 'omarchy.lock' } }),
  'a source restored while its clone holds the lock waits, even once the clone is removed'
)
assert(
  held('omarchy.lock', 'omarchy.lock', {
    services: { 'user.lock-copy': { sessionLockOwned: true } },
    families: { 'user.lock-copy': 'omarchy.lock' },
  }),
  'a published family member holding the lock blocks the rest of the family'
)
assert(
  !held('omarchy.polkit', 'omarchy.polkit', { auth: { 'omarchy.lock': true }, families: { 'omarchy.lock': 'omarchy.lock' } }),
  'a plugin outside the family is not held back'
)
assert(
  !held('omarchy.lock', 'omarchy.lock', { auth: { 'omarchy.lock': true }, families: { 'omarchy.lock': 'omarchy.lock' } }),
  'a service does not block itself'
)
assert(
  !held('user.lock-clone', 'omarchy.lock', { auth: { 'omarchy.lock': false }, families: { 'omarchy.lock': 'omarchy.lock' } }),
  'a family member that has let go of the lock blocks nothing'
)

// ------------------------------------------------- lock service: sessionLockOwned
// The signal the shell reads must be deterministic on a rebuilt service.
// sessionLock.secure resolves through the process-wide session-lock manager,
// which an earlier teardown can leave dangling, so the ownership property must
// not depend on it -- unlike `locked`, which deliberately still does.
const decl = lockQml.match(/readonly property bool sessionLockOwned:([^\n]*)/)
assert(decl, 'the lock service exposes sessionLockOwned for the shell to read')

const expr = decl[1].replace(/\/\/.*$/, '').replace(/\s+/g, ' ').trim()
const operands = expr.split('||').map((s) => s.trim()).sort()

// Token presence is not enough. `lockRequested && sessionLock.locked` contains
// both names and means the opposite; a `secure` term laundered through a helper
// property keeps the word off this line entirely. Compare the operand set.
assertEqual(
  JSON.stringify(operands),
  JSON.stringify(['lockRequested', 'sessionLock.locked']),
  'sessionLockOwned is exactly lockRequested OR sessionLock.locked -- no extra term, no conjunction'
)
assert(!/\bsecure\b/.test(expr), 'sessionLockOwned does not read sessionLock.secure')
JS
