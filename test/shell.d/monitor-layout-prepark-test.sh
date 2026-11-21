#!/bin/bash

# A resize that grows a monitor into the space of the neighbour beside it must
# move that neighbour out first, in its own eval, and wait for the move to
# land, so the growth fills a gap instead of covering the neighbour while
# Hyprland warns about the overlap. Shrinks and same-size turns keep the
# historic single eval.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
monitors_json="$tmpdir/monitors.json"
eval_log="$tmpdir/eval.log"
mkdir -p "$stub_dir" "$home_dir"

cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash
case "$1" in
  monitors)
    cat "$MONITORS_JSON"
    ;;
  eval)
    printf '%s\n' "$2" >>"$EVAL_LOG"
    [[ ${APPLY_EVALS:-true} == true ]] || exit 0
    # Apply the rules to the fake live state, as the compositor would.
    echo "$2" | grep -oE 'output = "[^"]+", (mode = "[^"]+", )?position = "-?[0-9]+x-?[0-9]+"(, scale = [0-9.]+(, transform = [0-7]))?' |
      while IFS= read -r line; do
        name=$(echo "$line" | sed -E 's/output = "([^"]+)".*/\1/')
        pos=$(echo "$line" | sed -E 's/.*position = "(-?[0-9]+x-?[0-9]+)".*/\1/')
        mode=$(echo "$line" | sed -nE 's/.*mode = "([^"]+)".*/\1/p')
        transform=$(echo "$line" | sed -nE 's/.*, transform = ([0-7]).*/\1/p')
        update='(.[] | select(.name == $n) | .x) = $x | (.[] | select(.name == $n) | .y) = $y'
        [[ -n $mode ]] && update+=" | (.[] | select(.name == \$n) | .width) = (\$mode | split(\"x\")[0] | tonumber) | (.[] | select(.name == \$n) | .height) = (\$mode | split(\"x\")[1] | split(\"@\")[0] | tonumber)"
        [[ -n $transform ]] && update+=" | (.[] | select(.name == \$n) | .transform) = \$t"
        jq --arg n "$name" --argjson x "${pos%x*}" --argjson y "${pos#*x}" \
          --arg mode "${mode:-}" --argjson t "${transform:-0}" \
          "$update" "$MONITORS_JSON" >"$MONITORS_JSON.tmp"
        mv "$MONITORS_JSON.tmp" "$MONITORS_JSON"
      done
    ;;
esac
EOF
chmod +x "$stub_dir/hyprctl"

cat >"$stub_dir/omarchy-hyprland-monitor-persist" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$PERSIST_LOG"
EOF
chmod +x "$stub_dir/omarchy-hyprland-monitor-persist"

# The 270-degree laptop beside a portrait external, the arrangement a
# quarter turn to 180 grows out from: eDP-1 stands 1125 wide and the
# external sits at its right edge.
setup_growing_rotation() {
  cat >"$monitors_json" <<'JSON'
[
  {"name": "eDP-1", "width": 2880, "height": 1800, "x": 0, "y": 0, "scale": 1.6, "transform": 3, "refreshRate": 90.0, "disabled": false, "mirrorOf": "none"},
  {"name": "HDMI-A-1", "width": 1920, "height": 1080, "x": 1125, "y": 0, "scale": 1, "transform": 1, "refreshRate": 60.0, "disabled": false, "mirrorOf": "none"}
]
JSON
}

# The same pair after the turn: eDP-1 stands 1800 wide, the external at its
# new right edge.
setup_shrinking_rotation() {
  cat >"$monitors_json" <<'JSON'
[
  {"name": "eDP-1", "width": 2880, "height": 1800, "x": 0, "y": 0, "scale": 1.6, "transform": 2, "refreshRate": 90.0, "disabled": false, "mirrorOf": "none"},
  {"name": "HDMI-A-1", "width": 1920, "height": 1080, "x": 1800, "y": 0, "scale": 1, "transform": 1, "refreshRate": 60.0, "disabled": false, "mirrorOf": "none"}
]
JSON
}

run_layout() {
  local apply=${APPLY_EVALS:-true}
  : >"$eval_log"
  : >"$tmpdir/persist.log"
  APPLY_EVALS="$apply" \
    HOME="$home_dir" \
    MONITORS_JSON="$monitors_json" \
    EVAL_LOG="$eval_log" \
    PERSIST_LOG="$tmpdir/persist.log" \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-monitor-layout" "$@"
}

setup_growing_rotation
run_layout --resized eDP-1 2880x1800 1.6 1800x2880 1.6 "2880x1800@90" 2

evals=$(wc -l <"$eval_log")
(( evals == 2 )) || fail "a growing rotation takes a first eval for the covered neighbour" "got $evals evals"
head -1 "$eval_log" | grep -Fq 'HDMI-A-1' ||
  fail "the first eval moves the covered neighbour" "$(head -1 "$eval_log")"
head -1 "$eval_log" | grep -Fvq 'eDP-1' ||
  fail "the first eval carries no other rule" "$(head -1 "$eval_log")"
pass "a growing rotation moves the covered neighbour out first"

tail -1 "$eval_log" | grep -F 'output = "eDP-1"' | grep -Fq 'transform = 2' ||
  fail "the second eval still carries the rotated monitor's rule"
tail -1 "$eval_log" | grep -Fq 'output = "HDMI-A-1"' ||
  fail "the second eval still carries the neighbour's final position"
pass "the second eval carries the full ordered layout"

jq -e '[.[] | select(.name == "HDMI-A-1")] | .[0] | .x == 1800 and .y == 0' "$monitors_json" >/dev/null ||
  fail "the first eval's move landed in the live state before the growth"
pass "the pre-move is confirmed against the live state"

# The same turn from the other side shrinks the monitor: the neighbour closes
# in on the freed space, so it must wait for the new size and move in a final
# eval of its own, keeping the single-eval middle eval free of it.
setup_shrinking_rotation
run_layout --resized eDP-1 2880x1800 1.6 1800x2880 1.6 "2880x1800@90" 1
(( $(wc -l <"$eval_log") == 2 )) || fail "a shrinking rotation defers the closing-in neighbour" "$(cat "$eval_log")"
head -1 "$eval_log" | grep -Fq 'eDP-1' ||
  fail "the middle eval carries the resized monitor" "$(head -1 "$eval_log")"
head -1 "$eval_log" | grep -Fvq 'HDMI-A-1' ||
  fail "the middle eval waits out the closing-in neighbour" "$(head -1 "$eval_log")"
tail -1 "$eval_log" | grep -Fq 'HDMI-A-1' &&
  tail -1 "$eval_log" | grep -Fvq 'eDP-1' ||
  fail "the final eval moves only the closing-in neighbour" "$(tail -1 "$eval_log")"
pass "a shrinking rotation lets the neighbour in only after the new size"

# A flip within the same standing changes no size at all.
setup_shrinking_rotation
run_layout --resized eDP-1 2880x1800 1.6 2880x1800 1.6 "2880x1800@90" 0
(( $(wc -l <"$eval_log") == 1 )) || fail "a same-size flip stays a single eval" "$(cat "$eval_log")"
pass "a same-size flip stays a single eval"

# A plain resolution growth covers the neighbour just the same.
cat >"$monitors_json" <<'JSON'
[
  {"name": "eDP-1", "width": 2880, "height": 1800, "x": 0, "y": 0, "scale": 1.6, "transform": 0, "refreshRate": 90.0, "disabled": false, "mirrorOf": "none"},
  {"name": "HDMI-A-1", "width": 1920, "height": 1080, "x": 1800, "y": 0, "scale": 1, "transform": 1, "refreshRate": 60.0, "disabled": false, "mirrorOf": "none"}
]
JSON
run_layout --resized eDP-1 2880x1800 1.6 3840x2400 1.6
(( $(wc -l <"$eval_log") == 2 )) || fail "a resolution growth moves the covered neighbour out first" "$(cat "$eval_log")"
pass "a resolution growth moves the covered neighbour out first"

# When the compositor never lands the pre-move, the layout still goes ahead
# after the bounded wait instead of hanging.
setup_growing_rotation
APPLY_EVALS=false OMARCHY_LAYOUT_WAIT_TRIES=3 run_layout --resized eDP-1 2880x1800 1.6 1800x2880 1.6 "2880x1800@90" 2
(( $(wc -l <"$eval_log") == 2 )) || fail "an unconfirmed pre-move still falls through to the layout eval"
pass "an unconfirmed pre-move falls through after the bounded wait"
