#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
JS

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const block = source.match(/Flow\s*\{\s*id: providerSwitch([\s\S]*?)\n\s*Repeater/)[1]
const expression = name => block.match(new RegExp('readonly property (?:real|int) ' + name + ': ([^\\n]+)'))[1]
const columnsBody = block.match(/readonly property int columns: \{([\s\S]*?)\n\s*\}/)[1]
const chipExpression = block.match(/readonly property real chipWidth: ([\s\S]*)$/)[1]
const columns = new Function('root', 'maxFittingCols', columnsBody)
function layout(count, width, scale = 1, gap) {
  const Style = { space: px => Math.max(1, Math.round(px * scale)) }
  const spacing = gap ?? Style.space(4)
  const minChipWidth = eval(expression('minChipWidth'))
  const maxFittingCols = eval(expression('maxFittingCols'))
  const root = { providers: Array(count).fill({}) }
  const n = columns(root, maxFittingCols)
  const chip = new Function('columns', 'width', 'spacing', 'minChipWidth', 'return ' + chipExpression)(n, width, spacing, minChipWidth)
  assert(n >= 1 && chip > 0, 'layout remains positive for ' + count + ' providers')
  if (width > 0) assert(n * chip + (n - 1) * spacing <= width, 'chips fit available width for ' + count + ' providers')
  return n
}
for (const [count, expected] of [[0,1],[1,1],[2,2],[3,3],[4,2],[5,3],[8,3]])
  assert(layout(count, 352) === expected, count + ' providers use expected columns at standard width')
assert(layout(8,480) === 4, 'eight providers balance as two rows when four fit')
assert(layout(4,480) === 4, 'four providers stay in one row when they fit')
assert(layout(8,90) === 1, 'narrow panel uses one column')
layout(8,0)
for (const scale of [0.833,1,1.333,1.833])
  for (const width of [90,200,352,480])
    for (const gap of [0,4,8]) layout(8,width,scale,gap)
assert(/visible: providers.length > 0/.test(source), 'empty provider list keeps stock self-hiding behavior')
assert(/visible: root.providers.length > 1/.test(block), 'single provider needs no selector')
assert(/text: chipLabel.elidedText/.test(source) && /elide: Text.ElideRight/.test(source), 'provider names elide to the right')
assert(/tooltipText: modelData.providerName/.test(source), 'tooltip retains the full provider name')
assert(/font.bold: providerChip.selected/.test(source), 'elision measures the selected bold font')
assert(/providerChip._reservedContentLeftInset/.test(source) && /providerChip._reservedBorderRight/.test(source), 'elision reserves button padding and borders')
JS
