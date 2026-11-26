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
  "--user is-enabled -q xdg-user-dirs.service") exit 0 ;;
  *) ;;
esac
STUB
chmod +x "$stub_bin/systemctl"

systemd_env_file="$config/environment.d/90-gcr-ssh-agent.conf"
session_env_file="$config/uwsm/env.d/90-omarchy-ssh-agent"
touch "$systemd_env_file"

prepare_session() {
  local initial_socket=$1 output=$2 marker=omarchy-uwsm-test-env
  local aux_file="$test_dir/uwsm-aux"

  cat >"$aux_file" <<EOF
__SELF_NAME__=uwsm
__WM_BIN_ID__=hyprland
__WM_DESKTOP_NAMES__=Hyprland
__WM_FIRST_DESKTOP_NAME__=Hyprland
__OIFS__=" \t\n"
__LOAD_PROFILE__=false
__RANDOM_MARK__=$marker
EOF
  env HOME=$home XDG_CONFIG_HOME=$config XDG_CONFIG_DIRS="$test_dir/no-system-config" \
    XDG_DATA_DIRS="$test_dir/no-system-data" XDG_RUNTIME_DIR=$runtime \
    SSH_AUTH_SOCK=$initial_socket PATH="$stub_bin:/usr/bin:/bin" \
    /bin/sh /usr/lib/uwsm/prepare-env.sh "$aux_file" >"$output"
  python3 - "$output" "$marker" <<'PY'
import pathlib
import sys

data = pathlib.Path(sys.argv[1]).read_bytes().split(sys.argv[2].encode(), 1)[1]
for item in data.rstrip(b"\0").split(b"\0"):
    if item.startswith(b"SSH_AUTH_SOCK="):
        print(item.split(b"=", 1)[1].decode())
        raise SystemExit
print("unset")
PY
}

HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-setup-security-ssh-agent" >"$test_dir/setup.log"
[[ -f $session_env_file ]] || fail "setup writes the UWSM session environment"
! grep -q '^unset SSH_AUTH_SOCK$' "$session_env_file" || fail "setup exports the agent socket"
[[ $(prepare_session "$runtime/old-agent" "$test_dir/setup-environment") == "$runtime/gcr/ssh" ]] ||
  fail "UWSM session preparation exports the active gcr socket over an old value"
[[ ! -e $systemd_env_file ]] || fail "setup retires the manager-start-only environment file"
pass "setup exports the socket from the UWSM session environment"

HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-remove-service-ssh-agent" >"$test_dir/remove.log"
[[ -f $session_env_file ]] || fail "removal keeps a UWSM environment override"
grep -Fq 'unset SSH_AUTH_SOCK' "$session_env_file" || fail "removal explicitly clears the saved socket"
[[ $(prepare_session "$runtime/gcr/ssh" "$test_dir/removed-environment") == "unset" ]] ||
  fail "UWSM session preparation removes the stale socket restored from the prior login"
[[ $(prepare_session "$runtime/other-agent/ssh" "$test_dir/other-agent-environment") == "$runtime/other-agent/ssh" ]] ||
  fail "UWSM session preparation preserves another agent's socket"
[[ ! -e $systemd_env_file ]] || fail "removal leaves no environment.d socket setting"
pass "removal clears only the stale gcr socket during UWSM session preparation"
