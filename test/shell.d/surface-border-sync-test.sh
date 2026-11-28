#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const borderQml = fs.readFileSync(path.join(root, 'shell/Commons/Border.qml'), 'utf8')
const shellTomlTpl = fs.readFileSync(path.join(root, 'default/themed/shell.toml.tpl'), 'utf8')

assert(
  /active-border-width\s*=/.test(shellTomlTpl),
  'shell.toml.tpl defines active-border-width in [hyprland]'
)

assert(
  /value\("hyprland",\s*"active-border-width"\)/.test(borderQml),
  'Border.qml checks hyprland active-border-width in surfaceWidths'
)

// Unit test surface width fallback resolution logic
const geometrySource = fs.readFileSync(path.join(root, 'shell/Commons/BorderGeometry.js'), 'utf8').replace(/^\.pragma library\n/, '')
const sandbox = { console }
vm.createContext(sandbox)
vm.runInContext(geometrySource, sandbox)

function makeSurfaceWidths(shellValues) {
  function value(section, key) {
    var v = shellValues[section + '.' + key]
    return (v === undefined || v === null) ? '' : v
  }
  function valueOr(section, keys) {
    for (var i = 0; i < keys.length; i++) {
      var v = value(section, keys[i])
      if (String(v).length > 0) return v
    }
    return ''
  }
  return function surfaceWidths(section, token, fallbackWidth) {
    var base = valueOr(section, token === 'border' ? ['border-width'] : [token + '-width', 'border-width'])
    if (String(base).length === 0) {
      base = value('hyprland', 'active-border-width')
    }
    return sandbox.parseWidthSpec(base, fallbackWidth)
  }
}

// Case 1: Specific section override takes precedence
const withExplicitMenu = makeSurfaceWidths({
  'menu.border-width': '3',
  'hyprland.active-border-width': '1'
})
assertDeepEqual(
  withExplicitMenu('menu', 'border', 2),
  { top: 3, right: 3, bottom: 3, left: 3 },
  'surfaceWidths honors explicit section border-width override over hyprland active-border-width'
)

// Case 2: No section override; inherits hyprland active-border-width
const withHyprlandWidth = makeSurfaceWidths({
  'hyprland.active-border-width': '1'
})
assertDeepEqual(
  withHyprlandWidth('menu', 'border', 2),
  { top: 1, right: 1, bottom: 1, left: 1 },
  'surfaceWidths falls back to hyprland active-border-width when section override is absent'
)

// Case 3: Neither defined; falls back to component fallbackWidth
const withoutOverrides = makeSurfaceWidths({})
assertDeepEqual(
  withoutOverrides('menu', 'border', 2),
  { top: 2, right: 2, bottom: 2, left: 2 },
  'surfaceWidths falls back to component fallbackWidth when no tokens are defined'
)
JS
