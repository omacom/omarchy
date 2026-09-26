#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

// manifestHasKind is the single gate for every capability a plugin facade
// carries: menu plugins get appLibrary through it, bar plugins get their bar
// grant through pluginHasBarCapabilities, and indicator clones are recognized
// by it. Whatever it rejects is dropped without a warning, so it has to answer
// the same way for every shape of manifest the host hands it.
const helper = shellSource.match(/function manifestHasKind\(manifest, kind\) \{[\s\S]*?\n {2}\}/)
assert(helper, 'shell defines the manifestHasKind capability gate')
eval(helper[0])

assert(
  manifestHasKind({ kinds: ['menu', 'bar-widget'] }, 'menu'),
  'a manifest read straight off installedPlugins carries its kinds'
)

// The regression. createScopedPluginShell is reached twice for the same
// plugin, and the second call comes from the panel Instantiator's delegate,
// which returns a manifest that crossed a QVariant boundary. That copy indexes
// like an array without being one, and an Array.isArray gate answered false —
// rebuilding the cached facade with appLibrary null, so the menu listed no
// apps while the plugin kept loading and reporting itself healthy.
assert(
  manifestHasKind({ kinds: { 0: 'menu', 1: 'bar-widget', length: 2 } }, 'menu'),
  'a manifest handed back by a model delegate still carries its kinds'
)
assert(
  !manifestHasKind({ kinds: { 0: 'bar-widget', length: 1 } }, 'menu'),
  'an array-like manifest is still denied a kind it does not declare'
)

// Accepting anything indexable must not start matching the characters of a
// string, which would grant "menu" to a manifest declaring kinds: "menu-ish".
assert(!manifestHasKind({ kinds: 'menu' }, 'menu'), 'a string kinds field grants nothing')
assert(!manifestHasKind({ kinds: 'm' }, 'm'), 'a string kinds field is not indexed character by character')

// Accepting an array-like grants nothing a real Array would not have, because
// the registry refuses a manifest whose kinds is not a non-empty Array long
// before it reaches installedPlugins. Anything indexable that gets this far is
// a QVariant copy of a list that was already validated, so a plugin cannot
// declare kinds as an object in its manifest to talk its way past the gate.
const registrySource = fs.readFileSync(root + '/shell/services/PluginRegistry.qml', 'utf8')
assert(
  /!Array\.isArray\(manifest\.kinds\) \|\| manifest\.kinds\.length === 0/.test(registrySource),
  'the registry still rejects a manifest whose kinds is not a non-empty array'
)

assert(!manifestHasKind(null, 'menu'), 'a missing manifest grants nothing')
assert(!manifestHasKind({}, 'menu'), 'a manifest with no kinds grants nothing')
assert(!manifestHasKind({ kinds: [] }, 'menu'), 'an empty kinds list grants nothing')
JS
