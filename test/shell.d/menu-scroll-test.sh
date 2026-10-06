#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A real ListView catches scroll errors that a model-only test cannot. Qt's
# offscreen platform runs this fixture without touching the desktop session.
qml_test_runner=""
if command -v qmltestrunner >/dev/null 2>&1; then
  qml_test_runner=$(command -v qmltestrunner)
elif command -v qtpaths6 >/dev/null 2>&1; then
  qml_test_runner="$(qtpaths6 --query QT_INSTALL_BINS)/qmltestrunner"
elif [[ -x /usr/lib/qt6/bin/qmltestrunner ]]; then
  qml_test_runner=/usr/lib/qt6/bin/qmltestrunner
fi
if [[ ! -x $qml_test_runner ]]; then
  pass "Qt Quick Test not installed; skipping menu scroll runtime test"
  exit 0
fi

require_command python3
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Run the function and geometry handlers from Menu.qml itself, with the
# surrounding shell replaced by a fixture that controls the opening resize.
python3 - "$ROOT" "$test_tmp" <<'PY'
from pathlib import Path
import re
import sys

root, target = map(Path, sys.argv[1:])
source = (root / 'shell/plugins/menu/Menu.qml').read_text()
fixtures = root / 'test/shell.d/fixtures/menu-scroll'
function = re.search(r'^  function revealCursor\(\) \{[\s\S]*?^  \}', source, re.M)
if function is None:
    raise SystemExit('Menu.qml does not define revealCursor()')
view = source[source.index('          ListView {\n            id: resultList'):]
view = view[:view.index('            section.property:')]
handlers = '\n'.join(re.findall(r'^\s*on(?:Width|Height)Changed:.*$', view, re.M))
harness = (fixtures / 'ScrollHarness.qml.in').read_text()
harness = harness.replace('@REVEAL_CURSOR@', function.group())
harness = harness.replace('@GEOMETRY_HANDLERS@', handlers)
(target / 'ScrollHarness.qml').write_text(harness)
(target / 'tst_menu-scroll.qml').write_text((fixtures / 'tst_menu-scroll.qml').read_text())
PY

output=$(timeout 15s env \
  QT_QPA_PLATFORM=offscreen \
  QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE=Basic \
  QT_QUICK_BACKEND=software \
  "$qml_test_runner" -input "$test_tmp" 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "menu keeps cursor rows visible during opening, resizing, and navigation"
}

printf '%s\n' "$output"
pass "menu keeps cursor rows visible during opening, resizing, and navigation"
