#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

quirks="$ROOT/default/libinput/50-omarchy.quirks"

[[ -f $quirks ]] || fail "the shipped libinput quirks file exists"
pass "the shipped libinput quirks file exists"

# The libinput CLI ships in libinput-tools, which a stock install does not have.
if command -v libinput >/dev/null 2>&1; then
  # Stage the file alone: libinput validates a whole directory, so the host's own
  # quirks would confound the result.
  test_tmp=$(mktemp -d)
  trap 'rm -rf "$test_tmp"' EXIT
  cp "$quirks" "$test_tmp/"

  if ! validate_output=$(libinput quirks validate --data-dir "$test_tmp" 2>&1); then
    fail "the shipped quirks file parses" "$validate_output"
  fi
  pass "the shipped quirks file parses"
else
  skip "libinput-tools not installed; skipping quirks validation"
fi

# Dropping a PID silently reintroduces the bug for that dongle.
for product in 0x2B1E 0x2EF2 0x2F06; do
  grep -qx "MatchProduct=$product" "$quirks" ||
    fail "the quirks cover the known Shokz dongles" "missing $product"
done
pass "the quirks cover the known Shokz dongles"

# The volume and media keys are real; only KEY_POWER may be dropped.
if grep '^AttrEventCode=' "$quirks" | grep -qvx 'AttrEventCode=-KEY_POWER'; then
  fail "the quirks drop only the phantom power key" "$(grep '^AttrEventCode=' "$quirks")"
fi
pass "the quirks drop only the phantom power key"

# Counted per section, so a filter moved from one dongle to another still fails.
unfiltered=$(awk '/^\[/ { if (section && !dropped) print section; section = $0; dropped = 0 }
  $0 == "AttrEventCode=-KEY_POWER" { dropped = 1 }
  END { if (section && !dropped) print section }' "$quirks")
[[ -z $unfiltered ]] || fail "every quirk section drops the power key" "$unfiltered"
pass "every quirk section drops the power key"
