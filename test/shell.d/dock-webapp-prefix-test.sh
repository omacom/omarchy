#!/bin/bash

# Issue #15364: a web app's window class carries the launching browser's own
# prefix (msedge-, brave-, ...), while the shipped entries hard-code chrome-.
# The dock retries an unmatched app id with the browser prefix normalized to
# chrome-, so a web app still matches its desktop entry on any supported
# browser.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const dock = requireFromRoot('shell/plugins/dock/DockModel.js')

assertEqual(dock.chromeWebAppClass('msedge-x.com__-Default'), 'chrome-x.com__-Default',
  'an Edge web app class normalizes to the chrome- prefix')
assertEqual(dock.chromeWebAppClass('brave-youtube.com_-Default'), 'chrome-youtube.com_-Default',
  'a Brave web app class normalizes to the chrome- prefix')
assertEqual(dock.chromeWebAppClass('chromium-web.whatsapp.com_-Default'), 'chrome-web.whatsapp.com_-Default',
  'a Chromium web app class normalizes to the chrome- prefix')
assertEqual(dock.chromeWebAppClass('vivaldi-stable-x.com__-Default'), 'chrome-x.com__-Default',
  'a Vivaldi web app class normalizes to the chrome- prefix')
assertEqual(dock.chromeWebAppClass('chrome-x.com__-Default'), '',
  'a chrome- class needs no normalization')
assertEqual(dock.chromeWebAppClass('msedge'), '', 'a bare browser name is not a web app class')
assertEqual(dock.chromeWebAppClass('org.gnome.Nautilus'), '', 'a regular app id keeps no chrome- form')
assertEqual(dock.chromeWebAppClass(''), '', 'an empty app id normalizes to nothing')

// The QML side: entryForAppId retries with the normalized class before giving
// up on an entry. Run the real function body against a desktop entries table
// that only knows the chrome- entry.
const source = fs.readFileSync(root + '/shell/plugins/dock/Dock.qml', 'utf8')
const body = source.match(/function entryForAppId\(appId\) \{([\s\S]*?)\n  \}/)[1]
if (!body) fail('entryForAppId not found in Dock.qml')

const entries = { 'chrome-x.com__-Default': { id: 'X' } }
const lookups = []
const DesktopEntries = {
  heuristicLookup(appId) { lookups.push(appId); return entries[appId] || null }
}
const dockRoot = { terminalEntries: [] }
const entryForAppId = new Function('appId', 'DesktopEntries', 'DockModel', 'root', body)

const hit = entryForAppId('msedge-x.com__-Default', DesktopEntries, dock, dockRoot)
assert(hit && hit.id === 'X',
  'an Edge web app window matches the chrome- entry through the retry',
  'lookups were: ' + lookups.join(', '))
assert(lookups[0] === 'msedge-x.com__-Default', 'the id is tried as-is first')
assert(lookups.indexOf('chrome-x.com__-Default') > 0, 'the normalized class is tried after')

const plainLookups = []
lookups.length = 0
entries['msedge-other.com__-Default'] = { id: 'direct' }
const direct = entryForAppId('msedge-other.com__-Default', {
  heuristicLookup(appId) { plainLookups.push(appId); return entries[appId] || null }
}, dock, dockRoot)
assert(direct && direct.id === 'direct' && plainLookups.length === 1,
  'a browser class with an entry of its own is still matched directly')
delete entries['msedge-other.com__-Default']

lookups.length = 0
assert(entryForAppId('org.gnome.Nautilus', DesktopEntries, dock, dockRoot) === null,
  'an unmatched regular app id still resolves to no entry',
  'lookups were: ' + lookups.join(', '))
JS
