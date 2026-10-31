#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v mpv >/dev/null; then
  skip "mpv is not installed, so playback checks cannot run"
  exit 0
fi

require_command python3
require_command luac
luac -p "$ROOT/config/mpv/scripts/omarchy-controls.lua"
luac -p "$ROOT/config/mpv/scripts/omarchy-theme.lua"
pass "mpv Lua scripts parse"
python3 "$ROOT/test/shell.d/fixtures/mpv/palette.py"
pass "mpv retints real paused playback and rejects invalid palette data"
