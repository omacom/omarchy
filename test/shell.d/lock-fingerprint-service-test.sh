#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

qml_fixture_scratch
# Observe dispatches from the real service without changing the displays.
for command in omarchy-brightness-display omarchy-brightness-keyboard omarchy-system-wake; do
  cat >"$QML_FIXTURE_TMP/bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$OMARCHY_LOCK_COMMANDS"
SH
  chmod +x "$QML_FIXTURE_TMP/bin/$command"
done

export OMARCHY_LOCK_COMMANDS="$QML_FIXTURE_TMP/commands"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons

display_runs=$(grep -cx 'omarchy-brightness-display off' "$OMARCHY_LOCK_COMMANDS" || true)
keyboard_runs=$(grep -cx 'omarchy-brightness-keyboard off' "$OMARCHY_LOCK_COMMANDS" || true)
(( display_runs == 3 )) || fail "every blank dispatches display off"
(( keyboard_runs == 3 )) || fail "every blank dispatches keyboard off, including after an external backlight change"
pass "repeated blanks dispatch both display and keyboard off across wakes"
