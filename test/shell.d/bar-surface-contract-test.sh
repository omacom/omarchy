#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Always use a private headless compositor, never the developer's session.
compositor=${OMARCHY_TEST_COMPOSITOR:-labwc}
if ! command -v "$compositor" >/dev/null 2>&1 || ! command -v quickshell >/dev/null 2>&1; then
  skip "labwc/quickshell unavailable; production bar surface integration"
  exit 0
fi
require_command jq

fixture_dir=$(mktemp -d)
compositor_pid=""
qs_pid=""
cleanup() {
  for pid in "$qs_pid" "$compositor_pid"; do
    if [[ -n $pid ]]; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  rm -rf "$fixture_dir"
}
trap cleanup EXIT
ulimit -c 0

mkdir -p "$fixture_dir/runtime" "$fixture_dir/home" "$fixture_dir/config" "$fixture_dir/bin"
chmod 700 "$fixture_dir/runtime"
cp "$SHELL_TEST_DIR/fixtures/bar-surface-contract/shell.qml" "$fixture_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$fixture_dir/Ui"
ln -s "$ROOT/shell/Commons" "$fixture_dir/Commons"
ln -s "$ROOT/shell/plugins" "$fixture_dir/plugins"
cat >"$fixture_dir/config/rc.xml" <<'XML'
<?xml version="1.0"?>
<labwc_config><core><decoration>server</decoration></core></labwc_config>
XML

# No host service activation, configuration, display sockets, or input devices.
export HOME="$fixture_dir/home" XDG_CONFIG_HOME="$fixture_dir/home/.config"
export XDG_CONFIG_DIRS="$fixture_dir/config" XDG_RUNTIME_DIR="$fixture_dir/runtime"
export XDG_CACHE_HOME="$fixture_dir/home/.cache" XDG_STATE_HOME="$fixture_dir/home/.state"
# The production bar's initialization only runs its Bash flag probe; stub
# action helpers so an unexpected fixture event cannot invoke desktop actions.
for helper in omarchy-notification-send omarchy-launch-terminal omarchy-shell; do
  printf '#!/bin/bash\nexit 0\n' >"$fixture_dir/bin/$helper"
  chmod +x "$fixture_dir/bin/$helper"
done
export PATH="$fixture_dir/bin:$PATH"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$fixture_dir/runtime/no-dbus.sock"
unset WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
export WLR_BACKENDS=headless WLR_HEADLESS_OUTPUTS=2 WLR_RENDERER=pixman
export LIBSEAT_BACKEND=seatd SEATD_SOCK="$fixture_dir/runtime/no-seatd.sock"
"$compositor" -C "$fixture_dir/config" >"$fixture_dir/compositor.log" 2>&1 &
compositor_pid=$!

for _ in {1..50}; do
  [[ ! -S $fixture_dir/runtime/wayland-0 ]] || break
  if ! kill -0 "$compositor_pid" 2>/dev/null; then
    cat "$fixture_dir/compositor.log" >&2
    fail "isolated compositor starts"
  fi
  sleep 0.1
done
[[ -S $fixture_dir/runtime/wayland-0 ]] || fail "isolated compositor publishes private socket"
export WAYLAND_DISPLAY=wayland-0 QT_QPA_PLATFORM=wayland
OMARCHY_PATH="$ROOT" OMARCHY_QML_TEST_RESULT="$fixture_dir/result.json" \
  quickshell -p "$fixture_dir" --no-color >"$fixture_dir/log" 2>&1 &
qs_pid=$!

for _ in {1..70}; do
  [[ -s $fixture_dir/result.json ]] && break
  if ! kill -0 "$qs_pid" 2>/dev/null; then
    cat "$fixture_dir/log" >&2
    fail "production bar fixture starts"
  fi
  sleep 0.1
done
if [[ ! -s $fixture_dir/result.json ]] || ! jq -e '.ok' "$fixture_dir/result.json" >/dev/null; then
  cat "$fixture_dir/log" >&2
  [[ ! -s $fixture_dir/result.json ]] || cat "$fixture_dir/result.json" >&2
  fail "production bar surface integration"
fi
pass "production BarPanels resolve windows, initialize scopes, reinject facades, reveal locally and clean removed surfaces"
