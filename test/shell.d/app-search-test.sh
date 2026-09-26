#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const search = requireFromRoot('shell/services/AppSearch.js')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const appLibraryQml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')

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

// omarchy-launch-webapp installs the same id shape for other Chromium-based
// browsers too - the invariant is the 32-letter extension id, not the
// "chrome-" prefix specifically.
assert(
  search.fuzzyScore({ name: 'YouTube', id: 'brave-agimnkijcaahngcdmfeangaknmldooml-Profile 1' }, 'profile') < 0,
  'the generated-id exclusion is not specific to Chrome or the "Default" profile name'
)

// A real, human-chosen id is unaffected - only the generated web app shape
// is excluded.
assert(
  search.fuzzyScore({ name: 'Firefox', id: 'firefox' }, 'firefox') > 0,
  'a normal app id is still searchable'
)

// The menu's Apps submenu is the launcher now: app rows launch and uninstall
// through the shared app library instead of running commands themselves.
const activateMatch = menuQml.match(/function activateIndex\(index, fromPointer\) \{([\s\S]*?)\n  \}/)
assert(activateMatch, 'menu activateIndex function exists')
assert(
  activateMatch[1].includes('root.appLibrary.launch('),
  'menu routes app launch through the shared app library'
)
assert(
  !activateMatch[1].includes('entry.execute()'),
  'menu does not execute desktop entries directly'
)

const confirmDeleteMatch = menuQml.match(/function confirmDelete\(\) \{([\s\S]*?)\n  \}/)
assert(confirmDeleteMatch, 'menu confirmDelete function exists')
assert(
  confirmDeleteMatch[1].includes('root.appLibrary.remove('),
  'menu delete routes through the shared app library'
)
assert(
  confirmDeleteMatch[1].includes('root.cancel()'),
  'menu delete closes the menu after confirmation'
)

assert(
  /function remove\(desktopId, name\) \{[\s\S]*?omarchy-remove-launcher-entry[\s\S]*?\n  \}/.test(appLibraryQml),
  'app library remove runs the remover through the shell'
)

assert(
  /function launch\(desktopId, name\) \{[\s\S]*?uwsm-app[\s\S]*?\n  \}/.test(appLibraryQml) &&
    appLibraryQml.includes('Util.execDetached("uwsm-app -- gtk-launch "'),
  'app library launches desktop entries through gtk-launch in their own scope'
)

assert(
  appLibraryQml.includes('Util.shellQuote(id + ".desktop")'),
  'app library launches by full file name so ids ending in .desktop (org.telegram.desktop) resolve'
)

assert(
  /function iconIndexScanCommand\(\)[\s\S]*-path "\*\/apps\/\*" -o -path "\*\/devices\/\*"/.test(appLibraryQml),
  'app library fallback icon index includes device icons'
)

assert(
  appLibraryQml.includes('command: ["bash", "-c", root.hiddenEntryScanCommand()]') &&
    appLibraryQml.includes('command: ["bash", "-c", root.iconIndexScanCommand()]') &&
    !appLibraryQml.includes('"-lc"'),
  'app library scans avoid login shells whose profile activation retriggers the desktop-entry watcher'
)

assert(
  /if \(active === "apps"\) \{[\s\S]*?rows\.sort\(function\(a, b\)/.test(menuQml),
  'apps menu enforces alphabetical display order after provider refreshes'
)

const iconSourceMatch = appLibraryQml.match(/function iconSource\(icon\) \{([\s\S]*?)\n  \}/)
assert(iconSourceMatch, 'app library iconSource function exists')
assert(
  iconSourceMatch[1].indexOf('root.iconIndex[value]') < iconSourceMatch[1].indexOf('Quickshell.iconPath(value, true)'),
  'app library prefers indexed app icons over ambiguous themed icons'
)

const beginLaunchMatch = appLibraryQml.match(/function beginLaunchFeedback\(name\) \{([\s\S]*?)\n  \}/)
assert(beginLaunchMatch, 'app library beginLaunchFeedback function exists')
assert(
  !beginLaunchMatch[1].includes('root.launchOsdOpen = false'),
  'app library keeps owning an OSD a previous launch left on screen'
)

const openMatch = menuQml.match(/function openExistingMenu\(initialMenu\) \{([\s\S]*?)\n  \}/)
assert(openMatch, 'menu openExistingMenu function exists')
assert(
  openMatch[1].includes('root.appLibrary.refreshIcons()'),
  'menu refreshes the shared icon index when opened'
)
JS
