#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"
cat >"$test_tmp/bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_HERMES_DESKTOP:-0} == "1" ]]
SH
chmod +x "$test_tmp/bin/omarchy-pkg-present"

scan_hidden_entries() {
  HOME="$test_tmp/home" \
    XDG_DATA_DIRS="$test_tmp/data" \
    PATH="$test_tmp/bin:$PATH" \
    OMARCHY_TEST_HERMES_DESKTOP="$1" \
    bash "$ROOT/shell/services/hidden-entries.sh" || true
}

if grep -qx com.nousresearch.hermes "$ROOT/default/omarchy/launcher.hides"; then
  fail "the standalone Hermes launcher is not hidden without the packaged app"
fi
scan_hidden_entries 0 | grep -qx com.nousresearch.hermes &&
  fail "the standalone Hermes launcher is hidden without the packaged app"
scan_hidden_entries 1 | grep -qx com.nousresearch.hermes ||
  fail "the renamed Hermes launcher is hidden while the packaged app owns Hermes"
pass "the renamed Hermes launcher hide follows packaged app ownership"

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
// The renamed id is hidden dynamically while the package owns Hermes.
const configuredHides = new Set(fs.readFileSync(path.join(root, 'default/omarchy/launcher.hides'), 'utf8').trim().split(/\n/))
const packagedHides = new Set([...configuredHides, 'com.nousresearch.hermes'])
const hermesEntries = [
  { name: 'Hermes', id: 'hermes' },
  { name: 'Hermes', id: 'com.nousresearch.hermes' },
  { name: 'Hermes', id: 'hermes-desktop' }
]
for (const query of ['', 'hermes']) {
  const visible = search.sortedEntries(hermesEntries, query, entry => packagedHides.has(entry.id))
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
JS
