#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "tailscale operator runtime test"
require_command quickshell

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

# stage <name> <pkexec exit> <initial state>: the widget's real Service.qml and
# Model.js against stand-ins for tailscale, pkexec and the browser. tailscale
# refuses up and down until pkexec has granted the operator, as it does for a
# user it doesn't know. Nothing reaches the host's tailscaled.
stage() {
  stage="$scratch/$1"
  mkdir -p "$stage/tailscale" "$stage/bin" "$stage/state"
  ln -s "$ROOT/shell/Commons" "$stage/Commons"
  cp "$SHELL_TEST_DIR/fixtures/tailscale-operator/shell.qml" "$stage/shell.qml"
  cp "$ROOT/shell/plugins/panels/tailscale/Service.qml" "$ROOT/shell/plugins/panels/tailscale/Model.js" "$stage/tailscale/"
  printf '%s\n' "$3" >"$stage/state/backend"

  cat >"$stage/bin/tailscale" <<'SH'
#!/bin/bash
state=$TAILSCALE_TEST_STATE
printf '%s\n' "$*" >>"$state/tailscale.log"
refuse() {
  printf "Access denied: prefs write access denied\n\nUse 'sudo tailscale %s' or 'tailscale set --operator=\$USER' to allow this user.\n" "$1" >&2
  exit 1
}
case $1 in
  status) printf '{"BackendState":"%s","AuthURL":"","TailscaleIPs":[],"Self":{"HostName":"test","DNSName":"test.tail.ts.net."},"Peer":{}}\n' "$(<"$state/backend")" ;;
  up)
    [[ -f $state/operator ]] || refuse up
    printf '\nTo authenticate, visit:\n\n\thttps://login.tailscale.com/a/test-sign-in\n\n' >&2 ;;
  down)
    [[ -f $state/operator ]] || refuse down
    printf 'Stopped\n' >"$state/backend" ;;
  switch) printf '[]\n' ;;
esac
exit 0
SH
  cat >"$stage/bin/pkexec" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"\$TAILSCALE_TEST_STATE/pkexec.log"
[[ $2 == 0 ]] && touch "\$TAILSCALE_TEST_STATE/operator"
exit $2
SH
  printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$TAILSCALE_TEST_STATE/browser.log"\n' >"$stage/bin/omarchy-launch-browser"
  chmod +x "$stage/bin/"*
}

# run <action>: run the staged service to completion, printing the status
# lines it showed.
run() {
  local output
  output=$(USER=tester HOME="$stage" PATH="$stage/bin:$PATH" TAILSCALE_TEST_STATE="$stage/state" TAILSCALE_TEST_ACTION="$1" \
    timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "tailscale $1 fixture exits cleanly" "$output"
  if rg -q 'RESULT timeout|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
    fail "tailscale $1 fixture runs without QML errors" "$output"
  fi
  rg -o 'STATUS .*' <<<"$output" || true
}

count() { [[ -f $1 ]] && grep -cx -- "$2" "$1" || printf '0\n'; }

stage sign-in 0 NeedsLogin
run up >/dev/null
[[ $(count "$stage/state/tailscale.log" up) == 2 ]] || fail "a refused sign-in runs again after the grant" "$(cat "$stage/state/tailscale.log")"
[[ $(count "$stage/state/pkexec.log" "tailscale set --operator=tester") == 1 ]] || fail "a refused sign-in asks once to grant the operator"
[[ $(<"$stage/state/browser.log") == "https://login.tailscale.com/a/test-sign-in" ]] || fail "the retried sign-in opens its page in the browser, not the refusal's"
pass "tailscale grants the operator when sign-in is refused, then signs in"

stage declined 126 NeedsLogin
result=$(run up)
[[ $(count "$stage/state/tailscale.log" up) == 1 ]] || fail "a declined grant does not run sign-in again"
[[ $(count "$stage/state/pkexec.log" "tailscale set --operator=tester") == 1 ]] || fail "a declined grant is asked for once"
[[ ! -f $stage/state/browser.log ]] || fail "a declined grant opens nothing in the browser"
grep -qx 'STATUS Tailscale authorization failed' <<<"$result" || fail "a declined grant says the authorization failed" "$result"
pass "tailscale stops after a declined operator grant and says so"

stage turn-off 0 Running
run down >/dev/null
[[ $(count "$stage/state/tailscale.log" down) == 2 ]] || fail "a refused turn-off runs again after the grant"
[[ $(count "$stage/state/pkexec.log" "tailscale set --operator=tester") == 1 ]] || fail "a refused turn-off asks once to grant the operator"
[[ $(<"$stage/state/backend") == Stopped ]] || fail "the retried turn-off stops tailscale"
pass "tailscale grants the operator when turning off is refused, then turns off"
