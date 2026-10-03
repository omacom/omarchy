#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const auth = {}
vm.createContext(auth)
vm.runInContext(fs.readFileSync(path.join(root, 'shell/services/AuthServiceStore.js'), 'utf8'), auth)

const created = []
const pending = []
const disabled = new Set()
let delayedUrl = ''
const trustedApi = { trusted: true }
const scopedApi = { trusted: false }
const host = {
  console,
  AuthServiceStore: auth,
  _services: {},
  _serviceProvenance: {},
  serviceHost: {},
  omarchyPath: '/checkout',
  Component: { Ready: 1, Loading: 2, PreferSynchronous: 0 },
  pluginRegistry: {
    installedPlugins: {},
    isEnabled(id) { return !disabled.has(id) },
    resolveEnabledId(id) { return id },
    entryPointUrl(manifest) { return manifest.__sourceDir + '/' + manifest.entryPoints.service }
  },
  pluginShellFor(manifest) { return manifest.__isFirstParty ? trustedApi : scopedApi },
  _pluginRegistryApis: {},
  _pluginRegistryApiSources: {},
  _pluginShellApis: {},
  _pluginShellApiDescriptors: {},
  _pluginBarWidgetRegistryApis: {},
  _pluginBarWidgetRegistryApiSources: {},
  _pluginAppLibraryApis: {},
  _pluginBarStateApis: {},
  _pluginFirstPartyServiceApis: {},
  _pluginBarEntryShellApis: {},
  _pluginBarEntryShellApiOwners: {},
  pluginShellApiComponent: { createObject(_parent, properties) {
    return { ...properties, destroyed: false, destroy() { this.destroyed = true } }
  } },
  pluginBarWidgetRegistryApiComponent: { createObject(_parent, properties) {
    return { ...properties, destroyed: false, destroy() { this.destroyed = true } }
  } },
  barWidgetRegistry: { revision: 1 },
  publicBarWidgetSnapshot() { return { fresh: { metadata: {} } } },
  pluginBarStateFor() { return {} },
  publicBarConfig() { return {} },
  publicIdleConfigFor() { return {} },
  manifestHasKind(value, kind) { return value.kinds.includes(kind) },
  pluginHasBarCapabilities(value) { return !!value && value.kinds.includes('bar') },
  pluginServiceFor(_owner, requestedId) { return host._services[requestedId] || null },
  barEntryConfigured() { return true },
  pluginRegistryFor() { return {} },
  Qt: {
    createComponent(url) {
      const component = {
        status: url === delayedUrl ? 2 : 1,
        statusChanged: { connect(callback) { pending.push(() => { component.status = 1; callback() }) } },
        createObject(parent) {
          const service = {
            url, parent, manifest: null, destroyed: false, everTrusted: false,
            destroy() { this.destroyed = true }
          }
          Object.defineProperty(service, 'shell', {
            set(value) { this.everTrusted ||= value.trusted },
            get() { return null }
          })
          created.push(service)
          return service
        }
      }
      return component
    }
  }
}
host.shell = host
vm.createContext(host)
for (const name of ['publicPluginManifest', 'pluginShellCapabilityProfile', 'cacheWithoutKey', 'cacheWithoutPrefix', 'revokePluginShellApi', 'createScopedPluginShell', 'pluginShellForBarEntry', 'pluginBarWidgetRegistryFor', 'pluginApiActive', 'prunePluginApis', 'syncPluginApis', 'isAuthenticationService', 'pluginSourceProvenance', 'serviceProvenance', 'ensureService', '_syncServices', 'serviceKeepLoaded', 'unloadPluginServices']) {
  const match = source.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))
  assert(!!match, `host defines ${name}`)
  vm.runInContext(match[0], host)
}

function manifest(id, sourceDir, trusted, entryPoint = 'Service.qml', authentication = false) {
  return {
    id, __sourceDir: sourceDir, __isFirstParty: trusted,
    __hostCapabilities: authentication ? ['authentication'] : [],
    kinds: ['service'], entryPoints: { service: entryPoint }, keepLoaded: true
  }
}
function select(value) {
  host.pluginRegistry.installedPlugins[value.id] = value
  host._syncServices()
  return host._services[value.id]
}

const id = 'omacom.demo'
const personalManifest = manifest(id, '/home/plugins/demo', false)
const home = select(personalManifest)
const oldApi = host.createScopedPluginShell(personalManifest, id, true, false)
const staleLookup = oldApi._serviceLookup
assert(staleLookup(id) === home, 'personal service can look up its own instance while selected')
home.manifest.__sourceDir = '/data/plugins/demo'
home.manifest.__isFirstParty = true
host.unloadPluginServices()
const facade = { pluginId: id, destroyed: false, destroy() { this.destroyed = true } }
Object.defineProperty(facade, 'manifest', {
  set(value) { if (value) value.__sourceDir = '/home/plugins/demo' }
})
host._pluginRegistryApis[id] = facade
host._pluginRegistryApiSources[id] = '/home/plugins/demo'
const packagedManifest = manifest(id, '/data/plugins/demo', true)
host.pluginRegistry.installedPlugins[id] = packagedManifest
host.syncPluginApis()
host._syncServices()
const packaged = host._services[id]
assert(facade.destroyed && !host._pluginRegistryApis[id],
  'personal registry facade is revoked before trusted replacement is published')
assertEqual(packagedManifest.__sourceDir, '/data/plugins/demo',
  'old facade callback cannot rewrite the trusted replacement source')
assert(packaged !== home && home.destroyed && !home.everTrusted,
  'kept HOME service is replaced before packaged host privileges are assigned')
assert(staleLookup(id) === null,
  'old service callback cannot resolve the trusted replacement after source and trust change')
assertEqual(packaged.url, '/data/plugins/demo/Service.qml', 'replacement loads packaged implementation')
assert(packaged.everTrusted, 'packaged replacement receives trusted host APIs')
host.unloadPluginServices()
assert(select(manifest(id, '/data/plugins/demo', true)) === packaged,
  'unchanged packaged keepLoaded service survives rescan')
const restored = select(manifest(id, '/home/plugins/demo', false))
assert(restored !== packaged && packaged.destroyed && !restored.everTrusted,
  'HOME override replaces the packaged service with an untrusted instance')
const trustOnly = select(manifest(id, '/home/plugins/demo', true))
assert(trustOnly !== restored && restored.destroyed && !restored.everTrusted,
  'trust change recreates a service even when its source URL is unchanged')
const entryPoint = select(manifest(id, '/home/plugins/demo', true, 'Other.qml'))
assert(entryPoint !== trustOnly && trustOnly.destroyed,
  'entrypoint change recreates a kept service within the same source directory')

const plainId = 'acme.transition'
const plainHome = select(manifest(plainId, '/home/plugins/plain', false))
const plainFacade = { pluginId: plainId, destroyed: false, destroy() { this.destroyed = true } }
host._pluginRegistryApis[plainId] = plainFacade
host._pluginRegistryApiSources[plainId] = '/home/plugins/plain'
host.syncPluginApis()
assert(!plainFacade.destroyed, 'unchanged personal registry facade survives rescan')
host.pluginRegistry.installedPlugins[plainId] = manifest(plainId, '/data/plugins/plain', false)
host.syncPluginApis()
host._syncServices()
assert(plainFacade.destroyed && !host._pluginRegistryApis[plainId]
  && host._services[plainId] !== plainHome && plainHome.destroyed,
  'an untrusted source change revokes the old registry facade and service')

const widgetId = 'acme.widget-view'
const widgetHome = manifest(widgetId, '/home/plugins/widget-view', false)
host.pluginRegistry.installedPlugins[widgetId] = widgetHome
const oldWidgetApi = host.pluginBarWidgetRegistryFor(widgetHome)
oldWidgetApi.widgets = { tampered: true }
const widgetData = manifest(widgetId, '/data/plugins/widget-view', false)
host.pluginRegistry.installedPlugins[widgetId] = widgetData
host.syncPluginApis()
assert(oldWidgetApi.destroyed && !host._pluginBarWidgetRegistryApis[widgetId],
  'an untrusted source change revokes the old widget registry facade')
const newWidgetApi = host.pluginBarWidgetRegistryFor(widgetData)
assert(newWidgetApi !== oldWidgetApi && !newWidgetApi.widgets.tampered && newWidgetApi.widgets.fresh,
  'the replacement receives a fresh widget registry snapshot')

const entryId = 'acme.bar-entry'
const entryHome = manifest(entryId, '/home/plugins/bar-entry', false)
host.pluginRegistry.installedPlugins[entryId] = entryHome
const oldEntryApi = host.pluginShellForBarEntry('bar-owner', entryId)
assert(host.pluginShellForBarEntry('bar-owner', entryId) === oldEntryApi,
  'unchanged replacement bar entry keeps its facade')
oldEntryApi._updateSettings = null
host.pluginRegistry.installedPlugins[entryId] = manifest(entryId, '/data/plugins/bar-entry', false)
host.syncPluginApis()
assert(oldEntryApi.destroyed && !host._pluginBarEntryShellApis['bar-owner::' + entryId],
  'a target source change prunes a replacement bar entry facade')
const dataEntryApi = host.pluginShellForBarEntry('bar-owner', entryId)
assert(dataEntryApi !== oldEntryApi && typeof dataEntryApi._updateSettings === 'function',
  'the replacement bar entry receives working callbacks')
host.pluginRegistry.installedPlugins[entryId] = manifest(entryId, '/fallback/plugins/bar-entry', false)
const fallbackEntryApi = host.pluginShellForBarEntry('bar-owner', entryId)
assert(dataEntryApi.destroyed && fallbackEntryApi !== dataEntryApi,
  'a target source change also revokes its facade before pruning')
host.revokePluginShellApi('bar-owner')
assert(fallbackEntryApi.destroyed && !host._pluginBarEntryShellApiOwners['bar-owner::' + entryId],
  'revoking the bar owner clears its entry facade provenance')

const removedId = 'acme.removed'
const spoofedFacade = { pluginId: id, destroyed: false, destroy() { this.destroyed = true } }
host._pluginRegistryApis[removedId] = spoofedFacade
host._pluginRegistryApiSources[removedId] = '/home/plugins/removed'
host.syncPluginApis()
assert(spoofedFacade.destroyed && !host._pluginRegistryApis[removedId],
  'a changed facade pluginId cannot prevent reconciliation of a removed plugin')

for (const builtin of ['omarchy.idle', 'omarchy.lock', 'omarchy.polkit']) {
  const authentication = builtin !== 'omarchy.idle'
  select(manifest(builtin, '/checkout/' + builtin, true, 'Service.qml', authentication))
  const original = created[created.length - 1]
  host.unloadPluginServices()
  select(manifest(builtin, '/checkout/' + builtin, true, 'Service.qml', authentication))
  assert(!original.destroyed && created[created.length - 1] === original,
    `unchanged ${builtin} keepLoaded service survives reload`)
  if (authentication) {
    assert(auth.has(builtin) && !host._services[builtin] && original.parent === null,
      `${builtin} remains outside the public service map and host tree`)
    select(manifest(builtin, '/replacement/' + builtin, true, 'Service.qml', true))
    assert(original.destroyed && auth.has(builtin) && !host._services[builtin],
      `${builtin} provenance change recreates its isolated instance`)
  }
}

const beforeAsync = created.length
const asyncId = 'omacom.async'
delayedUrl = '/old/Service.qml'
select(manifest(asyncId, '/old', false))
assertEqual(pending.length, 1, 'test queues an asynchronous component load')
delayedUrl = '/new/Service.qml'
select(manifest(asyncId, '/new', true))
assertEqual(pending.length, 2, 'replacement remains pending while the old load completes')
pending[0]()
assert(created.length === beforeAsync && !host._services[asyncId],
  'stale asynchronous completion cannot publish the old implementation')
pending[1]()
assert(created.length === beforeAsync + 1 && host._services[asyncId].url === '/new/Service.qml',
  'current asynchronous completion publishes only the selected implementation')

const disabledId = 'omacom.disabled-async'
delayedUrl = '/disabled/Service.qml'
select(manifest(disabledId, '/disabled', false))
assertEqual(pending.length, 3, 'disabled service begins an asynchronous load')
disabled.add(disabledId)
host._syncServices()
const beforeDisabledCompletion = created.length
pending[2]()
assert(created.length === beforeDisabledCompletion && !host._services[disabledId],
  'disabled service cannot publish after its pending load completes')

host.pluginRegistry.installedPlugins = {}
host._syncServices()
assertEqual(Object.keys(host._serviceProvenance).length, 0, 'removed services release their provenance records')
JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const bar = {
  console,
  pluginBarApis: {},
  pluginBarApiSources: {},
  moduleSlots: [],
  currentMetadata: { sourceDir: '/home/plugins/widget', firstParty: false },
  barWidgetRegistry: { metadataFor() { return bar.currentMetadata } },
  canonicalWidgetId(id) { return id },
  shell: { pluginShellForId() { return {} } },
  pluginBarApiComponent: { createObject(_parent, properties) {
    return { ...properties, destroyed: false, destroy() { this.destroyed = true } }
  } },
  bindPluginBarApi(api) { api.foreground = 'bound' },
  releasePluginObjects() {}
}
bar.root = bar
vm.createContext(bar)
for (const name of ['pluginBarApiProvenance', 'pluginBarApiFor', 'pluginBarApiSource', 'prunePluginBarApis']) {
  const match = source.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))
  assert(!!match, `bar defines ${name}`)
  vm.runInContext(match[0], bar)
}
const id = 'acme.widget'
bar.moduleSlots = [{ pluginApiId: id, registered: true, registryMetadata: bar.currentMetadata }]
const homeApi = bar.pluginBarApiFor(id, id, true)
assert(bar.pluginBarApiFor(id, id, true) === homeApi,
  'unchanged built-in bar widget keeps its facade')
homeApi.foreground = 'tampered'
bar.currentMetadata = { sourceDir: '/data/plugins/widget', firstParty: false }
bar.moduleSlots[0].registryMetadata = bar.currentMetadata
bar.prunePluginBarApis()
assert(homeApi.destroyed && !bar.pluginBarApis[id],
  'built-in bar prunes the previous source widget facade')
const dataApi = bar.pluginBarApiFor(id, id, true)
assert(dataApi !== homeApi && dataApi.foreground === 'bound',
  'replacement widget receives fresh bar bindings')
bar.currentMetadata = { sourceDir: '/fallback/plugins/widget', firstParty: false }
const fallbackApi = bar.pluginBarApiFor(id, id, true)
assert(dataApi.destroyed && fallbackApi !== dataApi,
  'built-in bar also revokes a changed source before pruning')
JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const pending = []
const registrations = {}
const host = {
  console,
  Component: { Ready: 1, Loading: 2, Error: 3, Asynchronous: 0 },
  Qt: { createComponent(url) {
    const component = {
      url, status: 2,
      statusChanged: { connect(callback) { pending.push((status = 1) => { component.status = status; callback() }) } },
      errorString() { return 'broken widget' }
    }
    return component
  } },
  pluginWidgetComponents: {},
  pluginRegistry: {
    installedPlugins: {},
    isEnabled() { return true },
    entryPointUrl(manifest) { return manifest.__sourceDir + '/' + manifest.entryPoints.barWidget },
    pluginLoadFailed() {}
  },
  barWidgetRegistry: {
    has(id) { return !!registrations[id] },
    register(id, component) { registrations[id] = component },
    unregister(id) { delete registrations[id] }
  }
}
host.shell = host
vm.createContext(host)
for (const name of ['pluginSourceProvenance', 'setPluginWidgetComponent', 'loadPluginWidget', 'syncPluginWidgets']) {
  const match = source.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))
  assert(!!match, `host defines ${name}`)
  vm.runInContext(match[0], host)
}
function widget(id, sourceDir, trusted = false) {
  return { id, __sourceDir: sourceDir, __isFirstParty: trusted,
    kinds: ['bar-widget'], entryPoints: { barWidget: 'Widget.qml' } }
}
const id = 'acme.async-widget'
host.pluginRegistry.installedPlugins[id] = widget(id, '/home/widget')
host.syncPluginWidgets()
assertEqual(pending.length, 1, 'first widget component load is pending')
host.pluginRegistry.installedPlugins[id] = widget(id, '/data/widget')
host.syncPluginWidgets()
assertEqual(pending.length, 2, 'replacement widget load is pending')
pending[0]()
assert(!registrations[id], 'stale widget completion does not publish the old source')
pending[1]()
assert(registrations[id] && registrations[id].url === '/data/widget/Widget.qml',
  'only the selected widget source is registered')

const lateId = 'acme.late-old-widget'
host.pluginRegistry.installedPlugins[lateId] = widget(lateId, '/home/late')
host.syncPluginWidgets()
host.pluginRegistry.installedPlugins[lateId] = widget(lateId, '/data/late')
host.syncPluginWidgets()
pending[3]()
pending[2]()
assert(registrations[lateId] && registrations[lateId].url === '/data/late/Widget.qml',
  'an old widget finishing last cannot replace the selected source')
assert(host.pluginWidgetComponents[lateId] && host.pluginWidgetComponents[lateId].url === '/data/late/Widget.qml',
  'an old widget finishing last cannot clear the selected claim')

const changedId = 'acme.changed-before-scan'
host.pluginRegistry.installedPlugins[changedId] = widget(changedId, '/same/widget')
host.syncPluginWidgets()
host.pluginRegistry.installedPlugins[changedId] = widget(changedId, '/same/widget', true)
pending[4]()
assert(!registrations[changedId] && !host.pluginWidgetComponents[changedId],
  'a changed selection invalidates its pending widget before the next scan')

const removedId = 'acme.removed-widget'
delete host.pluginRegistry.installedPlugins[changedId]
host.pluginRegistry.installedPlugins[removedId] = widget(removedId, '/home/removed')
host.syncPluginWidgets()
delete host.pluginRegistry.installedPlugins[removedId]
host.syncPluginWidgets()
assert(!host.pluginWidgetComponents[removedId],
  'removing a widget clears its pending claim before completion')
pending[5]()
assert(!registrations[removedId] && !host.pluginWidgetComponents[removedId],
  'removing a widget clears its pending claim and blocks late publication')

const failedId = 'acme.failed-replacement'
host.pluginRegistry.installedPlugins[failedId] = widget(failedId, '/home/failure')
host.syncPluginWidgets()
pending[6]()
assert(registrations[failedId], 'original widget is registered before replacement')
host.pluginRegistry.installedPlugins[failedId] = widget(failedId, '/data/failure')
host.syncPluginWidgets()
assert(!registrations[failedId], 'replacing a widget drops the displaced registration')
pending[7](3)
assert(!registrations[failedId] && !host.pluginWidgetComponents[failedId],
  'failed widget replacement cannot leave an orphan registration')
JS
