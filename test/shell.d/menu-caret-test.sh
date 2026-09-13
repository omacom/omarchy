#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

const header = menuQml.slice(menuQml.indexOf('id: queryText'), menuQml.indexOf('id: promptText'))

assert(
  header.indexOf('text: root.filterText') < header.indexOf('id: caret'),
  'the menu header draws its caret after the text typed into it'
)

assert(
  /id: caretBlink[\s\S]*?repeat: true[\s\S]*?onTriggered: caret\.lit = !caret\.lit/.test(header),
  'the caret blinks on a repeating timer'
)

assert(
  /function onFilterTextChanged\(\) \{ caret\.relight\(\) \}/.test(header)
    && /function relight\(\)[\s\S]*?caret\.lit = true/.test(header),
  'the caret goes solid on every keystroke, so a typed character is never read against a blinked-off caret'
)

assert(
  /property bool blinking: root\.opened && !root\.deleteConfirmOpen/.test(header)
    && /visible: !root\.deleteConfirmOpen/.test(header),
  'the caret stands down while the delete confirmation owns the keys'
)

assert(
  /elide: Text\.ElideLeft[\s\S]*?horizontalAlignment: Text\.AlignRight/.test(header),
  'a query too long for the header elides on the left and keeps its tail against the caret'
)

JS
