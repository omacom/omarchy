#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch

# The hung blank is detached, so Quickshell's cleanup misses it; end its timeout's group too.
cleanup() {
  local pid group
  if pid=$(cat "$QML_FIXTURE_TMP/hung/pid" 2>/dev/null); then
    group=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ' || true)
    if [[ -n $group && $group != "$(ps -o pgid= -p $$ | tr -d ' ')" ]]; then
      kill -KILL -- "-$group" 2>/dev/null || true
    else
      kill -KILL "$pid" 2>/dev/null || true
    fi
  fi
  qml_fixture_cleanup
}
trap cleanup EXIT

cat >"$QML_FIXTURE_TMP/bin/omarchy-brightness-keyboard" <<SH
#!/bin/bash
[[ \$1 == "off" ]] || exit 0
if mkdir "$QML_FIXTURE_TMP/hung" 2>/dev/null; then
  echo \$\$ >"$QML_FIXTURE_TMP/hung/pid"
  exec sleep 10
fi
SH
cat >"$QML_FIXTURE_TMP/bin/omarchy-brightness-display" <<SH
#!/bin/bash
echo "\$*" >>"$QML_FIXTURE_TMP/display"
SH
chmod +x "$QML_FIXTURE_TMP/bin/"omarchy-brightness-*

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons

for _ in {1..30}; do
  [[ -s $QML_FIXTURE_TMP/display ]] && break
  sleep 0.1
done
[[ $(cat "$QML_FIXTURE_TMP/display" 2>/dev/null) == "off" ]] || fail "a blank whose child hangs does not stop the next blank"
pass "a blank whose child hangs does not stop the next blank"
