#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
rects_log="$tmp_dir/rects"
mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

case $1 in
monitors)
  printf '%s\n' '[{"focused":true,"activeWorkspace":{"id":7},"x":0,"y":0,"width":1920,"height":1080,"scale":1,"transform":0}]'
  ;;
clients)
  printf '%s\n' "$OMARCHY_TEST_CLIENTS"
  ;;
esac
SH

cat >"$stub_bin/hyprpicker" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/slurp" <<'SH'
#!/bin/bash

rects=$(cat)
printf '%s\n' "$rects" >"$OMARCHY_TEST_RECTS_LOG"
printf '%s\n' "$rects" | head -1
SH

chmod +x "$stub_bin/hyprctl" "$stub_bin/hyprpicker" "$stub_bin/slurp"

capture_rects() {
  local clients=$1

  OMARCHY_TEST_CLIENTS="$clients" \
  OMARCHY_TEST_RECTS_LOG="$rects_log" \
  XDG_RUNTIME_DIR="$tmp_dir" \
  PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-capture-region" windows >/dev/null

  cat "$rects_log"
}

assert_rects() {
  local clients=$1 expected=$2 description=$3
  local actual

  actual=$(capture_rects "$clients")
  if [[ $actual == "$expected" ]]; then
    pass "$description"
  else
    fail "$description" "expected:\n$expected\nactual:\n$actual"
  fi
}

monitor_rect='0,0 1920x1080'

ordinary_clients='[
  {"workspace":{"id":7},"at":[0,30],"size":[900,1050],"hidden":false,"visible":true},
  {"workspace":{"id":7},"at":[920,30],"size":[1000,1050],"hidden":false,"visible":true},
  {"workspace":{"id":7},"at":[50,50],"size":[300,200],"hidden":true,"visible":false},
  {"workspace":{"id":6},"at":[10,10],"size":[400,300],"hidden":false,"visible":true}
]'
assert_rects "$ordinary_clients" "$monitor_rect
0,30 900x1050
920,30 1000x1050" "ordinary workspaces offer every visible window"

maximized_clients='[
  {"workspace":{"id":7},"at":[0,30],"size":[900,1050],"hidden":false,"visible":false},
  {"workspace":{"id":7},"at":[0,30],"size":[1920,1050],"hidden":false,"visible":true},
  {"workspace":{"id":7},"at":[700,300],"size":[500,400],"hidden":false,"visible":true},
  {"workspace":{"id":7},"at":[100,100],"size":[400,300],"hidden":false,"visible":false}
]'
assert_rects "$maximized_clients" "$monitor_rect
0,30 1920x1050
700,300 500x400" "a maximized window keeps only clients Hyprland reports as visible"

fullscreen_clients='[
  {"workspace":{"id":7},"at":[0,30],"size":[900,1050],"hidden":false,"visible":false},
  {"workspace":{"id":7},"at":[0,0],"size":[1920,1080],"hidden":false,"visible":true},
  {"workspace":{"id":7},"at":[700,300],"size":[500,400],"hidden":false,"visible":false}
]'
assert_rects "$fullscreen_clients" "$monitor_rect
$monitor_rect" "a fullscreen window hides covered window rectangles"
