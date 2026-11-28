#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
stdout_log="$test_tmp/stdout"
stderr_log="$test_tmp/stderr"
key_log="$test_tmp/key"
test_home="$test_tmp/home"
desktop_file="$test_home/.local/share/applications/Tailscale.desktop"
mkdir -p "$stub_bin"

cat >"$stub_bin/id" <<'SH'
#!/bin/bash
[[ $1 == "-un" ]] || exit 1
printf '%s\n' "omarchy-test-user"
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
[[ ${OMARCHY_TEST_FAIL_PACKAGE:-0} == 0 ]]
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
[[ -z ${OMARCHY_TAILSCALE_AUTH_KEY+x} ]] || exit 2
if [[ $1 == tailscale && $2 == up ]]; then
  for arg in "$@"; do
    if [[ $arg == "--auth-key=file:/dev/stdin" ]]; then
      cat >"$OMARCHY_TEST_KEY_LOG"
    fi
  done
  if [[ ${OMARCHY_TEST_FAIL_UP:-0} != 0 ]]; then
    echo "tailscale up failed" >&2
    exit 1
  fi
elif [[ $1 == systemctl && ${OMARCHY_TEST_FAIL_DAEMON:-0} != 0 ]]; then
  exit 1
fi
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
mkdir -p "$HOME/.local/share/applications"
printf '[Desktop Entry]\nExec=omarchy-launch-webapp "%s"\n' "$2" >"$HOME/.local/share/applications/$1.desktop"
SH
cat >"$stub_bin/omarchy-webapp-remove" <<'SH'
#!/bin/bash
printf 'webapp-remove %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
exec "$ROOT/bin/omarchy-webapp-remove" "$@"
SH
cat >"$stub_bin/update-desktop-database" <<'SH'
#!/bin/bash
printf 'desktop-database %s\n' "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
chmod +x "$stub_bin"/*

run_install() {
  : >"$call_log"
  : >"$stdout_log"
  : >"$stderr_log"
  : >"$key_log"
  local status=0
  env HOME="$test_home" PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_CALL_LOG="$call_log" \
    OMARCHY_TEST_KEY_LOG="$key_log" \
    USER=root \
    OMARCHY_TAILSCALE_LOGIN_SERVER="${1-}" \
    OMARCHY_TAILSCALE_AUTH_KEY="${2-}" \
    OMARCHY_TAILSCALE_ADMIN_URL="${3-}" \
    "$ROOT/bin/omarchy-install-service-tailscale" >"$stdout_log" 2>"$stderr_log" || status=$?
  printf '%s\n' "$status"
}

status=$(run_install)
[[ $status == 0 ]] || fail "hosted install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --operator=omarchy-test-user' "$call_log" >/dev/null || fail "hosted install names the invoking user as operator" "$(cat "$call_log")"
grep -F -- '--login-server' "$call_log" >/dev/null && fail "hosted install must not pass a login server" "$(cat "$call_log")"
grep -F 'webapp Tailscale https://login.tailscale.com/admin/machines ' "$call_log" >/dev/null || fail "hosted install keeps the admin console web app" "$(cat "$call_log")"
grep -Fx 'plugin omarchy.tailscale' "$call_log" >/dev/null || fail "hosted install still enables the bar plugin" "$(cat "$call_log")"
grep -Fx 'systemctl --user enable --now omarchy-tailscale-receive.service' "$call_log" >/dev/null || fail "hosted install still enables Taildrop receive" "$(cat "$call_log")"
[[ ! -s $key_log ]] || fail "a join without an auth key does not read one"
pass "hosted Tailscale install keeps hosted services and names the operator"

status=$(run_install "https://headscale.example.com")
[[ $status == 0 ]] || fail "self-hosted install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --operator=omarchy-test-user --login-server=https://headscale.example.com' "$call_log" >/dev/null || fail "self-hosted install passes the coordination server and operator" "$(cat "$call_log")"
grep -F 'webapp ' "$call_log" >/dev/null && fail "self-hosted install must not point a web app at the hosted admin console" "$(cat "$call_log")"
grep -F 'Skipping the hosted Tailscale admin web app' "$stdout_log" >/dev/null || fail "self-hosted install explains the skipped web app" "$(cat "$stdout_log")"
grep -F 'https://headscale.example.com' "$call_log" >/dev/null || fail "coordination server was not recorded" "$(cat "$call_log")"
pass "self-hosted install joins the given server and skips the hosted admin web app"

status=$(run_install "https://headscale.example.com" "tskey-auth-secret" "https://headscale.example.com/admin")
[[ $status == 0 ]] || fail "auth-key install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --operator=omarchy-test-user --login-server=https://headscale.example.com --auth-key=file:/dev/stdin' "$call_log" >/dev/null || fail "auth key is supplied through stdin" "$(cat "$call_log")"
[[ $(<"$key_log") == "tskey-auth-secret" ]] || fail "stdin carries the exact auth key"
! grep -F 'tskey-auth-secret' "$call_log" >/dev/null || fail "auth key appeared in command arguments"
grep -F 'webapp Tailscale https://headscale.example.com/admin ' "$call_log" >/dev/null || fail "custom admin URL is installed when set" "$(cat "$call_log")"
! grep -F 'tskey-auth-secret' "$stdout_log" >/dev/null || fail "auth key was printed" "$(cat "$stdout_log")"
! grep -F 'tskey-auth-secret' "$stderr_log" >/dev/null || fail "auth key was printed to stderr" "$(cat "$stderr_log")"
pass "pre-auth key and custom admin URL are honored without printing the key"

status=$(run_install "" "tskey-auth-hosted")
[[ $status == 0 ]] || fail "hosted auth-key install succeeds" "$(cat "$stderr_log")"
grep -Fx 'sudo tailscale up --accept-routes --operator=omarchy-test-user --auth-key=file:/dev/stdin' "$call_log" >/dev/null || fail "hosted install can take a key through stdin" "$(cat "$call_log")"
[[ $(<"$key_log") == "tskey-auth-hosted" ]] || fail "hosted join receives its auth key"
! grep -F 'tskey-auth-hosted' "$call_log" "$stdout_log" "$stderr_log" >/dev/null || fail "hosted auth key was exposed"
grep -F 'https://login.tailscale.com/admin/machines' "$call_log" >/dev/null || fail "hosted auth-key install keeps the admin web app" "$(cat "$call_log")"
pass "a hosted pre-auth key does not drop the admin web app"

status=$(run_install "headscale.example.com")
[[ $status != 0 ]] || fail "a login server without a scheme is rejected"
[[ ! -s $call_log ]] || fail "invalid login server is rejected before any side effect" "$(cat "$call_log")"
grep -F 'http(s) URL' "$stderr_log" >/dev/null || fail "invalid login server explains what was wrong" "$(cat "$stderr_log")"
pass "a login server that is not an http(s) URL is rejected before install"

status=$(run_install "https://headscale.example.com" "tskey auth secret")
[[ $status != 0 ]] || fail "an auth key with whitespace is rejected"
[[ ! -s $call_log ]] || fail "invalid auth key is rejected before any side effect" "$(cat "$call_log")"
pass "an auth key containing whitespace is rejected"

status=$(run_install "" "" "admin.example.com")
[[ $status != 0 ]] || fail "an admin URL without a scheme is rejected"
[[ ! -s $call_log ]] || fail "invalid admin URL is rejected before any side effect"
pass "an invalid admin URL is rejected before install"

for url in 'https://:8080' 'https://user@:8080' 'https://' 'https://[not-ipv6]' 'https://headscale.example.com:invalid' 'https://headscale.example.com:65536'; do
  status=$(run_install "$url")
  [[ $status != 0 && ! -s $call_log ]] || fail "a malformed server URL is rejected before any side effect" "$url"
  status=$(run_install "" "" "$url")
  [[ $status != 0 && ! -s $call_log ]] || fail "a malformed admin URL is rejected before any side effect" "$url"
done
pass "missing hosts, invalid IPv6, and invalid ports are rejected before install"

for url in 'http://localhost:8080' 'https://127.0.0.1:8443/path' 'https://[::1]:8443/path' 'https://headscale.example.com/path?key=value'; do
  status=$(run_install "$url")
  [[ $status == 0 ]] || fail "a valid hostname or IP URL is accepted" "$url"
done
pass "hostnames, IPv4, bracketed IPv6, ports, and paths remain supported"

status=$(run_install "" "" "https://admin.example.com")
[[ $status == 0 ]] || fail "hosted join with a custom admin URL succeeds"
grep -Fx 'sudo tailscale up --accept-routes --operator=omarchy-test-user' "$call_log" >/dev/null || fail "admin URL alone keeps the hosted join"
grep -F 'webapp Tailscale https://admin.example.com ' "$call_log" >/dev/null || fail "admin URL is used without a login server"
pass "admin URL alone overrides the hosted admin web app"

status=$(run_install "https://headscale.example.com" "--reset")
[[ $status == 0 && $(<"$key_log") == "--reset" ]] || fail "a flag-shaped auth key stays literal stdin data"
! grep -F -- '--reset' "$call_log" >/dev/null || fail "auth key became a command flag"
pass "a flag-shaped auth key cannot change Tailscale arguments"

for key in "" "tskey-auth-secret"; do
  status=$(OMARCHY_TEST_FAIL_UP=1 run_install "https://headscale.example.com" "$key")
  [[ $status != 0 ]] || fail "failed tailscale up fails the install"
  ! grep -E '^(plugin |webapp |systemctl --user |sudo tailscale set)' "$call_log" >/dev/null || fail "failed join must not continue setup" "$(cat "$call_log")"
  ! grep -F 'tskey-auth-secret' "$call_log" "$stdout_log" "$stderr_log" >/dev/null || fail "failed join exposed the key"
done
pass "a failed join stops setup with and without an auth key"

status=$(OMARCHY_TEST_FAIL_PACKAGE=1 run_install)
[[ $status != 0 && $(wc -l <"$call_log") == 1 ]] || fail "failed package installation stops setup"
status=$(OMARCHY_TEST_FAIL_DAEMON=1 run_install)
[[ $status != 0 && $(wc -l <"$call_log") == 2 ]] || fail "failed daemon startup stops setup"
pass "package and daemon failures stop setup before joining"

status=$(run_install)
[[ $status == 0 && -f $desktop_file ]] || fail "hosted installation creates its admin launcher"
status=$(run_install "https://headscale.example.com")
[[ $status == 0 && ! -e $desktop_file ]] || fail "self-hosted join removes the previous hosted admin launcher"
grep -F "desktop-database $test_home/.local/share/applications" "$call_log" >/dev/null || fail "removing the hosted launcher refreshes the desktop database"
pass "switching to a self-hosted server removes the old hosted admin launcher"

status=$(run_install)
custom_desktop_file="$test_home/.local/share/applications/Archived/Tailscale.desktop"
mkdir -p "$(dirname "$custom_desktop_file")"
printf '[Desktop Entry]\nExec=omarchy-launch-webapp "https://custom.example.com/admin"\n' >"$custom_desktop_file"
custom_icon="$test_home/.local/share/icons/hicolor/256x256/apps/tailscale.png"
mkdir -p "$(dirname "$custom_icon")"
printf 'shared icon\n' >"$custom_icon"
status=$(run_install "https://headscale.example.com")
[[ $status == 0 && ! -e $desktop_file ]] || fail "self-hosted join removes the exact hosted launcher when names overlap"
[[ -f $custom_desktop_file && -f $custom_icon ]] || fail "cleanup preserves a same-named nested launcher and its shared icon"
pass "hosted launcher cleanup preserves a same-named nested web app and shared icon"

status=$(run_install)
status=$(OMARCHY_TEST_FAIL_UP=1 run_install "https://headscale.example.com")
[[ $status != 0 && -f $desktop_file ]] || fail "failed self-hosted join preserves the previous launcher"
! grep -F 'webapp-remove' "$call_log" >/dev/null || fail "failed join must not remove the launcher"
pass "a failed server switch leaves the current admin launcher intact"

for exec in 'omarchy-launch-webapp "https://custom.example.com/admin"' '/usr/bin/custom-tailscale'; do
  printf '[Desktop Entry]\nExec=%s\n' "$exec" >"$desktop_file"
  status=$(run_install "https://headscale.example.com")
  [[ $status == 0 && -f $desktop_file ]] || fail "custom Tailscale launchers are preserved"
  ! grep -F 'webapp-remove' "$call_log" >/dev/null || fail "custom launcher must not be removed"
done
pass "custom launchers with the same name are preserved"
