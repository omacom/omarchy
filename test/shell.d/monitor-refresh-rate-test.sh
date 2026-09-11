#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
monitors_file="$test_tmp/monitors.json"

mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  cat "$FAKE_MONITORS"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

# Hyprland lists a 144Hz panel's mode as 143.91Hz while reporting the driver's
# 143.912 as the live rate, so the fixture keeps that mismatch.
write_monitors() {
  printf '%s\n' "${1:-$default_monitors}" >"$monitors_file"
}

default_monitors='[
  {
    "name": "eDP-1",
    "focused": true,
    "scale": 2,
    "width": 2880,
    "height": 1800,
    "refreshRate": 60.00000,
    "availableModes": ["2880x1800@143.91Hz", "2880x1800@60.00Hz", "1920x1080@120.00Hz"]
  }
]'

run_refresh_rate() {
  rm -f "$eval_out"

  FAKE_MONITORS="$monitors_file" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-monitor-refresh-rate" "$@"
}

write_monitors
[[ $(run_refresh_rate) == "60" ]] || fail "monitor refresh rate reports the live rate"
pass "monitor refresh rate reports the live rate"

write_monitors
run_refresh_rate 144 >/dev/null
grep -F 'mode = "2880x1800@143.91"' "$eval_out" >/dev/null ||
  fail "monitor refresh rate snaps a whole-hertz request onto the real mode" "actual: $(cat "$eval_out")"
pass "monitor refresh rate snaps a whole-hertz request onto the real mode"

# The rate change must not disturb the scale; hl.monitor rewrites the whole
# output, so an omitted scale would silently reset it.
write_monitors
run_refresh_rate 144 >/dev/null
grep -F 'scale = 2' "$eval_out" >/dev/null || fail "monitor refresh rate keeps the current scale"
pass "monitor refresh rate keeps the current scale"

write_monitors
run_refresh_rate 60 >/dev/null
grep -F 'mode = "2880x1800@60"' "$eval_out" >/dev/null ||
  fail "monitor refresh rate applies an exact mode" "actual: $(cat "$eval_out")"
pass "monitor refresh rate applies an exact mode"

# 120Hz exists, but only at another resolution. Applying it would ask Hyprland
# to change the picture, not the rate.
write_monitors
if run_refresh_rate 120 2>/dev/null; then
  fail "monitor refresh rate refuses a rate the current mode cannot reach"
fi
[[ ! -s $eval_out ]] || fail "monitor refresh rate applies nothing when it refuses a rate"
pass "monitor refresh rate refuses a rate the current mode cannot reach"

write_monitors
if run_refresh_rate nope 2>/dev/null; then
  fail "monitor refresh rate rejects a non-numeric rate"
fi
pass "monitor refresh rate rejects a non-numeric rate"

write_monitors '[
  {
    "name": "eDP-1\"; os.execute(\"touch /tmp/pwned\"); --",
    "focused": true,
    "scale": 2,
    "width": 2880,
    "height": 1800,
    "refreshRate": 60.00000,
    "availableModes": ["2880x1800@60.00Hz"]
  }
]'
if run_refresh_rate 60 2>/dev/null; then
  fail "monitor refresh rate refuses an unsafe monitor name"
fi
[[ ! -s $eval_out ]] || fail "monitor refresh rate evaluates nothing for an unsafe monitor name"
pass "monitor refresh rate refuses an unsafe monitor name"
