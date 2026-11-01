#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const search = requireFromRoot('shell/services/AppSearch.js')

const entries = [
  {
    name: 'Google Contacts',
    genericName: 'Address Book',
    comment: 'Manage contacts',
    keywords: ['contacts', 'address book', 'people'],
    id: 'google-contacts.desktop'
  },
  {
    name: 'Calculator',
    genericName: 'Calculator',
    comment: 'Perform arithmetic, scientific or financial calculations',
    keywords: ['calculation', 'arithmetic', 'scientific', 'financial'],
    id: 'org.gnome.Calculator.desktop'
  },
  {
    name: 'OBS Studio',
    genericName: 'Streaming/Recording Software',
    comment: 'Free and Open Source Streaming/Recording Software',
    keywords: ['streaming', 'recording', 'capture'],
    id: 'com.obsproject.Studio.desktop'
  },
  {
    name: 'Aether',
    genericName: '',
    comment: 'Minimal internet radio player',
    keywords: ['audio', 'music', 'radio'],
    id: 'io.github.taqi.aether.desktop'
  },
  {
    name: 'Xournal++',
    genericName: 'Notetaking',
    comment: 'Take handwritten notes',
    keywords: ['notes', 'pdf', 'annotation'],
    id: 'com.github.xournalpp.xournalpp.desktop'
  },
  {
    name: 'RustDesk',
    genericName: 'Remote Desktop',
    comment: 'Remote desktop control',
    keywords: ['remote', 'desktop', 'control'],
    id: 'com.rustdesk.RustDesk.desktop'
  }
]

// Keep the packaged launcher when upstream rebuilds register their own entry.
const configuredHides = new Set(fs.readFileSync(path.join(root, 'default/omarchy/launcher.hides'), 'utf8').trim().split(/\n/))
const hermesEntries = [{ name: 'Hermes', id: 'hermes' }, { name: 'Hermes', id: 'hermes-desktop' }]
for (const query of ['', 'hermes']) {
  const visible = search.sortedEntries(hermesEntries, query, entry => configuredHides.has(entry.id))
  assertDeepEqual(visible.map(row => row.entry.id), ['hermes-desktop'], 'only the packaged Hermes launcher is visible')
}

const contactMatches = search.sortedEntries(entries, 'contact').map(row => search.entryName(row.entry))
assertDeepEqual(contactMatches, ['Google Contacts'], 'contact search only returns direct contact matches')

assert(
  search.fuzzyScore(entries[1], 'contact') < 0,
  'calculator does not match contact as a loose subsequence'
)

const acronymMatches = search.sortedEntries(entries, 'gc').map(row => search.entryName(row.entry))
assertEqual(acronymMatches[0], 'Google Contacts', 'short acronym matching still works')

const directMatches = search.sortedEntries(entries, 'obs').map(row => search.entryName(row.entry))
assertEqual(directMatches[0], 'OBS Studio', 'direct app-name matching still works')

// Word-prefix matching (#11614)
const chromeEntry = { name: 'Google Chrome', id: 'google-chrome.desktop' }
const submatchEntry = { name: 'Synchro', id: 'synchro.desktop' }
const chromeScore = search.fuzzyScore(chromeEntry, 'chr')
const subScore = search.fuzzyScore(submatchEntry, 'chr')
assert(chromeScore > 9000, 'word prefix matching gives top tier score to second word (#11614)')
assert(subScore > 0, 'substring matches Synchro containing chr inside word')
assert(chromeScore > subScore, 'word prefix "Chrome" ranks above non-prefix substring match "Synchro"')

const doc = search.buildEntryDocument(chromeEntry)
assertDeepEqual(doc.nameWords, ['google', 'chrome'], 'entry document pre-tokenizes words')
assertEqual(search.buildEntryDocument(chromeEntry), doc, 'entry document is cached in weakmap')

// Cached entries refresh when data changes
const mutableEntry = { name: 'Original App', id: 'app.desktop', keywords: ['alpha'] }
const initialDoc = search.buildEntryDocument(mutableEntry)
assertEqual(initialDoc.name, 'Original App', 'initial document reflects original name')

mutableEntry.name = 'Updated App'
const refreshedDoc = search.buildEntryDocument(mutableEntry)
assertEqual(refreshedDoc.name, 'Updated App', 'cached document updates when entry is modified in place')

search.invalidateEntry(mutableEntry)
const invalidatedDoc = search.buildEntryDocument(mutableEntry)
assertEqual(invalidatedDoc.name, 'Updated App', 'invalidating entry rebuilds valid document')

// Menu ranking with word prefix and apps (#11614)
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const menuItems = {
  root: { id: 'root', parent: '', kind: 'menu', label: 'Root' },
  'install.browser.chrome': { id: 'install.browser.chrome', parent: 'root', kind: 'action', label: 'Chrome', order: 0 },
  'tools.synchro': { id: 'tools.synchro', parent: 'root', kind: 'action', label: 'Synchro Tool', order: 1 },
  'apps.chrome': { id: 'apps.chrome', parent: 'apps', kind: 'app', label: 'Google Chrome', order: 2 }
}
const chromeAppScore = menu.searchScore(menuItems, menuItems['apps.chrome'], 'chr')
const chromeActionScore = menu.searchScore(menuItems, menuItems['install.browser.chrome'], 'chr')
const synchroScore = menu.searchScore(menuItems, menuItems['tools.synchro'], 'chr')

assert(chromeAppScore < synchroScore, 'word-prefix app outranks substring action in menu')
assert(chromeAppScore < chromeActionScore, 'word-prefix app outranks prefix action in menu')
JS
