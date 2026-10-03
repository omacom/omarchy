#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command lua
export OMARCHY_PATH="$ROOT"
export PYTHONPATH="$ROOT/shell/plugins/bar/widgets/keyboard"
python3 -B -m unittest discover -s "$ROOT/test/keyboard-layouts" -v
