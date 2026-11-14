#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "Qt6 qmltestrunner not found; skipping dropdown popup geometry tests"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/qs/Commons" "$fixture/qs/Ui" "$fixture/home"
cp "$SHELL_TEST_DIR/dropdown/Commons/"* "$fixture/qs/Commons/"
cp "$ROOT/shell/Commons/Border.qml" "$ROOT/shell/Commons/BorderGeometry.js" "$fixture/qs/Commons/"
cp "$ROOT/shell/Ui/Dropdown.qml" "$ROOT/shell/Ui/BorderSurface.qml" "$ROOT/shell/Ui/BorderOverlay.qml" "$fixture/qs/Ui/"
cp "$SHELL_TEST_DIR/dropdown/qml/"* "$fixture/"

# DIAGNOSTIC, temporary: repeat the run and print what led up to a stalled walk.
run_once() {
  HOME="$fixture/home" XDG_CONFIG_HOME="$fixture/home/.config" XDG_STATE_HOME="$fixture/home/.state" \
    QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software QT_QUICK_CONTROLS_STYLE=Basic \
    "$qml_test_runner" -import "$fixture" -input "$fixture" -o -,txt >"$fixture/run-$1.log" 2>&1 || true
}
for round in 1 2 3 4 5 6 7 8; do
  for slot in 1 2 3 4; do
    run_once "$round-$slot" &
  done
  wait
done
stalled=$(grep -l "STALL" "$fixture"/run-*.log || true)
if [[ -n $stalled ]]; then
  for log in $stalled; do
    echo "=== $log"
    grep -B70 -A45 "STALL" "$log"
  done
  fail "dropdown walk stalled in $(wc -w <<<"$stalled") of 32 runs"
fi
grep -h "^FAIL!" -A4 "$fixture"/run-*.log || true
pass "dropdown walk never stalled in 32 runs"
