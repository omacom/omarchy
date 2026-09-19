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

const mediaQml = fs.readFileSync(path.join(root, 'shell/Ui/BackgroundMedia.qml'), 'utf8')
assert(
  backgroundQml.includes('background-alignments.json') &&
    backgroundQml.includes('function positionFor(path, map)') &&
    backgroundQml.includes('alignRatio: root.positionFor(root.displayedBackground, root.alignments)') &&
    mediaQml.includes('property real alignRatio: 0.5') &&
    mediaQml.includes('-root.alignRatio * Math.max(0, width - parent.width)'),
  'desktop background and media renderer apply stepped horizontal alignment from saved configuration'
)
JS
