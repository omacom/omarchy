#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/voxtype-recording-options-test.py" "$ROOT"
pass "Voxtype recording options retain argument boundaries and backend failures"
