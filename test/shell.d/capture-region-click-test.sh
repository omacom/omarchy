#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

# A 1920x1080 monitor with two tiled windows side by side and a floating window
# over the left one, and a second monitor left of it holding one window.
# OMARCHY_TEST_FOCUS picks which monitor is focused.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

focus=${OMARCHY_TEST_FOCUS:-DP-1}

case "$*" in
"monitors -j")
  printf '%s\n' '[
    {"name":"DP-1","x":0,"y":0,"width":1920,"height":1080,"scale":1,"transform":0,"activeWorkspace":{"id":1}},
    {"name":"DP-2","x":-1920,"y":0,"width":1920,"height":1080,"scale":1,"transform":0,"activeWorkspace":{"id":2}}
  ]' | jq --arg focus "$focus" '.[] |= . + {focused: (.name == $focus)}'
  ;;
"clients -j")
  printf '%s\n' '[
    {"at":[10,40],"size":[945,1030],"workspace":{"id":1},"hidden":false},
    {"at":[965,40],"size":[945,1030],"workspace":{"id":1},"hidden":false},
    {"at":[200,200],"size":[300,200],"workspace":{"id":1},"hidden":false},
    {"at":[-1910,40],"size":[1900,1030],"workspace":{"id":2},"hidden":false}
  ]'
  ;;
esac
SH

# slurp prints what the test hands it. A click that moves while the button is
# down comes back from slurp as a tiny drag rather than the highlighted box.
cat >"$stub_bin/slurp" <<'SH'
#!/bin/bash

cat >/dev/null
printf '%s\n' "$OMARCHY_TEST_SLURP_SELECTION"
SH

cat >"$stub_bin/hyprpicker" <<'SH'
#!/bin/bash

exec sleep 30
SH

chmod +x "$stub_bin"/*
export PATH="$stub_bin:$PATH"
export XDG_RUNTIME_DIR="$tmp_dir"

pick_smart() {
  OMARCHY_TEST_SLURP_SELECTION=$1 "$ROOT/bin/omarchy-capture-region" smart
}

assert_pick() {
  local description=$1 selection=$2 expected=$3
  local actual

  actual=$(pick_smart "$selection") || fail "$description" "omarchy-capture-region exited non-zero"
  [[ $actual == "$expected" ]] || fail "$description" "expected '$expected', got '$actual'"
  pass "$description"
}

assert_pick "a jittered click on a tiled window snaps to that window, not the monitor" "300,600 2x2" "10,40 945x1030"
assert_pick "a jittered click on the right-hand window snaps to it" "1500,500 3x3" "965,40 945x1030"
assert_pick "a jittered click on a floating window snaps to it rather than the window beneath" "250,250 1x1" "200,200 300x200"
assert_pick "a jittered click in a gap between windows snaps to the monitor" "5,5 1x1" "0,0 1920x1080"
OMARCHY_TEST_FOCUS=DP-2 assert_pick "a jittered click on a monitor at negative coordinates snaps to the window there" "-1500,500 2x2" "-1910,40 1900x1030"
assert_pick "a drag is kept as drawn" "100,100 400x300" "100,100 400x300"
