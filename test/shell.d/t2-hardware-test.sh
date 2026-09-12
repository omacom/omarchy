#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"
grep -Fq 'pm_async=off mem_sleep_default=deep' "$fix_t2" || fail "T2 setup installs suspend parameters"
(( $(grep -Ec '^\[Fan[12]\]$' "$fix_t2") == 2 )) || fail "T2 setup configures both fans"
! grep -q 'tiny-dfr' "$fix_t2" || fail "T2 setup leaves tiny-dfr uninstalled"
pass "fresh T2 setup retains the repaired defaults"
grep -Fq '/usr/share/omarchy/migrations/1785944594.sh --machine' "$ROOT/migrations/1785944594.sh" || fail "T2 migration lacks fixed machine phase"
pass "T2 repair uses its fixed packaged machine phase"
