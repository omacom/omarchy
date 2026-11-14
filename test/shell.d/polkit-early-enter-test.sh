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
  skip "qt6 qmltestrunner not found; skipping polkit early Enter tests"
  exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Run the shipped dialog, not a copy of its logic. Only the layer-shell
# attached properties, the exclusion mode enum and the window's screen anchors
# are dropped: QML can't stand in for an attached type, an enum or a window.
agent_qml=$ROOT/shell/plugins/polkit/PolkitAgent.qml
layer_shell='^ *(WlrLayershell\.|exclusionMode:|anchors \{ top: true)'
grep -Eq "$layer_shell" "$agent_qml" || fail "polkit dialog still sets layer-shell properties for the test to drop"
grep -Ev "$layer_shell" "$agent_qml" >"$work/PolkitAgentUnderTest.qml"
cp "$ROOT/shell/plugins/polkit/PolkitModel.js" "$work/"
cp "$SHELL_TEST_DIR/polkit-agent/qml/"*.qml "$work/"

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" \
  -import "$SHELL_TEST_DIR/polkit-agent/imports" -input "$work" -o -,txt 2>&1) ||
  fail "polkit keeps an early Enter visible, cancellable and sent once PAM asks" "$output"
[[ $output == *"Totals: 9 passed, 0 failed"* ]] || fail "polkit early Enter tests ran every case" "$output"
pass "polkit keeps an early Enter visible, cancellable and sent once PAM asks"
