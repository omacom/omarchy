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
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
STATE="$TMPDIR/hyprsunset-temp"
SHELL_LOG="$TMPDIR/omarchy-shell-log"
NOTIFICATION_LOG="$TMPDIR/notification-log"
SCHEDULE_STATE="$TMPDIR/nightlight.json"

cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash

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
  printf 'true\n' >"$HYPRSUNSET_STATE.identity"
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

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_NOTIFICATION_LOG"
SH

cat >"$TMPDIR/bin/timedatectl" <<'SH'
#!/bin/bash
case ${1:-} in
  show|list-timezones) printf 'America/Los_Angeles\n' ;;
  set-timezone) printf 'set-timezone %s\n' "$2" >>"$OMARCHY_SHELL_LOG" ;;
esac
SH

printf '#!/bin/bash\nread -r timezone; printf "%%s\\n" "$timezone"\n' >"$TMPDIR/bin/omarchy-menu-select"
printf '#!/bin/bash\n[[ ${1:-} == "-n" ]] && shift\n"$@"\n' >"$TMPDIR/bin/sudo"
chmod +x "$TMPDIR/bin/"*

nightlight_cli() {
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
  OMARCHY_NOTIFICATION_LOG="$NOTIFICATION_LOG" \
  OMARCHY_NIGHTLIGHT_STATE="${OMARCHY_NIGHTLIGHT_STATE_OVERRIDE:-$SCHEDULE_STATE}" \
  OMARCHY_NIGHTLIGHT_TIMEZONE="America/Los_Angeles" \
    "$ROOT/bin/omarchy-toggle-nightlight" "$@"
}

nightlight_schedule() {
  OMARCHY_NIGHTLIGHT_STATE="$SCHEDULE_STATE" \
  OMARCHY_NIGHTLIGHT_TIMEZONE="America/Los_Angeles" \
    "$ROOT/bin/omarchy-nightlight-schedule" "$@"
}

schedule_at_noon=$(nightlight_schedule evaluate --at "2026-08-30T12:00:00-07:00")
[[ $(jq -r .night <<<"$schedule_at_noon") == "false" ]] || fail "solar schedule recognizes daylight"
[[ $(jq -r .nextEvent <<<"$schedule_at_noon") == "sunset" ]] || fail "solar schedule finds sunset after daylight"
[[ $(jq -r .nextEventAt <<<"$schedule_at_noon") == 2026-08-30T19:2[01]:*-07:00 ]] || fail "solar schedule calculates Los Angeles sunset"
pass "solar schedule calculates daylight and the next sunset"

schedule_at_night=$(nightlight_schedule evaluate --at "2026-08-30T22:00:00-07:00")
[[ $(jq -r .night <<<"$schedule_at_night") == "true" ]] || fail "solar schedule recognizes night"
[[ $(jq -r .nextEvent <<<"$schedule_at_night") == "sunrise" ]] || fail "solar schedule finds sunrise after night"
pass "solar schedule calculates night and the next sunrise"

nightlight_schedule enable >/dev/null
nightlight_schedule enabled || fail "solar schedule persists enabled mode"
nightlight_schedule disable >/dev/null
if nightlight_schedule enabled; then
  fail "solar schedule persists manual mode"
fi
pass "solar schedule persists automatic and manual modes"

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

[[ $(nightlight_status 6500 | jq -r .scheduled) == "false" ]] || fail "nightlight status reports manual scheduling"
pass "nightlight status reports manual scheduling"

printf '6500\n' >"$STATE"
: >"$SHELL_LOG"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from daylight"
pass "nightlight toggle warms the screen from daylight"

grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "nightlight toggle nudges the shell nightlight service"
pass "nightlight toggle nudges the shell nightlight service"

[[ $(<"$STATE.identity") == "false" ]] || fail "nightlight toggle leaves identity when warming the screen"
pass "nightlight toggle leaves identity when warming the screen"

nightlight_cli >/dev/null
[[ $(<"$STATE") == 6500 ]] || fail "nightlight toggle restores daylight from night light"
pass "nightlight toggle restores daylight from night light"

[[ $(<"$STATE.identity") == "true" ]] || fail "nightlight toggle resets to the identity matrix when turning off"
pass "nightlight toggle resets to the identity matrix when turning off"

# hyprsunset's own default, as the shipped identity profile starts it
printf '6000\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from hyprsunset's default"
pass "nightlight toggle warms the screen from hyprsunset's default"

rg -F '(temp === dayTemperature ? " && hyprctl hyprsunset identity" : "")' "$ROOT/shell/plugins/services/nightlight/Service.qml" >/dev/null ||
  fail "nightlight service resets to the identity matrix when turning off"
pass "nightlight service resets to the identity matrix when turning off"

printf '6500\n' >"$STATE"
nightlight_schedule enable >/dev/null
nightlight_cli >/dev/null
if nightlight_schedule enabled; then
  fail "manual nightlight toggle disables automatic mode"
fi
[[ $(<"$STATE") == 4000 ]] || fail "manual nightlight toggle still applies after disabling automatic mode"
pass "manual nightlight toggle disables automatic mode"

mkdir "$TMPDIR/unwritable-schedule-state"
printf '6500\n' >"$STATE"
OMARCHY_NIGHTLIGHT_STATE_OVERRIDE="$TMPDIR/unwritable-schedule-state" nightlight_cli >/dev/null 2>&1
[[ $(<"$STATE") == 4000 ]] || fail "manual nightlight toggle survives schedule persistence failure"
grep -Fq 'Unable to disable automatic night light; applying a manual override' "$NOTIFICATION_LOG" ||
  fail "manual nightlight toggle reports schedule persistence failure"
pass "manual nightlight toggle survives schedule persistence failure"

nightlight_cli --schedule >/dev/null
nightlight_schedule enabled || fail "nightlight schedule option enables automatic mode"
grep -Fq 'Night light will follow sunset and sunrise in America/Los_Angeles' "$NOTIFICATION_LOG" ||
  fail "nightlight schedule option describes its timezone"
grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "nightlight schedule refreshes the shell service"
pass "nightlight schedule option enables automatic mode"

nightlight_cli --manual >/dev/null
if nightlight_schedule enabled; then
  fail "nightlight manual option disables automatic mode"
fi
pass "nightlight manual option disables automatic mode"

: >"$SHELL_LOG"
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" OMARCHY_SHELL_LOG="$SHELL_LOG" OMARCHY_NOTIFICATION_LOG="$NOTIFICATION_LOG" \
  "$ROOT/bin/omarchy-menu-timezone" >/dev/null
grep -Fqx 'set-timezone America/Los_Angeles' "$SHELL_LOG" || fail "timezone menu changes the selected timezone"
grep -Fqx -- '-q omarchy.clock refresh' "$SHELL_LOG" || fail "timezone menu refreshes the clock"
grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "timezone menu refreshes the solar schedule"
pass "timezone changes refresh the clock and solar schedule"

: >"$SHELL_LOG"
mapfile -d '' -t timezone_command < <(node -e '
  const model = require(process.env.ROOT + "/shell/plugins/panels/elsewhen/Model.js")
  process.stdout.write(model.timezoneCommand("America/Los_Angeles").join("\0") + "\0")
')
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" OMARCHY_SHELL_LOG="$SHELL_LOG" "${timezone_command[@]}"
grep -Fqx 'set-timezone America/Los_Angeles' "$SHELL_LOG" || fail "Elsewhen changes the selected timezone"
grep -Fqx -- '-q omarchy.clock refresh' "$SHELL_LOG" || fail "Elsewhen refreshes the clock"
grep -Fqx -- '-q nightlight refresh' "$SHELL_LOG" || fail "Elsewhen refreshes the solar schedule"
pass "Elsewhen timezone changes refresh the clock and solar schedule"

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
