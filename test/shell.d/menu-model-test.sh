#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The menu model is where both JSONC sources and the extension merge are
# decided. Each case here used to fail silently: one trailing comment made the
# whole menu parse to nothing, and an alias-only override wiped the default
# row's action (a childless menu, which is not shown at all).
run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const { execFileSync } = require('child_process')
const M = requireFromRoot('shell/plugins/menu/MenuModel.js')

// ---- JSONC: an annotated entry must not empty the file --------------------
const annotated = '{"items":{"a":{"label":"A"}, // note\n}}'
assertEqual(M.parseMenuJsonc(annotated).length, 1, 'a trailing comma before a line comment still parses')
assertEqual(M.parseMenuJsonc(annotated)[0].label, 'A', 'the annotated entry keeps its label')

assertEqual(M.parseMenuJsonc('{"items":{"a":{"label":"A"} /* note */,}}').length, 1, 'a block comment before a trailing comma parses')
assertEqual(M.parseMenuJsonc('\uFEFF{"items":{"a":{"label":"A"}}}').length, 1, 'a UTF-8 BOM does not empty the menu')

const comma = M.parseMenuJsonc('{"items":{"a":{"label":"x,}"}}}')
assertEqual(comma[0].label, 'x,}', 'a comma-brace inside a string survives')

// ---- merge: an alias-only override keeps the default row -------------------
const defaults = M.parseMenuJsonc('{"items":{"system":{"label":"System","action":"act","icon":"I","when":"true"}}}')
const aliasOnly = M.parseMenuJsonc('{"items":{"system":{"aliases":["x"]}}}')
const merged = M.mergeMenuSources(defaults, aliasOnly, 'Go').items.system
assertEqual(merged.action, 'act', 'an alias-only override keeps the default action')
assertEqual(merged.label, 'System', 'an alias-only override keeps the default label')
assertEqual(merged.icon, 'I', 'an alias-only override keeps the default icon')
assertEqual(merged.when, 'true', 'an alias-only override keeps the default guard')
assertEqual(merged.kind, 'action', 'the merged row is still an action')

const renamed = M.mergeMenuSources(defaults, M.parseMenuJsonc('{"items":{"system":{"label":"Mine"}}}'), 'Go').items.system
assertEqual(renamed.label, 'Mine', 'an explicit label still wins')
assertEqual(renamed.action, 'act', '... while the rest of the row survives')

const cleared = M.mergeMenuSources(defaults, M.parseMenuJsonc('{"items":{"system":{"action":""}}}'), 'Go').items.system
assertEqual(cleared.action, '', 'an explicit empty action clears it')
assertEqual(cleared.kind, 'menu', 'a row with no action becomes a submenu')

// ---- guards: the menu id is data, never shell ------------------------------
// The generated batch probes packages and may cache the answer in
// $XDG_RUNTIME_DIR, so this case runs against a scratch home and stub
// commands: tests must not touch the developer's session (docs/testing.md).
const sandbox = fs.mkdtempSync(path.join(os.tmpdir(), 'omarchy-menu-model-test-'))
process.on('exit', () => fs.rmSync(sandbox, { recursive: true, force: true }))
const stubBin = path.join(sandbox, 'bin')
const runDir = path.join(sandbox, 'run')
fs.mkdirSync(stubBin)
fs.mkdirSync(runDir)
for (const stub of ['pacman', 'pacman-conf']) {
  fs.writeFileSync(path.join(stubBin, stub), '#!/bin/bash\nexit 1\n', { mode: 0o755 })
}
const env = {
  ...process.env,
  HOME: path.join(sandbox, 'home'),
  XDG_RUNTIME_DIR: runDir,
  OMARCHY_PACMAN_DB_PATH: path.join(sandbox, 'pacman-db'),
  PATH: stubBin + ':' + process.env.PATH
}
fs.mkdirSync(env.HOME)
const marker = path.join(sandbox, 'guard-marker')
const hostile = 'x; touch ' + marker + '; #'
const script = M.guardScript({ [hostile]: { id: hostile, when: 'true' } })
const out = execFileSync('bash', ['-c', script], { encoding: 'utf8', env })
assertEqual(out.trim(), hostile + ':w:1', 'a hostile id is answered verbatim')
assert(!fs.existsSync(marker), 'a hostile id does not run shell')
JS
