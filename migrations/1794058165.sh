echo "Keep Super+number on your existing global workspaces when a workspace rule or an older workspace indicator still uses those numbers"

# Per-monitor workspaces number each monitor 1-10. A setup that already pinned
# workspaces 1-10 to monitors, or a cloned indicator that still compares its
# labels to those ids, would lose its shortcuts, highlights, and saved layouts.
# Leaving the numbers as they are keeps all three. Choosing per-monitor later
# is `omarchy_global_workspaces = false` in ~/.config/hypr/hyprland.lua.

hyprland="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"
[[ -f $hyprland ]] || exit 0
grep -qE '^[[:space:]]*omarchy_global_workspaces[[:space:]]*=' "$hyprland" && exit 0

[[ -n ${OMARCHY_PATH:-} && -f $OMARCHY_PATH/default/hypr/global-workspaces.lua ]] || exit 1

answer=$(lua -e 'package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path; local g = require("default.hypr.global-workspaces"); io.write(g.detected() and "yes" or "no")')
[[ $answer == "yes" ]] || exit 0

state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$state_home/omarchy/monitors"
printf '1\n' >"$state_home/omarchy/monitors/global-workspaces"

line=$(grep -nE -m1 "^[[:space:]]*require[[:space:]]*\(?[[:space:]]*[\"']default\.hypr\.omarchy[\"']" "$hyprland" | cut -d: -f1 || true)

# Follow a symlink into a dotfiles repo rather than replacing it with a copy.
# The flag is inserted only after the bar file is in place, so a retry that
# sees the flag does not need to write it again. Hyprland publishes the same
# file when it loads.
sed -i --follow-symlinks "${line:-1}i -- Your workspace rules or an older workspace indicator still use global workspace numbers.\\n-- Super+number keeps selecting those workspaces, and they are not renumbered, so saved layouts stay with them.\\n-- Set this to false to give each monitor its own workspaces 1-10.\\nomarchy_global_workspaces = true\\n" "$hyprland"
