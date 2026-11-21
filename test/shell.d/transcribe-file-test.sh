#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 "$ROOT/test/shell.d/fixtures/transcribe-file-test.py" "$ROOT"
pass "Local file transcription converts audio before inference and preserves existing outputs"
