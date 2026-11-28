#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v mpv >/dev/null; then
  skip "mpv is not installed, so playback checks cannot run"
  exit 0
fi

require_command python3
python3 "$ROOT/test/shell.d/fixtures/mpv/rounding.py"
pass "mpv follows live rounding, retains valid geometry, and respects fixed overrides"
