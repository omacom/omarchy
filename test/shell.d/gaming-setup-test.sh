#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
OMARCHY_TEST_ROOT="$ROOT" python3 "$ROOT/test/helpers/gaming-setup-routing.py"
