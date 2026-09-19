#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/shell/plugins/agents/tests/test_tracking.py"
pass "agents tracking indexes local records and reads previews"
