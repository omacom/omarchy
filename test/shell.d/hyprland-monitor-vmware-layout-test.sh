#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
fixture="$test_tmp/modetest.out"
modetest_log="$test_tmp/modetest.log"
modetest_fail="$test_tmp/modetest-fails"
drm="$test_tmp/drm"
mkdir -p "$fake_bin" "$drm"

# modetest answers with the fixture the case under test wrote, or fails when
# the flag file is present, as it does on a guest without the vmwgfx driver.
cat >"$fake_bin/modetest" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$OMARCHY_TEST_MODETEST_LOG"
[[ -f $OMARCHY_TEST_MODETEST_FAIL_FLAG ]] && exit 1
cat "$OMARCHY_TEST_MODETEST_FIXTURE"
SH
chmod +x "$fake_bin/modetest"

# One connector block in modetest's own shape: a tab-separated header line, a
# trimmed modes block, the DPMS property every driver carries, and the two
# suggested offsets only when a position is given, since only vmwgfx has them.
connector() {
  local id="$1" status="$2" name="$3" x="${4:-}" y="${5:-}"

  printf '%s\t%s\t%s\t%-15s\t0x0\t\t1\t%s\n' "$id" "$((id + 1))" "$status" "$name" "$((id + 1))"
  printf '  modes:\n'
  printf '\tindex name refresh (Hz) hdisp hss hse htot vdisp vss vse vtot\n'
  printf '  #0 1920x1080 60.00 1920 1970 2020 2070 1080 1130 1180 1230 152766 flags: nhsync, pvsync; type: preferred, driver\n'
  printf '  props:\n'
  printf '\t2 DPMS:\n'
  printf '\t\tflags: enum\n'
  printf '\t\tenums: On=0 Standby=1 Suspend=2 Off=3\n'
  printf '\t\tvalue: 0\n'
  if [[ -n $x ]]; then
    printf '\t35 suggested X:\n'
    printf '\t\tflags: immutable range\n'
    printf '\t\tvalues: 0 4294967295\n'
    printf '\t\tvalue: %s\n' "$x"
    printf '\t36 suggested Y:\n'
    printf '\t\tflags: immutable range\n'
    printf '\t\tvalues: 0 4294967295\n'
    printf '\t\tvalue: %s\n' "$y"
  fi
}

header() {
  printf 'Connectors:\n'
  printf 'id\tencoder\tstatus\t\tname\t\tsize (mm)\tmodes\tencoders\n'
}

# The sysfs modes file for a connector, first line being the preferred mode.
modes() {
  local name="$1"
  shift

  mkdir -p "$drm/card0-$name"
  printf '%s\n' "$@" >"$drm/card0-$name/modes"
}

run_layout() {
  : >"$modetest_log"
  PATH="$fake_bin:$PATH" \
  OMARCHY_DRM_CLASS_PATH="$drm" \
  OMARCHY_TEST_MODETEST_FIXTURE="$fixture" \
  OMARCHY_TEST_MODETEST_LOG="$modetest_log" \
  OMARCHY_TEST_MODETEST_FAIL_FLAG="$modetest_fail" \
    "$ROOT/bin/omarchy-hyprland-monitor-vmware-layout"
}

reset_drm() {
  rm -rf "$drm"
  mkdir -p "$drm"
}

# The layout a live guest was given for four host monitors, plus the spare
# connector vmwgfx keeps around disconnected.
{
  header
  connector 44 connected Virtual-1 1920 1
  connector 53 connected Virtual-2 1912 1081
  connector 62 connected Virtual-3 0 0
  connector 71 connected Virtual-4 3840 0
  connector 80 disconnected Virtual-5 0 0
} >"$fixture"
for name in Virtual-1 Virtual-2 Virtual-3 Virtual-4; do
  modes "$name" 1920x1080 1280x720
done

expected=$(printf '%s\n' \
  "Virtual-1 1920 1 1920x1080" \
  "Virtual-2 1912 1081 1920x1080" \
  "Virtual-3 0 0 1920x1080" \
  "Virtual-4 3840 0 1920x1080")
actual=$(run_layout) || fail "the layout reads cleanly" "exit $?"
[[ $actual == "$expected" ]] || fail "the four-monitor host layout prints one line per connected output" "$actual"
pass "the four-monitor host layout prints one line per connected output"

[[ $(<"$modetest_log") == "-M vmwgfx -c" ]] || fail "the vmwgfx connectors are asked for" "$(<"$modetest_log")"
pass "the vmwgfx connectors are asked for"

# A connector of another driver has no suggested offsets and no place in the
# host layout.
reset_drm
{
  header
  connector 30 connected eDP-1
} >"$fixture"
modes eDP-1 2560x1600
actual=$(run_layout) || fail "a connector without suggested offsets reads cleanly" "exit $?"
[[ -z $actual ]] || fail "a connector without suggested offsets prints nothing" "$actual"
pass "a connector without suggested offsets prints nothing"

# modetest's third status. A connector in that state starts its own block, so
# its offsets cannot be taken for the connected connector printed before it.
reset_drm
{
  header
  connector 44 connected Virtual-1 1920 0
  connector 53 unknown Virtual-2 0 0
} >"$fixture"
modes Virtual-1 1920x1080
modes Virtual-2 1920x1080
actual=$(run_layout) || fail "an unknown connector reads cleanly" "exit $?"
[[ $actual == "Virtual-1 1920 0 1920x1080" ]] || fail "an unknown connector neither prints nor overwrites its neighbour" "$actual"
pass "an unknown connector neither prints nor overwrites its neighbour"

# No sysfs modes file means no size to report, and a line without one would
# be a rule Hyprland cannot apply.
reset_drm
{
  header
  connector 44 connected Virtual-1 0 0
} >"$fixture"
actual=$(run_layout) || fail "a connector without a modes file reads cleanly" "exit $?"
[[ -z $actual ]] || fail "a connected connector with no modes file prints nothing" "$actual"
pass "a connected connector with no modes file prints nothing"

# The first modes line is the preferred mode; one that is not plain WxH is
# not a size this can hand to a monitor rule.
reset_drm
modes Virtual-1 1920x1080i 1920x1080
actual=$(run_layout) || fail "an interlaced preferred mode reads cleanly" "exit $?"
[[ -z $actual ]] || fail "a preferred mode that is not WxH is skipped" "$actual"
pass "a preferred mode that is not WxH is skipped"

# The name ends up inside a Lua monitor rule and a sysfs path, so anything
# other than a plain connector name is refused before either.
reset_drm
{
  header
  connector 44 connected 'Virtual-1")os.execute("calc")--' 0 0
  connector 53 connected '../card0-Virtual-1' 1920 0
} >"$fixture"
modes Virtual-1 1920x1080
actual=$(run_layout) || fail "injection-shaped names read cleanly" "exit $?"
[[ -z $actual ]] || fail "injection-shaped connector names are refused" "$actual"
pass "injection-shaped connector names are refused"

# Without the vmwgfx driver modetest fails; that is not an empty layout.
reset_drm
{
  header
  connector 44 connected Virtual-1 0 0
} >"$fixture"
modes Virtual-1 1920x1080
touch "$modetest_fail"
status=0
actual=$(run_layout) || status=$?
rm -f "$modetest_fail"
(( status != 0 )) || fail "a failing modetest exits non-zero" "exit $status"
[[ -z $actual ]] || fail "a failing modetest prints nothing" "$actual"
pass "a failing modetest exits non-zero and prints nothing"
