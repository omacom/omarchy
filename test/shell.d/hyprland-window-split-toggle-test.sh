#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Stand in for Hyprland: run the Lua the helper hands to `hyprctl eval` with a
# stubbed `hl`, so the test exercises the guard itself rather than its text.
cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 != "eval" ]]; then
  exit 1
fi

[[ ${HYPR_EVAL_FAIL:-0} == "0" ]] || exit 1

HL_LAYOUT="${HYPR_TILED_LAYOUT:-__nil__}" HL_DISPATCH_LOG="$HYPRCTL_LOG" lua -e '
hl = {
  get_active_workspace = function()
    local layout = os.getenv("HL_LAYOUT")
    if layout == "__nil__" then
      return nil
    end
    return { tiled_layout = layout }
  end,
  dispatch = function(dispatcher)
    local file = io.open(os.getenv("HL_DISPATCH_LOG"), "a")
    file:write(dispatcher.kind .. ":" .. tostring(dispatcher.arg) .. "\n")
    file:close()
  end,
  dsp = {
    layout = function(message)
      return { kind = "layout", arg = message }
    end,
  },
}
assert(load(io.read("*a")))()
' <<<"$2"
BASH
chmod +x "$tmpdir/hyprctl"

log="$tmpdir/hyprctl.log"

split_toggle() {
  PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" "$ROOT/bin/omarchy-hyprland-window-split-toggle"
}

toggle_count() {
  [[ -f $log ]] || {
    printf '0'
    return
  }

  grep -Fc 'layout:togglesplit' "$log" || true
}

PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_TILED_LAYOUT=dwindle split_toggle ||
  fail "window split toggle succeeds on a dwindle workspace"
(( $(toggle_count) == 1 )) ||
  fail "window split toggle toggles the split on a dwindle workspace"
pass "window split toggle toggles the split on a dwindle workspace"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_TILED_LAYOUT=scrolling split_toggle ||
  fail "window split toggle succeeds on a scrolling workspace"
(( $(toggle_count) == 0 )) ||
  fail "window split toggle stays silent on a scrolling workspace"
pass "window split toggle stays silent on a scrolling workspace"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" split_toggle ||
  fail "window split toggle succeeds without an active workspace"
(( $(toggle_count) == 0 )) ||
  fail "window split toggle stays silent without an active workspace"
pass "window split toggle stays silent without an active workspace"

>"$log"
PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" HYPR_EVAL_FAIL=1 split_toggle 2>/dev/null
(( $? != 0 )) ||
  fail "window split toggle reports a failed Lua dispatch"
pass "window split toggle reports a failed Lua dispatch"