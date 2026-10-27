#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "remote session service test"
require_command grim

qml_fixture_scratch

cleanup() {
  if [[ -f $QML_FIXTURE_TMP/stub.pid ]]; then
    kill "$(<"$QML_FIXTURE_TMP/stub.pid")" 2>/dev/null || true
  fi
  qml_fixture_cleanup
}
trap cleanup EXIT

# A stand-in for the real server: the probe matches it by process name, so it
# must stay a script called gliff-server rather than exec into sleep, and it
# takes its sleep down with it when killed. Its ssh peer comes from the
# environment the fixture launches it with. It cannot capture the screen, so
# the fixture uses grim for the screencast event.
cat >"$QML_FIXTURE_TMP/bin/gliff-server" <<'SH'
#!/bin/bash
sleep 30 &
trap 'kill $!' TERM EXIT
wait $!
SH
chmod +x "$QML_FIXTURE_TMP/bin/gliff-server"

OMARCHY_QML_TEST_STUB_PID="$QML_FIXTURE_TMP/stub.pid" \
OMARCHY_QML_TEST_FRAME="$QML_FIXTURE_TMP/frame.png" \
  run_qml_fixture remote-session "remote session service tracks a gliff-server session"

[[ -s $QML_FIXTURE_TMP/frame.png ]] || fail "the fixture raised screencast events through grim"
pass "the fixture raised screencast events through grim"
