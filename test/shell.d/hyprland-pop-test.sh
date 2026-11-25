#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "a popped-out window is centered again on the monitor it moves to"
local handlers, timers, centered = {}, {}, {}

hl = {
  on = function(event, callback) handlers[event] = callback end,
  timer = function(callback, opts) table.insert(timers, { run = callback, opts = opts }) end,
  dispatch = function(dispatcher) table.insert(centered, dispatcher.window) end,
  dsp = { window = { center = function(args) return args end } },
}

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.pop")

local left, right = { id = 0 }, { id = 1 }

local function move(tags, from, to)
  timers, centered = {}, {}
  handlers["window.move_to_workspace"]({ address = "0xabc", tags = tags, monitor = from }, { monitor = to })
  for _, timer in ipairs(timers) do timer.run() end
  return centered
end

local moved = move({ "pop" }, left, right)
assert(#moved == 1 and moved[1] == "address:0xabc", "a popped window moved to another monitor is centered there")

-- Centering in the event itself would measure the monitor it is leaving.
timers, centered = {}, {}
handlers["window.move_to_workspace"]({ address = "0xabc", tags = { "pop" }, monitor = left }, { monitor = right })
assert(#centered == 0, "nothing is centered while the move is still in flight")
assert(#timers == 1 and timers[1].opts.type == "oneshot" and timers[1].opts.timeout > 0, "the center waits until the move has landed")

assert(#move({ "pop" }, left, left) == 0, "a move between workspaces on the same monitor keeps where it was put")
assert(#move({ "default-opacity*" }, left, right) == 0, "a window that was not popped out is left alone")
assert(#move({ "pop" }, left, nil) == 0, "a workspace without a monitor is not measured")
LUA
pass "a popped-out window is centered again on the monitor it moves to"

# Popping a tile back in rebuilds the layout it left. The stub only serves the
# windows Hyprland would report; the script works out the splits.
require_command jq

pop_tmp=$(mktemp -d)
trap 'rm -rf "$pop_tmp"' EXIT
mkdir -p "$pop_tmp/bin" "$pop_tmp/run"

cat >"$pop_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
case "$1" in
  activewindow) cat "$POP_TMP/active.json" ;;
  clients) cat "$POP_TMP/clients.json" ;;
  workspaces) printf '[{"id": 1, "tiledLayout": "%s"}]\n' "$(cat "$POP_TMP/layout")" ;;
  getoption)
    case "$2" in
      general:layout) echo '{"str": "dwindle"}' ;;
      general:border_size) echo '{"int": 2}' ;;
      general:gaps_in) printf '{"css": "%s %s %s %s"}\n' "$(cat "$POP_TMP/gaps")" "$(cat "$POP_TMP/gaps")" "$(cat "$POP_TMP/gaps")" "$(cat "$POP_TMP/gaps")" ;;
      dwindle:default_split_ratio) echo '{"float": 1.0}' ;;
    esac
    ;;
  *) printf '%s\n' "$*" >>"$POP_TMP/hyprctl.log" ;;
esac
SH
chmod +x "$pop_tmp/bin/hyprctl"

# tile <address> <x> <y> <width> <height> [floating]
tile() {
  printf '{"address": "%s", "at": [%s, %s], "size": [%s, %s], "workspace": {"id": 1}, "floating": %s, "pinned": %s}\n' \
    "$1" "$2" "$3" "$4" "$5" "${6:-false}" "${6:-false}"
}

# Pops 0xa out of the first layout, then back in over the second, and prints
# what the script asked Hyprland for on the way back. AFTER_GAPS changes the
# gap while the window is out.
round_trip() {
  local before="$1" after="$2"

  rm -rf "$pop_tmp/hyprctl.log" "$pop_tmp/run"/*
  echo "${LAYOUT:-dwindle}" >"$pop_tmp/layout"
  echo 5 >"$pop_tmp/gaps"
  echo "$before" | jq -s . >"$pop_tmp/clients.json"
  echo "$before" | jq -s '.[] | select(.address == "0xa")' >"$pop_tmp/active.json"
  POP_TMP="$pop_tmp" XDG_RUNTIME_DIR="$pop_tmp/run" PATH="$pop_tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"

  rm -f "$pop_tmp/hyprctl.log"
  echo "${AFTER_GAPS:-5}" >"$pop_tmp/gaps"
  echo "$after" | jq -s . >"$pop_tmp/clients.json"
  echo "$after" | jq -s '.[] | select(.address == "0xa")' >"$pop_tmp/active.json"
  POP_TMP="$pop_tmp" XDG_RUNTIME_DIR="$pop_tmp/run" PATH="$pop_tmp/bin:$PATH" "$ROOT/bin/omarchy-hyprland-window-pop"
  cat "$pop_tmp/hyprctl.log"
}

popped=$(tile 0xa 290 -30 1300 900 true)

# A on the left, B over C on the right: A's neighbor is a stack, which a single
# split of B or C cannot put back.
log=$(round_trip "$(tile 0xa 12 40 621 780; tile 0xb 647 40 621 383; tile 0xc 647 437 621 383)" \
  "$popped$(printf '\n'; tile 0xb 12 40 621 383; tile 0xc 12 437 621 383)")
batch=$(grep -- "--batch" <<<"$log" | tr ';' '\n' | grep -oE 'preselect [lrud]|address:0x[abc]", action = "toggle"' | tr '\n' ' ')
[[ $batch == *'address:0xb", action = "toggle" address:0xc", action = "toggle" address:0xa", action = "toggle" preselect r address:0xb", action = "toggle" preselect d address:0xc", action = "toggle" '* ]] ||
  fail "a tile beside a stack pops back in beside the whole stack" "$log"
grep -q "splitratio" <<<"$log" && fail "even splits are left at the default ratio" "$log"
pass "a tile beside a stack pops back in beside the whole stack"

# A took 60% of the width before it popped out.
log=$(round_trip "$(tile 0xa 12 40 747 780; tile 0xb 773 40 495 780)" "$popped$(printf '\n'; tile 0xb 12 40 1256 780)")
grep -q 'splitratio 0.2' <<<"$log" || fail "a resized split pops back in at its size" "$log"
pass "a resized split pops back in at its size"

# A window that closed meanwhile leaves nothing to rebuild; the tile just retiles.
log=$(round_trip "$(tile 0xa 12 40 621 780; tile 0xb 647 40 621 383; tile 0xc 647 437 621 383)" \
  "$popped$(printf '\n'; tile 0xb 12 40 1256 780)")
grep -q -- "--batch" <<<"$log" && fail "a layout that changed while popped out retiles plainly" "$log"
grep -q 'address:0xa", action = "toggle"' <<<"$log" || fail "a layout that changed while popped out retiles plainly" "$log"
pass "a layout that changed while popped out retiles plainly"

# The split is read with the gap it was laid out with, not one changed since.
log=$(AFTER_GAPS=0 round_trip "$(tile 0xa 12 40 747 780; tile 0xb 773 40 495 780)" "$popped$(printf '\n'; tile 0xb 12 40 1256 780)")
grep -q 'splitratio 0.2' <<<"$log" || fail "a gap changed while popped out keeps the split's size" "$log"
pass "a gap changed while popped out keeps the split's size"

# A workspace switched to scrolling (Super+L) while general:layout stays dwindle.
log=$(LAYOUT=scrolling round_trip "$(tile 0xa 12 40 621 780; tile 0xb 647 40 621 780)" "$popped$(printf '\n'; tile 0xb 12 40 1256 780)")
grep -q -- "--batch" <<<"$log" && fail "a scrolling workspace retiles plainly" "$log"
pass "a scrolling workspace retiles plainly"
