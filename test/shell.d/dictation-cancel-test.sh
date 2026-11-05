#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/dictation-cancel-test.py" "$ROOT"
pass "Dictation cancellation discards Voxtype input and respects the backend-selection lock"
