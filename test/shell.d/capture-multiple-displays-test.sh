#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
require_command jq

# Load the rectangle helpers without starting the interactive picker.
source <(sed '/^if \[\[ ${1:-} == "--take-fullscreen"/,$d' "$ROOT/bin/omarchy-capture-region")

hyprctl() {
  case "$1" in
  monitors)
    cat <<'JSON'
[{"focused":true,"x":0,"y":0,"width":2880,"height":1800,"scale":2,"transform":0,"activeWorkspace":{"id":1},"specialWorkspace":{"id":0}},
 {"focused":false,"x":-1920,"y":-200,"width":1920,"height":1080,"scale":1,"transform":0,"activeWorkspace":{"id":6},"specialWorkspace":{"id":-99}}]
JSON
    ;;
  clients)
    cat <<'JSON'
[{"workspace":{"id":1},"at":[10,20],"size":[700,800]},
 {"workspace":{"id":6},"at":[-1900,-180],"size":[900,1000]},
 {"workspace":{"id":6},"at":[-1900,-180],"size":[900,1000]},
 {"workspace":{"id":2},"at":[100,100],"size":[400,400]},
 {"workspace":{"id":6},"hidden":true,"at":[200,200],"size":[300,300]},
 {"workspace":{"id":-99},"at":[-1000,0],"size":[500,500]},
 {"workspace":{"id":-98},"at":[300,300],"size":[200,200]}]
JSON
    ;;
  esac
}

actual=$(window_rects)
expected=$(printf '%s\n' '-1000,0 500x500' '-1900,-180 900x1000' '10,20 700x800')
[[ $actual == "$expected" ]] || fail "visible windows from every display, without hidden or duplicate rectangles" "$actual"
pass "visible windows from every display, without hidden or duplicate rectangles"
actual=$(monitor_rects)
[[ $actual == $'0,0 1440x900\n-1920,-200 1920x1080' ]] || fail "all display rectangles retain logical scale and negative origins" "$actual"
pass "all display rectangles retain logical scale and negative origins"
[[ $(focused_monitor_geo) == "0,0 1440x900" ]] || fail "fullscreen still targets focused display"
pass "fullscreen still targets focused display"
resolve_rect_at -1800 -100 < <(window_rects)
[[ $RESOLVED_RECT == '-1900,-180 900x1000' ]] || fail "click resolves a window on the unfocused display"
pass "click resolves a window on the unfocused display"
