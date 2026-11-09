#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v mpv >/dev/null; then
  skip "mpv is not installed, so playback checks cannot run"
  exit 0
fi

require_command python3
python3 "$ROOT/test/shell.d/fixtures/mpv/reveal.py"
pass "mpv top and bottom controls reveal independently with matching input regions"

require_command ffmpeg
python3 "$ROOT/test/shell.d/fixtures/mpv/seek.py"
pass "mpv clicks and drags seek precisely on short clips without timeline bounce"
