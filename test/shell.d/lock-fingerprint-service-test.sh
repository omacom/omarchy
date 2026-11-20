#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons

# A new lock service asks fprintd-list about enrolment, and the scan fixture's
# wiring check waits for that answer before it sends its stand-in line. Where
# this machine's lock has fingerprint PAM, the real fprintd-list can take
# longer than that wait to start the daemon, and an answer of no enrolment
# landing late would settle the attempt under the check. A stub answers at
# once, with an enrolment.
printf '#!/bin/bash\nprintf "Fingerprints for user %%s on Stub:\\n - #0: right-index-finger\\n" "$1"\n' >"$QML_FIXTURE_TMP/bin/fprintd-list"
chmod +x "$QML_FIXTURE_TMP/bin/fprintd-list"

run_qml_fixture lock-fingerprint-scan "fingerprint service shows the reader matching a finger" Ui Commons
