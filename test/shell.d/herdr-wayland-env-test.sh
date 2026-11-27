#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

envs_file="$ROOT/default/bash/envs"
[[ -f $envs_file ]] || fail "default/bash/envs exists"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
calls="$test_tmp/systemctl.calls"
mkdir -p "$stub_bin" "$runtime_dir"

# Create a real UNIX domain socket so [ -S ... ] passes for live displays.
python3 - "$runtime_dir/wayland-1" <<'PY'
import socket, sys
s = socket.socket(socket.AF_UNIX)
s.bind(sys.argv[1])
s.close()
PY

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_CALLS"
printf '%s\n' "${TEST_SYSTEMD_ENV:-}"
SH
chmod +x "$stub_bin/systemctl"

run_envs() {
  : >"$calls"
  env -i \
    HOME="$test_tmp" \
    PATH="$stub_bin:/usr/bin:/bin" \
    _OMARCHY_ENV_BOOTSTRAPPED=1 \
    LANG=C.UTF-8 \
    TEST_CALLS="$calls" \
    "$@" \
    bash -euo pipefail -c 'source "$1"; printf "WAYLAND_DISPLAY=%s\nXDG_RUNTIME_DIR=%s\n" "${WAYLAND_DISPLAY:-}" "${XDG_RUNTIME_DIR:-}"' bash "$envs_file"
}

# Remote-started herdr pane inherits live WAYLAND_DISPLAY from the graphical session.
out=$(run_envs HERDR_ENV=1 XDG_RUNTIME_DIR="$runtime_dir" TEST_SYSTEMD_ENV=$'DISPLAY=:0\nWAYLAND_DISPLAY=wayland-1')
[[ $out == *"WAYLAND_DISPLAY=wayland-1"* ]] || fail "herdr pane inherits live WAYLAND_DISPLAY" "$out"
pass "remote-started herdr pane inherits live WAYLAND_DISPLAY"

# Plain SSH shell (HERDR_ENV unset) stays headless and does not call systemctl.
out=$(run_envs XDG_RUNTIME_DIR="$runtime_dir" TEST_SYSTEMD_ENV="WAYLAND_DISPLAY=wayland-1")
[[ $out == *"WAYLAND_DISPLAY="$'\n'* ]] || fail "plain SSH shell does not inherit WAYLAND_DISPLAY" "$out"
[[ ! -s $calls ]] || fail "plain SSH shell skips systemctl lookup" "$(cat "$calls")"
pass "plain SSH shell stays headless without calling systemctl"

# Local herdr pane that already has WAYLAND_DISPLAY keeps it without calling systemctl.
out=$(run_envs HERDR_ENV=1 WAYLAND_DISPLAY=wayland-9 XDG_RUNTIME_DIR="$runtime_dir" TEST_SYSTEMD_ENV="WAYLAND_DISPLAY=wayland-1")
[[ $out == *"WAYLAND_DISPLAY=wayland-9"* ]] || fail "existing WAYLAND_DISPLAY is preserved" "$out"
[[ ! -s $calls ]] || fail "local herdr pane skips systemctl lookup" "$(cat "$calls")"
pass "local herdr pane keeps its existing WAYLAND_DISPLAY without calling systemctl"

# Stale WAYLAND_DISPLAY whose socket is missing is not exported.
out=$(run_envs HERDR_ENV=1 XDG_RUNTIME_DIR="$runtime_dir" TEST_SYSTEMD_ENV="WAYLAND_DISPLAY=wayland-missing")
[[ $out == *"WAYLAND_DISPLAY="$'\n'* ]] || fail "missing Wayland socket is not exported" "$out"
pass "stale WAYLAND_DISPLAY without a live socket is ignored"

# Headless session with no WAYLAND_DISPLAY in systemd user env leaves it unset.
out=$(run_envs HERDR_ENV=1 XDG_RUNTIME_DIR="$runtime_dir" TEST_SYSTEMD_ENV="DISPLAY=:0")
[[ $out == *"WAYLAND_DISPLAY="$'\n'* ]] || fail "headless session leaves WAYLAND_DISPLAY unset" "$out"
pass "headless session leaves WAYLAND_DISPLAY unset"
