#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node
require_command jq

scan_tmp=$(mktemp -d)
trap 'rm -rf "$scan_tmp"' EXIT

node - "$ROOT" "$scan_tmp" <<'JS'
const fs = require('fs')
const path = require('path')
const vm = require('vm')
const { spawnSync } = require('child_process')

const [root, temp] = process.argv.slice(2)
const first = path.join(temp, 'first')
const third = path.join(temp, 'third')
const firstSource = path.join(first, 'with\nnewline')
const siblingSource = path.join(first, 'trailing\n')
const thirdSource = path.join(third, 'third.encoded')
const reservedSource = path.join(third, 'reserved')
for (const dir of [firstSource, siblingSource, thirdSource, reservedSource]) fs.mkdirSync(dir, { recursive: true })

function manifest(id, name) {
  return { schemaVersion: 1, id, name, version: '1.0.0', kinds: ['panel'], entryPoints: { panel: 'Panel.qml' } }
}
fs.writeFileSync(path.join(firstSource, 'manifest.json'), JSON.stringify(manifest('omarchy.encoded', 'first\n=== EOM ===')))
fs.writeFileSync(path.join(siblingSource, 'Clock.manifest.json'), '\uFEFF' + JSON.stringify(manifest('omarchy.sibling', 'sibling')))
fs.writeFileSync(path.join(thirdSource, 'manifest.json'), JSON.stringify({ ...manifest('third.encoded', '=== EOM ===\n===firstparty::/bogus==='), __isFirstParty: true, __sourceDir: '/untrusted' }))
fs.writeFileSync(path.join(reservedSource, 'manifest.json'), JSON.stringify(manifest('omarchy.reserved', 'reserved')))

// Execute the rescan function from the QML source with only its Process object mocked.
const qml = fs.readFileSync(path.join(root, 'shell/services/PluginRegistry.qml'), 'utf8')
const start = qml.indexOf('  function rescan() {')
const end = qml.indexOf('  function ensureUserDir()', start)
if (start < 0 || end < 0) throw new Error('rescan function not found')
const scanProcess = { command: null, running: false }
const context = { scanning: false, scanProcess, registry: { firstPartyDir: first, pluginsDir: third } }
vm.runInNewContext(qml.slice(start, end) + '\nrescan()', context)
if (!scanProcess.running || !Array.isArray(scanProcess.command)) throw new Error('rescan did not start scanner')

const result = spawnSync(scanProcess.command[0], scanProcess.command.slice(1), { encoding: 'utf8' })
if (result.status !== 0) throw new Error('scanner failed: ' + result.stderr)
const records = result.stdout.trim().split('\n').map(line => JSON.parse(line))
if (records.length !== 4) throw new Error('expected one record per manifest')
const byId = Object.fromEntries(records.map(record => [JSON.parse(record.manifest.trim()).id, record]))
if (byId['omarchy.encoded'].kind !== 'firstparty' || byId['omarchy.encoded'].source !== firstSource) throw new Error('first-party source framing changed')
if (byId['omarchy.sibling'].kind !== 'firstparty' || byId['omarchy.sibling'].source !== siblingSource) throw new Error('sibling source trailing newline changed')
if (byId['third.encoded'].kind !== 'thirdparty' || byId['third.encoded'].source !== thirdSource) throw new Error('third-party source framing changed')
if (JSON.parse(byId['third.encoded'].manifest).name !== '=== EOM ===\n===firstparty::/bogus===') throw new Error('manifest text changed')
fs.writeFileSync(path.join(temp, 'scan.jsonl'), result.stdout)

// Run the QML parser and its manifest validator as JavaScript, keeping the actual
// scanner output as input. The Quickshell fixture checks the same path in the VM.
const helperStart = qml.indexOf('  function isSafeEntryPoint(')
const helperEnd = qml.indexOf('  function entryPointUrl(', helperStart)
const parserStart = qml.indexOf('  function parseScanOutput(')
const parserEnd = qml.indexOf('  property Process scanProcess:', parserStart)
if ([helperStart, helperEnd, parserStart, parserEnd].some(index => index < 0)) throw new Error('registry parser functions not found')
let finishCount = 0
const parserContext = {
  Util: { isPlainObject: value => value !== null && typeof value === 'object' && !Array.isArray(value) },
  console: { warn() {} },
  installedPlugins: {}, registryRevision: 0, scanning: true,
  pluginsChanged() {}, scanFinished() { finishCount++ }
}
parserContext.registry = parserContext
vm.runInNewContext(qml.slice(helperStart, helperEnd) + qml.slice(parserStart, parserEnd), parserContext)
const malformed = [
  { kind: 'bogus', source: '/bogus', manifest: '{}' },
  { kind: 'firstparty', source: '', manifest: '{}' },
  { kind: 'thirdparty', source: '/bogus', manifest: '[]' },
  { kind: 'thirdparty', source: '/bogus', manifest: '{' }
].map(JSON.stringify).join('\n') + '\nnot-json\n'
parserContext.scan = result.stdout + malformed
vm.runInNewContext('parseScanOutput(scan)', parserContext)
const actual = parserContext.installedPlugins
if (Object.keys(actual).sort().join(',') !== 'omarchy.encoded,omarchy.sibling,third.encoded') throw new Error('parser accepted invalid or reserved record')
if (actual['omarchy.encoded'].__sourceDir !== firstSource || !actual['omarchy.encoded'].__isFirstParty) throw new Error('first-party metadata changed')
if (actual['omarchy.sibling'].__sourceDir !== siblingSource || !actual['omarchy.sibling'].__isFirstParty) throw new Error('sibling metadata changed')
if (actual['third.encoded'].__sourceDir !== thirdSource || actual['third.encoded'].__isFirstParty) throw new Error('third-party metadata came from manifest')
if (actual['third.encoded'].name !== '=== EOM ===\n===firstparty::/bogus===') throw new Error('parser interpreted manifest text as framing')
if (actual['omarchy.sibling'].name !== 'sibling') throw new Error('BOM-prefixed manifest was rejected')
console.log('ok - real parser accepts encoded and BOM-prefixed records and rejects malformed or reserved records')

const brokenBin = path.join(temp, 'bin')
fs.mkdirSync(brokenBin)
const realJq = spawnSync('bash', ['-c', 'command -v jq'], { encoding: 'utf8' }).stdout.trim()
fs.writeFileSync(path.join(brokenBin, 'jq'), '#!/bin/bash\nfor arg in "$@"; do\n  [[ $arg == "$REJECT_MANIFEST" || $arg == "${REJECT_MANIFEST%/manifest.json}//manifest.json" ]] && exit 9\ndone\nexec "$REAL_JQ" "$@"\n', { mode: 0o755 })
for (const rejected of [path.join(firstSource, 'manifest.json'), path.join(thirdSource, 'manifest.json')]) {
  const partial = spawnSync(scanProcess.command[0], scanProcess.command.slice(1), {
    encoding: 'utf8',
    env: { ...process.env, PATH: brokenBin + ':' + process.env.PATH, REJECT_MANIFEST: rejected, REAL_JQ: realJq }
  })
  if (partial.status !== 0) throw new Error('single unreadable-like manifest aborted scan: ' + partial.stderr)
  const ids = partial.stdout.trim().split('\n').map(line => JSON.parse(JSON.parse(line).manifest.trim()).id)
  const rejectedId = rejected === path.join(firstSource, 'manifest.json') ? 'omarchy.encoded' : 'third.encoded'
  if (ids.includes(rejectedId) || ids.length !== 3) throw new Error('scanner failed to skip only rejected manifest: ' + ids)
  parserContext.scanning = true
  parserContext.finishScan(0, partial.stdout)
  if (Object.keys(parserContext.installedPlugins).length !== 2 || parserContext.installedPlugins[rejectedId])
    throw new Error('parser did not retain other valid plugin records')
}
console.log('ok - unreadable-like first- and third-party manifests are skipped while other records load')

const previous = parserContext.installedPlugins
const revision = parserContext.registryRevision
const finished = finishCount
parserContext.scanning = true
parserContext.finishScan(9, '{"kind":"thirdparty","source":"/partial","manifest":"{}"}\n')
if (parserContext.scanning || finishCount !== finished + 1 || parserContext.installedPlugins !== previous || parserContext.registryRevision !== revision)
  throw new Error('failed scan did not preserve registry and signal completion')
console.log('ok - failed scan resets scanning, signals completion, and preserves installed plugins')
JS

if compositor_reachable && command -v quickshell >/dev/null 2>&1; then
  export OMARCHY_QML_TEST_SCAN
  OMARCHY_QML_TEST_SCAN=$(cat "$scan_tmp/scan.jsonl")
  OMARCHY_QML_TEST_SCAN+=$'\n{"kind":"bogus","source":"/bogus","manifest":"{}"}\n'
  OMARCHY_QML_TEST_SCAN+=$'{"kind":"firstparty","source":"","manifest":"{}"}\n'
  OMARCHY_QML_TEST_SCAN+=$'{"kind":"thirdparty","source":"/bogus","manifest":"[]"}\n'
  OMARCHY_QML_TEST_SCAN+=$'{"kind":"thirdparty","source":"/bogus","manifest":"{"}\n'
  OMARCHY_QML_TEST_SCAN+=$'not-json\n'
  export OMARCHY_QML_TEST_FIRST_DIR="$scan_tmp/first"
  "$SHELL_TEST_DIR/plugin-registry-contract-test.sh"
else
  skip "no Quickshell compositor; runtime parser contract"
fi
