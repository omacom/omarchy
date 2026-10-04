#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// A wake fired while another is already running used to just vanish, so the
// keyboard restore it carried never happened if it lost that race.
assert(
  /function runWake\(\) \{[\s\S]*if \(!wakeProcess\.running\) wakeProcess\.running = true\s*\n\s*else wakeRerunRequested = true/.test(serviceQml),
  'a wake that arrives while one is already running is queued, not dropped'
)

assert(
  /if \(root\.keyboardBlanked\) \{\s*kbdRestoreReapplyTimer\.restart\(\)\s*\n\s*root\.keyboardRestoredOnce = true\s*\n\s*\}\s*\n\s*root\.keyboardBlanked = false\s*\n\s*if \(!root\.wakeRerunRequested\) return\s*\n\s*root\.wakeRerunRequested = false\s*\n\s*wakeProcess\.running = true/.test(serviceQml),
  'a queued wake reruns once the in-flight one finishes, and only the run that actually restored marks the session done'
)

assert(
  /if \(lockRequested\) armBlankTimer\(\)[\s\S]*if \(!wakeProcess\.running\) wakeProcess\.running = true/.test(serviceQml),
  'the suspend-gap check in armBlankTimer runs before wakeProcess captures keyboardBlanked, not after'
)

assert(
  /function beginLock\(\) \{[\s\S]*keyboardBlanked = false\s*\n\s*keyboardRestoredOnce = false/.test(serviceQml),
  'each lock session starts assuming it has neither blanked nor restored the keyboard yet'
)

assert(
  /function runBlank\(\) \{\s*(?:\/\/[^\n]*\n\s*)*(?:root\.\w+ = \w+\s*\n\s*)*keyboardBlanked = true/.test(serviceQml),
  'the real off marks the keyboard blanked'
)

assert(
  /if \(Date\.now\(\) - armedAt > interval \+ 2000\) \{[\s\S]*root\.keyboardBlanked = true/.test(serviceQml),
  'a suspend detected via the frozen timer also counts as reason to restore, even though this session never ran the blank itself'
)

// armBlankTimer checks the same gap on every re-arm, not only when
// idleBlankTimer's own onTriggered gets an uninterrupted turn to fire --
// a resume replays a burst of wake nudges that keeps re-arming the timer
// before its own deadline is ever reached, so onTriggered alone misses it.
assert(
  /function armBlankTimer\(\) \{[\s\S]*if \(idleBlankTimer\.armedAt > 0 && now - idleBlankTimer\.armedAt > idleBlankTimer\.interval \+ 2000\) \{\s*\n\s*root\.keyboardBlanked = true/.test(serviceQml),
  'a suspend gap is also detected on every re-arm, not only on an actual timer firing'
)

// Never sourced from brightnessctl's own `-s`/`-r` save-restore: that trusts
// "whatever's current right before the off call" to be the real value, which
// breaks the instant the EC dims the keyboard on its own faster than any
// software off call can run.
assert(
  /root\.keyboardBlanked && root\.kbdDeviceName && root\.savedKeyboardBrightness >= 0\s*\n\s*\? \("; brightnessctl -d '" \+ root\.kbdDeviceName \+ "' set " \+ root\.savedKeyboardBrightness\)/.test(serviceQml),
  'restore always uses the independently-tracked value, never brightnessctl\'s own restore'
)

assert(
  /keyboardOffSaved/.test(serviceQml) === false,
  'brightnessctl\'s own save/restore is not trusted at all -- there is no keyboardOffSaved branch left'
)

// Without this, a pause of more than 5s between the lock screen becoming
// visible and actually typing the password re-dims and then immediately
// re-lights the keyboard again -- a visible flicker, not a real off period.
assert(
  /if \(root\.keyboardRestoredOnce\) \{[\s\S]*root\.armBlankTimer\(\)\s*\n\s*return\s*\n\s*\}\s*\n\s*root\.runBlank\(\)/.test(serviceQml),
  'once a restore has run this session, a later idle gap re-arms the timer but never blanks again'
)

// A resume also triggers a USB re-enumeration on some hardware a couple of
// seconds after the EC's own wake sequence, resetting the keyboard
// independent of anything the initial restore just set; there is no
// notification for that, so the only way to win against it is to reapply.
assert(
  /Timer \{\s*\n\s*id: kbdRestoreReapplyTimer\s*\n\s*interval: 3000/.test(serviceQml),
  'a follow-up reapply is scheduled a few seconds after a restore, to win against a delayed hardware reset'
)

assert(
  /function finishUnlock\(\) \{[\s\S]*runWake\(\)[\s\S]*kbdRestoreReapplyTimer\.restart\(\)/.test(serviceQml),
  'the reapply is also scheduled independently at actual unlock, not only around a resume'
)

// Refreshed on a schedule that shares no trigger with locking or suspend, so
// it stays correct regardless of how fast the hardware reacts -- a read done
// reactively at lock time can lose the race against the EC's own near-instant
// dim and poison the tracked value with the already-dimmed reading.
assert(
  /Timer \{\s*\n\s*id: kbdBrightnessSnapshotTimer\s*\n\s*interval: 5000\s*\n\s*repeat: true\s*\n\s*running: root\.kbdBrightnessPath !== "" && !root\.locked/.test(serviceQml),
  'the tracked brightness is refreshed periodically while unlocked, never while locked'
)

// Without this, a session that never touches the brightness key would have
// no value to restore to.
assert(
  /findKbdDeviceProc[\s\S]*cat \\"\$c\/brightness\\"/.test(serviceQml),
  'the starting brightness is captured alongside the device name'
)

// brightness_hw_changed is only present on drivers that call
// led_classdev_notify_brightness_hw_changed(); without this check the watcher
// would loop forever trying to open a file that never exists on hardware
// that doesn't support it.
assert(
  /\[\[ -e \$c\/brightness_hw_changed \]\] && echo yes \|\| echo no/.test(serviceQml),
  'hardware-change notification support is checked before the watcher starts'
)

assert(
  /if \(\(lines\[2\] \|\| ""\)\.trim\(\) === "yes"\) kbdWatcherProc\.running = true/.test(serviceQml),
  'the watcher only starts on hardware that actually supports the notification'
)

// A firmware-handled brightness key changes the LED value directly, with no
// regular write for a file watch to see; brightness_hw_changed is the LED
// class's own poll()-able notification for exactly this case.
assert(
  /select\.poll\(\)[\s\S]*p\.register\(f, select\.POLLPRI \| select\.POLLERR\)/.test(serviceQml),
  'the watcher blocks on the driver-notified event rather than checking on a timer'
)

// Before the first hardware-notified change since boot, the kernel has
// nothing to report yet and reads raise ENODATA -- an uncaught read there
// would crash the watcher on every restart until one happens to land during
// one of the brief windows it is actually running.
assert(
  /if e\.errno != errno\.ENODATA: raise/.test(serviceQml),
  'only ENODATA is swallowed while priming the watcher; any other read error still surfaces'
)

assert(
  /drain\(f\); f\.seek\(0\)[\s\S]*?p = select\.poll\(\)/.test(serviceQml),
  'the poll is registered even when there is nothing to prime yet, rather than only after a successful read'
)

assert(
  /if \(!root\.kbdTrackingSuspended\) root\.savedKeyboardBrightness = val/.test(serviceQml),
  'a value the watcher reports while locked is ignored, not treated as the new baseline'
)

assert(
  /readonly property bool kbdTrackingSuspended: locked/.test(serviceQml),
  'tracking is suspended for a session\'s entire lock, not toggled around individual wake/blank events'
)

assert(
  /onExited: kbdWatcherRestartTimer\.restart\(\)/.test(serviceQml),
  'the watcher restarts if it ever exits, rather than leaving the session untracked for good'
)
JS
