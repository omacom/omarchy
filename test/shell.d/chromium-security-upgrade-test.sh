#!/bin/bash

set -euo pipefail

# Chromium on stable can lag a frozen Omarchy mirror (#10732). Keep a helper
# that lifts installed builds to the CVE-2026-85046 floor.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-pkg-upgrade-chromium-security"
[[ -x $helper ]] || fail "omarchy-pkg-upgrade-chromium-security is executable"

grep -q '152.0.7977.82-1' "$helper" ||
  fail "helper pins Chromium 152.0.7977.82-1 as the security floor"

grep -q 'stable-mirror.omarchy.org' "$helper" ||
  fail "helper prefers the Omarchy stable mirror when it has the floor build"

grep -q 'geo.mirror.pkgbuild.com' "$helper" ||
  fail "helper falls back to Arch when the Omarchy mirror is behind"

grep -q 'vercmp' "$helper" ||
  fail "helper compares installed vs floor with vercmp"

pass "Chromium security upgrade helper pins the CVE floor"

migration="$ROOT/migrations/1789400400.sh"
[[ -f $migration ]] || fail "a migration upgrades installed Chromium past the security floor"
grep -q 'omarchy-pkg-upgrade-chromium-security' "$migration" ||
  fail "migration calls the Chromium security upgrade helper"

pass "migration upgrades installed Chromium past the CVE floor"
