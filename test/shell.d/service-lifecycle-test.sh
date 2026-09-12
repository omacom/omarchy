#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# An optional source path lets the same regression run against an older revision.
export SERVICE_LIFECYCLE_SOURCE=${1:-"$ROOT/shell/shell.qml"}
export SERVICE_LIFECYCLE_AUTH_STORE="$ROOT/shell/services/AuthServiceStore.js"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const check = require('node:assert/strict')
const source = fs.readFileSync(process.env.SERVICE_LIFECYCLE_SOURCE, 'utf8')
const serviceSection = source.slice(source.indexOf('  property var _services:'), source.indexOf('  Connections {\n    target: shell.pluginRegistry'))
const functions = serviceSection.match(/^  function \w+\([^\n]*\) \{[\s\S]*?^  \}/gm)
check.ok(functions && functions.length >= 5, 'extract production service functions')
const properties = [...serviceSection.matchAll(/^  property (?:var|int) (\w+): (.+)$/gm)]
  .map(([, name, value]) => `var ${name} = ${value}`)
const production = properties.concat(functions).join('\n')
const Component = { Null: 0, Ready: 1, Loading: 2, Error: 3, PreferSynchronous: 0 }

function fixture() {
  const requests = []
  const queue = []
  const warnings = []
  const installedPlugins = {}
  const enabled = new Set()
  // The extracted production loader unconditionally calls AuthServiceStore
  // via ensureService's isAuthenticationService check; run the real,
  // dependency-free module (shell/services/AuthServiceStore.js) rather than
  // a hand-rolled stand-in. None of these fixtures are trusted, so isTrusted
  // stays false and the store otherwise just tracks put/has/destroy/ids.
  const authContext = {}
  vm.createContext(authContext)
  vm.runInContext(fs.readFileSync(process.env.SERVICE_LIFECYCLE_AUTH_STORE, 'utf8'), authContext)
  const AuthServiceStore = {
    isTrusted: authContext.isTrusted,
    has: authContext.has,
    put: authContext.put,
    updateManifest: authContext.updateManifest,
    destroy: authContext.destroy,
    ids: authContext.ids
  }
  const context = {
    Component,
    AuthServiceStore,
    serviceHost: {},
    omarchyPath: '/test/omarchy',
    barWidgetRegistry: {},
    pluginReloading: false,
    console: { warn: (...args) => warnings.push(args.join(' ')) },
    pluginRegistry: {
      installedPlugins,
      isEnabled: id => enabled.has(id),
      entryPointUrl: manifest => manifest.basePath + '/' + manifest.entryPoints.service,
      // No clone aliasing in these fixtures; every id already names itself.
      resolveEnabledId: id => id
    },
    Qt: {
      createComponent(url, mode) {
        check.equal(mode, Component.PreferSynchronous)
        const comp = queue.shift()
        check.ok(comp !== undefined, 'fixture has a component for each load')
        requests.push({ url, comp })
        return comp
      }
    }
  }
  context.shell = context
  vm.createContext(context)
  vm.runInContext(production, context, { filename: 'shell.qml:services' })

  function install(id = 'test.service') {
    // First-party so pluginShellFor/pluginRegistryFor/pluginBarWidgetRegistryFor/
    // publicPluginManifest take their identity short-circuit instead of the
    // scoped-plugin-API path, which needs real QML Components this harness
    // cannot construct. That wrapping is orthogonal to the load-ownership
    // behavior under test here.
    const manifest = { id, kinds: ['service'], entryPoints: { service: 'Service.qml' }, basePath: '/plugins/' + id, __isFirstParty: true }
    installedPlugins[id] = manifest
    enabled.add(id)
    return manifest
  }

  function component(status = Component.Loading, onCreate) {
    const callbacks = new Set()
    const history = []
    const instances = []
    const comp = {
      status,
      creates: 0,
      destroys: 0,
      callbacks,
      history,
      instances,
      statusChanged: {
        connect(callback) { callbacks.add(callback); history.push(callback) },
        disconnect(callback) { check.ok(callbacks.delete(callback), 'disconnect an attached callback') }
      },
      errorString() { return 'fixture component error' },
      destroy() { this.destroys++ },
      createObject(parent) {
        check.equal(parent, context.serviceHost)
        this.creates++
        const inst = { omarchyPath: null, shell: null, manifest: null, barWidgetRegistry: null, pluginRegistry: null, destroys: 0, destroy() { this.destroys++ } }
        instances.push(inst)
        return onCreate ? onCreate(inst) : inst
      },
      emit(nextStatus) {
        this.status = nextStatus
        for (const callback of [...callbacks]) callback()
      },
      late(nextStatus) {
        this.status = nextStatus
        for (const callback of history) callback()
      }
    }
    queue.push(comp)
    return comp
  }
  return { context, install, component, requests, queue, enabled, installedPlugins, warnings }
}

let failures = 0
function test(description, body) {
  try {
    body()
    pass(description)
  } catch (error) {
    failures++
    console.error(`not ok - ${description}\n${error.stack}`)
  }
}

test('late old load cannot displace the fresh service after unload', () => {
  const f = fixture()
  f.install()
  const old = f.component()
  f.context.ensureService('test.service')
  f.context.unloadPluginServices()
  const fresh = f.component()
  f.context.ensureService('test.service')
  fresh.emit(Component.Ready)
  const current = f.context.serviceFor('test.service')
  old.late(Component.Ready)
  check.ok(f.context.serviceFor('test.service') === current, 'the fresh service retains ownership')
  check.equal(old.creates, 0)
  check.equal(current.destroys, 0)
  check.equal(old.callbacks.size, 0)
  check.equal(fresh.callbacks.size, 0)
})

test('pending ensure and sync requests share one load and Loading remains pending', () => {
  const f = fixture()
  f.install()
  const comp = f.component()
  check.equal(f.context.ensureService('test.service'), null)
  check.equal(f.context.ensureService('test.service'), null)
  f.context._syncServices()
  comp.emit(Component.Loading)
  check.equal(comp.creates, 0)
  check.equal(f.warnings.length, 0)
  check.equal(comp.callbacks.size, 1)
  check.equal(f.requests.length, 1)
  comp.emit(Component.Ready)
  const inst = f.context.serviceFor('test.service')
  check.ok(inst)
  check.equal(f.context.ensureService('test.service'), inst)
  comp.late(Component.Ready)
  check.equal(comp.creates, 1)
  check.equal(comp.callbacks.size, 0)
  check.equal(f.context.serviceFor('test.service'), inst)
})

test('synchronous creation returns the injected service with the existing injection order', () => {
  const f = fixture()
  const manifest = f.install()
  const writes = []
  const comp = f.component(Component.Ready, inst => new Proxy(inst, {
    set(target, key, value) { writes.push(key); target[key] = value; return true }
  }))
  const inst = f.context.ensureService('test.service')
  check.ok(inst)
  check.equal(inst.omarchyPath, f.context.omarchyPath)
  check.equal(inst.shell.serviceFor('test.service'), inst)
  check.equal(inst.manifest, manifest)
  check.equal(inst.barWidgetRegistry, f.context.barWidgetRegistry)
  check.equal(inst.pluginRegistry, f.context.pluginRegistry)
  check.deepEqual(writes, ['omarchyPath', 'shell', 'manifest', 'barWidgetRegistry', 'pluginRegistry'])
  check.equal(comp.callbacks.size, 0)
  check.equal(f.context.firstPartyServiceFor('test.service'), inst)
})

const invalidations = {
  disabled: f => f.enabled.delete('test.service'),
  removed: f => delete f.installedPlugins['test.service'],
  'manifest replaced': f => f.install(),
  'URL changed': f => { f.installedPlugins['test.service'].basePath = '/replacement' },
  'service kind removed': f => { f.installedPlugins['test.service'].kinds = ['panel'] },
  'entry point removed': f => { delete f.installedPlugins['test.service'].entryPoints.service }
}

for (const [reason, invalidate] of Object.entries(invalidations)) {
  test(`${reason} while pending prevents stale construction and allows explicit retry`, () => {
    const f = fixture()
    f.install()
    const stale = f.component()
    f.context.ensureService('test.service')
    invalidate(f)
    stale.emit(Component.Ready)
    check.equal(stale.creates, 0)
    check.equal(stale.callbacks.size, 0)
    check.equal(f.context.serviceFor('test.service'), null)
    f.install()
    const fresh = f.component(Component.Ready)
    check.ok(f.context.ensureService('test.service'))
    check.equal(fresh.creates, 1)
  })
}

for (const reason of ['disabled', 'removed', 'service kind removed', 'entry point removed']) {
  test(`sync cancels a ${reason} pending load without waiting for completion`, () => {
    const f = fixture()
    f.install()
    const stale = f.component()
    f.context.ensureService('test.service')
    invalidations[reason](f)
    f.context._syncServices()
    check.equal(stale.callbacks.size, 0)
    stale.late(Component.Ready)
    check.equal(stale.creates, 0)
    check.equal(f.context.serviceFor('test.service'), null)
  })
}

test('disabled or invalid service requests do not create components', () => {
  const f = fixture()
  check.equal(f.context.ensureService('missing'), null)
  for (const reason of ['disabled', 'service kind removed', 'entry point removed']) {
    f.install()
    invalidations[reason](f)
    check.equal(f.context.ensureService('test.service'), null)
  }
  check.equal(f.requests.length, 0)
})

for (const status of [Component.Error, Component.Null]) {
  for (const asynchronous of [false, true]) {
    test(`${asynchronous ? 'asynchronous' : 'synchronous'} status ${status} releases failed load for retry`, () => {
      const f = fixture()
      f.install()
      const failed = f.component(asynchronous ? Component.Loading : status)
      check.equal(f.context.ensureService('test.service'), null)
      if (asynchronous) failed.emit(status)
      check.equal(failed.callbacks.size, 0)
      check.equal(failed.creates, 0)
      check.equal(f.context.serviceFor('test.service'), null)
      const fresh = f.component(Component.Ready)
      const inst = f.context.ensureService('test.service')
      check.ok(inst)
      failed.late(Component.Ready)
      check.equal(failed.creates, 0)
      check.equal(fresh.creates, 1)
      check.equal(f.context.serviceFor('test.service'), inst)
    })
  }
}

test('null createObject releases the load so an explicit retry can succeed', () => {
  const f = fixture()
  f.install()
  const failed = f.component(Component.Loading, () => null)
  f.context.ensureService('test.service')
  failed.emit(Component.Ready)
  check.equal(failed.callbacks.size, 0)
  check.equal(f.context.serviceFor('test.service'), null)
  f.component(Component.Ready)
  check.ok(f.context.ensureService('test.service'))
  check.equal(failed.creates, 1)
})

test('null component releases the load so an explicit retry can succeed', () => {
  const f = fixture()
  f.install()
  f.queue.push(null)
  check.equal(f.context.ensureService('test.service'), null)
  f.component(Component.Ready)
  check.ok(f.context.ensureService('test.service'))
  check.equal(f.requests.length, 2)
})

for (const reason of ['manifest replaced', 'URL changed']) {
  test(`sync replaces a pending load when its ${reason}`, () => {
    const f = fixture()
    f.install()
    const old = f.component()
    f.context.ensureService('test.service')
    invalidations[reason](f)
    const fresh = f.component()
    f.context._syncServices()
    check.equal(old.callbacks.size, 0)
    check.equal(fresh.callbacks.size, 1)
    old.late(Component.Ready)
    check.equal(old.creates, 0)
    check.equal(f.context.ensureService('test.service'), null)
    check.equal(f.requests.length, 2)
    fresh.emit(Component.Ready)
    check.equal(f.context.serviceFor('test.service'), fresh.instances[0])
    check.equal(fresh.instances[0].manifest, f.installedPlugins['test.service'])
    check.equal(f.requests[1].url, f.context.pluginRegistry.entryPointUrl(f.installedPlugins['test.service']))
  })
}

test('cancelled callbacks cannot release a newer pending claim', () => {
  const f = fixture()
  f.install()
  const old = f.component()
  f.context.ensureService('test.service')
  f.context.unloadPluginServices()
  const fresh = f.component()
  f.context.ensureService('test.service')
  old.late(Component.Error)
  old.late(Component.Ready)
  check.equal(f.context.ensureService('test.service'), null)
  check.equal(f.requests.length, 2)
  check.equal(fresh.callbacks.size, 1)
  check.equal(old.creates, 0)
  fresh.emit(Component.Ready)
  check.equal(f.context.serviceFor('test.service'), fresh.instances[0])
})

test('unloading destroys registered services and disconnects every pending service', () => {
  const f = fixture()
  f.install('ready')
  f.install('pending')
  const ready = f.component(Component.Ready)
  const inst = f.context.ensureService('ready')
  const pending = f.component()
  f.context.ensureService('pending')
  f.context.unloadPluginServices()
  check.equal(inst.destroys, 1)
  check.equal(pending.callbacks.size, 0)
  pending.late(Component.Ready)
  check.equal(pending.creates, 0)
  check.equal(f.context.serviceFor('ready'), null)
  check.equal(f.context.serviceFor('pending'), null)
  f.context.unloadPluginServices()
  check.equal(ready.instances[0].destroys, 1)
})

test('sync cancellation leaves an unrelated service and pending callback intact', () => {
  const f = fixture()
  f.install('retained')
  f.install('pending')
  f.install('disabled')
  f.component(Component.Ready)
  const retained = f.context.ensureService('retained')
  const pending = f.component()
  f.context.ensureService('pending')
  const disabled = f.component()
  f.context.ensureService('disabled')
  f.enabled.delete('disabled')
  f.context._syncServices()
  check.equal(disabled.callbacks.size, 0)
  check.equal(pending.callbacks.size, 1)
  check.equal(f.context.serviceFor('retained'), retained)
  check.equal(retained.destroys, 0)
  pending.emit(Component.Ready)
  check.ok(f.context.serviceFor('pending'))
})

for (const phase of ['createObject', 'omarchyPath', 'shell', 'manifest', 'barWidgetRegistry', 'pluginRegistry']) {
  test(`reentrant unload during ${phase} destroys the stale instance and preserves the replacement`, () => {
    const f = fixture()
    f.install()
    let replacement
    function reload() {
      f.context.unloadPluginServices()
      f.component(Component.Ready)
      replacement = f.context.ensureService('test.service')
    }
    const stale = f.component(Component.Ready, inst => {
      if (phase === 'createObject') {
        reload()
      } else {
        let value
        Object.defineProperty(inst, phase, {
          get() { return value },
          set(next) { value = next; reload() }
        })
      }
      return inst
    })
    f.context.ensureService('test.service')
    check.ok(replacement)
    check.ok(f.context.serviceFor('test.service') === replacement, 'replacement retains ownership after reentrant unload')
    check.equal(replacement.destroys, 0)
    check.equal(stale.instances[0].destroys, 1)
    check.equal(stale.callbacks.size, 0)
  })
}

test('reentrant duplicate requests during construction retain the in-flight claim', () => {
  const f = fixture()
  f.install()
  const comp = f.component(Component.Ready, inst => {
    check.equal(f.context.ensureService('test.service'), null)
    f.context._syncServices()
    return inst
  })
  check.ok(f.context.ensureService('test.service'))
  check.equal(f.requests.length, 1)
  check.equal(comp.creates, 1)
})

test('reentrant reload during component compilation cleans up the obsolete factory', () => {
  const f = fixture()
  f.install()
  const old = f.component()
  const createComponent = f.context.Qt.createComponent
  let reloaded = false
  let replacement
  f.context.Qt.createComponent = (url, mode) => {
    const comp = createComponent(url, mode)
    if (!reloaded) {
      reloaded = true
      f.context.unloadPluginServices()
      f.component(Component.Ready)
      replacement = f.context.ensureService('test.service')
    }
    return comp
  }
  f.context.ensureService('test.service')
  check.ok(replacement)
  check.equal(f.context.serviceFor('test.service'), replacement)
  check.equal(replacement.destroys, 0)
  check.equal(old.creates, 0)
  check.equal(old.callbacks.size, 0)
  check.equal(old.destroys, 1)
})

test('plugin reload blocks ensure and sync until the new registry is ready', () => {
  const f = fixture()
  f.install()
  f.context.pluginReloading = true
  check.equal(f.context.ensureService('test.service'), null)
  f.context._syncServices()
  check.equal(f.requests.length, 0)
  f.context.pluginReloading = false
  const old = f.component()
  f.context.ensureService('test.service')
  f.context.pluginReloading = true
  old.emit(Component.Ready)
  check.equal(old.creates, 0)
  check.equal(old.callbacks.size, 0)
  check.equal(f.context.serviceFor('test.service'), null)
  f.context.pluginReloading = false
  f.component(Component.Ready)
  f.context._syncServices()
  check.ok(f.context.serviceFor('test.service'))
})

for (const phase of ['createObject', 'manifest']) {
  for (const [reason, invalidate] of Object.entries(invalidations)) {
    test(`${reason} during ${phase} destroys the stale instance before registration`, () => {
      const f = fixture()
      f.install()
      const stale = f.component(Component.Ready, inst => {
        if (phase === 'createObject') {
          invalidate(f)
        } else {
          Object.defineProperty(inst, 'manifest', { set() { invalidate(f) } })
        }
        return inst
      })
      check.equal(f.context.ensureService('test.service'), null)
      check.equal(f.context.serviceFor('test.service'), null)
      check.equal(stale.instances[0].destroys, 1)
      f.install()
      f.component(Component.Ready)
      check.ok(f.context.ensureService('test.service'))
    })
  }
}

if (failures) process.exit(1)
JS
