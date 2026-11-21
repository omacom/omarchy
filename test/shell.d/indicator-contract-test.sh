#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "QML contract test"

# The section-peek check builds the real bar, which syncs the compositor's
# blur to its background as it starts.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-bar"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-bar"

run_qml_fixture indicator-contract "QML indicator contract checks pass" Ui Commons

if rg -q 'Indicators.qml.*Binding loop detected for property "implicitWidth"' "$QML_FIXTURE_LOG"; then
  sed -n '1,200p' "$QML_FIXTURE_LOG" >&2
  fail "indicator tray avoids implicit-width binding loops"
fi
pass "indicator tray avoids implicit-width binding loops"
