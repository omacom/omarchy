#!/bin/bash

source "$(dirname "$0")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  printf '{"fullscreenClient":%s}\n' "${HYPR_FULLSCREEN_CLIENT:-0}"
  exit 0
fi

if [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
  exit 0
fi

exit 1
BASH
chmod +x "$tmpdir/hyprctl"

log="$tmpdir/hyprctl.log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_FULLSCREEN_CLIENT=0 \
  "$ROOT/bin/omarchy-hyprland-window-tiled-fullscreen-toggle"

grep -Fq 'hl.dsp.window.fullscreen_state({ internal = 0, client = 2 })' "$log" || \
  fail "tiled fullscreen enables client fullscreen"
pass "tiled fullscreen enables client fullscreen"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_FULLSCREEN_CLIENT=2 \
  "$ROOT/bin/omarchy-hyprland-window-tiled-fullscreen-toggle"

grep -Fq 'hl.dsp.window.fullscreen_state({ internal = 0, client = 0 })' "$log" || \
  fail "tiled fullscreen disables client fullscreen"
pass "tiled fullscreen disables client fullscreen"

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "activeworkspace" && $2 == "-j" ]]; then
  printf '{"id":1,"tiledLayout":"%s"}\n' "${HYPR_TILED_LAYOUT-dwindle}"
  exit 0
fi

if [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
  exit 0
fi

exit 1
BASH
chmod +x "$tmpdir/hyprctl"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_TILED_LAYOUT=dwindle \
  "$ROOT/bin/omarchy-hyprland-window-split-toggle"

grep -Fq 'hl.dsp.layout("togglesplit")' "$log" || \
  fail "window split toggle dispatches togglesplit on dwindle layout"
pass "window split toggle dispatches togglesplit on dwindle layout"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_TILED_LAYOUT=scrolling \
  "$ROOT/bin/omarchy-hyprland-window-split-toggle"

[[ ! -s $log ]] || \
  fail "window split toggle does not dispatch on scrolling layout"
pass "window split toggle is a clean no-op on scrolling layout"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_TILED_LAYOUT="" \
  "$ROOT/bin/omarchy-hyprland-window-split-toggle"

[[ ! -s $log ]] || \
  fail "window split toggle does not dispatch when workspace layout is unknown"
pass "window split toggle does not dispatch when workspace layout is unknown"
