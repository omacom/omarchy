#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const idleQml = fs.readFileSync(`${root}/shell/plugins/services/idle/Service.qml`, 'utf8')
const lockQml = fs.readFileSync(`${root}/shell/plugins/lock/Service.qml`, 'utf8')
const viewQml = fs.readFileSync(`${root}/shell/plugins/lock/LockView.qml`, 'utf8')

assert(
  /lockFromIdle[\s\S]*while \[\[ \$\(omarchy-shell lock isLocked[\s\S]*\.secure \/\/ false[\s\S]*exec omarchy-system-lock cleanup/.test(idleQml),
  'idle keeps the screensaver mapped until secure, then cleans up without re-locking'
)
assert(
  /else if \(root\.screensaverLaunchComplete\)[\s\S]*dismissArmTimer\.restart\(\)/.test(idleQml),
  'late screensaver windows restart the dismiss arm timer'
)
assert(
  /id: lockProcess[\s\S]*exitCode === 0[\s\S]*resetScreensaverWindows\(\)[\s\S]*screensaverWindowCount > 0[\s\S]*dismissArmTimer\.restart\(\)/.test(idleQml),
  'failed lock handoff keeps screensaver tracking and restores dismissal'
)
assert(
  /function cancelIdleCycle[\s\S]*!lockProcess\.running[\s\S]*lockHandoff = false[\s\S]*if \(root\.lockHandoff\)[\s\S]*screensaverWindowCount === 0[\s\S]*resetScreensaverWindows\(\)[\s\S]*else \{[\s\S]*dismissArmTimer\.restart\(\)/.test(idleQml),
  'Stay Awake cancels idle deadlines without clearing handoff or visible screensaver tracking'
)
assert(
  /function lockFromIdle\(\): string \{[\s\S]*root\.beginIdleLock\(\)/.test(lockQml),
  'the idle service has a dedicated lock entry point'
)
assert(
  /function beginIdleLock\(\)[\s\S]*idleTransitionConcealed = true[\s\S]*beginLock\(\)/.test(lockQml),
  'idle concealment is enabled before ext-session-lock begins'
)
assert(
  /concealAuthentication: root\.idleTransitionConcealed/.test(lockQml)
    && /property bool concealAuthentication: false/.test(viewQml)
    && /color: root\.concealAuthentication \? "black" : Commons\.Color\.background/.test(viewQml)
    && /opacity: root\.concealAuthentication \? 0 : 1/.test(viewQml)
    && /fingerprintUnavailableNotice[\s\S]*visible: root\.fingerprintConfigured && root\.fingerprintUnavailable && !root\.concealAuthentication/.test(viewQml),
  'the lock surface conceals the wallpaper, password view, and fingerprint notice during handoff'
)
assert(
  /feedActive: root\.video && root\.loadBackground && !root\.concealAuthentication/.test(viewQml)
    && /path: root\.loadBackground && !root\.concealAuthentication \? \(root\.video \? root\.videoPosterPath : root\.backgroundPath\) : ""/.test(viewQml)
    && /visible: !root\.concealAuthentication && root\.video/.test(viewQml),
  'concealment also suppresses the OWE poster and lock feed'
)
assert(
  /cursorShape: root\.concealAuthentication \? Qt\.BlankCursor : Qt\.ArrowCursor/.test(viewQml),
  'the concealed handoff hides the pointer'
)
assert(
  /function handlePointerWake\(\)[\s\S]*idleTransitionConcealed && !root\.idleTransitionPointerArmed[\s\S]*runWake\(\)/.test(lockQml),
  'surface initialization cannot reveal a newly mapped concealed lock'
)
assert(
  /id: idleTransitionPointerTimer[\s\S]*sessionLock\.secure[\s\S]*idleTransitionPointerArmed = true/.test(lockQml),
  'real pointer wake is armed only after the secure lock settles'
)
assert(
  /signal pointerWakeRequested\(\)[\s\S]*onClicked: \{ root\.pointerWakeRequested\(\); root\.forcePasswordFocus\(\) \}[\s\S]*onPositionChanged: root\.pointerWakeRequested\(\)/.test(viewQml),
  'pointer activity uses the guarded wake path'
)
assert(
  /screensaverDismissEnabled[\s\S]*IdleMonitor[\s\S]*id: screensaverDismissMonitor/.test(idleQml),
  'idle arms a dedicated dismiss IdleMonitor while the screensaver is visible'
)
assert(
  /id: dismissArmTimer[\s\S]*armDismissAfterLaunch/.test(idleQml),
  'idle force-arms dismiss after launch so jittery pointers still dismiss'
)
JS

pass "Idle lock handoff and screensaver dismiss stay wired together"
