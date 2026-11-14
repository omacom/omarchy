#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 -B "$ROOT/test/powerprofiles/actions.py"
pass "profile actions validate files and continue after failures"
