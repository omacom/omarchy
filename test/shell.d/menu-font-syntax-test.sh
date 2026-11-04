#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const directory = path.join(root, 'shell/plugins/menu')
const syntax = {}
vm.createContext(syntax)
vm.runInContext(fs.readFileSync(path.join(directory, 'FontSyntax.js'), 'utf8'), syntax)
const colors = syntax.palette('red = "#ff0000"\ngreen = "#00ff00"\nyellow = "#ffff00"\nblue = "#0000ff"\nmagenta = "#ff00ff"\ncyan = "#00ffff"')
assertEqual(Object.keys(colors).length, 6, 'parse theme syntax colors')
const menu = fs.readFileSync(path.join(directory, 'Menu.qml'), 'utf8')
const samples = vm.runInNewContext(menu.match(/fontPreviewSamples: (\[[\s\S]*?\n  \])/)[1])
samples.forEach((sample, index) => {
  const highlighted = syntax.highlight(sample, index > 0, colors)
  assertEqual(highlighted.replace(/<font color="#[0-9a-fA-F]{6}">|<\/font>/g, ''), syntax.escape(sample), `sample ${index} preserves all characters`)
  assert(index === 0 ? !highlighted.includes('<font') : highlighted.includes('<font'), `sample ${index} uses expected highlighting`)
})
assert(!syntax.highlight('<img src="https://example.invalid">', true, colors).includes('<img'), 'escape markup-shaped preview text')
assert(!syntax.highlight('const x', true, {magenta: '"><img src="bad">'}).includes('<img'), 'reject markup in palette values')
assertEqual(syntax.highlight('const x < 3', true, {}), 'const x &lt; 3', 'missing palette preserves escaped foreground text')
const preview = menu.slice(menu.indexOf('                FontPreview {'), menu.indexOf('                FontPreview {') + 1300)
assert(preview.includes('color: root.foreground') && !preview.includes('root.selectedText'), 'preview foreground stays unchanged on selection')
JS
