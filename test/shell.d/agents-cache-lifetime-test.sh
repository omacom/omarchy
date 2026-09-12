#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command node
require_command python3
node --expose-gc "$SHELL_TEST_DIR/agents-cache-lifetime.js" "$ROOT"
qml_runner=$(command -v qmltestrunner || true)
if [[ -z $qml_runner && -x /usr/lib/qt6/bin/qmltestrunner ]]; then
  qml_runner=/usr/lib/qt6/bin/qmltestrunner
fi
if [[ -z $qml_runner ]]; then
  pass "Qt Test runner unavailable; skipping offscreen presentation cache lifetime tests"
  exit 0
fi
PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/agents-cache-lifetime.py" "$ROOT" "$qml_runner"
