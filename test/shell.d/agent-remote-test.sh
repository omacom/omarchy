#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/agent-remote.py" "$ROOT"
require_command node
node "$SHELL_TEST_DIR/agent-remote-views.js" "$ROOT"
