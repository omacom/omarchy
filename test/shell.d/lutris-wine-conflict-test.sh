#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/bin/omarchy-install-gaming-lutris"

grep -F 'wine-staging' "$install_script" >/dev/null ||
  fail "Lutris installer still prefers wine-staging when wine is not already installed"

grep -F 'pacman -Qq wine' "$install_script" >/dev/null ||
  fail "Lutris installer does not detect an existing wine package before adding wine-staging"

grep -F 'wine_pkg=wine' "$install_script" >/dev/null ||
  fail "Lutris installer does not keep existing wine instead of conflicting with wine-staging"

pass "Lutris installer keeps existing wine instead of conflicting with wine-staging"
