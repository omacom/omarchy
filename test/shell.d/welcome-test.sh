#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python
require_command node

OMARCHY_PATH="$ROOT" PYTHONPATH="$ROOT/default/welcome" python -m unittest discover -s "$ROOT/test/shell.d/fixtures/welcome" -v
node --check "$ROOT/default/welcome/web/app.js"
pass "welcome progress, shortcuts, email dispatch, and local API boundaries"
