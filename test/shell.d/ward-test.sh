#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if "$ROOT/bin/omarchy-cmd-present" cargo; then
  cargo test --locked --manifest-path "$ROOT/native/ward/Cargo.toml"
  cargo test --locked --manifest-path "$ROOT/test/shell.d/fixtures/ward-integration/Cargo.toml" --test documentation
  pass "plugin host native tests"
else
  pass "cargo unavailable; skipping optional native plugin host tests"
fi
