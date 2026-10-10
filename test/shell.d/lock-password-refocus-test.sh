#!/bin/bash
# LockView must keep reclaiming password focus while the field should be
# interactive. One-shot forceActiveFocus() from Component.onCompleted /
# onInputEnabledChanged is not enough: the surface can still be inactive,
# the idle screensaver can dismiss after lock-requested, and a failed PAM
# check disables then re-enables the field without restoring activeFocus.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const view = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
const compact = view.replace(/\s+/g, ' ')

assert(
  /Timer \{ interval: 100 repeat: true running: root\.inputEnabled && !root\.authenticatingPassword && !passwordInput\.activeFocus onTriggered: root\.forcePasswordFocus\(\)/.test(compact),
  'a retry Timer reclaims password focus whenever the field should hold it'
)

assert(
  !/onInputEnabledChanged: \{ if \(inputEnabled\) Qt\.callLater\(forcePasswordFocus\)/.test(compact),
  'one-shot onInputEnabledChanged focus is replaced by the retry Timer'
)

assert(
  !/Component\.onCompleted: \{ syncPasswordText\(\) if \(inputEnabled\) Qt\.callLater\(forcePasswordFocus\)/.test(compact),
  'one-shot onCompleted focus is replaced by the retry Timer'
)

assert(
  /enabled: root\.inputEnabled && !root\.authenticatingPassword/.test(compact),
  'the field is still disabled for the duration of the password check'
)
JS
