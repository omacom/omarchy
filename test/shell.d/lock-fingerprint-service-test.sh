#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch

# The hung blank and wake are detached, so Quickshell's cleanup misses them; end their timeouts' groups too.
cleanup() {
  local pid group
  for pid in $(cat "$QML_FIXTURE_TMP"/hung*/pid 2>/dev/null); do
    group=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ' || true)
    if [[ -n $group && $group != "$(ps -o pgid= -p $$ | tr -d ' ')" ]]; then
      kill -KILL -- "-$group" 2>/dev/null || true
    else
      kill -KILL "$pid" 2>/dev/null || true
    fi
  done
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
cat >"$QML_FIXTURE_TMP/bin/omarchy-system-wake" <<SH
#!/bin/bash
if mkdir "$QML_FIXTURE_TMP/hung-wake" 2>/dev/null; then
  echo \$\$ >"$QML_FIXTURE_TMP/hung-wake/pid"
  exec sleep 10
else
  echo wake >>"$QML_FIXTURE_TMP/wake"
fi
SH
chmod +x "$QML_FIXTURE_TMP/bin/"omarchy-brightness-* "$QML_FIXTURE_TMP/bin/omarchy-system-wake"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons

for _ in {1..30}; do
  [[ -s $QML_FIXTURE_TMP/display && -s $QML_FIXTURE_TMP/wake ]] && break
  sleep 0.1
done
[[ $(cat "$QML_FIXTURE_TMP/display" 2>/dev/null) == "off" ]] || fail "a blank whose child hangs does not stop the next blank"
pass "a blank whose child hangs does not stop the next blank"

sleep 0.5
[[ $(cat "$QML_FIXTURE_TMP/wake" 2>/dev/null) == "wake" ]] || fail "unlock wakes past a hung wake, and input inside the window spawns no more" "$(cat "$QML_FIXTURE_TMP/wake" 2>/dev/null)"
pass "unlock wakes past a hung wake, and input inside the window spawns no more"
