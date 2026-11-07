#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# An unknown target used to fall through the case statement and exit 0,
# silently installing nothing.
if "$ROOT/bin/omarchy-install-dev-env" not-a-real-env 2>/dev/null; then
  fail "install-dev-env rejects an unknown target"
fi
pass "install-dev-env rejects an unknown target"

# The error should say what was wrong and what the choices are.
usage=$("$ROOT/bin/omarchy-install-dev-env" not-a-real-env 2>&1 >/dev/null || true)
[[ $usage == *"Unknown dev environment: not-a-real-env"* ]] ||
  fail "install-dev-env names the unknown target" "actual: $usage"
[[ $usage == *"Usage: omarchy-install-dev-env"* ]] ||
  fail "install-dev-env prints usage for an unknown target" "actual: $usage"
pass "install-dev-env explains an unknown target"

# The existing missing-argument contract stays intact, and both failures
# must show the same complete list of valid targets.
if "$ROOT/bin/omarchy-install-dev-env" 2>/dev/null; then
  fail "install-dev-env still requires an argument"
fi
missing_usage=$("$ROOT/bin/omarchy-install-dev-env" 2>&1 >/dev/null || true)
unknown_usage=$(printf '%s\n' "$usage" | grep '^Usage:')
[[ $missing_usage == "$unknown_usage" ]] ||
  fail "missing and unknown arguments share identical supported targets" "missing: $missing_usage; unknown: $unknown_usage"
pass "install-dev-env rejects missing args with the same usage list"
