#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua
require_command python3

OMARCHY_PATH="$ROOT" python3 "$SHELL_TEST_DIR/fixtures/monitor-clamshell-layout.py"
