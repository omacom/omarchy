#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
stdout_log="$test_tmp/stdout"
stderr_log="$test_tmp/stderr"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/tailscale" <<'SH'
#!/bin/bash
printf 'tailscale %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/omarchy-plugin-enable" <<'SH'
#!/bin/bash
printf 'plugin %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/omarchy-webapp-install" <<'SH'
#!/bin/bash
printf 'webapp %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
chmod +x "$stub_bin"/*

run_install() {
  : >"$call_log"
  : >"$stdout_log"
  : >"$stderr_log"
  local status=0
  PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_CALL_LOG="$call_log" \
    OMARCHY_TAILSCALE_LOGIN_SERVER="${1-}" \
    OMARCHY_TAILSCALE_AUTH_KEY="${2-}" \
    OMARCHY_TAILSCALE_ADMIN_URL="${3-}" \
    "$ROOT/bin/omarchy-install-service-tailscale" >"$stdout_log" 2>"$stderr_log" || status=$?
  printf '%s\n' "$status"
}

status=$(run_install)
[[ $status == 0 ]] || fail "hosted install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes' "$call_log" >/dev/null || fail "hosted install keeps tailscale up --accept-routes" "$(cat "$call_log")"
grep -F -- '--login-server' "$call_log" >/dev/null && fail "hosted install must not pass a login server" "$(cat "$call_log")"
grep -F 'webapp Tailscale https://login.tailscale.com/admin/machines ' "$call_log" >/dev/null || fail "hosted install keeps the admin console web app" "$(cat "$call_log")"
grep -Fx 'plugin omarchy.tailscale' "$call_log" >/dev/null || fail "hosted install still enables the bar plugin" "$(cat "$call_log")"
grep -Fx 'systemctl --user enable --now omarchy-tailscale-receive.service' "$call_log" >/dev/null || fail "hosted install still enables Taildrop receive" "$(cat "$call_log")"
pass "hosted Tailscale install is unchanged"

status=$(run_install "https://headscale.example.com")
[[ $status == 0 ]] || fail "self-hosted install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --login-server=https://headscale.example.com' "$call_log" >/dev/null || fail "self-hosted install passes the coordination server" "$(cat "$call_log")"
grep -F 'webapp ' "$call_log" >/dev/null && fail "self-hosted install must not point a web app at the hosted admin console" "$(cat "$call_log")"
grep -F 'Skipping the hosted Tailscale admin web app' "$stdout_log" >/dev/null || fail "self-hosted install explains the skipped web app" "$(cat "$stdout_log")"
grep -F 'https://headscale.example.com' "$call_log" >/dev/null || fail "coordination server was not recorded" "$(cat "$call_log")"
! grep -F 'secret-auth-key' "$stdout_log" >/dev/null
pass "self-hosted install joins the given server and skips the hosted admin web app"

status=$(run_install "https://headscale.example.com" "tskey-auth-secret" "https://headscale.example.com/admin")
[[ $status == 0 ]] || fail "auth-key install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --login-server=https://headscale.example.com --auth-key=tskey-auth-secret' "$call_log" >/dev/null || fail "auth key is passed as one argument" "$(cat "$call_log")"
grep -F 'webapp Tailscale https://headscale.example.com/admin ' "$call_log" >/dev/null || fail "custom admin URL is installed when set" "$(cat "$call_log")"
! grep -F 'tskey-auth-secret' "$stdout_log" >/dev/null || fail "auth key was printed" "$(cat "$stdout_log")"
! grep -F 'tskey-auth-secret' "$stderr_log" >/dev/null || fail "auth key was printed to stderr" "$(cat "$stderr_log")"
pass "pre-auth key and custom admin URL are honored without printing the key"

status=$(run_install "" "tskey-auth-hosted")
[[ $status == 0 ]] || fail "hosted auth-key install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --auth-key=tskey-auth-hosted' "$call_log" >/dev/null || fail "hosted install can take an auth key without a login server" "$(cat "$call_log")"
grep -F 'https://login.tailscale.com/admin/machines' "$call_log" >/dev/null || fail "hosted auth-key install keeps the admin web app" "$(cat "$call_log")"
pass "a hosted pre-auth key does not drop the admin web app"

status=$(run_install "headscale.example.com")
[[ $status != 0 ]] || fail "a login server without a scheme is rejected"
grep -F 'sudo tailscale' "$call_log" >/dev/null && fail "invalid login server must not start tailscale" "$(cat "$call_log")"
grep -F 'http(s) URL' "$stderr_log" >/dev/null || fail "invalid login server explains what was wrong" "$(cat "$stderr_log")"
pass "a login server that is not an http(s) URL is rejected before install"

status=$(run_install "https://headscale.example.com" "tskey auth secret")
[[ $status != 0 ]] || fail "an auth key with whitespace is rejected"
grep -F 'sudo tailscale up' "$call_log" >/dev/null && fail "invalid auth key must not be passed to tailscale" "$(cat "$call_log")"
pass "an auth key containing whitespace is rejected"
