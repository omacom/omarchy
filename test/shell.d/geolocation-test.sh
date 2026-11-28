#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 -B "$ROOT/test/geolocation/test_bridge.py"
pass "geolocation bridge guards"
