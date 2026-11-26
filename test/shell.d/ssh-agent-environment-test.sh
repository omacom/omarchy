#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
home="$test_dir/home"
config="$home/config"
runtime="$test_dir/runtime"
mkdir -p "$stub_bin" "$config/environment.d" "$config/uwsm/env.d"

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
case $* in
  "--user show-environment") printf 'SSH_AUTH_SOCK=%s/gcr/ssh\n' "$XDG_RUNTIME_DIR" ;;
  *) ;;
esac
STUB
chmod +x "$stub_bin/systemctl"

systemd_env_file="$config/environment.d/90-gcr-ssh-agent.conf"
session_env_file="$config/uwsm/env.d/90-omarchy-ssh-agent"
touch "$systemd_env_file"

HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-setup-security-ssh-agent" >"$test_dir/setup.log"
[[ -f $session_env_file ]] || fail "setup writes the UWSM session environment"
! grep -q '^unset SSH_AUTH_SOCK$' "$session_env_file" || fail "setup exports the agent socket"
env -i XDG_RUNTIME_DIR=$runtime SSH_AUTH_SOCK=stale /bin/sh -c '. "$1"; [ "$SSH_AUTH_SOCK" = "$XDG_RUNTIME_DIR/gcr/ssh" ]' sh "$session_env_file" ||
  fail "setup exports the active socket over a stale manager value"
[[ ! -e $systemd_env_file ]] || fail "setup retires the manager-start-only environment file"
pass "setup exports the socket from the UWSM session environment"

HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-remove-service-ssh-agent" >"$test_dir/remove.log"
[[ -f $session_env_file ]] || fail "removal keeps a UWSM environment override"
grep -Fqx 'unset SSH_AUTH_SOCK' "$session_env_file" || fail "removal explicitly clears the saved socket"
env -i XDG_RUNTIME_DIR=$runtime SSH_AUTH_SOCK="$runtime/gcr/ssh" /bin/sh -c '. "$1"; [ -z "${SSH_AUTH_SOCK+x}" ]' sh "$session_env_file" ||
  fail "UWSM session preparation removes a socket restored from the prior login"
[[ ! -e $systemd_env_file ]] || fail "removal leaves no environment.d socket setting"
pass "removal clears a stale socket when UWSM prepares the next session"
