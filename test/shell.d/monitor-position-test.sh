#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command lua5.1
python3 "$ROOT/test/shell.d/monitor-position-checks.py"
pass "monitor positions preserve geometry, Lua options, and rollback safety"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/config/hypr"
printf '%s\n' 'hl.monitor({output="",scale=1})' >"$scratch/config/hypr/monitors.lua"
cp "$scratch/config/hypr/monitors.lua" "$scratch/original.lua"
cat >"$scratch/bin/hyprctl" <<'EOF'
#!/bin/bash
[[ $* == "monitors -j" ]] || exit 1
printf '%s\n' '[{"name":"DP-1","width":1920,"height":1080,"scale":1,"x":0,"y":0},{"name":"DP-2","width":1920,"height":720,"scale":1,"x":1920,"y":0}]'
EOF
cat >"$scratch/bin/omarchy-menu-select" <<'EOF'
#!/bin/bash
printf '%s\n' "$1" >>"$POSITION_MENU_LOG"
exit 1
EOF
cat >"$scratch/bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$scratch/bin/"*
export OMARCHY_PATH="$ROOT" XDG_CONFIG_HOME="$scratch/config" POSITION_MENU_LOG="$scratch/menu.log"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

bash "$ROOT/bin/omarchy-hyprland-monitor-position" DP-2 DP-1 left --dry-run >"$scratch/layout.json"
jq -e '.["DP-2"] == [-1920,0] and .["DP-1"] == [0,0]' "$scratch/layout.json" >/dev/null
pass "position command forwards CLI arguments to the backend"

bash "$ROOT/bin/omarchy-hyprland-monitor-position" DP-2 DP-1 left --align bottom --dry-run >"$scratch/layout.json"
jq -e '.["DP-2"] == [-1920,360] and .["DP-1"] == [0,0]' "$scratch/layout.json" >/dev/null
pass "position command forwards edge alignment for unequal screens"

bash "$ROOT/bin/omarchy-hyprland-monitor-position"
[[ $(< "$POSITION_MENU_LOG") == "Screen to move" ]] || fail "interactive command opens the screen selector"
cmp "$scratch/config/hypr/monitors.lua" "$scratch/original.lua" || fail "cancelling does not modify the configuration"
pass "cancelling the menu leaves the layout untouched"

# Exercise the menu's notification without touching the real compositor.
export POSITION_REAL_PYTHON="$(command -v python3)" POSITION_NOTIFICATION_LOG="$scratch/notification.log"
cat >"$scratch/bin/python3" <<'EOF'
#!/bin/bash
if [[ $1 == */monitor-position.py ]]; then
  if [[ ${2:-} == "--list" ]]; then
    printf '%s\n' '[{"name":"DP-1"},{"name":"DP-2"}]'
  else
    printf '%s\n' 'DP-2 is left of DP-1. Saved for next time.'
  fi
else
  exec "$POSITION_REAL_PYTHON" "$@"
fi
EOF
cat >"$scratch/bin/omarchy-menu-select" <<'EOF'
#!/bin/bash
case $1 in
  "Screen to move") printf '%s\n' DP-2 ;;
  "Position DP-2 relative to") printf '%s\n' DP-1 ;;
  "Place DP-2 relative to DP-1") printf '%s\n' left ;;
  *) exit 1 ;;
esac
EOF
cat >"$scratch/bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$POSITION_NOTIFICATION_LOG"
EOF
chmod +x "$scratch/bin/"*
bash "$ROOT/bin/omarchy-hyprland-monitor-position"
[[ $(tail -n1 "$POSITION_NOTIFICATION_LOG") == "$(omarchy-i18n monitorPosition.saved)" ]] || fail "successful menu saves use the notification catalog"
cmp "$scratch/config/hypr/monitors.lua" "$scratch/original.lua" || fail "notification fixture does not modify configuration"
pass "successful menu saves use a translated notification"
