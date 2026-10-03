#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
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
  "clients -j") cat "$FIXTURES/clients.json" ;;
  "monitors -j") cat "$FIXTURES/monitors.json" ;;
  "--batch "*) ;;
  *) exit 1 ;;
esac
SH
chmod +x "$mock_bin/hyprctl"

set_workspaces() {
  cat >"$fixtures/workspaces.json"
}
set_clients() {
  cat >"$fixtures/clients.json"
}
set_monitors() {
  cat >"$fixtures/monitors.json"
}
reset_log() {
  : >"$log_file"
}
run_compact() {
  HYPRCTL_LOG="$log_file" FIXTURES="$fixtures" PATH="$mock_bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-workspace-compact" "$@"
}

# Two monitors, each with gaps in its split-monitor-workspaces range. The
# scratchpad (negative id) is ignored, workspace 3 stays put, and the low
# workspaces 1/2 plus 8 are reserved: persistent workspaces are never moved and
# their numbers are never reassigned.
set_workspaces <<'EOF'
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
EOF
set_clients <<'EOF'
[
  {"address":"0x1","workspace":{"id":1}},
  {"address":"0x3a","workspace":{"id":3}},
  {"address":"0x3b","workspace":{"id":3}},
  {"address":"0x7","workspace":{"id":7}},
  {"address":"0x12","workspace":{"id":12}},
  {"address":"0x17","workspace":{"id":17}},
  {"address":"0x18","workspace":{"id":18}},
  {"address":"0x99","workspace":{"id":-99}}
]
EOF
set_monitors <<'EOF'
[
  {"name":"eDP-1","focused":true,"activeWorkspace":{"id":7}},
  {"name":"DVI-D-1","focused":false,"activeWorkspace":{"id":12}}
]
EOF
reset_log
run_compact

mapfile -t calls <"$log_file"
[[ ${#calls[@]} == 4 ]] || fail "workspace compaction uses three reads and one dispatch batch" "${calls[*]}"
[[ ${calls[0]} == "workspaces -j" ]] || fail "workspace compaction reads workspaces once" "${calls[0]}"
[[ ${calls[1]} == "clients -j" ]] || fail "workspace compaction reads clients once" "${calls[1]}"
[[ ${calls[2]} == "monitors -j" ]] || fail "workspace compaction reads monitors once" "${calls[2]}"

batch=${calls[3]}
[[ $batch == "--batch "* ]] || fail "workspace compaction sends one dispatch batch" "$batch"
[[ $batch == *'address:0x17"'* ]] || fail "workspace compaction moves a gapped second-monitor workspace"
[[ $batch == *'address:0x18"'* ]] || fail "workspace compaction moves later second-monitor workspaces"
[[ $batch == *'address:0x7"'* ]] || fail "workspace compaction moves a gapped first-monitor workspace"
[[ $batch != *'address:0x12"'* ]] || fail "workspace compaction keeps the lowest workspace of each range"
[[ $batch != *'address:0x3a"'* && $batch != *'address:0x3b"'* ]] ||
  fail "workspace compaction leaves already compact workspaces alone"
[[ $batch != *'address:0x1"'* && $batch != *'address:0x2"'* ]] ||
  fail "workspace compaction leaves reserved workspaces alone"
[[ $batch != *'address:0x99"'* ]] || fail "workspace compaction ignores the scratchpad"
[[ $batch == *'dispatch hl.dsp.focus({ workspace = "4" })' ]] ||
  fail "workspace compaction follows the renumbered focused workspace"
[[ ${batch##*;} == 'dispatch hl.dsp.focus({ workspace = "4" })' ]] ||
  fail "workspace compaction restores the focused workspace last" "$batch"
pass "workspace compaction batches per-monitor moves and restores focus"

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
set_clients <<'EOF'
[
  {"address":"0x1","workspace":{"id":1}},
  {"address":"0x2","workspace":{"id":2}},
  {"address":"0x5","workspace":{"id":5}},
  {"address":"0x6","workspace":{"id":6}}
]
EOF
set_monitors <<'EOF'
[
  {"name":"eDP-1","focused":true,"activeWorkspace":{"id":5}}
]
EOF
reset_log
run_compact
mapfile -t calls <"$log_file"
mid_batch=${calls[3]}
[[ $mid_batch == *'dispatch hl.dsp.window.move({ workspace = "3", follow = false, window = "address:0x5" })'* ]] ||
  fail "workspace compaction packs around a persistent anchor" "$mid_batch"
[[ $mid_batch == *'dispatch hl.dsp.window.move({ workspace = "5", follow = false, window = "address:0x6" })'* ]] ||
  fail "workspace compaction skips the reserved number as a destination" "$mid_batch"
[[ $mid_batch == *'dispatch hl.dsp.focus({ workspace = "3" })'* ]] ||
  fail "workspace compaction follows the focused workspace past an anchor" "$mid_batch"
pass "workspace compaction keeps persistent workspaces fixed"

# A focused special workspace is never renumbered, so no focus command is
# emitted; only the moves run.
set_monitors <<'EOF'
[
  {"name":"eDP-1","focused":true,"activeWorkspace":{"id":-99}},
  {"name":"DVI-D-1","focused":false,"activeWorkspace":{"id":12}}
]
EOF
reset_log
run_compact
mapfile -t calls <"$log_file"
[[ ${calls[3]} == "--batch "* && ${calls[3]} != *'hl.dsp.focus'* ]] ||
  fail "workspace compaction leaves focus on the scratchpad alone" "${calls[3]}"
pass "workspace compaction does not steal focus from the scratchpad"

# An already compact state is a no-op: no batch is sent.
set_workspaces <<'EOF'
[
  {"id":1,"name":"1","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":2,"name":"2","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":3,"name":"3","monitor":"eDP-1","windows":1,"ispersistent":false},
  {"id":11,"name":"11","monitor":"DVI-D-1","windows":2,"ispersistent":false}
]
EOF
set_clients <<'EOF'
[
  {"address":"0x1","workspace":{"id":1}},
  {"address":"0x2","workspace":{"id":2}},
  {"address":"0x3","workspace":{"id":3}},
  {"address":"0x11a","workspace":{"id":11}},
  {"address":"0x11b","workspace":{"id":11}}
]
EOF
set_monitors <<'EOF'
[
  {"name":"eDP-1","focused":true,"activeWorkspace":{"id":3}},
  {"name":"DVI-D-1","focused":false,"activeWorkspace":{"id":11}}
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