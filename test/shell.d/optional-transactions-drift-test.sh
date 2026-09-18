#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Menu guards are hand-curated, but their targets must keep matching what the
# recipes really request: an installer that gains a package without its
# transaction following would show a row the architecture cannot install.
# Deriving the transactions independently from the menu actions and the
# scripts they run turns that silent drift into a hard failure.
run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))

// Recipes whose package name is a variable resolved at runtime carry their
// base package here; the menu action itself is what would drift.
const overrides = {
  'install.ai.ollama': ['ollama'],
  'install.terminal.alacritty': ['alacritty'],
  'install.terminal.foot': ['foot'],
  'install.terminal.ghostty': ['ghostty'],
  'install.terminal.kitty': ['kitty']
}

// Split a menu action the way the shell would, honouring single quotes.
function tokenize(text) {
  const tokens = []
  let current = ''
  let quoted = false
  let seen = false
  for (const char of text) {
    if (char === "'") { quoted = !quoted; seen = true; continue }
    if (!quoted && /\s/.test(char)) {
      if (seen) tokens.push(current)
      current = ''
      seen = false
      continue
    }
    current += char
    seen = true
  }
  if (seen) tokens.push(current)
  return tokens
}

// Package names that follow omarchy-pkg-add / omarchy-pkg-aur-add in a run
// of script lines, with continuations joined and comments dropped. A shell
// metacharacter ends the command; a variable is a name the recipe resolves
// itself, so it is left to the overrides.
function packageTargetsIn(lines) {
  const joined = lines.join('\n').replace(/\\\n/g, ' ')
  const targets = {sync: [], aur: []}
  for (let line of joined.split('\n')) {
    line = line.replace(/#.*/, '')
    const pattern = /omarchy-pkg-(aur-)?add\s+([^;&|<>]*)/g
    let match
    while ((match = pattern.exec(line))) {
      const names = match[1] ? targets.aur : targets.sync
      for (const token of match[2].trim().split(/\s+/)) {
        const name = token.replace(/^["']|["']$/g, '')
        if (!name || name.includes('$')) continue
        if (!names.includes(name)) names.push(name)
      }
    }
  }
  return targets
}

// A recipe taking a selector installs from one case arm; the arm may hand
// off to a function defined in the same script, which is followed once.
function functionBodies(lines) {
  const bodies = {}
  for (let i = 0; i < lines.length; i++) {
    const match = lines[i].match(/^([a-z_]+)\(\)\s*\{\s*$/)
    if (!match) continue
    const body = []
    for (let j = i + 1; j < lines.length && lines[j] !== '}'; j++) body.push(lines[j])
    bodies[match[1]] = body
  }
  return bodies
}

function caseArm(lines, selector) {
  const start = lines.findIndex(line => new RegExp(`^\\s*'?${selector}'?\\)`).test(line))
  if (start < 0) return null
  const arm = []
  for (let i = start; i < lines.length; i++) {
    arm.push(lines[i].replace(/;;.*/, ''))
    if (/;;/.test(lines[i])) break
  }
  return arm
}

function scriptTransaction(command, selector) {
  const file = path.join(root, 'bin', command)
  if (!fs.existsSync(file)) return null
  const lines = fs.readFileSync(file, 'utf8').split('\n')
  if (!selector) return packageTargetsIn(lines)
  const arm = caseArm(lines, selector)
  if (!arm) return null
  const bodies = functionBodies(lines)
  const expanded = []
  for (const line of arm) {
    const call = line.trim().match(/^([a-z_]+)$/)
    if (call && bodies[call[1]]) expanded.push(...bodies[call[1]])
    else expanded.push(line)
  }
  return packageTargetsIn(expanded)
}

function deriveTransaction(item) {
  if (overrides[item.id]) return {sync: overrides[item.id], aur: []}
  const action = item.action || ''

  // The packages sit in the action itself, right after the display name.
  const direct = action.match(/omarchy-install-(?:and-launch|app|font) (.*)$/)
  if (direct) {
    const tokens = tokenize(direct[1])
    return tokens.length > 1 ? {sync: tokens[1].split(/\s+/), aur: []} : null
  }

  // The action runs a recipe, possibly through the floating terminal, which
  // takes the whole command as one quoted argument.
  const probe = action.replace(/^omarchy-launch-floating-terminal-with-presentation /, '')
  let tokens = tokenize(probe)
  if (tokens.length === 1) tokens = tokens[0].split(/\s+/)
  const command = tokens[0] || ''
  if (!/^omarchy-(install-|voxtype-install$)/.test(command)) return null
  const selector = /^omarchy-install-(browser|terminal|dev-env)$/.test(command) ? tokens[1] : ''
  return scriptTransaction(command, selector)
}

// An architecture-only guard can exempt a recipe from sync availability only
// when its actual package helpers use the AUR exclusively. AUR recipes may
// still choose an availability guard, as Emacs does.
function isAurException(item, targets) {
  return (item.when || '').startsWith('[[ $(uname -m)') &&
    targets.sync.length === 0 && targets.aur.length > 0
}

const architecture = {when: '[[ $(uname -m) == "aarch64" ]]'}
const availability = {when: 'omarchy-pkg-available example'}
assert(!isAurException(architecture, {sync: ['example'], aur: []}), 'sync recipes cannot bypass availability with architecture guards')
assert(isAurException(architecture, {sync: [], aur: ['example']}), 'pure AUR recipes can use architecture guards')
assert(!isAurException(availability, {sync: [], aur: ['example']}), 'pure AUR availability guards still participate in target comparison')
assert(!isAurException(architecture, {sync: ['primary'], aur: ['secondary']}), 'mixed recipes cannot bypass sync availability')
assertDeepEqual(packageTargetsIn(['omarchy-pkg-aur-add example && omarchy-install-example']), {sync: [], aur: ['example']}, 'chained AUR commands retain their backend and targets')

const derived = new Map()
const aurOnly = new Set()
for (const item of items) {
  if (!item.id.startsWith('install.') || !item.action) continue
  const targets = deriveTransaction(item)
  if (!targets) continue
  if (isAurException(item, targets)) {
    aurOnly.add(item.id)
    continue
  }
  const packages = [...new Set([...targets.sync, ...targets.aur])]
  if (packages.length) derived.set(item.id, packages)
}
assert(derived.size > 0, 'optional transactions can be derived from the install recipes')

const committed = new Map(items.filter(item => (item.when || '').startsWith('omarchy-pkg-available ')).map(item => {
  const targets = item.when.replace(/^omarchy-pkg-available /, '')
  return [item.id, targets.split(/\s+/)]
}))

// Compare as sets: the menu owns row order and comments, the recipes
// own the contents.
const render = map => [...map.keys()].sort().map(id => `${id}|${[...map.get(id)].sort().join(' ')}`).join('\n')
const wanted = render(derived)
const actual = render(committed)
assert(
  wanted === actual,
  'optional menu targets match the install recipes',
  `derived from the recipes:\n${wanted}\n\ndeclared in menu conditions:\n${actual}`
)

// Every derived sync row and declared AUR row is guarded: a guard without a
// transaction reports unavailable for every architecture.
const guarded = items.filter(item => /^(omarchy-pkg-available |\[\[ \$\(uname -m\))/.test(item.when || '')).map(item => item.id).sort()
assertDeepEqual(guarded, [...derived.keys(), ...aurOnly].sort(), 'optional install guards cover exactly the rows with a transaction')
JS
