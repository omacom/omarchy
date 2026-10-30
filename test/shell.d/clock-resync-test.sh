#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

units="$ROOT/default/systemd/user"

require_command systemd-analyze

# systemd ignores a key it does not know with only a warning, so a misspelt
# OnClockChange= would leave a timer that never fires. verify also checks that
# the ExecStart binary exists, so it needs the package.
if [[ -x /usr/bin/omarchy-shell ]]; then
  verify=$(systemd-analyze --user verify "$units/omarchy-clock-resync.timer" "$units/omarchy-clock-resync.service" 2>&1) ||
    fail "systemd accepts the clock resync units" "$verify"
  [[ -z $verify ]] || fail "systemd accepts the clock resync units" "$verify"
  pass "systemd accepts the clock resync units"
else
  skip "systemd accepts the clock resync units: /usr/bin/omarchy-shell is not installed"
fi
