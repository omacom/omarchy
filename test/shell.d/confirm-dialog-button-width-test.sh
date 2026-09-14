#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

DIALOG="$ROOT/shell/Ui/ConfirmDialog.qml"

[[ -f $DIALOG ]] || fail "ConfirmDialog.qml is missing"

run_node_test <<'JS'
const fs = require('fs')

const qml = fs.readFileSync(path.join(root, 'shell/Ui/ConfirmDialog.qml'), 'utf8')
const clipboard = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')
const menu = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

// Fixed 88px width is the overflow bug: long confirmText paints past the frame.
assert(
  !/^\s*width:\s*Style\.space\(88\)\s*$/m.test(qml),
  'confirm buttons must not hardcode a fixed Style.space(88) width'
)

assert(
  /minWidth:\s*Style\.space\(88\)/.test(qml),
  'confirm buttons keep Style.space(88) as the minimum width'
)

assert(
  /width:\s*Math\.min\(\s*maxWidth\s*,\s*Math\.max\(\s*minWidth\s*,\s*label\.implicitWidth\s*\+\s*labelPadding\s*\*\s*2\s*\)\s*\)/.test(qml),
  'confirm button width grows with the label up to a card-aware max'
)

assert(
  /maxWidth:\s*\{[\s\S]*card\.width[\s\S]*\/\s*2[\s\S]*\}/.test(qml) ||
    /half\s*=\s*Math\.floor\(\(content\s*-\s*Style\.space\(10\)\)\s*\/\s*2\)/.test(qml),
  'confirm button max width is half the card content so both buttons fit'
)

assert(
  /id:\s*label/.test(qml) &&
    /elide:\s*Text\.ElideRight/.test(qml) &&
    /width:\s*Math\.min\(\s*implicitWidth\s*,\s*parent\.width\s*-\s*labelPadding\s*\*\s*2\s*\)/.test(qml),
  'confirm label is width-constrained and elides inside the button frame'
)

assert(
  /horizontalAlignment:\s*Text\.AlignHCenter/.test(qml),
  'confirm label stays centered while eliding'
)

// First-party callers still use short English labels that fit the minimum.
assert(
  /confirmText:\s*"Delete"/.test(clipboard),
  'clipboard clear confirm keeps short Delete label'
)
assert(
  /confirmText:\s*"Uninstall"/.test(menu),
  'menu uninstall confirm keeps short Uninstall label'
)

// Sizing model: short labels stay at minWidth; long labels grow then cap.
function buttonWidth(textPx, minW, maxW, pad) {
  return Math.min(maxW, Math.max(minW, textPx + pad * 2))
}

const minW = 88
const pad = 12
// Card content for default Style.space(370) card with Style.space(18) padding
// and 1px borders is roughly 370 - 2*(18+1) = 332; half minus gap ≈ 161.
const maxW = Math.max(minW, Math.floor((332 - 10) / 2))

assertEqual(buttonWidth(37, minW, maxW, pad), minW, 'Cancel-sized label stays at the 88px minimum')
assertEqual(buttonWidth(54, minW, maxW, pad), minW, 'Uninstall-sized label stays at the 88px minimum')
assertEqual(buttonWidth(109, minW, maxW, pad), 109 + pad * 2, 'Delete permanently grows past 88px')
assert(
  buttonWidth(109, minW, maxW, pad) <= maxW,
  'grown button still fits beside its pair inside the card'
)
assertEqual(
  buttonWidth(400, minW, maxW, pad),
  maxW,
  'extreme labels cap at half the card and rely on elide inside the frame'
)
JS

pass "confirm dialog buttons size to their labels without overflowing the card"
