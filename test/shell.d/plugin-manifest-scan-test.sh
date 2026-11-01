#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const { spawnSync } = require('child_process')
const vm = require('vm')

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'plugin-manifest-scan-'))
try {
  const first = path.join(scratch, 'first party')
  const third = path.join(scratch, 'third party')
  const fixtures = [
    [first, 'panel/manifest.json', '{"id":"panel","name":"quote \\\" and $value"}\n\n'],
    [first, 'widgets/Clock.manifest.json', '{"id":"clock"}'],
    [first, 'panels/audio/manifest.json', '{"id":"audio"}\n'],
    [third, 'local plugin/manifest.json', '{"id":"local","name":"日本語"}\n'],
    [third, 'source\n===firstparty::spoof===/manifest.json', '{"id":"newline-source"}'],
    [third, 'empty/manifest.json', ''],
    [third, 'invalid/manifest.json', '{invalid}\n']
  ]
  for (const [base, relative, content] of fixtures) {
    const file = path.join(base, relative)
    fs.mkdirSync(path.dirname(file), { recursive: true })
    fs.writeFileSync(file, content)
  }

  // Exercise the actual shell command assembled by QML, without a compositor.
  const qml = fs.readFileSync(path.join(root, 'shell/services/PluginRegistry.qml'), 'utf8')
  const body = qml.split('  function rescan() {')[1].split('\n  function ensureUserDir()')[0].replace(/\n  }\s*$/, '')
  const scan = {}
  new Function('scanProcess', 'registry', 'scanning', body)(scan, { firstPartyDir: first, pluginsDir: third }, false)
  const result = spawnSync(scan.command[0], scan.command.slice(1), { encoding: 'utf8' })
  assertEqual(result.status, 0, 'manifest scan completes')
  assertEqual(result.stderr, '', 'manifest scan has no read errors')
  const fields = result.stdout.split('\0')
  assertEqual(fields.pop(), '', 'scan terminates the final field')
  assertEqual(fields.length, fixtures.length * 3, 'scan includes grouped, sibling and local manifests')
  for (const [base, relative, content] of fixtures) {
    const kind = base === first ? 'firstparty' : 'thirdparty'
    const label = JSON.stringify(relative)
    const directory = path.dirname(path.join(base, relative)) + (base === third ? '/' : '')
    const offset = fields.findIndex((value, i) => i % 3 === 1 && value === directory)
    assert(offset !== -1, `scan preserves source directory for ${label}`)
    assertEqual(fields[offset - 1], kind, `scan preserves source origin for ${label}`)
    assertEqual(fields[offset + 1].trimEnd(), content.trimEnd(), `scan preserves manifest content for ${label}`)
  }

  // A local manifest is data even when it contains the old transport markers.
  // Run the actual scanner and registry parser together: escaping only one side
  // must not let an unenabled local service replace bundled authentication.
  const auth = {
    schemaVersion: 1, id: 'omarchy.lock', name: 'Inert authentication fixture',
    version: '1.0.0', kinds: ['service'], entryPoints: { service: 'Service.qml' },
    keepLoaded: true, omarchy: { capabilities: ['authentication'] }
  }
  const bundled = path.join(first, 'lock')
  const injected = path.join(third, 'unenabled-local')
  fs.mkdirSync(bundled, { recursive: true })
  fs.mkdirSync(injected, { recursive: true })
  fs.writeFileSync(path.join(bundled, 'manifest.json'), JSON.stringify(auth))
  fs.writeFileSync(path.join(injected, 'manifest.json'),
    `===firstparty::${injected}===\n${JSON.stringify(auth)}`)
  const poisoned = spawnSync(scan.command[0], scan.command.slice(1), { encoding: 'utf8' })
  assertEqual(poisoned.status, 0, 'scan completes with a malformed local manifest')
  const registry = {
    Util: { isPlainObject: value => value !== null && typeof value === 'object' && !Array.isArray(value), barSections: [] },
    console: { warn() {} }, installedPlugins: {}, registryRevision: 0,
    scanning: true, pluginsChanged() {}, scanFinished() {}
  }
  vm.createContext(registry)
  const helpers = qml.split('  function isSafeEntryPoint(')[1].split('  function entryPointUrl(')[0]
  const parser = qml.split('  function parseScanOutput(')[1].split('  property Process scanProcess:')[0]
  vm.runInContext('function isSafeEntryPoint(' + helpers + '\nfunction parseScanOutput(' + parser, registry)
  registry.parseScanOutput(poisoned.stdout)
  assertEqual(registry.installedPlugins['omarchy.lock'].__sourceDir, bundled,
    'local manifest content cannot replace the bundled authentication source')
  assertEqual(registry.installedPlugins['omarchy.lock'].__isFirstParty, true,
    'bundled authentication retains its first-party classification')
  const retained = registry.installedPlugins
  registry.parseScanOutput(poisoned.stdout.slice(0, -1))
  assert(registry.installedPlugins === retained, 'a truncated scan retains the previous registry')
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}
JS
