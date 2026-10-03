#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping clipboard QML lifecycle"
  exit 0
fi
python3 "$SHELL_TEST_DIR/fixtures/clipboard/lifecycle.py"
