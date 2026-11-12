#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const body = qml.split('  function iconSource(icon) {')[1].split('\n  }')[0]
const activeIcon = '/icons/active/apps/browser.svg'
const otherIcon = '/icons/other/apps/browser.svg'
const fallback = '/icons/hicolor/apps/application-x-executable.svg'
const library = { iconIndex: {} }
const themedIcons = { browser: activeIcon, zoom: '/icons/active/actions/zoom.svg', 'application-x-executable': fallback }
const resolve = new Function('root', 'Quickshell', 'Util', 'icon', body)
const iconSource = icon => resolve(library, { iconPath: name => themedIcons[name] || '' }, { fileUrl: value => 'file://' + value }, icon)

assertEqual(iconSource('browser'), activeIcon, 'active theme is used before the scan completes')
library.iconIndex = { browser: otherIcon, newlyInstalled: '/icons/hicolor/apps/new.svg', zoom: '/icons/other/apps/zoom.svg' }
assertEqual(iconSource('browser'), activeIcon, 'scan completion does not replace the active theme with another installed theme')
assertEqual(iconSource('newlyInstalled'), 'file:///icons/hicolor/apps/new.svg', 'index still resolves icons missing from the theme cache')
assertEqual(iconSource('zoom'), 'file:///icons/other/apps/zoom.svg', 'app icon still wins over an action with the same name')
themedIcons.zoom = '/icons/active/actions@2x/zoom.svg'
assertEqual(iconSource('zoom'), 'file:///icons/other/apps/zoom.svg', 'app icon wins over a high-DPI action icon')
delete library.iconIndex.zoom
assertEqual(iconSource('zoom'), themedIcons.zoom, 'themed match remains available when the index has no app icon')
assertEqual(iconSource('missing'), fallback, 'unknown icon uses the generic application fallback')
assertEqual(iconSource(''), fallback, 'empty icon uses the generic application fallback')
for (const value of ['file:///custom/icon.svg', 'image://provider/icon'])
  assertEqual(iconSource(value), value, 'explicit icon URL is preserved: ' + value)
assertEqual(iconSource('/custom/icon.svg'), 'file:///custom/icon.svg', 'absolute icon path is preserved')
JS
