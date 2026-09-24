#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

SCRIPT="$ROOT/shell/services/AppLibrary.qml"

if ! grep -q 'launchTimeout\.running' "$SCRIPT"; then
  fail "beginLaunchFeedback must not restart the launch timeout while one is running"
fi
pass "beginLaunchFeedback does not restart the launch timeout"

if ! grep -q 'launchTimeout\.start()' "$SCRIPT"; then
  fail "beginLaunchFeedback still starts the launch timeout when none is running"
fi
pass "beginLaunchFeedback starts the launch timeout when none is running"

run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/services/AppLibrary.qml', 'utf8')

const begin = source.match(/function beginLaunchFeedback[\s\S]*?\n  \}/)
assert(begin, 'beginLaunchFeedback exists')
assert(/launchSerial\+\+/.test(begin[0]), 'beginLaunchFeedback increments the launch serial')
assert(/launchDelay\.restart\(\)/.test(begin[0]), 'beginLaunchFeedback restarts the launch delay')
assert(/!launchTimeout\.running/.test(begin[0]), 'beginLaunchFeedback does not restart a running launch timeout')
assert(/launchTimeout\.start\(\)/.test(begin[0]), 'beginLaunchFeedback starts the launch timeout when stopped')

const timeout = source.match(/Timer \{\s*id: launchTimeout[\s\S]*?onTriggered:.*?\n  \}/)
assert(timeout, 'launchTimeout timer exists')
assert(/closeLaunchFeedback\(root\.launchSerial\)/.test(timeout[0]), 'launchTimeout closes the current launch feedback')
pass('launch feedback timeout is bounded and cannot be restarted indefinitely')
JS
