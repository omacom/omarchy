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

// Evaluate the real visibility predicate against changing DesktopEntries, so a
// source install stays visible and registering the packaged app hides its copy.
const vm = require('vm')
const library = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const visibility = library.match(/  function isHiddenEntry\(entry\) \{([\s\S]*?)\n  \}/)[1]
const configuredHides = Object.fromEntries(fs.readFileSync(path.join(root, 'default/omarchy/launcher.hides'), 'utf8').trim().split(/\n/).map(id => [id, true]))
let hermesEntries = [{ name: 'Hermes', id: 'hermes' }]
const context = vm.createContext({
  root: { configuredHiddenEntryIds: configuredHides, desktopHiddenEntryIds: {} },
  DesktopEntries: { byId: id => hermesEntries.find(entry => entry.id === id) }
})
vm.runInContext('function isHiddenEntry(entry) {' + visibility + '\n}', context)
for (const query of ['', 'hermes']) {
  const visible = search.sortedEntries(hermesEntries, query, context.isHiddenEntry)
  assertDeepEqual(visible.map(row => row.entry.id), ['hermes'], 'standalone Hermes remains visible without the packaged app')
}
hermesEntries.push({ name: 'Hermes', id: 'hermes-desktop' })
for (const query of ['', 'hermes']) {
  const visible = search.sortedEntries(hermesEntries, query, context.isHiddenEntry)
  assertDeepEqual(visible.map(row => row.entry.id), ['hermes-desktop'], 'only the packaged Hermes launcher is visible when present')
}
hermesEntries.pop()
assert(!context.isHiddenEntry(hermesEntries[0]), 'removing the packaged app restores the standalone launcher')
context.root.desktopHiddenEntryIds.hermes = true
assert(context.isHiddenEntry(hermesEntries[0]), 'standalone Hermes still honors desktop visibility')

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
JS
