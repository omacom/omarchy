#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
python3 "$SHELL_TEST_DIR/agent-usage-codex-daily.py" "$ROOT"
