#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

// The Apps menu sorts its own rows, since DesktopEntries can reorder them.
// Run that comparator as written rather than restating it here.
const match = menuQml.match(/if \(active === "apps"\) \{\s*rows\.sort\((function\(a, b\) \{[\s\S]*?\n\s*\})\)/)
assert(match, 'apps menu sorts its rows with an inline comparator')
const compare = new Function(`return (${match[1]})`)()
const order = rows => rows.slice().sort(compare).map(row => row.label)

// App names come from each desktop entry's Name for the user's language, so
// a French or German desktop has names that start with É or Ü. Comparing
// UTF-16 code units put every one of them after Z.
assertDeepEqual(
  order([
    { label: 'Zed', itemId: 'apps.zed' },
    { label: 'Éditeur de texte', itemId: 'apps.text-editor' },
    { label: 'Übersetzer', itemId: 'apps.translator' },
    { label: 'Calculatrice', itemId: 'apps.calculator' },
    { label: 'Fichiers', itemId: 'apps.files' },
    { label: 'Terminal', itemId: 'apps.terminal' }
  ]),
  ['Calculatrice', 'Éditeur de texte', 'Fichiers', 'Terminal', 'Übersetzer', 'Zed'],
  'apps menu files an accented name under its letter, not after Z'
)

assertDeepEqual(
  order([
    { label: 'zed', itemId: 'apps.b' },
    { label: 'Alacritty', itemId: 'apps.a' },
    { label: 'Zed', itemId: 'apps.a' }
  ]),
  ['Alacritty', 'Zed', 'zed'],
  'apps menu ignores case and breaks a tie on the id'
)

// The plugin API hands out the same list through AppSearch.sortedEntries,
// so a plugin that lists apps sees the order the menu shows.
const search = require(path.join(root, 'shell/services/AppSearch.js'))
const entry = name => ({ id: name, name, noDisplay: false })
assertDeepEqual(
  search.sortedEntries(['Zed', 'Éditeur de texte', 'Fichiers', 'Übersetzer'].map(entry), '').map(row => search.entryName(row.entry)),
  ['Éditeur de texte', 'Fichiers', 'Übersetzer', 'Zed'],
  'app list files an accented name under its letter, not after Z'
)

// Names that collate the same, such as a composed and a decomposed É, still
// come out in one order whichever order the desktop entries arrived in.
const composed = entry('\u00c9diteur'), decomposed = entry('E\u0301diteur')
const listed = list => search.sortedEntries(list, '').map(row => row.entry.name)
assertDeepEqual(listed([composed, decomposed]), listed([decomposed, composed]), 'app list keeps one order for names that collate the same')

// The visible change for English names: a leading symbol now sorts ahead of
// digits and letters, instead of wherever its code point falls.
assertDeepEqual(
  order(['Zed', '1Password', '~Tilde', 'Alacritty', '_Under'].map((label, i) => ({ label, itemId: `apps.${i}` }))),
  ['_Under', '~Tilde', '1Password', 'Alacritty', 'Zed'],
  'apps menu groups names that start with a symbol ahead of digits and letters'
)
JS
