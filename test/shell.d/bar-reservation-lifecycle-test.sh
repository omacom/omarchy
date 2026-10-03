#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping bar reservation lifecycle"
  exit 0
fi
require_command python3
PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/fixtures/bar-reservation.py" "$ROOT"
