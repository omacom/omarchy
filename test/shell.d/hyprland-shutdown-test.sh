#!/bin/bash

source "$(dirname "$0")/base-test.sh"

if ! systemctl --user show-environment >/dev/null 2>&1; then
  skip "no user manager; skipping compositor shutdown"
  exit 0
fi

require_command python3
require_command systemd-run

test_tmp=$(mktemp -d)
unit="omarchy-test-hyprland-shutdown-$$.service"
trap 'systemctl --user stop "$unit" >/dev/null 2>&1; rm -rf "$test_tmp"' EXIT

cat >"$test_tmp/compositor.py" <<'PY'
import os
import pathlib
import signal
import sys
import time

state = pathlib.Path(sys.argv[1])
child = os.fork()
if child == 0:
    def stop_shell(signum, frame):
        (state / "shell-stopped").touch()
        sys.exit(0)

    signal.signal(signal.SIGTERM, stop_shell)
    (state / "shell-ready").touch()
    while True:
        signal.pause()

def stop_compositor(signum, frame):
    # Give an early shell SIGTERM time to remove the wallpaper.
    time.sleep(0.2)
    if not (state / "shell-stopped").exists():
        (state / "wallpaper-retained").touch()
    sys.exit(0)

signal.signal(signal.SIGTERM, stop_compositor)
while not (state / "shell-ready").exists():
    time.sleep(0.01)
(state / "ready").touch()
while True:
    signal.pause()
PY

dropin="$ROOT/etc/systemd/user/wayland-wm@hyprland.desktop.service.d/10-keep-shell.conf"
kill_mode=$(sed -n 's/^KillMode=//p' "$dropin")
systemd-run --user --collect --quiet --unit="$unit" \
  --property="KillMode=$kill_mode" --property=TimeoutStopSec=2s \
  python3 "$test_tmp/compositor.py" "$test_tmp" || fail "isolated compositor starts"

for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -f $test_tmp/ready ]] && break
  sleep 0.02
done
[[ -f $test_tmp/ready ]] || fail "isolated compositor and shell are ready"

systemctl --user stop "$unit" || fail "isolated compositor stops"
[[ -f $test_tmp/wallpaper-retained ]] || fail "wallpaper survives compositor teardown"
pass "wallpaper survives compositor teardown"

if systemctl --user is-active --quiet "$unit"; then
  fail "compositor shutdown leaves no running service"
fi
pass "compositor shutdown leaves no running service"
