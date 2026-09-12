#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 python3 -m unittest \
  "$ROOT/shell/plugins/agents/tests/test_today_fields.py" \
  "$ROOT/shell/plugins/agents/tests/test_period_model_map.py"
pass "agents usage accuracy: stale today fields and period model map"
