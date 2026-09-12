#!/bin/bash
source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')

assert(
  /theme=\$\(omarchy-theme-switcher\); \[\[ -n \$theme \]\] && omarchy-theme-set \\"\$theme\\" >\/dev\/null 2>&1 &/.test(backgroundQml),
  'background theme switcher starts theme application asynchronously after selection'
)

assert(
  backgroundQml.includes('pendingThemeFallbackTimer.restart()') &&
    backgroundQml.includes('pendingThemeFallbackTimer.stop()') &&
    backgroundQml.includes('id: pendingThemeFallbackTimer') &&
    !backgroundQml.includes('pendingThemeVersion !== backgroundVersion'),
  'background theme transition applies pending colors even if image reveal stalls'
)
JS

run_node_test <<'JS'
const fs = require('fs')

const backgroundQml = fs.readFileSync(path.join(root, 'shell/plugins/background/Background.qml'), 'utf8')
const mediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')

// Every frame a screen paints goes through the per-screen orientation lookup.
assert(
  backgroundQml.includes('path: panel.oriented(root.displayedBackground)') &&
    backgroundQml.includes('source: root.imageUrl(panel.oriented(root.oldBackground))') &&
    backgroundQml.includes('source: root.imageUrl(panel.oriented(root.incomingBackground))'),
  'background base, old and incoming frames resolve the portrait twin per screen'
)
assert(mediaQml.includes('readonly property bool failed:'), 'BackgroundMedia reports a failed image so a missing twin can fall back')

// Run the lookup itself against a fake panel.
const fn = backgroundQml.match(/function oriented\(path\) \{[\s\S]*?\n      \}/)[0]
const oriented = (screen, orientFailedFor, p) => new Function('panel', 'orientFailedFor', 'path', `${fn.replace('function oriented(path)', 'const oriented = (path) =>')}; return oriented(path)`)({ screen }, orientFailedFor, p)
const portrait = { width: 1440, height: 2560 }
const landscape = { width: 3840, height: 2160 }
const plain = '/theme/backgrounds/1-moonrise.png'
const twin = '/theme/backgrounds/portrait/1-moonrise.png'
assert(oriented(portrait, '', plain) === twin, 'portrait screen swaps to backgrounds/portrait/<same name>')
assert(oriented(landscape, '', plain) === plain, 'landscape screen keeps the plain file')
assert(oriented(landscape, '', twin) === plain, 'landscape screen swaps a portrait twin back to the plain file')
assert(oriented(portrait, plain, plain) === plain, 'a path whose twin failed to load stays on the plain file')
JS
