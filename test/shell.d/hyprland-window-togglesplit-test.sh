#!/bin/bash

source "$(dirname "$0")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "activeworkspace" && $2 == "-j" ]]; then
  printf '{"id":3,"tiledLayout":"%s"}\n' "${HYPR_LAYOUT:-dwindle}"
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

PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_LAYOUT=dwindle \
  "$ROOT/bin/omarchy-hyprland-window-togglesplit"

grep -Fq 'hl.dsp.layout("togglesplit")' "$log" ||
  fail "togglesplit is dispatched on dwindle" "$(cat "$log")"
pass "togglesplit is dispatched on dwindle"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_LAYOUT=scrolling \
  "$ROOT/bin/omarchy-hyprland-window-togglesplit"

[[ ! -s $log ]] || fail "togglesplit is not dispatched on scrolling" "$(cat "$log")"
pass "togglesplit is not dispatched on scrolling"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_LAYOUT=master \
  "$ROOT/bin/omarchy-hyprland-window-togglesplit"

[[ ! -s $log ]] || fail "togglesplit is not dispatched on master" "$(cat "$log")"
pass "togglesplit is not dispatched on other layouts"

grep -Fq 'omarchy-hyprland-window-togglesplit' "$ROOT/default/hypr/bindings/tiling.lua" ||
  fail "SUPER + J uses the layout-aware togglesplit command"
grep -F 'SUPER + J' "$ROOT/default/hypr/bindings/tiling.lua" | grep -Fq 'hl.dsp.layout("togglesplit")' &&
  fail "SUPER + J no longer dispatches togglesplit unconditionally"
pass "SUPER + J uses the layout-aware togglesplit command"
