#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin" "$test_tmp/runtime"

# Hyprland answers from the JSON each case writes. The cursor rests on the
# scratchpad window, which floats over the tiled one.
cat >"$fake_bin/hyprctl" <<'STUB'
#!/bin/bash
case "$*" in
"monitors -j") cat "$OMARCHY_TEST_MONITORS" ;;
"clients -j") cat "$OMARCHY_TEST_CLIENTS" ;;
cursorpos) printf '1500, 300\n' ;;
esac
STUB

# slurp records the rectangles it was offered. Asked to, it is dismissed the
# way the take-window bind dismisses it, so the picker resolves the window
# under the cursor itself.
cat >"$fake_bin/slurp" <<'STUB'
#!/bin/bash
cat >"$OMARCHY_TEST_SLURP_INPUT"
if [[ -n ${OMARCHY_TEST_TAKE_WINDOW:-} ]]; then
  touch "$XDG_RUNTIME_DIR/omarchy-capture-region-window"
fi
STUB

printf '#!/bin/bash\n' >"$fake_bin/hyprpicker"
chmod +x "$fake_bin/hyprctl" "$fake_bin/slurp" "$fake_bin/hyprpicker"

monitors() {
  cat >"$test_tmp/monitors.json" <<JSON
[{"name":"eDP-1","focused":true,"x":0,"y":0,"width":2820,"height":1880,"scale":1,"transform":0,
  "activeWorkspace":{"id":1,"name":"1"},"specialWorkspace":{"id":$1,"name":"$2"}}]
JSON
}

cat >"$test_tmp/clients.json" <<'JSON'
[{"workspace":{"id":1,"name":"1"},"hidden":false,"at":[1366,0],"size":[1410,940]},
 {"workspace":{"id":-98,"name":"special:scratchpad"},"hidden":false,"at":[1367,28],"size":[1408,911]},
 {"workspace":{"id":-97,"name":"special:other"},"hidden":false,"at":[10,10],"size":[500,500]}]
JSON

slurp_input="$test_tmp/slurp-input"

capture_region() {
  PATH="$fake_bin:$PATH" \
  XDG_RUNTIME_DIR="$test_tmp/runtime" \
  OMARCHY_TEST_MONITORS="$test_tmp/monitors.json" \
  OMARCHY_TEST_CLIENTS="$test_tmp/clients.json" \
  OMARCHY_TEST_SLURP_INPUT="$slurp_input" \
    bash "$ROOT/bin/omarchy-capture-region" "$@"
}

monitors -98 "special:scratchpad"
capture_region windows >/dev/null || true
grep -Fxq '1367,28 1408x911' "$slurp_input" || fail "the shown scratchpad's window is offered" "$(<"$slurp_input")"
grep -Fxq '1366,0 1410x940' "$slurp_input" || fail "the window under the scratchpad is still offered" "$(<"$slurp_input")"
if grep -Fxq '10,10 500x500' "$slurp_input"; then
  fail "a closed special workspace's window is not offered" "$(<"$slurp_input")"
fi
pass "the picker offers the windows of a shown special workspace"

picked=$(OMARCHY_TEST_TAKE_WINDOW=1 capture_region windows)
[[ $picked == "1367,28 1408x911" ]] || fail "taking the window under the cursor picks the scratchpad on top" "$picked"
pass "taking the window under the cursor picks the scratchpad window on top"

monitors 0 ""
capture_region windows >/dev/null || true
grep -Fxq '1366,0 1410x940' "$slurp_input" || fail "the workspace's window is offered" "$(<"$slurp_input")"
if grep -Fq 'x911' "$slurp_input" || grep -Fq '500x500' "$slurp_input"; then
  fail "closed special workspaces' windows are not offered" "$(<"$slurp_input")"
fi
pass "windows of closed special workspaces are not offered"
