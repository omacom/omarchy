#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/capture-describe-test.py" "$ROOT"
pass "Image descriptions validate vision support and cancellation before sending images"
