#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const color = requireFromRoot('shell/plugins/clipboard/ColorParse.js')

function rgb8(text) {
  const c = color.parse(text)
  if (!c) return null
  return [Math.round(c.r * 255), Math.round(c.g * 255), Math.round(c.b * 255), Math.round(c.a * 100) / 100]
}

assertDeepEqual(rgb8('E1D9CB'), [225, 217, 203, 1], 'bare six-digit hex parses')
assertDeepEqual(rgb8('  #e1d9cb\n'), [225, 217, 203, 1], 'hex parses with prefix, lowercase, and surrounding whitespace')
assertDeepEqual(rgb8('#fff'), [255, 255, 255, 1], 'three-digit hex expands')
assertDeepEqual(rgb8('#0f08'), [0, 255, 0, 0.53], 'four-digit hex carries alpha')
assertDeepEqual(rgb8('80ff0080'), [128, 255, 0, 0.5], 'bare eight-digit hex carries alpha')
assertEqual(rgb8('fff'), null, 'bare three-digit hex is not a color')
assertEqual(rgb8('bad'), null, 'bare three-letter words are not colors')
assertEqual(rgb8('#12345'), null, 'five-digit hex is not a color')
assertEqual(rgb8('#ggg'), null, 'non-hex characters are not a color')

assertDeepEqual(rgb8('rgb(255, 0, 0)'), [255, 0, 0, 1], 'legacy rgb() parses')
assertDeepEqual(rgb8('rgba(0, 0, 255, 0.5)'), [0, 0, 255, 0.5], 'legacy rgba() parses')
assertDeepEqual(rgb8('rgb(255 0 0 / 50%)'), [255, 0, 0, 0.5], 'modern rgb() with slash alpha parses')
assertDeepEqual(rgb8('rgb(100% 0% 0%)'), [255, 0, 0, 1], 'percentage rgb() parses')
assertEqual(rgb8('rgb(1, 2)'), null, 'rgb() with two channels is not a color')

assertDeepEqual(rgb8('hsl(120, 100%, 50%)'), [0, 255, 0, 1], 'legacy hsl() parses')
assertDeepEqual(rgb8('hsl(120deg 100% 50% / 0.3)'), [0, 255, 0, 0.3], 'modern hsl() with deg and slash alpha parses')
assertDeepEqual(rgb8('hsla(0.5turn 50% 50%, 0.8)'), [64, 191, 191, 0.8], 'hsla() with turn angle parses')
assertDeepEqual(rgb8('hsl(120 100 50)'), [0, 255, 0, 1], 'unitless hsl() channels are percentages')

assertDeepEqual(rgb8('oklch(70% 0.15 200)'), [0, 185, 195, 1], 'oklch() parses')
assertDeepEqual(rgb8('oklch(0.7 0.15 200deg / 50%)'), [0, 185, 195, 0.5], 'oklch() with alpha parses')
assertDeepEqual(rgb8('oklab(0.5 0.1 -0.1)'), [129, 69, 154, 1], 'oklab() parses')
assertDeepEqual(rgb8('oklch(100% 0 0)'), [255, 255, 255, 1], 'oklch() white is white')
assertDeepEqual(rgb8('oklch(0% none none)'), [0, 0, 0, 1], 'oklch() none channels are zero')

assertEqual(rgb8('url(foo)'), null, 'other functions are not colors')
assertEqual(rgb8('hello'), null, 'plain words are not colors')
assertEqual(rgb8('orange'), null, 'named colors are not recognized')
assertEqual(rgb8('E1D9CB\nF05F22'), null, 'multi-line text is not a color')
assertEqual(rgb8(''), null, 'empty text is not a color')
JS
