#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fan_setter="$ROOT/bin/omarchy-theme-set-fan-framework-desktop"
fan_dispatcher="$ROOT/bin/omarchy-theme-set-fan"
wrapper="$ROOT/bin/omarchy-framework-tool-rgb"
install_script="$ROOT/install/hardware/framework/desktop-argb.sh"
migration="$ROOT/migrations/1785698076.sh"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-framework-tool"

# Exactly one rule, matched whole. Dropping the argument -- which sudoers reads
# as "any arguments" -- or appending a second line would widen the grant while
# leaving a substring check green.
rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == '%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-framework-tool-rgb' ]] ||
  fail "sudoers file carries exactly the wrapper rule and nothing else" "got: $rules"

! grep -F 'NOPASSWD: /usr/bin/framework_tool' "$sudoers_file" >/dev/null ||
  fail "sudoers rule does not expose the raw framework_tool binary"

if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "sudoers rule parses"
fi

grep -F 'omarchy-pkg-add framework-system' "$install_script" >/dev/null ||
  fail "framework desktop install script installs the framework-system package"

! grep -F '/etc/sudoers.d/' "$install_script" >/dev/null ||
  fail "install script does not hand-write sudoers (package owns the rule)"

grep -E '^# omarchy:summary=' "$fan_setter" >/dev/null ||
  fail "fan setter has command metadata summary"

grep -E '^# omarchy:summary=' "$fan_dispatcher" >/dev/null ||
  fail "fan dispatcher has command metadata summary"

grep -E '^# omarchy:summary=' "$ROOT/bin/omarchy-hw-framework-desktop" >/dev/null ||
  fail "framework desktop hardware detection has command metadata summary"

grep -E '^# omarchy:summary=' "$wrapper" >/dev/null ||
  fail "RGB wrapper has command metadata summary"

# The setter's use of the packaged wrapper through non-interactive sudo is
# asserted behaviourally below (assert_rgb_applied), not by reading source text.
! grep -F 'sudo framework_tool' "$fan_setter" >/dev/null ||
  fail "fan setter does not invoke the raw framework_tool via sudo"

! grep -F '/etc/sudoers.d/' "$fan_setter" >/dev/null ||
  fail "fan setter does not manage sudoers (relies on shipping rule)"

# --- Wrapper root hygiene (same privilege class as browser-policy) ---
grep -F 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin' "$wrapper" >/dev/null ||
  fail "RGB wrapper pins PATH to system directories when root"

grep -F 'PACKAGED_PATH=/usr/bin/omarchy-framework-tool-rgb' "$wrapper" >/dev/null ||
  fail "RGB wrapper knows the packaged path"

grep -F 'exec "$PACKAGED_PATH" "$@"' "$wrapper" >/dev/null ||
  fail "RGB wrapper re-execs the packaged copy when root"

grep -F 'exec /usr/bin/framework_tool --rgbkbd 0' "$wrapper" >/dev/null ||
  fail "RGB wrapper forwards only the --rgbkbd operation"

grep -E '\$# != 10' "$wrapper" >/dev/null ||
  fail "RGB wrapper rejects argument counts other than exact 10"

grep -E '\^0x\[0-9a-fA-F\]\{6\}\$' "$wrapper" >/dev/null ||
  fail "RGB wrapper validates each color as 0xRRGGBB"

grep -F 'source "$CALIBRATION_FILE"' "$fan_setter" >/dev/null &&
  fail "fan setter does not source the user calibration file"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --- Wrapper unit invocations ---
# Run a copy pointed at a stub framework_tool and at itself for PACKAGED_PATH so
# a root test run does not re-exec the real /usr/bin copy.
wrapper_fixture="$tmpdir/wrapper"
mkdir -p "$wrapper_fixture"

framework_tool_stub="$wrapper_fixture/framework_tool"
cat >"$framework_tool_stub" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$FRAMEWORK_TOOL_LOG"
exit 0
STUB
chmod +x "$framework_tool_stub"

wrapper_copy="$wrapper_fixture/omarchy-framework-tool-rgb"
sed -e "s#^PACKAGED_PATH=.*#PACKAGED_PATH=$wrapper_copy#" \
  -e "s#/usr/bin/framework_tool#$framework_tool_stub#" \
  "$wrapper" >"$wrapper_copy"
chmod +x "$wrapper_copy"

FRAMEWORK_TOOL_LOG="$wrapper_fixture/args.log"
export FRAMEWORK_TOOL_LOG

good_colors=(0x112233 0x445566 0x778899 0xaabbcc 0xddeeff 0x010203 0x040506 0x070809)

rm -f "$FRAMEWORK_TOOL_LOG"
if ! bash "$wrapper_copy" --rgbkbd 0 "${good_colors[@]}"; then
  fail "wrapper accepts --rgbkbd 0 with eight colors" "exit: $?"
fi
[[ -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper forwards good argv to framework_tool" "stub was not invoked"
[[ $(cat "$FRAMEWORK_TOOL_LOG") == "--rgbkbd 0 ${good_colors[*]}" ]] ||
  fail "wrapper forwards good argv unchanged" "got: $(cat "$FRAMEWORK_TOOL_LOG")"
pass "wrapper accepts --rgbkbd 0 with eight colors"

rm -f "$FRAMEWORK_TOOL_LOG"
if bash "$wrapper_copy" --rgbkbd 0 0x112233 0x445566 0x778899 2>/dev/null; then
  fail "wrapper rejects wrong arity (too few colors)"
fi
[[ ! -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper does not call framework_tool on wrong arity"
pass "wrapper rejects wrong arity (too few colors)"

rm -f "$FRAMEWORK_TOOL_LOG"
if bash "$wrapper_copy" --rgbkbd 0 0x112233 0x445566 0x778899 0xaabbcc 0xddeeff 0x010203 0x040506 0x070809 0x080910 2>/dev/null; then
  fail "wrapper rejects wrong arity (too many colors)"
fi
[[ ! -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper does not call framework_tool on extra argv"
pass "wrapper rejects wrong arity (too many colors)"

rm -f "$FRAMEWORK_TOOL_LOG"
if bash "$wrapper_copy" --rgbkbd 0 nothex 0x445566 0x778899 0xaabbcc 0xddeeff 0x010203 0x040506 0x070809 2>/dev/null; then
  fail "wrapper rejects an invalid color"
fi
[[ ! -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper does not call framework_tool with an invalid color"
pass "wrapper rejects an invalid color"

rm -f "$FRAMEWORK_TOOL_LOG"
if bash "$wrapper_copy" --kblight 0 "${good_colors[@]}" 2>/dev/null; then
  fail "wrapper rejects operations other than --rgbkbd"
fi
[[ ! -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper does not forward non-RGB operations"
pass "wrapper rejects operations other than --rgbkbd"

rm -f "$FRAMEWORK_TOOL_LOG"
if bash "$wrapper_copy" --rgbkbd 1 "${good_colors[@]}" 2>/dev/null; then
  fail "wrapper rejects a start key other than 0"
fi
[[ ! -f $FRAMEWORK_TOOL_LOG ]] || fail "wrapper does not forward a non-zero start key"
pass "wrapper rejects a start key other than 0"

# --- Setter behavior (override validation, calibration parsing, apply) ---
setter_home="$tmpdir/home"
mkdir -p "$setter_home/.local/state/omarchy/current/theme" \
  "$setter_home/.config/omarchy/fan-colors" \
  "$setter_home/stubs"

cat >"$setter_home/stubs/omarchy-hw-framework-desktop" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$setter_home/stubs/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$setter_home/stubs/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$SUDO_LOG"
exit 0
STUB
chmod +x "$setter_home"/stubs/*

SUDO_LOG="$setter_home/sudo.log"
export SUDO_LOG

run_setter() {
  rm -f "$SUDO_LOG"
  set +e
  HOME="$setter_home" \
    PATH="$setter_home/stubs:$PATH" \
    SUDO_LOG="$SUDO_LOG" \
    bash "$fan_setter" >"$setter_home/stdout" 2>"$setter_home/stderr"
  setter_status=$?
  set -e
}

assert_rgb_applied() {
  local color="$1"
  local description="$2"
  local expected="${3:-1}"
  local log count

  [[ -s $SUDO_LOG ]] || fail "$description" "wrapper was not invoked\nstderr: $(cat "$setter_home/stderr")"

  log=$(cat "$SUDO_LOG")
  [[ $log == "-n /usr/bin/omarchy-framework-tool-rgb --rgbkbd 0 "* ]] ||
    fail "$description" "expected non-interactive sudo to the packaged wrapper: $log"

  count=$(grep -o "$color" "$SUDO_LOG" | wc -l || true)
  [[ $count -eq $expected ]] || fail "$description" "expected ${expected}x $color, got $count in: $log"
  pass "$description"
}

assert_rgb_skipped() {
  local description="$1"

  [[ ! -s $SUDO_LOG ]] || fail "$description" "wrapper should not run: $(cat "$SUDO_LOG")"
  pass "$description"
}

theme_name="test-theme"
printf '%s' "$theme_name" >"$setter_home/.local/state/omarchy/current/theme.name"
override_file="$setter_home/.config/omarchy/fan-colors/${theme_name}.txt"

# Single override color repeats across all eight zones.
printf '#ff4d00\n' >"$override_file"
run_setter
[[ $setter_status -eq 0 ]] || fail "single-color override exits 0" "status: $setter_status, stderr: $(cat "$setter_home/stderr")"
assert_rgb_applied "0xff4d00" "single override color fills all eight zones" 8

# Eight override colors are applied in order, blanks and comments ignored.
cat >"$override_file" <<'EOF'
# comment

#112233
#445566
#778899
#aabbcc
#ddeeff
#010203
#040506
#070809
EOF
run_setter
[[ $setter_status -eq 0 ]] || fail "eight-color override exits 0" "status: $setter_status, stderr: $(cat "$setter_home/stderr")"
assert_rgb_applied "0x070809" "comments and blank lines are ignored in override"
[[ $(cat "$SUDO_LOG") == *"0x112233 0x445566 0x778899 0xaabbcc 0xddeeff 0x010203 0x040506 0x070809"* ]] ||
  fail "override colors are applied in order" "got: $(cat "$SUDO_LOG")"
pass "override colors are applied in order"

# A malformed override is reported and nothing is applied.
printf '#ff4d00\n#zzzzzz\n' >"$override_file"
run_setter
[[ $setter_status -ne 0 ]] || fail "invalid override color exits non-zero" "status: $setter_status"
assert_rgb_skipped "invalid override color is not applied"

# Two to seven colors are ambiguous and rejected.
printf '#ff4d00\n#00ff00\n' >"$override_file"
run_setter
[[ $setter_status -ne 0 ]] || fail "ambiguous override count exits non-zero" "status: $setter_status"
assert_rgb_skipped "ambiguous override count is not applied"

# Calibration parses KEY=VAL and ignores comments and arbitrary shell.
rm -f "$override_file"
printf '#23103f\n' >"$setter_home/.local/state/omarchy/current/theme/framework-desktop-fan.rgb"
cat >"$setter_home/.config/omarchy/fan-colors/calibration.conf" <<'EOF'
# comment
RED_PERCENT=100
GREEN_PERCENT=50
BLUE_PERCENT=100
IGNORED_KEY=200
touch "$HOME/pwned"
EOF
run_setter
[[ $setter_status -eq 0 ]] || fail "theme color with calibration exits 0" "status: $setter_status, stderr: $(cat "$setter_home/stderr")"
# #23103f: r=0x23=35, g=0x10*50/100=8, b=0x3f=63 -> 0x23083f
assert_rgb_applied "0x23083f" "calibration.conf is parsed, not sourced" 8
[[ ! -e $setter_home/pwned ]] || fail "calibration.conf is not executed as shell"
pass "calibration.conf is not executed as shell"

# An invalid theme color is reported instead of failing arithmetic.
printf 'not-a-color\n' >"$setter_home/.local/state/omarchy/current/theme/framework-desktop-fan.rgb"
run_setter
[[ $setter_status -ne 0 ]] || fail "invalid theme color exits non-zero" "status: $setter_status"
assert_rgb_skipped "invalid theme color is not applied"

# A missing sudoers grant is surfaced, not hidden.
cat >"$setter_home/stubs/sudo" <<'STUB'
#!/bin/bash
echo "sudo: a password is required" >&2
exit 1
STUB
chmod +x "$setter_home/stubs/sudo"
printf '#23103f\n' >"$setter_home/.local/state/omarchy/current/theme/framework-desktop-fan.rgb"
run_setter
[[ $setter_status -ne 0 ]] || fail "failed privileged call exits non-zero" "status: $setter_status"
grep -q 'failed to set fan RGB' "$setter_home/stderr" ||
  fail "failed privileged call is reported on stderr" "stderr: $(cat "$setter_home/stderr")"
pass "failed privileged call is reported on stderr"

# --- Migration execution (idempotent, fake HOME, sandboxed sudoers dir) ---
# The migration hardcodes /etc/sudoers.d. Redirect that to a temp directory so
# the test never touches the host, then run it with a stub sudo that executes
# the command in place.
migration_home="$tmpdir/migration-home"
migration_sudoers="$tmpdir/migration-sudoers"
migration_bin="$tmpdir/migration-bin"
mkdir -p "$migration_home" "$migration_sudoers" "$migration_bin"

migration_copy="$tmpdir/migration.sh"
sed "s#/etc/sudoers.d#$migration_sudoers#g" "$migration" >"$migration_copy"

cat >"$migration_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$PKG_LOG"
STUB

cat >"$migration_bin/omarchy-hw-framework-desktop" <<'STUB'
#!/bin/bash
exit "${STUB_FRAMEWORK_DESKTOP:-0}"
STUB

cat >"$migration_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_LOG_MIG"
"$@"
STUB
chmod +x "$migration_bin"/*

PKG_LOG="$tmpdir/pkg.log"
SUDO_LOG_MIG="$tmpdir/migration-sudo.log"
export PKG_LOG SUDO_LOG_MIG

run_migration() {
  set +e
  HOME="$migration_home" PATH="$migration_bin:$PATH" \
    PKG_LOG="$PKG_LOG" SUDO_LOG_MIG="$SUDO_LOG_MIG" \
    STUB_FRAMEWORK_DESKTOP="${STUB_FRAMEWORK_DESKTOP:-0}" \
    bash -euo pipefail "$migration_copy" >"$tmpdir/migration.out" 2>&1
  migration_status=$?
  set -e
}

# A legacy raw-framework_tool rule must be removed, not renamed, and the
# canonical wrapper rule installed with the sudoers-friendly mode.
printf '%%wheel ALL=(root) NOPASSWD: /usr/bin/framework_tool\n' >"$migration_sudoers/framework-tool"
: >"$PKG_LOG"
: >"$SUDO_LOG_MIG"
run_migration
[[ $migration_status -eq 0 ]] ||
  fail "migration runs on Framework Desktop" "status: $migration_status, output: $(cat "$tmpdir/migration.out")"
grep -qx 'framework-system' "$PKG_LOG" || fail "migration installs framework-system"
[[ ! -e $migration_sudoers/framework-tool ]] || fail "migration removes the legacy rule"
rules=$(grep -vE '^[[:space:]]*(#|$)' "$migration_sudoers/omarchy-framework-tool")
[[ $rules == '%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-framework-tool-rgb' ]] ||
  fail "migration writes exactly the canonical rule" "got: $rules"
[[ $(stat -c '%a' "$migration_sudoers/omarchy-framework-tool") == 440 ]] ||
  fail "migration sets the canonical rule mode to 440"
if command -v visudo >/dev/null; then
  visudo -cf "$migration_sudoers/omarchy-framework-tool" >/dev/null || fail "migration's rule parses"
fi
pass "migration installs the package and writes the canonical rule"

# Second run is a no-op: the canonical rule already exists, so it is not rewritten.
: >"$SUDO_LOG_MIG"
run_migration
[[ $migration_status -eq 0 ]] ||
  fail "migration is idempotent" "status: $migration_status, output: $(cat "$tmpdir/migration.out")"
! grep -q 'tee' "$SUDO_LOG_MIG" ||
  fail "migration does not rewrite an existing canonical rule" "ran: $(cat "$SUDO_LOG_MIG")"
rules=$(grep -vE '^[[:space:]]*(#|$)' "$migration_sudoers/omarchy-framework-tool")
[[ $rules == '%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-framework-tool-rgb' ]] ||
  fail "migration leaves the canonical rule intact on rerun" "got: $rules"
pass "migration is idempotent"

# Non-Framework hardware is left alone.
: >"$PKG_LOG"
: >"$SUDO_LOG_MIG"
STUB_FRAMEWORK_DESKTOP=1 run_migration
[[ $migration_status -eq 0 ]] ||
  fail "migration no-ops off Framework Desktop" "status: $migration_status"
[[ ! -s $PKG_LOG ]] || fail "migration installs nothing off Framework Desktop" "$(cat "$PKG_LOG")"
[[ ! -s $SUDO_LOG_MIG ]] || fail "migration touches no sudoers off Framework Desktop" "$(cat "$SUDO_LOG_MIG")"
pass "migration no-ops off Framework Desktop"
