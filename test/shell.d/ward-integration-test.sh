#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if [[ ${OMARCHY_TEST_SYSTEMD:-} == "1" && ${OMARCHY_TEST_GRAPHICS:-} == "1" && -n ${OMARCHY_TEST_QT_BRIDGE:-} && -n ${OMARCHY_TEST_WARD_HOST:-} && -n ${OMARCHY_TEST_WARD_RUNTIME:-} ]]; then
  require_command cargo
  cargo test --locked --manifest-path "$ROOT/test/shell.d/fixtures/ward-integration/Cargo.toml" -- --test-threads=1
  pass "Ward adapter, shell activation, reviewer and geometry integration"
else
  pass "Ward integration opt-ins absent; skipping private-display tests"
fi
