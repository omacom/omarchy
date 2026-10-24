#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/run"
touch "$test_dir/run/wayland-1" "$test_dir/run/wayland-1.lock"

cat >"$test_dir/bin/qs" <<'STUB'
#!/bin/bash
echo "display=[$WAYLAND_DISPLAY]"
STUB
chmod +x "$test_dir/bin/qs"

export PATH="$test_dir/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export XDG_RUNTIME_DIR="$test_dir/run"

# Callers from a stripped environment have no WAYLAND_DISPLAY, and qs matches
# instances by display.
output=$(env -u WAYLAND_DISPLAY "$ROOT/bin/omarchy-shell" omarchy.indicators refresh)
[[ $output == "display=[wayland-1]" ]] || fail "shell ipc recovers a missing display" "$output"
pass "shell ipc recovers a missing display"

touch "$test_dir/run/wayland-9"
output=$(WAYLAND_DISPLAY=wayland-9 "$ROOT/bin/omarchy-shell" omarchy.indicators refresh)
[[ $output == "display=[wayland-9]" ]] || fail "shell ipc keeps an existing display" "$output"
pass "shell ipc keeps an existing display"
rm "$test_dir/run/wayland-9"

# A second Hyprland session leaves its display in the systemd user environment
# after it ends, and services started then must still reach the live shell.
output=$(WAYLAND_DISPLAY=wayland-2 "$ROOT/bin/omarchy-shell" omarchy.indicators refresh)
[[ $output == "display=[wayland-1]" ]] || fail "shell ipc recovers from a display whose socket is gone" "$output"
pass "shell ipc recovers from a display whose socket is gone"

# A display may be an absolute path to a socket outside the runtime directory.
mkdir -p "$test_dir/elsewhere"
touch "$test_dir/elsewhere/wayland-5"
output=$(WAYLAND_DISPLAY="$test_dir/elsewhere/wayland-5" "$ROOT/bin/omarchy-shell" omarchy.indicators refresh)
[[ $output == "display=[$test_dir/elsewhere/wayland-5]" ]] || fail "shell ipc keeps a live absolute display" "$output"
pass "shell ipc keeps a live absolute display"
