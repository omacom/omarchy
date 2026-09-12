#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command node
PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/agent-remote.py" "$ROOT"
node "$SHELL_TEST_DIR/agent-remote-views.js" "$ROOT"
node "$SHELL_TEST_DIR/agent-remote-scheduling.js" "$ROOT"
