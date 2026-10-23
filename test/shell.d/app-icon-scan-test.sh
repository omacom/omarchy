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
  [system, 'icons/parent/apps/inherited.svg'],
  [system, 'icons/parent/apps/shared.svg'],
  [system, 'icons/unrelated/apps/unselected.svg'],
  [pixmaps, 'fallback.png']
]
for (const [base, relative] of files) {
  const file = path.join(base, relative)
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, '')
}

fs.writeFileSync(path.join(home, '.icons/theme/index.theme'), '[Icon Theme]\nInherits=parent\n')

// Redirect the fixed pixmaps path into the fixture; traverse real icon trees.
const stubDir = path.join(scratch, 'bin')
const calls = path.join(scratch, 'find-calls')
const starts = path.join(scratch, 'find-starts')
fs.mkdirSync(stubDir)
fs.writeFileSync(path.join(stubDir, 'find'), `#!/bin/bash
options=()
if [[ $1 == "-L" || $1 == "-H" ]]; then options+=("$1"); shift; fi
printf '%s\\n' "$1" >> "$FIND_CALLS"
for arg in "$@"; do
  case $arg in "(" | "!" | -*) break ;; esac
  printf '%s\\n' "$arg" >> "$FIND_STARTS"
done
if [[ $1 == "/usr/share/pixmaps" ]]; then
  shift
  /usr/bin/find "\${options[@]}" "$PIXMAPS" "$@"
else
  /usr/bin/find "\${options[@]}" "$@"
fi
`, { mode: 0o755 })

fs.writeFileSync(path.join(stubDir, 'gsettings'), `#!/bin/bash\necho "'theme'"\n`, { mode: 0o755 })

const qml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const body = qml.split('  function iconIndexScanCommand() {')[1].split('\n  function indexIconLine(')[0].replace(/\n  }\s*$/, '')
const command = new Function(body)()
const result = spawnSync('bash', ['-c', command], {
  encoding: 'utf8',
  env: { ...process.env, HOME: home, XDG_DATA_HOME: path.join(home, '.local/share'), XDG_DATA_DIRS: `${local}:${system}`, PATH: `${stubDir}:${process.env.PATH}`, FIND_CALLS: calls, FIND_STARTS: starts, PIXMAPS: pixmaps }
})
assertEqual(result.status, 0, 'icon scan completes')
const lines = result.stdout.trim().split('\n')
assertEqual(lines.length, files.length - 2, 'scan includes selected and inherited app/device icons and excludes action and unrelated icons')
const themeLines = lines.filter(value => value.includes('/theme/'))
const firstPng = themeLines.findIndex(value => value.endsWith('.png'))
assert(themeLines.slice(0, firstPng).every(value => value.endsWith('.svg')), 'SVG icons are emitted before PNG icons within a theme')
assert(themeLines.slice(firstPng).every(value => value.endsWith('.png')), 'no SVG icons follow PNG icons within a theme')
const firstParent = lines.findIndex(value => value.includes('/parent/'))
assert(lines.slice(0, firstParent).every(value => value.includes('/theme/')), 'selected theme is exhausted before inherited SVG icons')
assert(lines.indexOf(path.join(system, 'icons/parent/apps/inherited.svg')) < lines.indexOf(path.join(pixmaps, 'fallback.png')), 'inherited icons precede pixmaps fallback')
assert(!lines.some(value => value.includes('/unrelated/')), 'uninherited themes cannot select an application icon')
const shared = themeLines.filter(value => path.basename(value).startsWith('shared.'))
assertDeepEqual(shared, [path.join(local, 'icons/theme/apps/shared.svg'), path.join(system, 'icons/theme/apps/shared.svg'), path.join(home, '.icons/theme/apps/shared.png')], 'scan preserves format preference and XDG directory precedence')
assertDeepEqual(lines.filter(value => path.basename(value) === 'pngonly.png'), [path.join(local, 'icons/theme/apps/pngonly.png'), path.join(system, 'icons/theme/apps/pngonly.png')], 'scan preserves directory precedence for PNG-only icons')
assert(lines.includes(path.join(system, 'icons/theme/apps/name with spaces.png')), 'scan preserves spaces in filenames')
const roots = fs.readFileSync(calls, 'utf8').trim().split('\n')
assertEqual(new Set(roots).size, 5, 'scan visits all icon roots and pixmaps')
assertEqual(roots.length, 5, 'scan visits each root only once')
const startPoints = fs.readFileSync(starts, 'utf8').trim().split('\n')
assert(startPoints.every(value => value === '/usr/share/pixmaps' || ['theme', 'parent'].includes(path.basename(value))), 'scan starts at the themes it searches rather than walking every theme in a root')
assert(startPoints.includes(path.join(system, 'icons/parent')), 'scan starts at inherited themes as well as the selected one')
JS
