#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const nightlight = requireFromRoot('shell/plugins/services/nightlight/NightlightModel.js')
const serviceSource = fs.readFileSync(root + '/shell/plugins/services/nightlight/Service.qml', 'utf8')
const runApply = serviceSource.match(/function runApply\(temp\) \{([\s\S]*?)\n  \}/)
const executableRunApply = runApply ? runApply[1].replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '') : ''

assert(/^\s*applyProcess\.command\s*=\s*NightlightModel\.applyCommand\(temp\)\s*$/m.test(executableRunApply), 'nightlight service delegates its apply process to the tested model command')
assertEqual(nightlight.temperatureFromOutput('4000\n'), 4000, 'nightlight parses probe temperature')
assertEqual(nightlight.temperatureFromOutput("Couldn't connect to hyprsunset"), null, 'nightlight treats unreachable hyprsunset as unknown')
assertEqual(nightlight.isNightlight(4000), true, 'nightlight reports warm temperatures as enabled')
assertEqual(nightlight.isNightlight(5999), true, 'nightlight reports warmer-than-identity values as enabled')
assertEqual(nightlight.isNightlight(6000), false, 'nightlight reports identity temperature as disabled')
assertEqual(nightlight.isNightlight(null), false, 'nightlight reports unknown temperature as disabled')
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
STATE="$TMPDIR/hyprsunset-temp"
SHELL_LOG="$TMPDIR/omarchy-shell-log"

cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == "hyprsunset" && ${2:-} == "temperature" ]]; then
  if [[ -n ${3:-} ]]; then
    printf '%s\n' "$3" >"$HYPRSUNSET_STATE"
  else
    cat "$HYPRSUNSET_STATE" 2>/dev/null || exit 1
  fi
  exit 0
fi

exit 1
SH

cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_SHELL_LOG"
SH

chmod +x "$TMPDIR/bin/hyprctl" "$TMPDIR/bin/pgrep" "$TMPDIR/bin/omarchy-shell"

nightlight_cli() {
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
    "$ROOT/bin/omarchy-toggle-nightlight" "$@"
}

nightlight_status() {
  printf '%s\n' "$1" >"$STATE"
  nightlight_cli --status
}

[[ $(nightlight_status 4000 | jq -r .enabled) == "true" ]] || fail "nightlight status reports 4000K as enabled"
pass "nightlight status reports 4000K as enabled"

[[ $(nightlight_status 5999 | jq -r .enabled) == "true" ]] || fail "nightlight status reports warmer-than-identity values as enabled"
pass "nightlight status reports warmer-than-identity values as enabled"

[[ $(nightlight_status 6000 | jq -r .enabled) == "false" ]] || fail "nightlight status reports identity temperature as disabled"
pass "nightlight status reports identity temperature as disabled"

[[ $(nightlight_status 6500 | jq -r .enabled) == "false" ]] || fail "nightlight status reports daylight temperature as disabled"
pass "nightlight status reports daylight temperature as disabled"

printf '6500\n' >"$STATE"
: >"$SHELL_LOG"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from daylight"
pass "nightlight toggle warms the screen from daylight"

grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "nightlight toggle nudges the shell nightlight service"
pass "nightlight toggle nudges the shell nightlight service"

nightlight_cli >/dev/null
[[ $(<"$STATE") == 6500 ]] || fail "nightlight toggle restores daylight from night light"
pass "nightlight toggle restores daylight from night light"

# hyprsunset reports its age through ps. A boot still in progress applies its
# default temperature on the first wait, overriding whatever was set before.
BOOT_PENDING="$TMPDIR/boot-pending"
printf '#!/bin/bash\n[[ $* == *etimes* ]] && echo "${HYPRSUNSET_AGE:-100}"\n' >"$TMPDIR/bin/ps"
cat >"$TMPDIR/bin/sleep" <<'SH'
#!/bin/bash
printf 'sleep %s\n' "$*" >>"$OMARCHY_SHELL_LOG"
if [[ -e $BOOT_PENDING ]]; then
  rm -f "$BOOT_PENDING"
  printf '6000\n' >"$HYPRSUNSET_STATE"
fi
SH
printf '#!/bin/bash\necho 4242\n' >"$TMPDIR/bin/pgrep"
chmod +x "$TMPDIR/bin/sleep" "$TMPDIR/bin/ps" "$TMPDIR/bin/pgrep"
toggle_from_daylight() {
  printf '6500\n' >"$STATE"
  : >"$SHELL_LOG"
  BOOT_PENDING="$BOOT_PENDING" HYPRSUNSET_AGE="$1" nightlight_cli >/dev/null
}

toggle_from_daylight 100
[[ $(<"$STATE") == 4000 ]] && ! grep -q '^sleep' "$SHELL_LOG" || fail "a hyprsunset that has finished starting applies the toggle without waiting"
pass "a hyprsunset that has finished starting applies the toggle without waiting"

: >"$BOOT_PENDING"
toggle_from_daylight 1
[[ $(<"$STATE") == 4000 && ! -e $BOOT_PENDING ]] || fail "a hyprsunset still booting can't undo the toggle with its default"
pass "a hyprsunset still booting can't undo the toggle with its default"

printf '#!/bin/bash\nexit 1\n' >"$TMPDIR/bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$TMPDIR/bin/setsid"
chmod +x "$TMPDIR/bin/setsid"
: >"$BOOT_PENDING"
toggle_from_daylight 100
[[ $(<"$STATE") == 4000 && ! -e $BOOT_PENDING ]] || fail "a freshly started hyprsunset can't undo the toggle with its default"
pass "a freshly started hyprsunset can't undo the toggle with its default"

if rg -q 'omarchy.indicators' "$ROOT/bin/omarchy-toggle-nightlight"; then
  fail "nightlight toggle leaves indicator refresh to the nightlight service"
fi
pass "nightlight toggle leaves indicator refresh to the nightlight service"

# Another user's hyprsunset always runs here, for their own Hyprland session;
# this user's runs only when OWN_HYPRSUNSET=1. Limited by -u, pgrep finds a match
# only for this user's UID and only when that process exists.
LAUNCH_LOG="$TMPDIR/launches"
rm -f "$TMPDIR/bin/setsid"
cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
while (( $# )); do
  if [[ $1 == "-u" ]]; then
    [[ $2 == "$TEST_UID" && ${OWN_HYPRSUNSET:-0} == 1 ]]
    exit
  fi
  shift
done
exit 0
SH
cat >"$TMPDIR/bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$LAUNCH_LOG"
SH
chmod +x "$TMPDIR/bin/pgrep" "$TMPDIR/bin/uwsm-app"

wait_for_launch() {
  for _ in {1..20}; do
    [[ -s $LAUNCH_LOG ]] && break
    sleep 0.05
  done
}

LAUNCH_LOG="$LAUNCH_LOG" TEST_UID="$UID" nightlight_cli >/dev/null
wait_for_launch
grep -Fqx -- '-- hyprsunset' "$LAUNCH_LOG" || fail "nightlight toggle starts this user's hyprsunset when only another user's runs"

rm -f "$LAUNCH_LOG"
LAUNCH_LOG="$LAUNCH_LOG" TEST_UID="$UID" OWN_HYPRSUNSET=1 nightlight_cli >/dev/null
sleep 0.2
[[ ! -e $LAUNCH_LOG ]] || fail "nightlight toggle leaves a running hyprsunset of this user's alone"
pass "nightlight toggle only counts this user's hyprsunset as running"

# The shell service runs its script in a login shell; run it without -l here, so
# no login profile can put the real commands ahead of these mocks.
mapfile -d '' -t apply_command < <(run_node_test <<'JS'
const nightlight = requireFromRoot('shell/plugins/services/nightlight/NightlightModel.js')
process.stdout.write(nightlight.applyCommand(4000).map(arg => arg + '\0').join(''))
JS
)
[[ ${apply_command[0]:-} == "bash" && ${apply_command[1]:-} == "-lc" ]] || fail "the nightlight service applies through a login shell" "${apply_command[*]}"

nightlight_service() {
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
  LAUNCH_LOG="$LAUNCH_LOG" \
  TEST_UID="$UID" \
    bash -c "${apply_command[2]}"
}

printf '6500\n' >"$STATE"
rm -f "$LAUNCH_LOG"
nightlight_service
wait_for_launch
grep -Fqx -- '-- hyprsunset' "$LAUNCH_LOG" || fail "nightlight service starts this user's hyprsunset when only another user's runs"
[[ $(<"$STATE") == 4000 ]] || fail "nightlight service applies the requested temperature"

printf '6500\n' >"$STATE"
rm -f "$LAUNCH_LOG"
OWN_HYPRSUNSET=1 nightlight_service
sleep 0.2
[[ ! -e $LAUNCH_LOG && $(<"$STATE") == 4000 ]] || fail "nightlight service leaves a running hyprsunset of this user's alone"
pass "nightlight service only counts this user's hyprsunset as running"
