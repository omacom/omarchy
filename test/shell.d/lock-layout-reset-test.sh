#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock layout reset test"

# Suspend and recovery reach the lock service without omarchy-system-lock, so
# the service itself must reset the layout, and a stalled IPC must not hold the lock up.
qml_fixture_scratch
call_log="$QML_FIXTURE_TMP/hyprctl.calls"
cat >"$QML_FIXTURE_TMP/bin/hyprctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$HYPRCTL_CALL_LOG"
[[ $1 == "switchxkblayout" ]] && sleep 5
exit 0
SH
chmod +x "$QML_FIXTURE_TMP/bin/hyprctl"

HYPRCTL_CALL_LOG="$call_log" \
  run_qml_fixture lock-layout-reset "a lock request is queued without waiting on a stalled layout reset" Ui Commons

# Commons reads Hyprland options through the same hyprctl, so look only at resets.
resets=""
for _ in {1..20}; do
  resets=$(rg '^switchxkblayout ' "$call_log" 2>/dev/null || true)
  [[ -n $resets ]] && break
  sleep 0.1
done
[[ $resets == "switchxkblayout all 0" ]] ||
  fail "a lock request resets every keyboard to the first layout once" "resets: ${resets:-none}"
pass "a lock request resets every keyboard to the first layout once"
