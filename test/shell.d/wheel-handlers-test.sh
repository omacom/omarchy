#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping wheel handler tests"
  exit 0
fi

# Quickshell's QML plugin only loads inside quickshell, so the shell's own
# handler files run here against stubs of everything they import.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

cp -r "$SHELL_TEST_DIR/wheel-handlers/stubs" "$test_tmp/imports"
cp -r "$SHELL_TEST_DIR/wheel-handlers/qml" "$test_tmp/qml"
mkdir "$test_tmp/qml/clock" "$test_tmp/qml/media" "$test_tmp/qml/widgets"

ln -s "$ROOT/shell/Commons/Util.qml" "$test_tmp/imports/qs/Commons/Util.qml"
ln -s "$ROOT/shell/Ui/PanelKeyCatcher.qml" "$test_tmp/imports/qs/Ui/PanelKeyCatcher.qml"
ln -s "$ROOT/shell/Ui/PanelSlider.qml" "$test_tmp/imports/qs/Ui/PanelSlider.qml"
ln -s "$ROOT/shell/plugins/bar/widgets/Microphone.qml" "$test_tmp/qml/widgets/Microphone.qml"
ln -s "$ROOT/shell/plugins/panels/clock/Model.js" "$test_tmp/qml/clock/Model.js"
ln -s "$ROOT/shell/plugins/panels/clock/Panel.qml" "$test_tmp/qml/clock/Panel.qml"
ln -s "$ROOT/shell/plugins/services/media/BarWidget.qml" "$test_tmp/qml/media/BarWidget.qml"

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -import "$test_tmp/imports" -input "$test_tmp/qml" -o -,txt 2>&1) ||
  fail "wheel handlers step once per split notch" "$output"
pass "wheel handlers step once per split notch"
