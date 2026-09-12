#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

socket="$XDG_RUNTIME_DIR/podman/podman.sock"
class='io.podman_desktop.PodmanDesktop'
desktop_pid=""
cleanup() {
  if [[ -n $desktop_pid ]]; then
    kill -TERM "$desktop_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# The harness enters over SSH, which does not inherit the graphical session's
# generated environment. Inspect a real user-manager child, like a launched app.
endpoint=$(systemd-run --user --quiet --pipe --wait /bin/sh -c 'printf "%s" "${DOCKER_HOST:-}"')
if pacman -Q podman-docker >/dev/null 2>&1; then
  [[ $endpoint == "unix://$socket" ]] || fail "Docker compatibility defaults to the user socket"
else
  [[ -z $endpoint ]] || fail "Native Podman does not configure a Docker API endpoint"
fi
systemctl --user start podman.socket
api_ready() {
  [[ $(curl -fsS --max-time 5 --unix-socket "$socket" http://localhost/_ping) == "OK" ]]
}
wait_until "Docker API responds before opening Desktop" 15 api_ready
inode=$(stat -c %i "$socket")
close_windows "$class"
wait_until "previous Podman windows are closed" 10 window_absent "$class"
# Use the compositor's exec path, as the keyboard binding does. A child of the
# test runner could inherit its app.slice and hide a missing uwsm-app wrapper.
desktop_command="env OMARCHY_PATH=\"$OMARCHY_PATH\" \"$OMARCHY_PATH/bin/omarchy-launch-podman\""
hyprctl dispatch "hl.dsp.exec_cmd([[$desktop_command]])" >/dev/null 2>&1 ||
  hyprctl dispatch exec "$desktop_command" >/dev/null
wait_until "Podman Desktop opens" 30 window_present "$class"
desktop_pid=$(hyprctl -j clients | jq -r --arg class "$class" '.[] | select(.class == $class) | .pid' | head -n 1)
grep -q '/app.slice/' "/proc/$desktop_pid/cgroup" || fail "Podman Desktop runs in the managed application slice"
# Let the bundled Linux extension finish starting its API connection.
sleep 5
wait_until "Docker API responds while Desktop is open" 15 api_ready
[[ $(stat -c %i "$socket") == "$inode" ]] || fail "Desktop preserves the systemd API socket"
screenshot "success-podman-desktop-api"
kill -TERM "$desktop_pid"
desktop_pid=""
wait_until "Podman Desktop exits" 15 window_absent "$class"
sleep 7 # The API service's default idle timeout is five seconds.
[[ -S $socket && $(stat -c %i "$socket") == "$inode" ]] || fail "Desktop exit preserves the API socket"
wait_until "Docker API reactivates after Desktop exits" 15 api_ready
curl -fsS --max-time 5 --unix-socket "$socket" 'http://localhost/v1.40/containers/json?all=true' |
  jq -e 'type == "array"' >/dev/null || fail "Docker SDK container listing works after Desktop exits"
pass "Desktop open and close preserve Docker API access across idle activation"
