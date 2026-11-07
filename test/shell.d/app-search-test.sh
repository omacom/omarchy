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

// A browser-installed web app's .desktop id is a generated identifier, not
// something a user would ever intentionally type: <browser>-<32-char
// Chromium extension id>-<browser profile directory name> ("Default",
// "Profile 1", ...). Installing more than one web app under the same
// profile used to mean every one of them matched any search for that
// profile's name - three unrelated PWAs all matching a search for
// "default", ranked as real results ahead of unrelated, actually relevant
// matches.
const webapps = [
  { name: 'YouTube', id: 'chrome-agimnkijcaahngcdmfeangaknmldooml-Default' },
  { name: 'Prime Video', id: 'chrome-amkmcdedgjbeaehpnmhmlpkbmcnebgko-Default' },
  { name: 'Disney+', id: 'chrome-mbjafbmjpcimpkkihihoideiofnoalmh-Default' }
]
assertDeepEqual(
  search.sortedEntries(webapps, 'default'),
  [],
  'web apps installed under the "Default" profile do not match a search for "default"'
)
assertEqual(
  search.entryAcronym(webapps[0]),
  'yt',
  'a web app acronym does not fold in its generated id'
)

// The id shape comes from the browser's own "Install" menu item, which every
// Chromium-based browser shares - the invariant is the 32-letter extension
// id, not the "chrome-" prefix specifically.
assert(
  search.fuzzyScore({ name: 'YouTube', id: 'brave-agimnkijcaahngcdmfeangaknmldooml-Profile 1' }, 'profile') < 0,
  'the generated-id exclusion is not specific to Chrome or the "Default" profile name'
)

// A real, human-chosen id is unaffected - only the generated web app shape
// is excluded.
assert(
  search.fuzzyScore({ name: 'Calculator', id: 'org.gnome.Calculator' }, 'gnome') > 0,
  'a normal app id is still searchable'
)
JS
