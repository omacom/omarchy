#!/bin/bash

set -euo pipefail

# Sunshine on stable can lag the security-fixed edge build (#10836). The helper
# and install path must keep that floor pinned until stable catches up.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-pkg-upgrade-sunshine-security"
[[ -x $helper ]] || fail "omarchy-pkg-upgrade-sunshine-security is executable"

grep -q '2026.906.222525-1.1' "$helper" ||
  fail "helper pins Sunshine 2026.906.222525-1.1 as the security floor"

grep -q 'pkgs.omarchy.org/edge' "$helper" ||
  fail "helper pulls the security build from the edge package repo"

grep -q 'vercmp' "$helper" ||
  fail "helper compares installed vs floor with vercmp"

pass "Sunshine security upgrade helper pins the edge security build"

install="$ROOT/bin/omarchy-install-service-sunshine"
grep -q 'omarchy-pkg-upgrade-sunshine-security' "$install" ||
  fail "Sunshine install path upgrades past the security floor after pkg-add"

pass "Sunshine install invokes the security upgrade helper"

migration="$ROOT/migrations/1789400200.sh"
[[ -f $migration ]] || fail "a migration upgrades installed Sunshine past the security floor"
grep -q 'omarchy-pkg-upgrade-sunshine-security' "$migration" ||
  fail "migration calls the Sunshine security upgrade helper"

pass "migration upgrades installed Sunshine past the security floor"
