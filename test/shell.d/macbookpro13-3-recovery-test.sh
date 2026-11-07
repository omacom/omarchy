#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
python3 -B -m unittest discover -s "$ROOT/test/shell.d/fixtures/macbookpro13-3" -v
pass "MacBookPro13,3 recovery, refusal and installation fixtures"
