#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua
OMARCHY_PATH="$ROOT" lua "$ROOT/test/shell.d/fixtures/scrolling-window-move.lua"
pass "scrolling swaps stay local, cross monitor boundaries, and stop safely at outer edges"
