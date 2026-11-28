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

# Exercise the real scoped-shell and service-proxy factories, including cache
# reuse and live revocation, without depending on the user's service state.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const clone = {id: 'tester.indicators', kinds: ['bar-widget'], omarchy: {clonedFrom: 'omarchy.indicators'}}
let enabled = true
const services = {
  'omarchy.idle': {stayAwake: false, setIdleEnabled(value) { this.stayAwake = !value }},
  'omarchy.nightlight': {enabled: false, setNightlight(value) { this.enabled = value }},
  'omarchy.notifications': {doNotDisturb: false, setDoNotDisturb(value) { this.doNotDisturb = value }},
  'omarchy.remote-session': {active: true, peers: ['test-peer']},
  'omarchy.media': {}
}
function object(props) {
  return new Proxy({...props, destroy() { this.destroyed = true }}, {
    set(target, key, value) {
      if (value && typeof value.binding === 'function') Object.defineProperty(target, key, {get: value.binding, configurable: true})
      else target[key] = value
      return true
    }
  })
}
const scope = {
  pluginRegistry: {installedPlugins: {[clone.id]: clone}, isEnabled: () => enabled, resolveEnabledId: id => id},
  Util: {isPlainObject: value => !!value && typeof value === 'object' && !Array.isArray(value)},
  Qt: {binding: get => ({binding: get})},
  serviceFor: id => services[id], pluginOwnsTarget: () => false,
  pluginBarStateFor: () => ({}), publicBarConfig: () => ({}), publicIdleConfigFor: () => ({}),
  pluginShellApiComponent: {createObject: (parent, props) => object(props)},
  pluginFirstPartyServiceApiComponent: {createObject(parent, props) {
    assertEqual(parent, null, 'service proxies have no host parent')
    return object(props)
  }}
}
scope.shell = scope
for (const cache of ['Shell', 'Registry', 'BarWidgetRegistry', 'AppLibrary', 'BarState', 'FirstPartyService', 'BarEntryShell']) {
  scope['_plugin' + cache + 'Apis'] = {}
}
// Descriptors have a separate name from the QObject caches.
scope._pluginShellApiDescriptors = {}
vm.createContext(scope)
for (const name of ['manifestHasKind', 'pluginHasBarCapabilities', 'pluginFirstPartyServiceIds', 'pluginFirstPartyServiceFor',
  'pluginShellCapabilityProfile', 'createScopedPluginShell', 'cacheWithoutKey', 'cacheWithoutPrefix', 'revokePluginShellApi', 'pluginApiActive', 'prunePluginApis']) {
  const fn = source.match(new RegExp('  function ' + name + String.raw`\([^]*?\n  \}`))
  if (fn) vm.runInContext(fn[0], scope)
}
const api = scope.createScopedPluginShell(clone, clone.id, true, false)
for (const id of ['omarchy.idle', 'omarchy.nightlight', 'omarchy.notifications', 'omarchy.remote-session']) {
  const proxy = api._firstPartyServiceLookup(id)
  assert(proxy && proxy !== services[id], 'indicator clones get a narrow proxy for ' + id)
}
const idle = api._firstPartyServiceLookup('omarchy.idle')
idle._setIdleEnabled(false)
assert(idle.stayAwake, 'stay-awake changes reach the clone')
const nightlight = api._firstPartyServiceLookup('omarchy.nightlight')
nightlight._setNightlight(true)
assert(nightlight.enabled, 'night-light changes reach the clone')
const dnd = api._firstPartyServiceLookup('omarchy.notifications')
dnd._setDoNotDisturb(true)
assert(dnd.doNotDisturb && services['omarchy.notifications'].doNotDisturb, 'the DND proxy forwards changes and follows live state')
assert(api._firstPartyServiceLookup('omarchy.remote-session').active, 'remote-session activity reaches the clone')
for (const id of ['omarchy.media', 'omarchy.lock', 'omarchy.polkit']) {
  assertEqual(api._firstPartyServiceLookup(id), null, 'indicator clones cannot reach ' + id)
}
assertEqual(api._mutateBarConfig(() => {}), false, 'indicator clones do not gain bar configuration control')
assertEqual(api, scope.createScopedPluginShell(clone, clone.id, true, false), 'the service-capable facade is reused')
scope.prunePluginApis()
assert(!api.destroyed && !dnd.destroyed, 'normal pruning keeps the indicator service profile alive')
enabled = false
dnd._setDoNotDisturb(false)
assert(services['omarchy.notifications'].doNotDisturb, 'a retained proxy cannot act while its owner is disabled')
enabled = true
scope.pluginRegistry.installedPlugins[clone.id] = {...clone, omarchy: undefined}
assertEqual(api._firstPartyServiceLookup('omarchy.notifications'), null, 'withdrawing clone metadata revokes new lookups immediately')
dnd._setDoNotDisturb(false)
assert(services['omarchy.notifications'].doNotDisturb, 'a retained proxy cannot act after clone metadata is withdrawn')
scope.prunePluginApis()
assert(api.destroyed && dnd.destroyed, 'pruning destroys facades whose clone service scope changed')
const ordinary = scope.createScopedPluginShell(scope.pluginRegistry.installedPlugins[clone.id], clone.id, true, false)
assertEqual(ordinary._firstPartyServiceLookup('omarchy.nightlight'), null, 'ordinary bar widgets receive no indicator services')
const bar = {id: 'tester.bar', kinds: ['bar']}
scope.pluginRegistry.installedPlugins[bar.id] = bar
const barApi = scope.createScopedPluginShell(bar, bar.id, true, true)
assert(barApi._firstPartyServiceLookup('omarchy.media'), 'replacement bars retain their existing media proxy')
assertEqual(barApi._firstPartyServiceLookup('omarchy.lock'), null, 'replacement bars still cannot reach authentication services')
JS

require_quickshell "plugin authentication boundary runtime test"

run_qml_fixture plugin-auth-boundary "plugin authentication boundary runtime behavior" services
