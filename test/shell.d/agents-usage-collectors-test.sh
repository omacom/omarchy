#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 python3 -m unittest \
  "$ROOT/shell/plugins/agents/tests/test_cursor_usage.py" \
  "$ROOT/shell/plugins/agents/tests/test_opencode_usage.py"
pass "agents usage collectors: Cursor Settings meters and OpenCode message dates"
