#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/capture-text-file-test.py" "$ROOT"
pass "Saved-image OCR handles layouts, languages, and clipboard preservation"
