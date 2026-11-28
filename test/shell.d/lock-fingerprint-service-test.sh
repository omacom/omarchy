#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch
cp -a "$ROOT/shell/plugins/lock" "$QML_FIXTURE_TMP/lock"
touch "$QML_FIXTURE_TMP/fingerprint-pam"
# Redirect only the PAM presence check; run the real Process, timeout and callback.
sed -i "s|/etc/pam.d/omarchy-lock-fingerprint|$QML_FIXTURE_TMP/fingerprint-pam|g" "$QML_FIXTURE_TMP/lock/Service.qml"
cat >"$QML_FIXTURE_TMP/bin/fprintd-list" <<'STUB'
#!/bin/bash
if [[ ${OMARCHY_TIMEOUT_CHECK:-} != 1 ]]; then
  echo no
elif [[ ! -e $OMARCHY_QML_PROBE_CALLS ]]; then
  touch "$OMARCHY_QML_PROBE_CALLS"
  printf ' - #0: right-index-finger\n'
  exec sleep 30
else
  echo no
fi
STUB
chmod +x "$QML_FIXTURE_TMP/bin/fprintd-list"
OMARCHY_QML_PROBE_SERVICE="$QML_FIXTURE_TMP/lock/Service.qml" \
OMARCHY_QML_PROBE_CALLS="$QML_FIXTURE_TMP/probe-called" \
run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
