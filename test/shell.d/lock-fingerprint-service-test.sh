#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch
# The fixture's wake section drives runWake: a no-op wake, and a hyprctl whose
# monitors answer dark until the fixture flips its state file, so the blank
# grace can be watched holding while the displays are dark and starting once
# they report themselves lit.
cat >"$QML_FIXTURE_TMP/bin/omarchy-system-wake" <<'SH'
#!/bin/bash
SH
cat >"$QML_FIXTURE_TMP/bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == monitors ]]; then
  if [[ $(<"$OMARCHY_TEST_DPMS_FILE") == on ]]; then
    echo '[{"name":"DP-1","disabled":false,"dpmsStatus":true}]'
  else
    echo '[{"name":"DP-1","disabled":false,"dpmsStatus":false}]'
  fi
fi
SH
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-system-wake" "$QML_FIXTURE_TMP/bin/hyprctl"
printf off >"$QML_FIXTURE_TMP/dpms"

OMARCHY_TEST_WAKE_CHECK=1 \
OMARCHY_TEST_DPMS_FILE="$QML_FIXTURE_TMP/dpms" \
  run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
