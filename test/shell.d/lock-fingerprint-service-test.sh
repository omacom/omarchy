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

# A lock with a reader enrolled starts the watch on fprintd. The scan fixture
# never lets one run long enough to spawn it, and the wiring check swaps in a
# printf, but should that change, a real gdbus would join this machine's system
# bus and could start the host's fprintd. The stub prints the monitor's header,
# then waits until the lock stops it or the shell is gone.
printf '#!/bin/bash\necho "Monitoring signals from all objects owned by net.reactivated.Fprint"\nwhile kill -0 "$PPID" 2>/dev/null; do sleep 0.2; done\n' >"$QML_FIXTURE_TMP/bin/gdbus"
chmod +x "$QML_FIXTURE_TMP/bin/gdbus"

run_qml_fixture lock-fingerprint-scan "fingerprint service shows the reader matching a finger" Ui Commons
