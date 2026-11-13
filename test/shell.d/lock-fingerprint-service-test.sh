#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-system-wake"
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-brightness-display"
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-brightness-keyboard"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-system-wake" \
  "$QML_FIXTURE_TMP/bin/omarchy-brightness-display" \
  "$QML_FIXTURE_TMP/bin/omarchy-brightness-keyboard"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
