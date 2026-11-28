#!/bin/bash

# #15360: a panel plugin's manifest arrives through a QML model, so `kinds` is a V4Sequence and
# `Array.isArray()` rejects it. Third-party menu plugins were then given a null appLibrary. The
# predicate is in PluginManifest.js so both shapes can be tested without a compositor.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const manifest = requireFromRoot('shell/services/PluginManifest.js')
const shellSource = fs.readFileSync(root + '/shell/shell.qml', 'utf8')

assert(manifest.hasKind({ kinds: ['menu', 'bar-widget'] }, 'menu'),
  'a JS array declares its kinds')
assert(!manifest.hasKind({ kinds: ['bar-widget'] }, 'menu'),
  'a JS array without the kind is not a match')

// What a manifest looks like after the model has carried it: indexable, with a length, and not a
// JS array. This is the shape that left third-party menu plugins without an app library.
const sequence = { 0: 'menu', 1: 'bar-widget', length: 2 }
assert(manifest.hasKind({ kinds: sequence }, 'menu'), 'a V4Sequence declares its kinds')
assert(manifest.hasKind({ kinds: sequence }, 'bar-widget'), 'every kind in a V4Sequence is read')
assert(!manifest.hasKind({ kinds: sequence }, 'panel'), 'a V4Sequence is not read past its length')

assert(!manifest.hasKind({ kinds: [] }, 'menu'), 'an empty list matches nothing')
assert(!manifest.hasKind({}, 'menu'), 'a manifest without kinds matches nothing')
assert(!manifest.hasKind(null, 'menu'), 'a missing manifest matches nothing')
assert(!manifest.hasKind({ kinds: 'menu' }, 'menu'), 'a kind string is not a kind list')

assert(/return PluginManifest\.hasKind\(manifest, kind\)/.test(shellSource),
  'the shell uses the shared predicate, so the rule cannot drift back into the QML')
JS
