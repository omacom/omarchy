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

assert(
  backgroundQml.includes('function backgroundFor(screenName, fallbackPath)') &&
    backgroundQml.includes('shell.shellConfig.background.screens'),
  'background resolves a per-screen wallpaper from shell.json background.screens'
)

assert(
  /path: root\.backgroundFor\(panel\.screenName, root\.displayedBackground\)/.test(backgroundQml),
  'background renders each output through the per-screen resolver'
)

assert(
  /visible: !panel\.hasOverride && root\.oldBackground/.test(backgroundQml) &&
    /visible: !panel\.hasOverride && root\.incomingBackground/.test(backgroundQml),
  'background skips theme transition frames on screens with their own wallpaper'
)

assert(
  /if \(override === "~"\) return home/.test(backgroundQml) &&
    /if \(override\.indexOf\("~\/"\) === 0\) return home \+ override\.substring\(1\)/.test(backgroundQml),
  'background expands a leading ~ in a per-screen wallpaper path'
)
JS
