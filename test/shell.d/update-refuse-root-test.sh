#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -F 'EUID == 0' "$ROOT/bin/omarchy-update" >/dev/null ||
  fail "omarchy-update does not refuse a root caller"
grep -F 'must not run as root' "$ROOT/bin/omarchy-update" >/dev/null ||
  fail "omarchy-update root refusal lacks a clear error"
pass "omarchy-update refuses to run as root"

# Fake a root EUID without needing real root: rewrite check via bash -c env is hard;
# assert the guard sits before logging/lock so it cannot be skipped by -y alone.
guard_line=$(grep -n 'EUID == 0' "$ROOT/bin/omarchy-update" | head -1 | cut -d: -f1)
logged_line=$(grep -n 'OMARCHY_UPDATE_LOGGED' "$ROOT/bin/omarchy-update" | head -1 | cut -d: -f1)
(( guard_line < logged_line )) ||
  fail "root refusal must run before update logging begins"
pass "omarchy-update root refusal runs before logging"
