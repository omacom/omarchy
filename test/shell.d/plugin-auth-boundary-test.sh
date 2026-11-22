#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell_qml="$ROOT/shell/shell.qml"
bar_qml="$ROOT/shell/plugins/bar/Bar.qml"
plugin_shell_api="$ROOT/shell/services/PluginShellApi.qml"
idle_service="$ROOT/shell/plugins/services/idle/Service.qml"

# Normalize horizontal and vertical whitespace so the wiring assertions survive
# harmless QML reflow. The runtime fixture below behaviorally covers
# PluginShellApi and AuthServiceStore; these checks remain the guard for their
# integration through shell.qml and Bar.qml, including without a compositor.
qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

qml_matches "$shell_qml" 'comp\.createObject\( *manifest\.__isFirstParty *&& *!authenticationService *\? *serviceHost *: *null *\)' ||
  fail "third-party and authentication services are detached from the host object tree"
qml_matches "$shell_qml" 'AuthServiceStore\.put\( *key, *inst *\)' ||
  fail "authentication services are retained outside the host service map"
qml_matches "$shell_qml" 'AuthServiceStore\.isTrusted\( *key *\)' ||
  fail "live authentication classification survives public manifest mutation"
qml_matches "$shell_qml" 'AuthServiceStore\.updateManifest\( *id, *shell\.publicPluginManifest\( *m *\) *\)' ||
  fail "kept authentication services receive only a public manifest snapshot"
qml_matches "$shell_qml" 'if *\( *!serviceKeepLoaded\( *authenticationId *\) *\) *AuthServiceStore\.destroy\( *authenticationId *\)' ||
  fail "keepLoaded authentication services survive plugin rescans"
pass "third-party and authentication services are detached from the host object tree"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const store = {}
vm.createContext(store)
vm.runInContext(
  fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8'),
  store
)
const service = { destroy() {} }
store.put('omarchy.lock', service)
store.destroy('omarchy.lock')
assert(
  !store.has('omarchy.lock') && store.isTrusted('omarchy.lock'),
  'authentication classification survives service teardown'
)
JS

qml_matches "$shell_qml" 'inst\.shell *= *shell\.pluginShellFor\( *manifest *\)' ||
  fail "service plugins receive a scoped shell facade"
qml_matches "$shell_qml" 'item\.shell *= *shell\.pluginShellFor\( *panelEntry\.manifest *\)' ||
  fail "panel plugins receive a scoped shell facade"
qml_matches "$shell_qml" 'target\.shell *= *shell\.pluginShellFor\( *manifest *\)' ||
  fail "full-bar plugins receive a scoped shell facade"
pass "third-party entry points receive scoped shell facades"

if qml_matches "$plugin_shell_api" 'function +pluginShellForId\('; then
  fail "replacement-bar facade exposes a generic plugin-shell factory"
fi
qml_matches "$bar_qml" 'else if *\( *root\.shell *&& *typeof root\.shell\.pluginShellForBarEntry *=== *"function" *\) *\{[^}]*pluginShell *= *root\.shell\.pluginShellForBarEntry\( *key, *moduleName *\)' ||
  fail "replacement bars do not fall back to a service-less entry facade"
pass "replacement bars cannot manufacture another plugin's service facade"

qml_matches "$shell_qml" 'target\.barConfig *= *shell\.barConfigFor\( *manifest *\)' ||
  fail "initial replacement-bar configuration is not detached"
qml_matches "$shell_qml" 'bar\.barConfig *= *shell\.barConfigFor\( *shell\.activeBarManifest *\)' ||
  fail "replacement-bar configuration updates are not detached"
pass "replacement bars receive detached configuration snapshots"

qml_matches "$bar_qml" 'target\.bar *= *firstParty *\? *root *: *root\.pluginBarApiFor\( *pluginApiId, *moduleName, *registered *\)' ||
  fail "third-party widgets receive a bar facade instead of the host bar"
qml_matches "$bar_qml" 'api\.clickTargets *= *root\.pluginClickTargets\( *api\.pluginId *\)' ||
  fail "third-party bar facades exclude other widgets from their object graph"
pass "third-party widgets receive a bar facade instead of the host bar"

qml_matches "$shell_qml" 'widgets: *shell\.publicBarWidgetSnapshot\( *\)' ||
  fail "third-party widget registries receive detached snapshots"
qml_matches "$bar_qml" 'root\.markPluginObject\( *pluginId, *target, *"clickTarget" *\)' ||
  fail "third-party bar-object ownership is stamped by the host callback"
qml_matches "$bar_qml" 'root\.markPluginObject\( *pluginId, *owner, *"popout" *\)' ||
  fail "owner-less popouts receive trusted ownership before activation"
qml_matches "$shell_qml" 'manifest\.__hostCapabilities\.indexOf\( *"authentication" *\)' ||
  fail "authentication isolation follows host-stamped capabilities"
pass "registry mutation and ownership boundaries are host-controlled"

qml_matches "$bar_qml" 'root\.moduleWidgets\( *moduleName *\)' ||
  fail "custom bar module widget lookups use their real module name"
qml_matches "$shell_qml" 'shell\.pluginShellForBarEntry\( *cacheKey *\+ *":" *\+ *ownerId, *moduleName *\)' ||
  fail "full-bar plugins receive a scoped settings facade for custom modules"
pass "custom bar modules retain settings and popout identity"

if qml_matches "$bar_qml" 'on(Foreground|BarForeground|Background|Urgent|FontFamily|Vertical|BarSize|Transparent)Changed: *sync'; then
  fail "animated scalar properties still trigger full facade resyncs"
fi
qml_matches "$bar_qml" 'api\.foreground *= *Qt\.binding\( *function\( *\) *\{ *return root\.foreground *\} *\)' ||
  fail "third-party bar scalar mirrors use bindings"
qml_matches "$shell_qml" 'shell\.prunePluginApis\( *\)' ||
  fail "disabled plugin facade caches are pruned"
pass "plugin facade synchronization is bounded"

qml_matches "$shell_qml" 'descriptor\.profile *!== *expectedProfile[^}]*shell\.revokePluginShellApi\( *shellKey *\)' ||
  fail "manifest capability changes do not revoke cached plugin facades"
qml_matches "$shell_qml" 'shell\.barPluginMayControl\( *currentManifest\( *\), *requestedId *\)' ||
  fail "bar lifecycle callbacks do not validate the current manifest"
qml_matches "$shell_qml" 'return hasCurrentBarCapabilities\( *\) *\? *shell\.mutatePluginBarConfig\( *mutator *\) *: *false' ||
  fail "bar configuration mutation does not validate the current manifest"
pass "manifest changes revoke cached facade capabilities"

qml_matches "$shell_qml" 'idleConfig: *shell\.publicIdleConfigFor\( *manifest *\)' ||
  fail "cloned idle services do not receive their configured timeouts"
qml_matches "$shell_qml" 'shellApi\.idleConfig *= *shell\.publicIdleConfigFor\( *shellManifest *\)' ||
  fail "cloned idle service configuration does not refresh"
qml_matches "$idle_service" 'shell *&& *shell\.idleConfig *\? *shell\.idleConfig *: *\(\{\}\)' ||
  fail "the idle service does not consume its scoped configuration"
bar_entry_shell=$(sed -n '/^  function pluginShellForBarEntry(/,/^  function pluginShellFor(/p' "$shell_qml")
tr '\n\r\t' '   ' <<<"$bar_entry_shell" |
  grep -Eq 'var id *= *shell\.pluginRegistry\.resolveEnabledId\( *target *\)[^}]*return shell\.pluginRegistry\.installedPlugins\[id\] *\|\| *null' ||
  fail "replacement-bar clone authorization does not follow the enabled implementation"
tr '\n\r\t' '   ' <<<"$bar_entry_shell" |
  grep -Eq 'shell\.pluginCloneMaySummon\( *currentManifest\( *\), *requestedId *\)' ||
  fail "built-in clones in replacement bars cannot summon their existing auxiliary UI"
qml_matches "$shell_qml" 'shell\.pluginCloneMaySummon\( *currentManifest\( *\), *requestedId *\)' ||
  fail "built-in clones cannot summon their existing auxiliary UI"
qml_matches "$shell_qml" '"omarchy\.media": *\["omarchy\.osd"\]' ||
  fail "media clones cannot summon their existing OSD target"
qml_matches "$shell_qml" '"omarchy\.network": *\["omarchy\.speedtest", *"omarchy\.wifiqr"\]' ||
  fail "network clones cannot summon their existing auxiliary panels"
pass "built-in service and widget clones retain narrow configuration and UI integration"

qml_matches "$shell_qml" 'shell\.serviceFor\( *shell\.pluginRegistry\.resolveEnabledId\( *id *\) *\)' ||
  fail "narrow first-party service proxies do not resolve enabled clones"
qml_matches "$shell_qml" 'return serviceFor\( *shell\.pluginRegistry\.resolveEnabledId\( *pluginId *\) *\)' ||
  fail "trusted first-party service lookups do not resolve enabled clones"
qml_matches "$shell_qml" 'allowOwnService *&& *shell\.pluginOwnsTarget\( *key, *requestedId *\)[^}]*return shell\.pluginServiceFor\( *key, *requestedId *\)' ||
  fail "cloned widgets cannot use a source id to reach their own service"
pass "service facades resolve enabled clones without widening replacement-bar access"

require_quickshell "plugin authentication boundary runtime test"

run_qml_fixture plugin-auth-boundary "plugin authentication boundary runtime behavior" services

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const storeSource = fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8')

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

// Run the host's real lifecycle functions with observable service objects.
function lifecycle() {
  const store = vm.createContext({})
  vm.runInContext(storeSource, store)
  const host = vm.createContext({
    _services: {}, _serviceFamilies: {}, _familyMountDeferred: false,
    pluginReloading: false, AuthServiceStore: store,
    pluginRegistry: {
      installedPlugins: {}, disabled: new Set(),
      isEnabled(id) { return !this.disabled.has(id) },
      entryPointUrl(manifest) { return manifest.id },
    },
    Util: { isPlainObject: value => !!value, canonicalWidgetId: value => value },
    Component: { Ready: 1, Loading: 2, PreferSynchronous: 0 },
    created: {}, pending: [],
    publicPluginManifest: manifest => manifest,
  })
  host.shell = host
  host.Qt = {
    callLater(fn) { host.pending.push(fn) },
    createComponent(url) {
      return { status: 1, createObject() {
        const callbacks = []
        const inst = {
          sessionLockOwned: false, destroyed: false,
          unlockSettled: { connect(fn) { callbacks.push(fn) } },
          unlock() {
            this.sessionLockOwned = false
            callbacks.forEach(fn => fn())
          },
          destroy() { this.destroyed = true },
        }
        host.created[url] = inst
        return inst
      } }
    },
  }
  for (const name of ['isAuthenticationService', 'sessionLockHeldByFamily', 'ensureService',
      '_syncServices', 'serviceKeepLoaded', 'unloadPluginServices', 'syncServicesAfterUnlock']) {
    const args = shellQml.match(new RegExp(`function ${name}\\(([^)]*)\\)`))[1]
    vm.runInContext(`function ${name}(${args}) {${bodyOf(shellQml, name, name)}}`, host)
  }
  host.install = (id, authentication, family) => {
    host.pluginRegistry.installedPlugins[id] = {
      id, kinds: ['service'], entryPoints: { service: 'Service.qml' },
      __hostCapabilities: authentication ? ['authentication'] : [],
      omarchy: family ? { clonedFrom: family } : {},
    }
  }
  host.drain = () => { while (host.pending.length) host.pending.shift()() }
  return host
}

for (const authentication of [false, true]) {
  for (const change of ['disable', 'remove', 'drop-service']) {
    const host = lifecycle()
    const id = 'user.lock-copy'
    host.install(id, authentication)
    host._syncServices()
    const lock = host.created[id]
    lock.sessionLockOwned = true
    if (change === 'disable') host.pluginRegistry.disabled.add(id)
    if (change === 'remove') delete host.pluginRegistry.installedPlugins[id]
    if (change === 'drop-service') host.pluginRegistry.installedPlugins[id].kinds = ['panel']
    host._syncServices()
    host.unloadPluginServices()
    host.unloadPluginServices()
    assert(!lock.destroyed, `${authentication ? 'private' : 'published'} owner survives ${change} and repeated reloads`)
    lock.unlock()
    host.drain()
    assert(lock.destroyed, `${authentication ? 'private' : 'published'} owner is collected after ${change} and unlock`)
  }
  const host = lifecycle()
  host.install('user.unlocked', authentication)
  host._syncServices()
  const unlocked = host.created['user.unlocked']
  delete host.pluginRegistry.installedPlugins['user.unlocked']
  host._syncServices()
  assert(unlocked.destroyed, 'an unlocked removed service is collected without waiting')
  host.install('user.keep', authentication)
  host.pluginRegistry.installedPlugins['user.keep'].keepLoaded = true
  host._syncServices()
  host.unloadPluginServices()
  assert(!host.created['user.keep'].destroyed, 'reload still retains a keepLoaded service without lock ownership')
}

const moving = lifecycle()
moving.install('user.moving', false)
moving._syncServices()
const published = moving.created['user.moving']
published.sessionLockOwned = true
moving.pluginRegistry.installedPlugins['user.moving'].__hostCapabilities = ['authentication']
moving._syncServices()
assert(!published.destroyed && !moving.AuthServiceStore.has('user.moving'), 'gaining authentication defers migration while locked')
published.unlock()
moving.drain()
assert(published.destroyed && moving.AuthServiceStore.has('user.moving') && !moving._services['user.moving'], 'unlock moves the service into private storage')

for (const authentication of [false, true]) {
  const host = lifecycle()
  host.install('user.holder', authentication, 'omarchy.lock')
  host._syncServices()
  const holder = host.created['user.holder']
  holder.sessionLockOwned = true
  host.install('user.waiting', authentication, 'omarchy.lock')
  host._syncServices()
  assert(!host.created['user.waiting'] && host._familyMountDeferred, 'a sibling is not created while its family owns the lock')
  holder.unlock()
  host.drain()
  assert(!!host.created['user.waiting'] && !host._familyMountDeferred, 'unlock retries the refused sibling even when the holder stays enabled')
  host.unloadPluginServices()
  assert(host.created['user.waiting'].destroyed, 'reload collects an unlocked service without keepLoaded')
}

const store = lifecycle().AuthServiceStore
store.put('legacy.locked', { locked: true })
store.put('legacy.unlocked', { locked: false })
store.put('current.released', { sessionLockOwned: false, locked: true })
assert(store.ownsSessionLock('legacy.locked'), 'a legacy clone can report ownership through locked')
assert(!store.ownsSessionLock('legacy.unlocked'), 'an unlocked legacy clone reports no ownership')
assert(!store.ownsSessionLock('current.released'), 'explicit ownership outranks legacy locked state')
assert(!store.ownsSessionLock('missing'), 'an absent service owns no lock')

const resync = new Function(
  'pluginId', 'authenticationService', 'pluginRegistry', 'shell', 'Qt',
  bodyOf(shellQml, 'syncServicesAfterUnlock', 'unlock re-sync')
)
function resyncs(opts) {
  let scheduled = false
  const registry = {
    installedPlugins: opts.installed === false ? {} : {
      'omarchy.lock': opts.serviceDropped === true
        ? { kinds: ['bar-widget'], entryPoints: {} }
        : { kinds: ['service'], entryPoints: { service: 'Service.qml' } },
    },
    isEnabled: () => opts.enabled !== false,
  }
  const host = {
    pluginReloading: opts.reloading === true,
    _familyMountDeferred: opts.familyMountDeferred === true,
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
assert(resyncs({ serviceDropped: true }), 'an unlock of a lock plugin that no longer declares a service re-syncs')
assert(resyncs({ placedAsAuthentication: false }), 'an unlock of a lock service that gained the capability re-syncs')
assert(!resyncs({ enabled: false, reloading: true }), 'an unlock during a reload leaves the re-sync to the reload')
assert(
  resyncs({ familyMountDeferred: true }),
  'an unlock of a service still wanted re-syncs when a family member was refused while it held the lock'
)

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

JS
