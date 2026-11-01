#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

# Exercise wake IPC without changing the real display or brightness.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-system-wake"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-system-wake"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
