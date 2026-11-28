#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar drag test"

# The bar syncs the compositor's blur to its background as it starts.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-bar"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-bar"

run_qml_fixture bar-drag "dragged widgets land where dropped, as the instances dragged" Ui Commons

export OMARCHY_CYCLE_LOG="$QML_FIXTURE_TMP/omarchy-bar-calls.log"
{
  echo '#!/bin/bash'
  echo 'echo "$*" >>"$OMARCHY_CYCLE_LOG"'
  echo 'exit 0'
} >"$QML_FIXTURE_TMP/bin/omarchy-bar"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-bar"

printf '#!/bin/bash\necho dwindle\n' >"$QML_FIXTURE_TMP/bin/omarchy-hyprland-workspace-layout-current"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-hyprland-workspace-layout-current"

run_qml_fixture bar-clicks "the click cycles answer bar.clicks in shell.json" Ui Commons

count=$(grep -cx 'background cycle' "$OMARCHY_CYCLE_LOG" || true)
if (( count != 1 )); then
  printf 'omarchy-bar calls (%s background cycles):\n' "$count" >&2
  cat "$OMARCHY_CYCLE_LOG" >&2
  fail "exactly one background cycle: from the double-click with the click on alone"
fi
pass "the double-click cycles the background with the click on and stays put with it off"

run_qml_fixture bar-clicks-workspaces "the active workspace cycles the layout only while the click is on, and other presses still focus" Ui Commons
