#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const { spawnSync } = require('child_process')

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'plugin-manifest-scan-'))
try {
  const first = path.join(scratch, 'first party')
  const third = path.join(scratch, 'third party')
  const fixtures = [
    [first, 'panel/manifest.json', '{"id":"panel","name":"quote \\\" and $value"}\n\n'],
    [first, 'widgets/Clock.manifest.json', '{"id":"clock"}'],
    [first, 'panels/audio/manifest.json', '{"id":"audio"}\n'],
    [third, 'local plugin/manifest.json', '{"id":"local","name":"日本語"}\n'],
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
  const blocks = result.stdout.split('\n=== EOM ===\n').filter(Boolean)
  assertEqual(blocks.length, fixtures.length, 'scan includes grouped, sibling and local manifests')
  for (const [base, relative, content] of fixtures) {
    const kind = base === first ? 'firstparty' : 'thirdparty'
    const directory = path.dirname(path.join(base, relative)) + (base === third ? '/' : '')
    const header = `===${kind}::${directory}===\n`
    const block = blocks.find(value => value.startsWith(header))
    assert(block !== undefined, `scan preserves source directory for ${relative}`)
    assertEqual(block.slice(header.length).trimEnd(), content.trimEnd(), `scan preserves manifest content for ${relative}`)
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}
JS
