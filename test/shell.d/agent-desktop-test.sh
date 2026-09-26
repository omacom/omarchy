#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command python3
python3 -m unittest discover -s "$ROOT/default/agent-desktop/test"
pass "agent desktop installer preserves existing configuration and recovers from failure"
