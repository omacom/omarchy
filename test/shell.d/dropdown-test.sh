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
    "$qml_test_runner" -import "$fixture" -input "$fixture" -o -,txt >"$fixture/run-$1.log" 2>&1 ||
    touch "$fixture/run-$1.failed"
}
for round in 1 2 3 4 5 6 7 8 9 10 11 12; do
  for slot in 1 2 3 4; do
    run_once "$round-$slot" &
  done
  wait
done
failed=0
for marker in "$fixture"/run-*.failed; do
  [[ -e $marker ]] || continue
  failed=$(( failed + 1 ))
  log=${marker%.failed}.log
  echo "=== $log"
  if grep -q "STALL" "$log"; then
    grep -B6 -A12 "STALL" "$log"
  else
    # A failure the walk did not flag: what led up to it, and the runner's own summary.
    grep -B70 -A8 "^FAIL!" "$log" || tail -n 60 "$log"
  fi
done
(( failed == 0 )) || fail "dropdown popup test failed in $failed of 48 runs"
pass "dropdown popup fits short lists and preserves capped scrolling in 48 runs"
