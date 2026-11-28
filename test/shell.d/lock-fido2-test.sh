#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/lock/Fido2Model.js')

assertEqual(model.retryDelayMs(0), model.RETRY_MS, 'a missed touch window retries at the normal interval')
assertEqual(model.retryDelayMs(1), model.ERROR_RETRY_BASE_MS, 'the first failure backs off')
assertEqual(model.retryDelayMs(3), model.ERROR_RETRY_BASE_MS * 4, 'failures keep doubling')
assertEqual(model.retryDelayMs(50), model.ERROR_RETRY_CAP_MS, 'the backoff is capped')
assertEqual(model.nextStreak(2, true, model.TOUCH_WINDOW_MS), 0, 'a prompt that waited out the window resets the streak')
assertEqual(model.nextStreak(2, true, model.TOUCH_WINDOW_MS - 1), 3, 'a prompt that failed inside the window counts as a miss')
assertEqual(model.nextStreak(2, false, 60000), 3, 'an attempt that never prompted counts as a miss however long it took')
assertEqual(model.WAKE_DELAY_MS < model.RETRY_MS, true, 'a nudge or wake comes sooner than a normal retry')
JS

require_quickshell "lock fido2 service test"

run_qml_fixture lock-fido2-service "security key attempts back off, pause on blank and clear on reset" Ui Commons
