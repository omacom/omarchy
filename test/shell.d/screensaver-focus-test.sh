#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

screensaver="$ROOT/bin/omarchy-screensaver"

grep -Fq 'was_focused=0' "$screensaver" ||
  fail "screensaver latches whether it has held focus"
grep -Fq 'elif ((was_focused)); then' "$screensaver" ||
  fail "screensaver only treats lost focus as dismissal after it has held focus"

# The old check exited whenever activewindow was not the screensaver, which is
# exactly the state while a layer-shell panel (clock calendar, etc.) holds
# keyboard focus and the newly mapped screensaver never becomes active.
if grep -Eq 'read -n1 -t 1 \|\| ! screensaver_in_focus' "$screensaver"; then
  fail "screensaver still dismisses before it has ever held focus"
fi

pass "screensaver ignores missing focus until it has held focus once"
