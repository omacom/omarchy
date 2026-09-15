#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command quickshell
python3 -B "$ROOT/test/keyboard-layouts/render_native.py"
