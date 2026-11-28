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
  "--user -q is-active gcr-ssh-agent.socket") [[ -e $XDG_CONFIG_HOME/gcr-agent-active ]] ;;
  "--user is-enabled -q xdg-user-dirs.service") exit 0 ;;
  *) ;;
esac
STUB
chmod +x "$stub_bin/systemctl"

systemd_env_file="$config/environment.d/90-gcr-ssh-agent.conf"
session_env_file="$config/uwsm/env.d/90-omarchy-ssh-agent"
touch "$systemd_env_file"

prepare_session() {
  env HOME=$home XDG_CONFIG_HOME=$config XDG_CONFIG_DIRS="$test_dir/no-system-config" \
    XDG_DATA_DIRS="$test_dir/no-system-data" XDG_RUNTIME_DIR=$runtime \
    SSH_AUTH_SOCK="$1" PATH="$stub_bin:/usr/bin:/bin" \
    python3 "$test_dir/uwsm-manager-test.py"
}

cat >"$test_dir/uwsm-manager-test.py" <<'PY'
import contextlib
import io
import os
import sys

sys.path.insert(0, "/usr/share/uwsm/modules")
from uwsm import main

manager = {
    key: os.environ[key]
    for key in ("HOME", "PATH", "XDG_CONFIG_HOME", "XDG_CONFIG_DIRS", "XDG_DATA_DIRS", "XDG_RUNTIME_DIR")
}
manager["SSH_AUTH_SOCK"] = os.environ["SSH_AUTH_SOCK"]


class FakeManager:
    def get_systemd_vars(self):
        return dict(manager)

    def get_unit_property(self, unit, prop):
        return "dbus-broker.service"

    def list_units_by_patterns(self, states, patterns):
        return ["wayland-session-bindpid@1.service"]

    def set_systemd_vars(self, values):
        manager.update(values)

    def unset_systemd_vars(self, names):
        for name in names:
            manager.pop(name, None)


fake_manager = FakeManager()
main.DbusInteractions = lambda bus: fake_manager
main.BaseDirectory.load_data_paths = lambda *args, **kwargs: []
main.load_env = lambda *args, **kwargs: {}
main.get_fg_vt = lambda: 1
main.get_session_by_vt = lambda *args, **kwargs: ("1", "seat0")
main.random_hex = lambda size: "ssh-agent-test"
main.CompGlobals.name = "uwsm"
main.CompGlobals.bin_name = "uwsm"
main.CompGlobals.id = "hyprland"
main.CompGlobals.id_unit_string = "hyprland"
main.CompGlobals.bin_id = "hyprland"
main.CompGlobals.desktop_names = ["Hyprland"]
main.CompGlobals.cli_desktop_names_exclusive = False
with contextlib.redirect_stdout(io.StringIO()):
    main.prepare_env()
print(manager.get("SSH_AUTH_SOCK", "unset"))
PY

HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-setup-security-ssh-agent" >"$test_dir/setup.log"
[[ -f $session_env_file ]] || fail "setup writes the UWSM session environment"
! grep -q '^unset SSH_AUTH_SOCK$' "$session_env_file" || fail "setup exports the agent socket"
[[ $(prepare_session "$runtime/old-agent") == "$runtime/gcr/ssh" ]] ||
  fail "UWSM session preparation exports the active gcr socket over an old value"
[[ ! -e $systemd_env_file ]] || fail "setup retires the manager-start-only environment file"
pass "setup exports the socket from the UWSM session environment"

touch "$systemd_env_file"
HOME=$home XDG_CONFIG_HOME=$config XDG_RUNTIME_DIR=$runtime PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-remove-service-ssh-agent" >"$test_dir/remove.log"
[[ -f $session_env_file ]] || fail "removal keeps a UWSM environment override"
grep -Fq 'unset SSH_AUTH_SOCK' "$session_env_file" || fail "removal explicitly clears the saved socket"
[[ $(prepare_session "$runtime/gcr/ssh") == "unset" ]] ||
  fail "UWSM session preparation removes the stale socket restored from the prior login"
[[ $(prepare_session "$runtime/other-agent/ssh") == "$runtime/other-agent/ssh" ]] ||
  fail "UWSM session preparation preserves another agent's socket"
[[ ! -e $systemd_env_file ]] || fail "removal leaves no environment.d socket setting"
pass "removal clears only the stale gcr socket during UWSM session preparation"

touch "$config/gcr-agent-active"
[[ $(prepare_session "$runtime/gcr/ssh") == "$runtime/gcr/ssh" ]] ||
  fail "UWSM preserves a gcr agent reactivated after removal"
pass "removal does not hide a reactivated gcr agent"
