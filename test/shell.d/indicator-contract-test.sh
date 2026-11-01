#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "QML contract test"

run_qml_fixture indicator-contract "QML indicator contract checks pass" Ui Commons

if rg -q 'Indicators.qml.*Binding loop detected for property "implicitWidth"' "$QML_FIXTURE_LOG"; then
  sed -n '1,200p' "$QML_FIXTURE_LOG" >&2
  fail "indicator tray avoids implicit-width binding loops"
fi
pass "indicator tray avoids implicit-width binding loops"

# Hold an active status result until the recorder-exit event has arrived.
qml_fixture_scratch
export TEST_RECORDING_STATE="$QML_FIXTURE_TMP/recording-state"
mkdir -p "$TEST_RECORDING_STATE"
touch "$TEST_RECORDING_STATE/active"
mkfifo "$TEST_RECORDING_STATE/release"
cat >"$QML_FIXTURE_TMP/bin/omarchy-capture-screenrecording" <<'SH'
#!/bin/bash
if [[ -e $TEST_RECORDING_STATE/active ]]; then
  touch "$TEST_RECORDING_STATE/observed"
  read -r _ <"$TEST_RECORDING_STATE/release"
  exit 0
fi
exit 1
SH
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-capture-screenrecording"
run_qml_fixture recording-refresh "recording exit refresh survives an in-flight status query" Ui Commons
