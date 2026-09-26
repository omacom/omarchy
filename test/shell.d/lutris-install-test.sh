#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

installer="$ROOT/bin/omarchy-install-gaming-lutris"

rg -q 'if omarchy-pkg-present wine' "$installer" ||
  fail "Lutris installer keeps an already-installed wine package"
rg -q 'wine_pkg=wine-staging' "$installer" ||
  fail "Lutris installer still prefers wine-staging when wine is absent"
rg -q 'omarchy-pkg-add lutris umu-launcher "\$wine_pkg"' "$installer" ||
  fail "Lutris installer installs exactly one wine provider"
pass "Lutris installer does not conflict with an existing wine package"
