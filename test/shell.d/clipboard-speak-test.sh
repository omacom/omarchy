#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/clipboard-speak-test.py" "$ROOT"
pass "Clipboard speech uses a local voice, waits for synthesis, and cleans temporary audio"
