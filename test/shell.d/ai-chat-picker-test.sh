#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/ai-chat-picker-test.py" "$ROOT"
pass "Local chat picks installed completion models without downloads or cloud routing"
