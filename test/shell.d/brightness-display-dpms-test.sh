#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'MOCK'
#!/bin/bash
printf 'eDP-1\n'
MOCK
cat >"$mock_bin/hyprctl" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "monitors" ]]; then
  printf '%s\n' "$MONITORS_JSON"
else
  exit "${DISPATCH_STATUS:-0}"
fi
MOCK
chmod +x "$mock_bin"/*

run_brightness() {
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-brightness-display" "$@"
}

export MONITORS_JSON='[{"disabled":false,"dpmsStatus":false}]'
for action in off on; do
  : >"$call_log"
  run_brightness "$action"
  grep -q '^dispatch ' "$call_log" || fail "successful DPMS request is dispatched" "action: $action"

  status=0
  DISPATCH_STATUS=7 run_brightness "$action" || status=$?
  (( status == 7 )) || fail "DPMS dispatch failure propagates" "action: $action; status: $status"
done
pass "DPMS on and off preserve successful and failed dispatch status"

: >"$call_log"
MONITORS_JSON='[{"disabled":false,"dpmsStatus":true},{"disabled":true,"dpmsStatus":false}]' run_brightness on
[[ $(cat "$call_log") == "monitors -j" ]] || fail "already-lit displays avoid redundant DPMS dispatch" "$(cat "$call_log")"
pass "already-lit displays avoid redundant DPMS dispatch"
