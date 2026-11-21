#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Dismissing or clicking a card replayed from history removes that history
# entry. Every other close path keeps the behaviour of the service as written.
require_command node

if output=$(node "$SHELL_TEST_DIR/notifications/dismissal.cjs" 2>&1); then
  pass "replayed history cards are forgotten only when dismissed or clicked"
else
  fail "replayed history cards are forgotten only when dismissed or clicked" "$output"
fi
