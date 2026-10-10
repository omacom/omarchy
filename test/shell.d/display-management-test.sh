#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
PYTHONPATH="$ROOT/shell/plugins/panels/monitor" python3 -B -m unittest discover \
  -s "$ROOT/test/shell.d/fixtures/display-management" -p 'test_*.py'
pass "display settings reject stale, concurrent, and unsupported changes"
