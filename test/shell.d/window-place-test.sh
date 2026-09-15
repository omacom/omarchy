#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/monitors.json" <<'JSON'
[
  {"id":0,"name":"DP-1","x":1920,"y":0,"width":2560,"height":1440,"scale":1.0,"transform":0,"focused":false},
  {"id":1,"name":"eDP-1","x":0,"y":0,"width":1920,"height":1080,"scale":1.0,"transform":0,"focused":true}
]
JSON

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "-j" && $2 == "monitors" ]]; then
  cat "$MONITOR_JSON"
  exit 0
fi

if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  printf '{"floating":%s,"address":"0xTEST","at":[100,100],"size":[800,600]}\n' "${HYPR_FLOATING:-false}"
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

place() {
  PATH="$tmpdir:$PATH" HYPRCTL_LOG="$log" MONITOR_JSON="$tmpdir/monitors.json" \
    "$ROOT/bin/omarchy-hyprland-window-place" "$@"
}

: >"$log"
out=$(place left)
grep -Fq 'hl.dsp.window.float({ window = "address:0xTEST", action = "toggle" })' "$log" || fail "left floats a tiled window first"
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 942, y = 1056 })' "$log" || fail "left resizes to 942x1056"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 12, y = 12 })' "$log" || fail "left moves to 12,12"
[[ $out == *"12,12 942x1056"* ]] || fail "left prints its geometry" "$out"
pass "left places a 1920x1080 window at 12,12 942x1056"

: >"$log"
out=$(place right)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 942, y = 1056 })' "$log" || fail "right resizes to 942x1056"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 966, y = 12 })' "$log" || fail "right moves to 966,12"
[[ $out == *"966,12 942x1056"* ]] || fail "right prints its geometry" "$out"
pass "right places a 1920x1080 window at 966,12 942x1056"

: >"$log"
out=$(place center-half)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 948, y = 528 })' "$log" || fail "center-half resizes to 948x528"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 486, y = 276 })' "$log" || fail "center-half moves to 486,276"
[[ $out == *"486,276 948x528"* ]] || fail "center-half prints its geometry" "$out"
pass "center-half places a 1920x1080 window at 486,276 948x528"

: >"$log"
out=$(place center)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 800, y = 600 })' "$log" || fail "center keeps the 800x600 size"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 560, y = 240 })' "$log" || fail "center moves to 560,240"
pass "true center keeps size and centers"

: >"$log"
out=$(place left-third)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 624, y = 1056 })' "$log" || fail "left-third resizes to 624x1056"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 12, y = 12 })' "$log" || fail "left-third moves to 12,12"
pass "left-third geometry"

: >"$log"
out=$(place center-third)
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 648, y = 12 })' "$log" || fail "center-third moves to 648,12"
pass "center-third geometry"

: >"$log"
out=$(place right-third)
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 1284, y = 12 })' "$log" || fail "right-third moves to 1284,12"
pass "right-third geometry"

: >"$log"
out=$(place left-two-thirds)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 1260, y = 1056 })' "$log" || fail "left-two-thirds resizes to 1260x1056"
pass "left-two-thirds geometry"

: >"$log"
out=$(place right-two-thirds)
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 648, y = 12 })' "$log" || fail "right-two-thirds moves to 648,12"
pass "right-two-thirds geometry"

: >"$log"
out=$(place maximize-height)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 800, y = 1056 })' "$log" || fail "maximize-height keeps width, fills height"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 100, y = 12 })' "$log" || fail "maximize-height keeps x"
pass "maximize-height geometry"

: >"$log"
out=$(place maximize-width)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 1896, y = 600 })' "$log" || fail "maximize-width fills width, keeps height"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 12, y = 100 })' "$log" || fail "maximize-width keeps y"
pass "maximize-width geometry"

: >"$log"
out=$(place larger)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 920, y = 690 })' "$log" || fail "larger scales 800x600 up"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 40, y = 55 })' "$log" || fail "larger recenters to 40,55"
pass "larger geometry"

: >"$log"
out=$(place smaller)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 695, y = 521 })' "$log" || fail "smaller scales 800x600 down"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 152, y = 139 })' "$log" || fail "smaller recenters to 152,139"
pass "smaller geometry"

: >"$log"
out=$(place next-display)
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", monitor = "+1" })' "$log" || fail "next-display moves across monitors"
[[ $out == *"next-display"* ]] || fail "next-display prints confirmation" "$out"
pass "next-display dispatch"

: >"$log"
out=$(place prev-display)
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", monitor = "-1" })' "$log" || fail "prev-display moves across monitors"
pass "prev-display dispatch"

: >"$log"
out=$(place maximize)
grep -Fq 'hl.dsp.window.resize({ window = "address:0xTEST", x = 1896, y = 1056 })' "$log" || fail "maximize resizes to 1896x1056"
grep -Fq 'hl.dsp.window.move({ window = "address:0xTEST", x = 12, y = 12 })' "$log" || fail "maximize moves to 12,12"
[[ $out == *"12,12 1896x1056"* ]] || fail "maximize prints its geometry" "$out"
pass "maximize places a 1920x1080 window at 12,12 1896x1056"

: >"$log"
HYPR_FLOATING=true place right >/dev/null
if grep -Fq 'setfloating' "$log"; then
  fail "an already floating window is not re-floated"
fi
pass "an already floating window skips setfloating"

: >"$log"
out=$(place left --dry-run)
[[ -s $log ]] && fail "dry-run dispatches nothing" "$(cat "$log")"
[[ $out == *"12,12 942x1056"* ]] || fail "dry-run still prints the geometry" "$out"
pass "dry-run prints geometry without dispatching"

if place bogus 2>/dev/null; then
  fail "an unknown preset exits non-zero"
else
  code=$?
  ((code == 2)) || fail "an unknown preset exits 2" "exit $code"
  pass "an unknown preset exits 2"
fi

if place --help >/dev/null 2>&1; then
  pass "--help exits 0"
else
  fail "--help exits 0"
fi

for preset in left right center-half maximize left-third center-third right-third left-two-thirds right-two-thirds center maximize-height maximize-width next-display prev-display larger smaller; do
  grep -Fq "\"trigger.window.${preset}\":" "$ROOT/default/omarchy/omarchy-menu.jsonc" || \
    fail "menu has a ${preset} window row"
  grep -Fq "omarchy-hyprland-window-place ${preset}" "$ROOT/default/omarchy/omarchy-menu.jsonc" || \
    fail "menu ${preset} row runs window-place"
done
pass "menu has the full window placement rows"
