#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
PYTHONDONTWRITEBYTECODE=1 python3 "$ROOT/test/shell.d/fixtures/dots/test_dots.py"
pass 'preferences publish, merge, conflict recovery, deletion and isolation'
