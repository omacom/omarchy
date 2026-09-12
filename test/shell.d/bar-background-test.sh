#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
[[ -x /usr/lib/qt6/bin/qmltestrunner ]] || fail "Qt 6 qmltestrunner is available"
background_test_dir=$(mktemp -d)
trap 'rm -rf "$background_test_dir"' EXIT
# Exercise the actual loader and fallback expression, without launching a
# second desktop shell or depending on monitors/services unrelated to paint.
python3 - "$ROOT" "$background_test_dir" <<'PY'
from pathlib import Path
import sys
root, target = map(Path, sys.argv[1:])
source = (root / "shell/plugins/bar/Bar.qml").read_text()
start = source.rfind("    Loader {", 0, source.index("id: backgroundLoader"))
end, depth = source.index("{", start) + 1, 1
while depth:
    depth += (source[end] == "{") - (source[end] == "}")
    end += 1
loader = source[start:end]
color = next(line.strip() for line in source.splitlines() if "color: root.transparent || backgroundLoader.item" in line)
(target / "BackgroundHarness.qml").write_text('''import QtQuick
Rectangle {
  id: root
  property color background: "#223344"
  property bool transparent: false
  property string position: "top"
  property bool vertical: false
  property Component backgroundComponent: null
  property alias painted: backgroundLoader.item
''' + color + "\n" + loader + "\n}\n")
PY
cp "$SHELL_TEST_DIR/fixtures/bar-background/tst_background.qml" "$background_test_dir/"
QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input "$background_test_dir"
pass "bar backgrounds follow geometry/theme, ignore input and restore on removal/transparency"
