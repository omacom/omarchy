#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command magick

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
backgrounds="$home/.local/state/omarchy/current/theme/backgrounds"
mkdir -p "$backgrounds"

sample() {
  HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-bar-text-color" \
    top 10 '#ffffff' '#000000' --background "$backgrounds/test.png" --screen 100x100 "$@"
}

# Focal extremes select entirely different cover windows, so a centered
# approximation would choose the wrong foreground on one of them.
magick -size 300x100 xc:black -fill white -draw 'rectangle 0,0 99,99' "$backgrounds/test.png"
printf '[defaults]\nfocal = "0 0.5"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#000000" ]] || fail "left focal samples the white crop"
printf '[defaults]\nfocal = "1 0.5"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#ffffff" ]] || fail "right focal samples the black crop"
magick -size 100x300 xc:black -fill white -draw 'rectangle 0,0 99,99' "$backgrounds/test.png"
printf '[defaults]\nfocal = "0.5 0"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#000000" ]] || fail "top focal samples the white crop"
printf '[defaults]\nfocal = "0.5 1"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#ffffff" ]] || fail "bottom focal samples the black crop"
pass "bar sampling follows horizontal and vertical focal windows"

# The fit foreground leaves the top bar in a letterbox. A white cover at 35%
# opacity lightens the configured gray enough to change the contrast winner.
magick -size 200x20 xc:white "$backgrounds/test.png"
printf '[defaults]\nfill = "fit"\nfill_color = "#555555"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#ffffff" ]] || fail "solid letterbox samples its declared fill"
printf 'backdrop = "blur"\n' >>"$backgrounds/backgrounds.toml"
[[ $(sample) == "#000000" ]] || fail "blur letterbox samples the subdued cover"
pass "bar sampling includes the blurred cover behind fitted images"

# Same canonical, two geometries, independent variants and contrast results.
magick -size 100x100 xc:black "$backgrounds/test.png"
magick -size 200x100 xc:white "$backgrounds/test@wide.png"
printf '[defaults]\nfill = "crop"\n' >"$backgrounds/backgrounds.toml"
[[ $(sample) == "#ffffff" ]] || fail "square display samples the black canonical"
wide=$(HOME="$home" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-bar-text-color" top 20 '#ffffff' '#000000' --background "$backgrounds/test.png" --screen 200x100 --scale 2)
[[ $wide == "#000000" ]] || fail "wide display samples its white variant"
pass "each display samples its own geometry and variant"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
function productionFunction(name) {
  const start = source.indexOf('  function ' + name + '(')
  assert(start >= 0, name + ' exists')
  return source.slice(start, source.indexOf('\n  }', start) + 4)
}
const context = vm.createContext({
  useTransparentForeground: true, screenForegrounds: { square: '#ffffff', wide: '#000000' },
  barForeground: '#aaaaaa', shell: null, pluginBarApis: {},
  pluginBarApiComponent: { createObject(parent, properties) { return properties } },
  targetWindow(item) { return { screen: item.screen } },
  bindPluginBarApi(api, screen) { api.sampleScreen = screen },
  pluginBarApiUsed() { return false }, releasePluginObjects(id) { this.released.push(id) },
  released: []
})
context.root = context
for (const name of ['foregroundForScreen', 'foregroundForItem', 'pluginBarApiFor', 'prunePluginBarApis']) {
  vm.runInContext(productionFunction(name), context)
}
const square = { name: 'square' }, wide = { name: 'wide' }
assertEqual(context.foregroundForItem({screen: square}), '#ffffff', 'square widget gets its light foreground')
assertEqual(context.foregroundForItem({screen: wide}), '#000000', 'wide widget gets its dark foreground')
context.useTransparentForeground = false
assertEqual(context.foregroundForItem({screen: wide}), '#aaaaaa', 'opaque bars use the theme foreground')
const a = context.pluginBarApiFor('example.widget', 'example.widget', false, square)
const b = context.pluginBarApiFor('example.widget', 'example.widget', false, wide)
assert(a !== b, 'third-party widgets receive distinct presentation facades per screen')
assertEqual(a.pluginId, b.pluginId, 'per-screen presentation retains the original plugin authority scope')
assertEqual(b.sampleScreen.name, 'wide', 'wide facade binds to the correct screen')
context.prunePluginBarApis()
assertDeepEqual(Array.from(context.released), ['example.widget', 'example.widget'], 'facade pruning releases by plugin ID rather than presentation cache key')
JS

for flag in --background --screen --scale; do
  rc=0
  HOME="$home" PATH="$ROOT/bin:$PATH" timeout 2 bash "$ROOT/bin/omarchy-bar-text-color" top 10 '#ffffff' '#000000' "$flag" >/dev/null || rc=$?
  (( rc != 124 )) || fail "missing $flag value must not hang"
done
pass "missing bar sampling arguments cannot hang"
