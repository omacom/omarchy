#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin"

# Every external effect is stubbed and logged: the real exit node, browser,
# windows, NetworkManager and notifications are never touched.
stub() {
  printf '#!/bin/bash\n%s\n' "$2" > "$stage/bin/$1"
  chmod +x "$stage/bin/$1"
}
stub tailscale 'printf "%s\n" "$TEST_TAILSCALE_STATUS"'
stub curl 'printf "curl %s\n" "${@: -1}" >> "$TEST_LOG"; exit "${TEST_CURL_STATUS:-0}"'
# Records the launch apart from the main log, since the command starts it in
# the background. With TEST_WEBAPP_BLOCKS it then stays in the foreground, as
# the real launcher does when no browser is running to take the handoff.
stub omarchy-launch-webapp 'printf "webapp %s\n" "$*" >> "$TEST_WEBAPP_LOG"
if [[ -n ${TEST_WEBAPP_BLOCKS:-} ]]; then exec -a captive-portal-test-browser /usr/bin/sleep 30; fi
# The real fallback with no browser running: exec setsid of the browser.
if [[ -n ${TEST_WEBAPP_FALLBACK_STATUS:-} ]]; then exec setsid /bin/sh -c "exit $TEST_WEBAPP_FALLBACK_STATUS"; fi
exit "${TEST_WEBAPP_STATUS:-0}"'
stub omarchy-notification-send 'printf "notify %s\n" "$*" >> "$TEST_LOG"'
stub sleep ':'
# Lists the portal window from the TEST_WINDOW_AFTER-th look (the first by
# default), as a window that maps late would, until a close is dispatched.
stub hyprctl 'if [[ $1 == "clients" ]]; then
  looks=$(( $(cat "$TEST_LOOKS" 2>/dev/null || echo 0) + 1 )); echo "$looks" > "$TEST_LOOKS"
  if [[ -e $TEST_CLOSED ]] || (( looks < ${TEST_WINDOW_AFTER:-1} )); then echo "[]"; else echo "[{\"class\":\"chrome-ping.omacom.io__nm-check.txt-Default\"}]"; fi
else
  printf "hyprctl %s\n" "$*" >> "$TEST_LOG"
  touch "$TEST_CLOSED"
fi'
# Reports a portal for the first TEST_NMCLI_PORTAL_CHECKS checks (two by
# default), then full connectivity. Like the real nmcli it answers in the
# session's language, so only the C locale reads "full".
stub nmcli 'count=$(( $(cat "$TEST_NMCLI_COUNT" 2>/dev/null || echo 0) + 1 )); echo "$count" > "$TEST_NMCLI_COUNT"
if [[ ${LC_ALL:-} != "C" ]]; then echo vollständig; elif (( count > ${TEST_NMCLI_PORTAL_CHECKS:-2} )); then echo full; else echo portal; fi'

# Runs in a session locale other than C, where the nmcli stub answers in
# translation, so every run below only finishes if the command reads C.
run_portal() {
  rm -f "$stage/log" "$stage/webapp" "$stage/count" "$stage/closed" "$stage/looks"
  TEST_LOG="$stage/log" TEST_WEBAPP_LOG="$stage/webapp" TEST_NMCLI_COUNT="$stage/count" TEST_CLOSED="$stage/closed" TEST_LOOKS="$stage/looks" XDG_RUNTIME_DIR="$stage" \
    TEST_TAILSCALE_STATUS="$1" TEST_CURL_STATUS="${2:-0}" LC_ALL=C.UTF-8 \
    OMARCHY_PATH="$ROOT" PATH="$stage/bin:$ROOT/bin:$PATH" timeout 20 "$ROOT/bin/omarchy-network-captive-portal" "http://ping.omacom.io/nm-check.txt"
}

toggle="http://local-tailscaled.sock/localapi/v0/set-use-exit-node-enabled"
webapp="webapp http://ping.omacom.io/nm-check.txt"

# The launch runs in the background, so give it a moment to be recorded.
portal_opened() {
  for (( i = 0; i < 50; i++ )); do
    [[ -s $stage/webapp ]] && break
    /usr/bin/sleep 0.1
  done
  [[ $(cat "$stage/webapp" 2>/dev/null) == "$webapp" ]]
}
close='hyprctl dispatch hl.dsp.window.close({ window = "class:^chrome-ping[.]omacom[.]io__.*$" })'

run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}'
expected="curl $toggle?enabled=false
notify -g  Tailscale exit node paused It comes back once you're signed in
$close
curl $toggle?enabled=true
notify -g  Tailscale exit node restored"
portal_opened && [[ $(<"$stage/log") == "$expected" ]] || fail "pauses the exit node, opens the portal window, then closes it and restores the node once online" "$(<"$stage/log")"
pass "pauses the exit node, opens the portal window, then closes it and restores the node once online"
[[ $(<"$stage/count") == 3 ]] || fail "re-checks until connectivity is full, then stops" "$(<"$stage/count")"
pass "re-checks until connectivity is full, then stops"

run_portal '{"ExitNodeStatus":null}'
portal_opened && [[ $(<"$stage/log") == "$close" ]] || fail "leaves Tailscale alone without an exit node" "$(<"$stage/log")"
pass "leaves Tailscale alone without an exit node"

run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}' 1
portal_opened && [[ $(<"$stage/log") == "curl $toggle?enabled=false
$close" ]] || fail "does not restore an exit node it failed to pause" "$(<"$stage/log")"
pass "does not restore an exit node it failed to pause"

# Well past the old ten-minute cap: the exit node stays paused until online.
TEST_NMCLI_PORTAL_CHECKS=400 run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}'
[[ $(<"$stage/count") == 401 ]] || fail "keeps checking through a slow sign-in" "$(<"$stage/count")"
[[ $(tail -1 "$stage/log") == "notify -g  Tailscale exit node restored" ]] || fail "restores the exit node only once a slow sign-in completes" "$(<"$stage/log")"
pass "keeps the exit node paused until a slow sign-in completes"

# A second click while the first is still watching only reopens the portal.
exec 8>"$stage/omarchy-network-captive-portal.lock"
flock -n 8
run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}'
exec 8>&-
portal_opened && [[ ! -e $stage/log ]] || fail "a second click only reopens the portal" "$(<"$stage/log")"
pass "a second click only reopens the portal"

# Online before the browser maps its window: the window still closes.
TEST_WINDOW_AFTER=4 TEST_NMCLI_PORTAL_CHECKS=0 run_portal '{"ExitNodeStatus":null}'
portal_opened && [[ $(<"$stage/log") == "$close" ]] || fail "closes a portal window that maps after the sign-in completed" "$(<"$stage/log")"
pass "closes a portal window that maps after the sign-in completed"

# No browser running to take the handoff: the launcher stays in the foreground
# until the browser exits, and the wait for the sign-in must not wait on it.
TEST_WEBAPP_BLOCKS=1 run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}' || fail "does not wait on a launcher that stays in the foreground"
pkill -f '^captive-portal-test-browser' || true
portal_opened && [[ $(tail -1 "$stage/log") == "notify -g  Tailscale exit node restored" ]] || fail "re-checks and restores the exit node while the browser is still open" "$(<"$stage/log")"
pass "does not wait on a launcher that stays in the foreground"

# A browser that fails to start leaves nothing to sign in with: stop and
# restore the exit node rather than wait behind the portal with it paused.
# Status 1 is the command giving up itself; timeout's 124 would mean it hung.
status=0
TEST_WEBAPP_STATUS=1 TEST_NMCLI_PORTAL_CHECKS=100000 run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}' || status=$?
(( status == 1 )) || fail "gives up when the portal window fails to open" "exit status $status"
[[ $(tail -1 "$stage/log") == "notify -g  Tailscale exit node restored" ]] || fail "restores the exit node when the portal window fails to open" "$(<"$stage/log")"
pass "gives up and restores the exit node when the portal window fails to open"

# The same when the launcher has to start the browser itself and that fails.
status=0
TEST_WEBAPP_FALLBACK_STATUS=1 TEST_NMCLI_PORTAL_CHECKS=100000 run_portal '{"ExitNodeStatus":{"ID":"node","Online":true}}' || status=$?
(( status == 1 )) || fail "gives up when a freshly started browser fails" "exit status $status"
[[ $(tail -1 "$stage/log") == "notify -g  Tailscale exit node restored" ]] || fail "restores the exit node when a freshly started browser fails" "$(<"$stage/log")"
pass "gives up and restores the exit node when a freshly started browser fails"
