#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

mkdir -p "$fixture/test/shell.d" "$fixture/install/hardware"
cp "$ROOT/test/shell.d/base-test.sh" "$ROOT/test/shell.d/hardware-packages-test.sh" "$fixture/test/shell.d/"
printf '%s\n' mirrored-driver >"$fixture/install/omarchy-base.packages"
printf '' >"$fixture/install/omarchy-other.packages"
cat >"$fixture/install/hardware/example.sh" <<'EOF'
drivers=(missing-driver)
omarchy-pkg-add "${drivers[@]}"
omarchy-pkg-add mirrored-driver
EOF

if output=$(bash "$fixture/test/shell.d/hardware-packages-test.sh" 2>&1); then
  fail "an unresolved package array fails closed" "$output"
else
  [[ $output == *'cannot resolve package argument: ${drivers[@]}'* ]] ||
    fail "an unresolved package array fails closed" "$output"
fi

pass "an unresolved package array fails closed"
