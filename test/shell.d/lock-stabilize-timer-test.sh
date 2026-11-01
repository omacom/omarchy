#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Pins sessionLockStabilizeTimer so idle multi-monitor fractional-scale locks
# wait long enough for output geometry to settle before requestSessionLock().
# See #12949 / #12962: 500ms raced; 1500ms is the verified fix.

lock_service="$ROOT/shell/plugins/lock/Service.qml"

[[ -f $lock_service ]] || fail "lock Service.qml exists"

grep -F 'id: sessionLockStabilizeTimer' "$lock_service" >/dev/null ||
  fail "sessionLockStabilizeTimer is present in lock Service.qml"

# Match the Timer block so a different Timer's interval: 1500 cannot satisfy this.
if ! grep -Pzo 'id: sessionLockStabilizeTimer\n\s*interval: 1500\n' "$lock_service" >/dev/null; then
  fail "sessionLockStabilizeTimer interval is 1500ms" "$(rg -n -A2 'id: sessionLockStabilizeTimer' "$lock_service" || true)"
fi

# Guard against regressing to the pre-fix 500ms idle race.
if grep -Pzo 'id: sessionLockStabilizeTimer\n\s*interval: 500\n' "$lock_service" >/dev/null; then
  fail "sessionLockStabilizeTimer must not remain at 500ms"
fi

pass "sessionLockStabilizeTimer waits 1500ms before requestSessionLock"
