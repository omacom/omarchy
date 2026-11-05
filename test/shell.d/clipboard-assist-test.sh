#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/clipboard-assist-test.py" "$ROOT"
pass "Clipboard assistance previews edits and preserves the clipboard on inference failures"
