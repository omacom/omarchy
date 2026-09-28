#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
python3 "$ROOT/test/shell.d/fixtures/blackwell-audio-test.py"
pass "Blackwell/audio profile matching, ownership, flags, installer, migration and rollback"
