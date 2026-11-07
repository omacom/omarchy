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
  [pixmaps, 'fallback.png'],
  // Bare files in the icon base directories: the spec's unthemed fallback.
  [home, '.local/share/icons/bare-home.png'],
  [local, 'icons/bare-local.svg'],
  [system, 'icons/bare-system.png']
]
for (const [base, relative] of files) {
  const file = path.join(base, relative)
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, '')
}

const unthemed = [
  path.join(local, 'icons/bare-local.svg'),
  path.join(home, '.local/share/icons/bare-home.png'),
  path.join(system, 'icons/bare-system.png')
]

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
assertEqual(lines.length, files.length - 1, 'scan includes themed and unthemed icons and excludes action icons')
assertDeepEqual(lines.slice(-unthemed.length), unthemed, 'unthemed icons come after every themed icon, SVG first')
const themed = lines.slice(0, -unthemed.length)
const firstPng = themed.findIndex(value => value.endsWith('.png'))
assert(themed.slice(0, firstPng).every(value => value.endsWith('.svg')), 'themed SVG icons are emitted before themed PNG icons')
assert(themed.slice(firstPng).every(value => value.endsWith('.png')), 'no themed SVG icons follow themed PNG icons')
const shared = lines.filter(value => path.basename(value).startsWith('shared.'))
assertDeepEqual(shared, [path.join(local, 'icons/theme/apps/shared.svg'), path.join(system, 'icons/theme/apps/shared.svg'), path.join(home, '.icons/theme/apps/shared.png')], 'scan preserves format preference and XDG directory precedence')
assertDeepEqual(lines.filter(value => path.basename(value) === 'pngonly.png'), [path.join(local, 'icons/theme/apps/pngonly.png'), path.join(system, 'icons/theme/apps/pngonly.png')], 'scan preserves directory precedence for PNG-only icons')
assert(lines.includes(path.join(system, 'icons/theme/apps/name with spaces.png')), 'scan preserves spaces in filenames')
const roots = fs.readFileSync(calls, 'utf8').trim().split('\n')
assertEqual(new Set(roots).size, 5, 'scan visits all icon roots and pixmaps')
assertEqual(roots.length, 9, 'scan visits each root for themed and unthemed icons')
JS
