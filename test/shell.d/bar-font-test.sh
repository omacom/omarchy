#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/bar/FontFamily.js'), 'utf8').replace(/^\.pragma library\n/, '')
const fonts = {}
vm.createContext(fonts)
vm.runInContext(source, fonts)

const cases = [
  ['normal', 'JetBrainsMono Nerd Font', ['JetBrainsMono Nerd Font Propo'], 'JetBrainsMono Nerd Font Propo'],
  ['mono', 'JetBrainsMono Nerd Font Mono', ['JetBrainsMono Nerd Font Propo'], 'JetBrainsMono Nerd Font Propo'],
  ['already Propo', 'JetBrainsMono Nerd Font Propo', [], 'JetBrainsMono Nerd Font Propo'],
  ['absent sibling', 'JetBrainsMono Nerd Font', ['Other Nerd Font Propo'], 'JetBrainsMono Nerd Font'],
  ['plain font', 'DejaVu Sans Mono', ['DejaVu Sans Propo'], 'DejaVu Sans Mono'],
  ['short NF', 'CaskaydiaMono NF', ['CaskaydiaMono NFP'], 'CaskaydiaMono NFP'],
  ['short NFM', 'CaskaydiaMono NFM', ['CaskaydiaMono NFP'], 'CaskaydiaMono NFP'],
  ['short NFP', 'CaskaydiaMono NFP', [], 'CaskaydiaMono NFP'],
  ['case insensitive', 'jetbrainsmono nerd font', ['JetBrainsMono Nerd Font Propo'], 'JetBrainsMono Nerd Font Propo'],
  ['no substring match', 'Test Nerd Font', ['Test Nerd Font Propo ExtraLight'], 'Test Nerd Font'],
  ['custom family', 'Ransom Mono NF Propo Unruly', [], 'Ransom Mono NF Propo Unruly'],
  ['empty family', '', [], '']
]
for (const [description, family, available, expected] of cases)
  assertEqual(fonts.preferPropo(family, available), expected, `bar font: ${description}`)

// Exercise the actual binding body with a changing Style source, not a copy
// of the fallback policy. This guards retaining the alias and explicit fonts.
const bar = fs.readFileSync(path.join(root, 'shell/plugins/bar/Bar.qml'), 'utf8')
const binding = bar.match(/property string fontFamily: \{([\s\S]*?)\n  \}/)
assert(Boolean(binding), 'bar has a computed font binding')
const context = {
  FontFamily: fonts,
  Qt: { fontFamilies: () => ['CaskaydiaMono Nerd Font Propo'] },
  Style: { font: { family: 'monospace', resolvedFamily: 'CaskaydiaMono Nerd Font Mono' } }
}
vm.createContext(context)
const evaluate = () => vm.runInContext(`(function () {${binding[1]}\n})()`, context)
assertEqual(evaluate(), 'CaskaydiaMono Nerd Font Propo', 'bar uses installed Propo sibling')
context.Style.font.resolvedFamily = 'DejaVu Sans Mono'
assertEqual(evaluate(), 'monospace', 'bar keeps live alias when sibling is absent')
context.Style.font.family = 'Custom UI Font'
assertEqual(evaluate(), 'Custom UI Font', 'bar respects explicit shared family')
context.Style.font.family = 'monospace'
context.Style.font.resolvedFamily = 'CaskaydiaMono Nerd Font'
assertEqual(evaluate(), 'CaskaydiaMono Nerd Font Propo', 'bar follows another resolved family change')
JS
