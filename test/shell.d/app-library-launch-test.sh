#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/shell/services/AppLibrary.qml"



run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/services/AppLibrary.qml', 'utf8')

const begin = source.match(/function beginLaunchFeedback[\s\S]*?\n  \}/)
assert(begin, 'beginLaunchFeedback exists')
assert(/launchSerial\+\+/.test(begin[0]), 'beginLaunchFeedback increments the launch serial')
assert(/launchDelay\.restart\(\)/.test(begin[0]), 'beginLaunchFeedback restarts the launch delay')
assert(/var sameApp = String\(name \|\| ""\) === root\.launchName/.test(begin[0]), 'beginLaunchFeedback compares the launched name against the running deadline')
assert(/if \(!launchTimeout\.running \|\| !sameApp\) launchTimeout\.restart\(\)/.test(begin[0]), 'beginLaunchFeedback only restarts the deadline for a different app or a stopped timer')
assert(
  !/launchTimeout\.restart\(\)/.test(begin[0].replace(/if \(!launchTimeout\.running \|\| !sameApp\) launchTimeout\.restart\(\)/, '')),
  'beginLaunchFeedback never restarts the launch deadline unconditionally'
)

const delay = source.match(/id: launchDelay[\s\S]*?\n  \}/)
assert(delay, 'launchDelay timer exists')
assert(/duration: launchTimeout\.interval/.test(delay[0]), 'launch OSD self-hides at the launch deadline even if a close is lost')

const timeout = source.match(/Timer \{\s*id: launchTimeout[\s\S]*?onTriggered:.*?\n  \}/)
assert(timeout, 'launchTimeout timer exists')
assert(/closeLaunchFeedback\(root\.launchSerial\)/.test(timeout[0]), 'launchTimeout closes the current launch feedback')
pass('launch feedback timeout is bounded and cannot be restarted indefinitely')
JS
