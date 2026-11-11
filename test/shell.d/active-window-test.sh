#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/ActiveWindowModel.js')

// cleanAppId
assertEqual(model.cleanAppId('code.desktop'), 'code', 'strips .desktop extension')
assertEqual(model.cleanAppId('  firefox  '), 'firefox', 'trims whitespace')
assertEqual(model.cleanAppId(''), '', 'handles empty string')

// formatFallbackName
assertEqual(model.formatFallbackName('org.gnome.Nautilus'), 'Nautilus', 'extracts last part of reverse DNS')
assertEqual(model.formatFallbackName('com.anthropic.Claude'), 'Claude', 'extracts class name')
assertEqual(model.formatFallbackName('org.omarchy.nvim'), 'Nvim', 'handles omarchy TUI prefix')
assertEqual(model.formatFallbackName('google-chrome'), 'Google Chrome', 'formats kebab-case')
assertEqual(model.formatFallbackName('my_custom_tool'), 'My Custom Tool', 'formats snake_case')
assertEqual(model.formatFallbackName('foot'), 'Foot', 'capitalizes simple app name')

// resolveAppName with mock DesktopEntries
const mockEntries = {
  byId: id => {
    if (id === 'code') return { name: 'Visual Studio Code' }
    if (id === 'org.gnome.Nautilus') return { name: 'Files' }
    if (id === 'nvim') return { name: 'Neovim' }
    return null
  },
  heuristicLookup: id => {
    if (id === 'code') return { name: 'Visual Studio Code' }
    if (id === 'chromium-browser') return { name: 'Chromium' }
    if (id === 'Nautilus') return { name: 'Files' }
    return null
  }
}

const mockTerminalEntries = [
  { id: 'nvim', runInTerminal: true, command: ['nvim'] }
]

assertEqual(model.resolveAppName('code', mockEntries, []), 'Visual Studio Code', 'finds by heuristic lookup')
assertEqual(model.resolveAppName('code.desktop', mockEntries, []), 'Visual Studio Code', 'cleans .desktop before lookup')
assertEqual(model.resolveAppName('chromium-browser', mockEntries, []), 'Chromium', 'finds browser entry')
assertEqual(model.resolveAppName('org.gnome.Nautilus', mockEntries, []), 'Files', 'resolves reverse DNS by last segment')
assertEqual(model.resolveAppName('org.omarchy.nvim', mockEntries, mockTerminalEntries), 'Neovim', 'resolves terminal app via claiming entry')
assertEqual(model.resolveAppName('unknown-app', mockEntries, []), 'Unknown App', 'falls back to formatted name when entry not found')
assertEqual(model.resolveAppName('', mockEntries, []), '', 'empty appId returns empty string')

// labelText
assertEqual(model.labelText('appName', 'Visual Studio Code', 'ActiveWindow.qml - omarchy'), 'Visual Studio Code', 'appName mode shows app name')
assertEqual(model.labelText('title', 'Visual Studio Code', 'ActiveWindow.qml - omarchy'), 'ActiveWindow.qml - omarchy', 'title mode shows window title')
assertEqual(model.labelText('both', 'Visual Studio Code', 'ActiveWindow.qml - omarchy'), 'Visual Studio Code  ·  ActiveWindow.qml - omarchy', 'both mode shows combined label')
assertEqual(model.labelText('both', 'Files', 'Files'), 'Files', 'both mode avoids repeating identical app and title')
assertEqual(model.labelText('appName', '', 'Only Title Available'), 'Only Title Available', 'fallback to title when appName is empty')
assertEqual(model.labelText('title', 'Only App Available', ''), 'Only App Available', 'fallback to app when title is empty')
JS
