#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ROOT="$ROOT" run_node_test <<'JS'
const fs = require('fs')

// AppGrid.qml needs Quickshell, so it cannot be loaded here. Its arrow-key
// logic is plain JavaScript, though, so the function is lifted out of the
// source and run on a stand-in grid: what is tested is the code that ships.
const raw = fs.readFileSync(path.join(root, 'shell/plugins/dock/AppGrid.qml'), 'utf8')

// Comments are stripped so a note about what the code no longer does cannot
// fail a check on what it does.
const source = raw.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '').replace(/\s\/\/ .*$/gm, '')

function functionBody(name) {
  const start = source.indexOf(`function ${name}(`)
  if (start < 0) fail(`AppGrid.qml defines ${name}`)
  const open = source.indexOf('{', source.indexOf(')', start))
  let depth = 0
  for (let i = open; i < source.length; i++) {
    if (source[i] === '{') depth++
    else if (source[i] === '}' && --depth === 0) return source.slice(open + 1, i)
  }
  return fail(`AppGrid.qml closes ${name}`)
}

const selectRows = new Function('root', 'rows', functionBody('selectRows'))

// The app selectRows ends on for a grid of `count` apps in `columns` columns,
// with `index` selected.
function move(index, rows, count = 25, columns = 7) {
  const grid = {
    selectedIndex: index,
    columns,
    apps: new Array(count),
    selectIndex(next) { grid.selectedIndex = next }
  }
  selectRows(grid, rows)
  return grid.selectedIndex
}

// --- arrow keys ---------------------------------------------------------------
// 25 apps in 7 columns: rows 0-2 are full, row 3 holds apps 21-24.
assertEqual(move(3, 1), 10, 'Down moves to the app below')
assertEqual(move(10, -1), 3, 'Up moves to the app above')
assertEqual(move(3, -1), 3, 'Up on the first row stays put instead of jumping to the first app')
assertEqual(move(22, 1), 22, 'Down on the last row stays put instead of jumping to the last app')
assertEqual(move(20, 1), 24, 'Down below a short last row lands on its last app')
assertEqual(move(17, 1), 24, 'Down lands on the app directly below when there is one')
assertEqual(move(17, -1), 10, 'Up from the row above a short row is a plain step')
assertEqual(move(17, -3), 3, 'a page up that would leave the grid lands on the first row in the same column')
assertEqual(move(5, 3), 24, 'a page down that would leave the grid lands on the last app')
assertEqual(move(3, 3), 24, 'a page down that fits lands on the app that far below')
assertEqual(move(0, 1, 0), 0, 'an empty grid has nowhere to go')
assertEqual(move(0, 1, 1), 0, 'a single app has nowhere to go')
assertEqual(move(2, 1, 5, 1), 3, 'a single column moves one app at a time')

// Whatever the size of the grid, a move only goes the way it was asked, never
// wraps, never leaves the grid, and goes no further than it was asked.
let moves = 0
for (let count = 1; count <= 40; count++) {
  for (let columns = 1; columns <= 8; columns++) {
    for (let index = 0; index < count; index++) {
      for (let rows = -4; rows <= 4; rows++) {
        const next = move(index, rows, count, columns)
        const from = Math.floor(index / columns)
        const to = Math.floor(next / columns)
        const ok = next >= 0 && next < count
          && (rows === 0 ? next === index : true)
          && (rows > 0 ? to >= from && to <= from + rows : true)
          && (rows < 0 ? to <= from && to >= from + rows : true)
          && (next === index || to !== from)
          && (rows > 0 ? next >= index : next <= index)
        if (!ok) fail('a move stays inside the grid and goes the way it was asked',
          `count ${count}, columns ${columns}, index ${index}, rows ${rows} gave ${next}`)
        moves++
      }
    }
  }
}
pass(`a move stays inside the grid and goes the way it was asked (${moves} moves)`)

// --- the grid, held to what the change set out to do ---------------------------
// The selection tile is as tall as its icon and name, not as its cell: a cell
// always has room for two lines, so a tile cut to the cell leaves empty space
// below a one-line name.
const tile = /Rectangle\s*\{\s*id:\s*tile\b[^}]*\}/.exec(source)
assert(tile !== null, 'the selection is a tile of its own')
assert(/height:[^\n]*label\.contentHeight/.test(tile[0]), 'the selection tile is as tall as the name it holds')
assert(!/height:[^\n]*cellHeight/.test(tile[0]), 'the selection tile is not cut to the cell, which would leave empty space below a one-line name')

assert(/FilterInput\s*\{[^}]*keyHandler:\s*keyCatcher/.test(source), 'the search line is a FilterInput the grid handles keys for, so input methods reach it')
assert(!/root\.filterText\s*\+\s*event\.text/.test(source), 'the grid does not type into the search itself, which would leave input methods out')
assert(!/Qt\.callLater\(function\(\) \{ keyCatcher\.forceActiveFocus/.test(source), 'focus goes to the search line, not to the key catcher behind it')

assert(/PointerMoveGate\s*\{/.test(source) && /pointerGate\.moved\(/.test(source), 'hover selects through the pointer gate, so scrolling cells do not take the selection')
assert(!/onContainsMouseChanged/.test(source), 'hover does not select on cells arriving under a resting pointer')

assert(/WheelHandler\s*\{/.test(source) && /GradientStop/.test(source) && !/ScrollBar|scrollbar/i.test(source), 'the grid scrolls the way the menu does: its wheel and edge scrims, no scrollbar')

assert(/event\.text === " " && !root\.filterText/.test(source), 'a space at the start of a search is dropped')
JS
