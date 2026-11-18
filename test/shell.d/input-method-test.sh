#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" python "$ROOT/test/shell.d/input-method-checks.py"
