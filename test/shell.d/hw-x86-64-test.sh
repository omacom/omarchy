#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hw_x86_64() {
  OMARCHY_UNAME_M="$1" "$ROOT/bin/omarchy-hw-x86-64"
}

if hw_x86_64 x86_64 >/dev/null 2>&1; then
  pass "x86_64 reports as x86_64"
else
  fail "x86_64 reports as x86_64"
fi

if hw_x86_64 aarch64 >/dev/null 2>&1; then
  fail "aarch64 is not x86_64"
else
  pass "aarch64 is not x86_64"
fi

if hw_x86_64 arm64 >/dev/null 2>&1; then
  fail "arm64 is not x86_64"
else
  pass "arm64 is not x86_64"
fi
