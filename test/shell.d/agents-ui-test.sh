#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command node
node "$SHELL_TEST_DIR/fixtures/agents-ui/refresh-reuse.js" "$ROOT/shell/plugins/agents/Main.qml"

qml_runner=$(command -v qmltestrunner || true)
if [[ -z $qml_runner && -x /usr/lib/qt6/bin/qmltestrunner ]]; then
  qml_runner=/usr/lib/qt6/bin/qmltestrunner
fi
if [[ -z $qml_runner ]]; then
  pass "Qt Test runner unavailable; skipping offscreen Agents QML behavior tests"
  exit 0
fi
PYTHONDONTWRITEBYTECODE=1 python3 "$SHELL_TEST_DIR/agents-ui.py" "$ROOT" "$qml_runner"
