#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
python "$ROOT/test/shell.d/input-acceptance-checks.py"
