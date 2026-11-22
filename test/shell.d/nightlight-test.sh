#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const nightlight = requireFromRoot('shell/plugins/services/nightlight/NightlightModel.js')

assertEqual(nightlight.temperatureFromOutput('4000\n'), 4000, 'nightlight parses probe temperature')
assertEqual(nightlight.temperatureFromOutput("Couldn't connect to hyprsunset"), null, 'nightlight treats unreachable hyprsunset as unknown')
assertEqual(nightlight.isNightlight(4000), true, 'nightlight reports warm temperatures as enabled')
assertEqual(nightlight.isNightlight(5999), true, 'nightlight reports warmer-than-identity values as enabled')
assertEqual(nightlight.isNightlight(6000), false, 'nightlight reports identity temperature as disabled')
assertEqual(nightlight.isNightlight(null), false, 'nightlight reports unknown temperature as disabled')
assertEqual(nightlight.isNightlight(4000, true), false, 'nightlight reports a warm temperature under identity as disabled')
assertEqual(nightlight.identityFromOutput('true\n'), true, 'nightlight parses identity on')
assertEqual(nightlight.identityFromOutput('false\n'), false, 'nightlight parses identity off')
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
STATE="$TMPDIR/hyprsunset-temp"
SHELL_LOG="$TMPDIR/omarchy-shell-log"
HYPRCTL_LOG="$TMPDIR/hyprctl-log"

cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$HYPRCTL_LOG"

if [[ ${1:-} == "hyprsunset" && ${2:-} == "temperature" ]]; then
  if [[ -n ${3:-} ]]; then
    printf '%s\n' "$3" >"$HYPRSUNSET_STATE"
    printf 'false\n' >"$HYPRSUNSET_STATE.identity"
  else
    cat "$HYPRSUNSET_STATE" 2>/dev/null || exit 1
  fi
  exit 0
fi

if [[ ${1:-} == "hyprsunset" && ${2:-} == "identity" ]]; then
  if [[ ${3:-} == "get" ]]; then
    cat "$HYPRSUNSET_STATE.identity" 2>/dev/null || echo false
  else
    printf 'true\n' >"$HYPRSUNSET_STATE.identity"
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
  HYPRCTL_LOG="$HYPRCTL_LOG" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
    "$ROOT/bin/omarchy-toggle-nightlight" "$@"
}

nightlight_status() {
  printf '%s\n' "$1" >"$STATE"
  printf '%s\n' "${2:-false}" >"$STATE.identity"
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

[[ $(nightlight_status 4000 true | jq -r .enabled) == "false" ]] || fail "nightlight status reports a warm temperature under identity as disabled"
pass "nightlight status reports a warm temperature under identity as disabled"

printf '6500\n' >"$STATE"
: >"$SHELL_LOG"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from daylight"
pass "nightlight toggle warms the screen from daylight"

grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "nightlight toggle nudges the shell nightlight service"
pass "nightlight toggle nudges the shell nightlight service"

[[ $(<"$STATE.identity") == "false" ]] || fail "nightlight toggle leaves identity when warming the screen"
pass "nightlight toggle leaves identity when warming the screen"

: >"$HYPRCTL_LOG"
nightlight_cli >/dev/null
[[ $(<"$STATE.identity") == "true" ]] || fail "nightlight toggle resets to the identity matrix when turning off"
pass "nightlight toggle resets to the identity matrix when turning off"

# A second request restarts Hyprland's fade from the first one's target, so
# stepping through daylight on the way off snaps instead of fading.
! grep -q '^hyprsunset temperature [0-9]' "$HYPRCTL_LOG" ||
  fail "nightlight toggle turns off in a single identity request" "$(<"$HYPRCTL_LOG")"
pass "nightlight toggle turns off in a single identity request"

nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 && $(<"$STATE.identity") == "false" ]] || fail "nightlight toggle turns back on from identity"
pass "nightlight toggle turns back on from identity"

# hyprsunset's own default, as the shipped identity profile starts it
printf '6000\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from hyprsunset's default"
pass "nightlight toggle warms the screen from hyprsunset's default"

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
