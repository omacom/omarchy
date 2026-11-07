#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const launch = requireFromRoot('shell/services/AppLaunch.js')
const appLibraryQml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')

const vscodeWindow = { appId: 'com.microsoft.VSCode' }

assert(
  launch.toplevelMatches('com.microsoft.VSCode', 'com.microsoft.VSCode', 'com.microsoft.VSCode'),
  'a window matches its desktop id and startup class'
)
assert(
  launch.toplevelMatches('com.microsoft.VSCode', 'com.microsoft.VSCode', ''),
  'a window matches its desktop id when the entry has no startup class'
)
assert(
  !launch.toplevelMatches('org.omarchy.agent', 'com.microsoft.VSCode', 'com.microsoft.VSCode'),
  'a different window does not match the launched app'
)
assert(
  launch.appHasWindow([vscodeWindow, { appId: 'org.omarchy.agent' }], 'com.microsoft.VSCode', 'com.microsoft.VSCode'),
  'an already-open app is detected among other windows'
)
assert(
  !launch.appHasWindow([{ appId: 'org.omarchy.agent' }], 'com.microsoft.VSCode', 'com.microsoft.VSCode'),
  'a cold start has no matching window'
)

assertEqual(
  launch.launchDelayAction(false, 2, 2, true, false),
  'ignore',
  'a posted delay callback does not open the OSD after the launch timer was stopped'
)
assertEqual(
  launch.launchDelayAction(true, 2, 2, true, true),
  'finish',
  'an app that already has a window does not show Launching'
)
assertEqual(
  launch.launchDelayAction(true, 3, 2, true, false),
  'finish',
  'a new toplevel ends launch feedback instead of showing the OSD'
)
assertEqual(
  launch.launchDelayAction(true, 2, 2, false, false),
  'finish',
  'a focus change ends launch feedback instead of showing the OSD'
)
assertEqual(
  launch.launchDelayAction(true, 2, 2, true, false),
  'show',
  'a cold start that is still waiting shows the launch OSD'
)

assert(
  appLibraryQml.includes('if (!root.launchedAppHasWindow()) root.beginLaunchFeedback(name)'),
  'app library skips launch feedback when the app already has a window'
)
assert(
  appLibraryQml.includes('AppLaunch.launchDelayAction('),
  'app library asks AppLaunch before opening the launch OSD'
)
assert(
  appLibraryQml.includes('duration: launchTimeout.interval - launchDelay.interval'),
  'launch OSD carries a finite duration so a late show cannot stick'
)
const beginLaunchMatch = appLibraryQml.match(/function beginLaunchFeedback\(name\) \{([\s\S]*?)\n  \}/)
assert(beginLaunchMatch, 'app library beginLaunchFeedback function exists')
assert(
  !beginLaunchMatch[1].includes('root.launchOsdOpen = false'),
  'a new launch does not drop ownership of an OSD the previous launch left up'
)
JS
