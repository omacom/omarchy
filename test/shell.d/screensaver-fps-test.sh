#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

screensaver="$ROOT/bin/omarchy-screensaver"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

grep -Fq 'frame_rate=${OMARCHY_SCREENSAVER_FRAME_RATE:-30}' "$screensaver" ||
  fail "screensaver defaults to 30fps instead of 120"
grep -Fq -- '--frame-rate "$frame_rate"' "$screensaver" ||
  fail "screensaver passes the resolved frame rate to ttfx"
if grep -Fq -- '--frame-rate 120' "$screensaver"; then
  fail "screensaver no longer hardcodes 120fps"
fi
pass "screensaver caps ttfx at 30fps by default"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/ttfx" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TTFX_ARGS"
exit 0
SH
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$stub_bin/jq" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin"/*

run_once() {
  local rate=$1
  local args=$2
  if [[ -n $rate ]]; then
    TEST_TTFX_ARGS="$args" OMARCHY_SCREENSAVER_FRAME_RATE="$rate" \
      PATH="$stub_bin:$PATH" timeout 2s bash "$screensaver" >/dev/null 2>&1 || true
  else
    TEST_TTFX_ARGS="$args" env -u OMARCHY_SCREENSAVER_FRAME_RATE \
      PATH="$stub_bin:$PATH" timeout 2s bash "$screensaver" >/dev/null 2>&1 || true
  fi
}

args_default="$test_tmp/ttfx-default.args"
run_once "" "$args_default"
grep -Fq -- '--frame-rate 30' "$args_default" ||
  fail "default frame rate is 30" "$(cat "$args_default" 2>/dev/null)"
pass "default OMARCHY_SCREENSAVER_FRAME_RATE is 30"

args_custom="$test_tmp/ttfx-custom.args"
run_once 45 "$args_custom"
grep -Fq -- '--frame-rate 45' "$args_custom" ||
  fail "custom frame rate is honored" "$(cat "$args_custom" 2>/dev/null)"
pass "OMARCHY_SCREENSAVER_FRAME_RATE overrides the default"

args_invalid="$test_tmp/ttfx-invalid.args"
run_once "fast" "$args_invalid"
grep -Fq -- '--frame-rate 30' "$args_invalid" ||
  fail "invalid frame rate falls back to 30" "$(cat "$args_invalid" 2>/dev/null)"
pass "invalid OMARCHY_SCREENSAVER_FRAME_RATE falls back to 30"

args_high="$test_tmp/ttfx-high.args"
run_once 240 "$args_high"
grep -Fq -- '--frame-rate 120' "$args_high" ||
  fail "frame rate clamps at 120" "$(cat "$args_high" 2>/dev/null)"
pass "OMARCHY_SCREENSAVER_FRAME_RATE clamps at 120"
