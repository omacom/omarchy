#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const { spawnSync } = require('child_process')
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'app-icon-scan-'))
process.on('exit', () => fs.rmSync(scratch, { recursive: true, force: true }))

const home = path.join(scratch, 'home')
const local = path.join(scratch, 'local')
const system = path.join(scratch, 'system')
const pixmaps = path.join(scratch, 'pixmaps')
const files = [
  [home, '.icons/theme/apps/shared.png'],
  [home, '.icons/theme/apps/local.svg'],
  [home, '.local/share/icons/theme/devices/printer.svg'],
  [local, 'icons/theme/apps/shared.svg'],
  [local, 'icons/theme/apps/pngonly.png'],
  [system, 'icons/theme/apps/shared.svg'],
  [system, 'icons/theme/apps/pngonly.png'],
  [system, 'icons/theme/apps/name with spaces.png'],
  [system, 'icons/theme/actions/excluded.svg'],
  [pixmaps, 'fallback.png']
]
for (const [base, relative] of files) {
  const file = path.join(base, relative)
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, '')
}

// Redirect the fixed pixmaps path into the fixture; traverse real icon trees.
const stubDir = path.join(scratch, 'bin')
const calls = path.join(scratch, 'find-calls')
fs.mkdirSync(stubDir)
fs.writeFileSync(path.join(stubDir, 'find'), `#!/bin/bash
printf '%s\\n' "$1" >> "$FIND_CALLS"
if [[ $1 == "/usr/share/pixmaps" ]]; then
  shift
  /usr/bin/find "$PIXMAPS" "$@"
else
  /usr/bin/find "$@"
fi
`, { mode: 0o755 })

const qml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const body = qml.split('  function iconIndexScanCommand() {')[1].split('\n  function indexIconLine(')[0].replace(/\n  }\s*$/, '')
const command = new Function(body)()
const result = spawnSync('bash', ['-c', command], {
  encoding: 'utf8',
  env: { ...process.env, HOME: home, XDG_DATA_DIRS: `${local}:${system}`, PATH: `${stubDir}:${process.env.PATH}`, FIND_CALLS: calls, PIXMAPS: pixmaps }
})
assertEqual(result.status, 0, 'icon scan completes')
const lines = result.stdout.trim().split('\n')
assertEqual(lines.length, files.length - 1, 'scan includes app and device icons and excludes action icons')
const firstPng = lines.findIndex(value => value.endsWith('.png'))
assert(lines.slice(0, firstPng).every(value => value.endsWith('.svg')), 'SVG icons are emitted before PNG icons')
assert(lines.slice(firstPng).every(value => value.endsWith('.png')), 'no SVG icons follow PNG icons')
const shared = lines.filter(value => path.basename(value).startsWith('shared.'))
assertDeepEqual(shared, [path.join(local, 'icons/theme/apps/shared.svg'), path.join(system, 'icons/theme/apps/shared.svg'), path.join(home, '.icons/theme/apps/shared.png')], 'scan preserves format preference and XDG directory precedence')
assertDeepEqual(lines.filter(value => path.basename(value) === 'pngonly.png'), [path.join(local, 'icons/theme/apps/pngonly.png'), path.join(system, 'icons/theme/apps/pngonly.png')], 'scan preserves directory precedence for PNG-only icons')
assert(lines.includes(path.join(system, 'icons/theme/apps/name with spaces.png')), 'scan preserves spaces in filenames')
const roots = fs.readFileSync(calls, 'utf8').trim().split('\n')
assertEqual(new Set(roots).size, 5, 'scan visits all icon roots and pixmaps')
assertEqual(roots.length, 5, 'scan visits each root only once')
JS
