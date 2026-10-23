#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const extensions = requireFromRoot('shell/Ui/PluginExtensions.js')
const extensionsQml = fs.readFileSync(path.join(root, 'shell/Ui/PluginExtensions.qml'), 'utf8')
const clipboardQml = fs.readFileSync(path.join(root, 'shell/plugins/clipboard/Clipboard.qml'), 'utf8')

// ------------------------------------------------------------------ shortcuts

assertDeepEqual(
  extensions.parseShortcut('Ctrl+E'),
  { key: 'E', ctrl: true, shift: false, alt: false, meta: false },
  'shortcut parser reads a modifier and a key'
)

assertDeepEqual(
  extensions.parseShortcut('ctrl+shift+return'),
  { key: 'RETURN', ctrl: true, shift: true, alt: false, meta: false },
  'shortcut parser is case-insensitive and stacks modifiers'
)

assertDeepEqual(
  extensions.parseShortcut('E'),
  { key: 'E', ctrl: false, shift: false, alt: false, meta: false },
  'shortcut parser accepts a bare key'
)

assertEqual(extensions.parseShortcut('Hyper+E'), null, 'shortcut parser rejects an unknown modifier')
assertEqual(extensions.parseShortcut(''), null, 'shortcut parser rejects an empty spec')
assertEqual(extensions.parseShortcut(undefined), null, 'shortcut parser rejects a missing spec')
assertEqual(extensions.parseShortcut('Ctrl+'), null, 'shortcut parser rejects a modifier with no key')

// ------------------------------------------------------------------- host list

const installed = {
  'zz.late': { id: 'zz.late', kinds: ['extension'], extension: { host: 'omarchy.clipboard' } },
  'aa.early': { id: 'aa.early', kinds: ['extension'], extension: { host: 'omarchy.clipboard' } },
  'other.host': { id: 'other.host', kinds: ['extension'], extension: { host: 'omarchy.menu' } },
  'no.extension': { id: 'no.extension', kinds: ['overlay'], extension: { host: 'omarchy.clipboard' } },
  'no.host': { id: 'no.host', kinds: ['extension'] },
  'disabled.one': { id: 'disabled.one', kinds: ['extension'], extension: { host: 'omarchy.clipboard' } }
}
const enabled = (id) => id !== 'disabled.one'

assertDeepEqual(
  extensions.hostedExtensions(installed, 'omarchy.clipboard', enabled).map((m) => m.id),
  ['aa.early', 'zz.late'],
  'host lookup returns enabled extensions for that host in id order'
)

assertDeepEqual(
  extensions.hostedExtensions(installed, 'omarchy.background', enabled).map((m) => m.id),
  [],
  'a host nobody extends gets an empty list'
)

assertDeepEqual(extensions.hostedExtensions(null, 'omarchy.clipboard', enabled), [], 'host lookup tolerates no registry')
assertDeepEqual(extensions.hostedExtensions(installed, '', enabled), [], 'host lookup requires a host id')

// ------------------------------------------------------------------- contracts

assert(
  /if \("host" in item\) item\.host = extensions/.test(extensionsQml),
  'the slot injects itself as host so extensions can call back'
)

assert(
  /status !== Loader\.Error[\s\S]{0,400}console\.warn\("plugin extension /.test(extensionsQml),
  'an extension that fails to load warns instead of taking the host down'
)

assert(
  /function available\(entry\)[\s\S]*?try \{[\s\S]*?catch \(error\)/.test(extensionsQml),
  'a supports() that throws drops the extension, not the host row'
)

assert(
  /onObjectRemoved: Qt\.callLater\(function\(\) \{ extensions\.revision\+\+ \}\)/.test(extensionsQml),
  'a disabled extension leaves items after its delegate is torn down, not during'
)

assert(
  /PluginExtensions \{[\s\S]*?hostId: "omarchy\.clipboard"/.test(clipboardQml),
  'the clipboard offers its extension point under the built-in id'
)

assert(
  /extensions\.handleKey\(event, root\.selectedEntry\(\)\)/.test(clipboardQml),
  'contributed shortcuts get first refusal over the clipboard search filter'
)

assert(
  /if \(extensions\.paneOpen\) \{[\s\S]{0,300}Qt\.Key_Escape/.test(clipboardQml),
  'Escape still closes an extension pane that never took focus'
)

assert(
  /function selectFromPointer\(index, item, mouse\) \{\s*\n\s*if \(extensions\.paneOpen\) return/.test(clipboardQml),
  'hovering the history cannot move the cursor out from under an open pane'
)
JS
