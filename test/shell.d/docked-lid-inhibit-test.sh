#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin" "$tmpdir/drm/card0-eDP-1" "$tmpdir/drm/card0-DP-1"
export OMARCHY_DRM_PATH="$tmpdir/drm" CALL_LOG="$tmpdir/calls" TEST_STATE="$tmpdir"
export PATH="$tmpdir/bin:$ROOT/bin:$PATH"
monitor="$ROOT/bin/omarchy-system-docked-lid-inhibit"

cat >"$tmpdir/bin/busctl" <<'SH'
#!/bin/bash
[[ $SCENARIO != "query-failure" ]] || exit 17
printf 's "%s"\n' "$(<"$TEST_STATE/policy")"
SH
cat >"$tmpdir/bin/systemd-inhibit" <<'SH'
#!/bin/bash
[[ $SCENARIO != "acquire-failure" ]] || exit 27
[[ $SCENARIO != "delayed-acquire" ]] || sleep 1
printf 'acquired %s\n' "$*" >>"$CALL_LOG"
while [[ $1 == --* ]]; do shift; done
[[ $SCENARIO != "disconnect-during-acquire" ]] || echo disconnected >"$OMARCHY_DRM_PATH/card0-DP-1/status"
# Newer systemd forks remove this from the inherited environment.
unset NOTIFY_SOCKET
"$@"
echo released >>"$CALL_LOG"
SH
cat >"$tmpdir/bin/systemd-notify" <<'SH'
#!/bin/bash
[[ $1 == "--ready" ]] || exit 1
echo ready >>"$CALL_LOG"
SH
cat >"$tmpdir/bin/sleep" <<'SH'
#!/bin/bash
count=$(<"$TEST_STATE/count")
echo "$((count + 1))" >"$TEST_STATE/count"
echo tick >>"$CALL_LOG"
case "$SCENARIO:$count" in
  connect:0) echo connected >"$OMARCHY_DRM_PATH/card0-DP-1/status" ;;
  connect:1 | docked:0 | delayed-acquire:1) echo disconnected >"$OMARCHY_DRM_PATH/card0-DP-1/status" ;;
  delayed-acquire:0) : ;;
  policy:0) echo suspend >"$TEST_STATE/policy" ;;
  disabled:0) exit 23 ;;
  *) exit 24 ;;
esac
SH
chmod +x "$tmpdir/bin/"*

reset_scenario() {
  export SCENARIO="$1" NOTIFY_SOCKET="$tmpdir/notify"
  : >"$CALL_LOG"
  echo 0 >"$TEST_STATE/count"
  echo ignore >"$TEST_STATE/policy"
  echo connected >"$OMARCHY_DRM_PATH/card0-eDP-1/status"
  echo connected >"$OMARCHY_DRM_PATH/card0-DP-1/status"
  echo disabled >"$OMARCHY_DRM_PATH/card0-DP-1/enabled"
}

run_monitor() {
  local status=0
  "$monitor" || status=$?
  [[ $status == "$1" ]] || fail "monitor exits with the expected fixture status" "$status instead of $1"
  mapfile -t calls <"$CALL_LOG"
}

reset_scenario docked
run_monitor 24
[[ ${calls[0]} == 'acquired --what=handle-lid-switch --mode=block --who=Omarchy --why=External monitor connected '* ]] ||
  fail "connected but disabled external display inhibits only lid handling"
[[ ${calls[1]} == "ready" && ${calls[2]} == "tick" && ${calls[3]} == "released" && ${calls[4]} == "tick" ]] ||
  fail "docked readiness follows acquisition and unplug releases without a service restart"
pass "docked readiness survives a cleared notify environment; unplug releases and monitoring continues"

reset_scenario connect
echo disconnected >"$OMARCHY_DRM_PATH/card0-DP-1/status"
run_monitor 24
[[ ${calls[0]} == "ready" && ${calls[1]} == "tick" && ${calls[2]} == acquired* && ${calls[4]} == "released" ]] ||
  fail "undocked startup must be ready without an inhibitor and hotplug must acquire one"
[[ $(grep -c '^ready$' "$CALL_LOG") == "1" ]] || fail "hotplug must not repeat startup notification"
pass "undocked startup is ready promptly and external hotplug acquires protection"

reset_scenario delayed-acquire
run_monitor 24
[[ ${calls[0]} == "tick" && ${calls[1]} == acquired* && ${calls[2]} == "ready" ]] ||
  fail "delayed inhibitor acquisition must not send readiness early"
pass "delayed inhibitor acquisition cannot report readiness before the lock exists"

reset_scenario disconnect-during-acquire
run_monitor 24
[[ ${calls[0]} == acquired* && ${calls[1]} == "ready" && ${calls[2]} == "released" && ${#calls[@]} == 4 ]] ||
  fail "disconnect during acquisition must release protection and still complete startup"
pass "disconnect race releases the lock without leaving startup blocked"

reset_scenario policy
run_monitor 24
[[ ${calls[3]} == "released" ]] || fail "policy change releases the inhibitor"
pass "administrator docked lid policy takes precedence"

reset_scenario disabled
echo suspend >"$TEST_STATE/policy"
run_monitor 23
[[ $(<"$CALL_LOG") == $'ready\ntick' ]] || fail "non-ignore policy must report readiness without acquiring a lock"
pass "explicit docked suspend policy starts promptly without acquiring a lock"

for scenario in query-failure acquire-failure; do
  reset_scenario "$scenario"
  if [[ $scenario == "query-failure" ]]; then
    run_monitor 17
  else
    run_monitor 27
  fi
  [[ ! -s $CALL_LOG ]] || fail "failed logind access must not report readiness"
done
pass "logind query and acquisition failures cannot claim readiness"
