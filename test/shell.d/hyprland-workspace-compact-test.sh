#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d 2>/dev/null || mktemp -d -p "$ROOT" .compact-test.XXXXXX)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
fixtures="$test_tmp/fixtures"
log_file="$test_tmp/hyprctl.log"
mkdir -p "$mock_bin" "$fixtures"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HYPRCTL_LOG"
case "$1 $2" in
  "workspaces -j") cat "$FIXTURES/workspaces.json" ;;
  "--batch "*) ;;
  *) exit 1 ;;
esac
SH
chmod +x "$mock_bin/hyprctl"

set_workspaces() {
  cat >"$fixtures/workspaces.json"
}
reset_log() {
  : >"$log_file"
}
run_compact() {
  HYPRCTL_LOG="$log_file" FIXTURES="$fixtures" PATH="$mock_bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-workspace-compact" "$@"
}

# Two monitors, each with gaps. Workspace numbers are global, so workspaces are
# renumbered in place with change_id (monitor, windows and visibility are kept)
# and never onto a number that already exists on another monitor. The scratchpad
# (negative id) is ignored, workspace 3 stays put, and persistent workspaces
# 1/2/8 are never moved and their numbers never reassigned.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":true},
  {"id":2,"name":"2","monitor":"eDP-1","windows":0,"ispersistent":true},
  {"id":3,"name":"3","monitor":"eDP-1","windows":2,"ispersistent":false},
  {"id":7,"name":"7","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":8,"name":"8","monitor":"eDP-1","windows":0,"ispersistent":true},
  {"id":12,"name":"12","monitor":"DVI-D-1","windows":1,"ispersistent":false},
  {"id":17,"name":"17","monitor":"DVI-D-1","windows":1,"ispersistent":false},
  {"id":18,"name":"18","monitor":"DVI-D-1","windows":1,"ispersistent":false},
  {"id":-99,"name":"special:scratchpad","monitor":"eDP-1","windows":2,"ispersistent":false}
]
EOF2
reset_log
run_compact

mapfile -t calls <"$log_file"
[[ ${#calls[@]} == 2 ]] || fail "workspace compaction uses one read and one dispatch batch" "${calls[*]}"
[[ ${calls[0]} == "workspaces -j" ]] || fail "workspace compaction reads workspaces once" "${calls[0]}"
expected='--batch dispatch hl.dsp.workspace.change_id({ workspace = "17", id = 13 });dispatch hl.dsp.workspace.change_id({ workspace = "18", id = 14 });dispatch hl.dsp.workspace.change_id({ workspace = "7", id = 4 })'
[[ ${calls[1]} == "$expected" ]] || fail "workspace compaction renumbers each gapped workspace in place" "${calls[1]}"
[[ ${calls[1]} != *'hl.dsp.focus'* && ${calls[1]} != *'window.move'* ]] ||
  fail "workspace compaction neither moves windows nor changes focus" "${calls[1]}"
pass "workspace compaction renumbers workspaces in place with one batch"

# Dry run prints the same plan without touching the compositor.
reset_log
dry_output=$(run_compact --dry-run)
[[ $dry_output == $'[DVI-D-1] 17 -> 13 (1 window)\n[DVI-D-1] 18 -> 14 (1 window)\n[eDP-1] 7 -> 4 (1 window)' ]] ||
  fail "workspace compaction --dry-run prints the planned moves" "$dry_output"
grep -q -- '--batch' "$log_file" && fail "workspace compaction --dry-run dispatches nothing"
pass "workspace compaction --dry-run prints the plan without dispatching"

# A persistent empty workspace in the middle of a range holds its number: 5 and
# 6 pack to 3 and 5, never reusing reserved 4.
set_workspaces <<'EOF'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":true},
  {"id":2,"name":"2","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":4,"name":"4","monitor":"eDP-1","windows":0,"ispersistent":true},
  {"id":5,"name":"5","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":6,"name":"6","monitor":"eDP-1","windows":1,"ispersistent":false}
]
EOF
reset_log
run_compact
mapfile -t calls <"$log_file"
mid_batch=${calls[1]}
[[ $mid_batch == '--batch dispatch hl.dsp.workspace.change_id({ workspace = "5", id = 3 });dispatch hl.dsp.workspace.change_id({ workspace = "6", id = 5 })' ]] ||
  fail "workspace compaction packs around a persistent anchor" "$mid_batch"
pass "workspace compaction keeps persistent workspaces fixed"

# A number that exists on another monitor is never a destination, even when it
# is a gap in this monitor's own packing: 9 stays because 2 and 3 are taken
# elsewhere, and 10 can only use the free 4.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":9,"name":"9","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":10,"name":"10","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":2,"name":"2","monitor":"HDMI-A-1","windows":1,"ispersistent":false},
  {"id":3,"name":"3","monitor":"HDMI-A-1","windows":0,"ispersistent":false}
]
EOF2
reset_log
run_compact
mapfile -t calls <"$log_file"
[[ ${calls[1]} == '--batch dispatch hl.dsp.workspace.change_id({ workspace = "9", id = 4 });dispatch hl.dsp.workspace.change_id({ workspace = "10", id = 5 })' ]] ||
  fail "workspace compaction never renumbers onto another monitor's number" "${calls[1]}"
pass "workspace compaction treats workspace numbers as global"

# A workspace that cannot move to a lower free number stays where it is.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":2,"name":"2","monitor":"HDMI-A-1","windows":1,"ispersistent":false},
  {"id":3,"name":"3","monitor":"HDMI-A-1","windows":1,"ispersistent":false}
]
EOF2
reset_log
run_compact
grep -q -- '--batch' "$log_file" && fail "workspace compaction sends no batch when nothing can move"
pass "workspace compaction leaves unmovable workspaces alone"

# Open scratchpads and focus are irrelevant: no focus is dispatched at all, so a
# scratchpad shown over a renumbered workspace stays open and the focused
# monitor does not change.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":5,"name":"5","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":-98,"name":"special:scratchpad","monitor":"eDP-1","windows":2,"ispersistent":false}
]
EOF2
reset_log
run_compact
mapfile -t calls <"$log_file"
[[ ${calls[1]} == '--batch dispatch hl.dsp.workspace.change_id({ workspace = "5", id = 2 })' ]] ||
  fail "workspace compaction ignores special workspaces" "${calls[1]}"
[[ ${calls[1]} != *'focus'* ]] || fail "workspace compaction never dispatches focus" "${calls[1]}"
pass "workspace compaction does not touch focus or an open scratchpad"

# Destinations are reserved globally while planning: A={1,10} and B={2,9} must
# not both be sent to 3.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"A","windows":1,"ispersistent":false},
  {"id":10,"name":"10","monitor":"A","windows":1,"ispersistent":false},
  {"id":2,"name":"2","monitor":"B","windows":1,"ispersistent":false},
  {"id":9,"name":"9","monitor":"B","windows":1,"ispersistent":false}
]
EOF2
reset_log
run_compact
mapfile -t calls <"$log_file"
[[ ${calls[1]} == '--batch dispatch hl.dsp.workspace.change_id({ workspace = "10", id = 3 });dispatch hl.dsp.workspace.change_id({ workspace = "9", id = 4 })' ]] ||
  fail "workspace compaction reserves each planned destination across monitors" "${calls[1]}"
pass "workspace compaction never plans the same destination twice"

# The packing starts at the lowest occupied workspace, persistent or not.
set_workspaces <<'EOF2'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":true},
  {"id":5,"name":"5","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":7,"name":"7","monitor":"eDP-1","windows":1,"ispersistent":false}
]
EOF2
reset_log
run_compact
mapfile -t calls <"$log_file"
[[ ${calls[1]} == '--batch dispatch hl.dsp.workspace.change_id({ workspace = "5", id = 2 });dispatch hl.dsp.workspace.change_id({ workspace = "7", id = 3 })' ]] ||
  fail "workspace compaction starts after a leading persistent workspace" "${calls[1]}"
pass "workspace compaction packs from the lowest occupied workspace"

# An already compact state is a no-op: no batch is sent.
set_workspaces <<'EOF'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":2,"name":"2","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":3,"name":"3","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":11,"name":"11","monitor":"DVI-D-1","windows":2,"ispersistent":false}
]
EOF
reset_log
run_compact
grep -q -- '--batch' "$log_file" && fail "workspace compaction sends no batch for a compact layout"
pass "workspace compaction is a no-op when there are no gaps"

reset_log
no_gaps_output=$(run_compact --dry-run)
[[ $no_gaps_output == "No gaps between occupied workspaces." ]] ||
  fail "workspace compaction --dry-run reports a compact layout" "$no_gaps_output"
pass "workspace compaction --dry-run reports a compact layout"

if run_compact --nonsense 2>/dev/null; then
  fail "workspace compaction rejects unknown arguments"
fi
pass "workspace compaction rejects unknown arguments"