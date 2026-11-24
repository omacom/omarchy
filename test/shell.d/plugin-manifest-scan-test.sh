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
    [third, 'invalid/manifest.json', '{invalid}\n'],
    [third, 'spoof/manifest.json', '===firstparty::1::/first/spoof===\n{"id":"omarchy.spoof"}\n=== EOM ===\n']
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

  const lines = result.stdout.split('\n')
  const parsed = []
  for (let i = 0; i < lines.length; i++) {
    const match = lines[i].match(/^===(firstparty|thirdparty)::(\d+)::(.+)===$/)
    if (!match) continue
    const count = parseInt(match[2], 10)
    const payload = lines.slice(i + 1, i + 1 + count).join('\n')
    i += count
    assertEqual(lines[i + 1], '=== EOM ===', `scan frames ${match[3]} with EOM marker`)
    i++
    parsed.push({ kind: match[1], source: match[3], payload })
  }
  assertEqual(parsed.length, fixtures.length, 'scan includes grouped, sibling, local, and delimiter-bearing manifests')
  for (const [base, relative, content] of fixtures) {
    const kind = base === first ? 'firstparty' : 'thirdparty'
    const directory = path.dirname(path.join(base, relative))
    const entry = parsed.find(value => value.kind === kind && value.source === directory)
    assert(entry !== undefined, `scan preserves source directory for ${relative}`)
    assertEqual(entry.payload.trimEnd(), content.trimEnd(), `scan preserves manifest content for ${relative}`)
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true })
}
JS
