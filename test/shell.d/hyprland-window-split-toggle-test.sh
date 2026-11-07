#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
log_file="$tmpdir/hyprctl.log"
mkdir -p "$stub_dir" "$home_dir"

cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash

if [[ $1 == "activeworkspace" ]]; then
  printf '{"id":3,"tiledLayout":"%s"}\n' "${HYPRCTL_TILED_LAYOUT:-dwindle}"
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
EOF
chmod +x "$stub_dir/hyprctl"

# XDG_STATE_HOME is named rather than inherited so a machine that sets it does
# not have its real saved layouts read.
split_toggle() {
  env HOME="$home_dir" XDG_STATE_HOME="$home_dir/.local/state" \
    HYPRCTL_LOG="$log_file" PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-window-split-toggle"
}

dispatched() {
  grep -q 'togglesplit' "$log_file"
}

# Dwindle is where togglesplit applies, so the binding sends it.
: >"$log_file"
split_toggle
dispatched || fail "a dwindle workspace toggles the split" "$(cat "$log_file")"
pass "a dwindle workspace toggles the split"

# A scrolling workspace has no split. Sending togglesplit there comes back from
# Hyprland as a Lua runtime error, so the command sends nothing.
: >"$log_file"
HYPRCTL_TILED_LAYOUT=scrolling split_toggle
if dispatched; then
  fail "a scrolling workspace sends no dwindle-only message" "$(cat "$log_file")"
fi
pass "a scrolling workspace sends no dwindle-only message"

# Floating is not a tiled layout either, and it is read back from the saved
# mode rather than from the compositor.
: >"$log_file"
mkdir -p "$home_dir/.local/state/omarchy/workspace-layouts"
printf 'o.workspace_mode({ workspace = "3", mode = "floating" })\n' \
  >"$home_dir/.local/state/omarchy/workspace-layouts/3.lua"
split_toggle
if dispatched; then
  fail "a floating workspace sends no dwindle-only message" "$(cat "$log_file")"
fi
pass "a floating workspace sends no dwindle-only message"
