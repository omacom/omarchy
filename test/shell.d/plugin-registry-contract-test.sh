#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "plugin registry contract test"

run_qml_fixture plugin-registry "plugin registry contract checks pass" services Commons

watcher=""
for _ in {1..30}; do
  watcher=$(pgrep -P "$QML_FIXTURE_PID" -x inotifywait) && break
  sleep 0.1
done
[[ -n $watcher ]] || fail "fixture starts a plugin watcher"
# A stopped child cannot handle TERM, so cleanup must also reach its KILL fallback.
kill -STOP "$watcher"
kill -KILL "$QML_FIXTURE_PID"
wait "$QML_FIXTURE_PID" 2>/dev/null || true
qml_fixture_cleanup
for _ in {1..100}; do
  kill -0 "$watcher" 2>/dev/null || break
  sleep 0.01
done
if kill -0 "$watcher" 2>/dev/null; then
  kill -KILL "$watcher" 2>/dev/null || true
  fail "crashed fixture cleanup stops its surviving plugin watcher"
fi
pass "crashed fixture cleanup stops its surviving plugin watcher"
