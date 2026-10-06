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

assert(nightlight.MAX_TEMPERATURE < nightlight.IDENTITY_TEMPERATURE, 'nightlight schedule warmth always reads as night light')

assertEqual(nightlight.normalizeTime('7'), '07:00', 'nightlight schedule reads a bare hour')
assertEqual(nightlight.normalizeTime('7:5'), '07:05', 'nightlight schedule pads a single-digit minute')
assertEqual(nightlight.normalizeTime('730'), '07:30', 'nightlight schedule reads three digits as h:mm')
assertEqual(nightlight.normalizeTime(' 2015 '), '20:15', 'nightlight schedule reads four digits as hh:mm')
assertEqual(nightlight.normalizeTime('23:59'), '23:59', 'nightlight schedule keeps a valid time')
assertEqual(nightlight.normalizeTime('24:00'), '', 'nightlight schedule rejects hour 24')
assertEqual(nightlight.normalizeTime('12:60'), '', 'nightlight schedule rejects minute 60')
assertEqual(nightlight.normalizeTime('noon'), '', 'nightlight schedule rejects words')
assertEqual(nightlight.normalizeTime(''), '', 'nightlight schedule rejects empty input')

assertEqual(nightlight.shiftTime('23:50', 15), '00:05', 'nightlight schedule steps forward across midnight')
assertEqual(nightlight.shiftTime('00:10', -15), '23:55', 'nightlight schedule steps back across midnight')
assertEqual(nightlight.shiftTime('', 60, '20:00'), '21:00', 'nightlight schedule steps from the fallback when the field is empty')

assertEqual(nightlight.nightMinutes('07:00', '20:00'), 660, 'nightlight schedule measures a night across midnight')
assertEqual(nightlight.nightMinutes('18:00', '06:00'), 720, 'nightlight schedule measures a daytime warm stretch')
assertEqual(nightlight.formatDuration(660), '11h', 'nightlight schedule formats whole hours')
assertEqual(nightlight.formatDuration(645), '10h 45m', 'nightlight schedule formats hours and minutes')
assertEqual(nightlight.formatDuration(30), '30m', 'nightlight schedule formats minutes alone')

assertEqual(nightlight.clampTemperature(1000), nightlight.MIN_TEMPERATURE, 'nightlight schedule clamps warmth to the minimum')
assertEqual(nightlight.clampTemperature(9000), nightlight.MAX_TEMPERATURE, 'nightlight schedule clamps warmth to the maximum')
assertEqual(nightlight.clampTemperature(3849), 3800, 'nightlight schedule rounds warmth to the step')
assertEqual(nightlight.clampTemperature('oops'), 4000, 'nightlight schedule falls back to the default warmth')

assertDeepEqual(nightlight.parseSchedule(''), { saved: false, scheduled: false, day: '07:00', night: '20:00', temperature: 4000 }, 'nightlight schedule treats a missing file as never saved')
assertDeepEqual(nightlight.parseSchedule('[]'), { saved: false, scheduled: false, day: '07:00', night: '20:00', temperature: 4000 }, 'nightlight schedule treats a non-object file as never saved')
assertDeepEqual(nightlight.parseSchedule('{"scheduled":true,"day":"06:30","night":"21:15","temperature":3200}'), { saved: true, scheduled: true, day: '06:30', night: '21:15', temperature: 3200 }, 'nightlight schedule reads a saved schedule')
assertDeepEqual(nightlight.parseSchedule('{"scheduled":true,"day":"25:00","temperature":99999}'), { saved: true, scheduled: true, day: '07:00', night: '20:00', temperature: nightlight.MAX_TEMPERATURE }, 'nightlight schedule repairs bad fields one at a time')

assertEqual(nightlight.describeSchedule(true, '07:00', '20:00').text, 'Warm from 20:00 to 07:00 · 11h', 'nightlight schedule summarizes the warm stretch')
assertEqual(nightlight.describeSchedule(false, '07:00', '20:00').valid, true, 'nightlight schedule can be saved switched off')
assertEqual(nightlight.describeSchedule(true, '', '20:00').valid, false, 'nightlight schedule refuses an unreadable time')
assertEqual(nightlight.describeSchedule(true, '07:00', '07:00').valid, false, 'nightlight schedule refuses equal start times')

const warm = nightlight.kelvinColor(2500)
const neutral = nightlight.kelvinColor(5500)
assert(warm.r === 1 && warm.b < neutral.b, 'nightlight schedule swatch gets warmer as kelvin drops')
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

# hyprsunset counts as running until the schedule's pkill stops it.
cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
[[ ! -e $HYPRSUNSET_STATE.killed ]]
SH

cat >"$TMPDIR/bin/pkill" <<'SH'
#!/bin/bash
printf 'pkill %s\n' "$*" >>"$OMARCHY_SHELL_LOG"
: >"$HYPRSUNSET_STATE.killed"
SH

# Answers like a shell with no nightlight service, unless SHELL_TOGGLE_REPLY
# is set, in which case it answers the toggle the way the service would.
cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_SHELL_LOG"
if [[ $1 == "nightlight" && $2 == "toggle" ]]; then
  [[ -n ${SHELL_TOGGLE_REPLY:-} ]] || exit 1
  printf '%s\n' "$SHELL_TOGGLE_REPLY"
fi
SH

for stub in setsid omarchy-notification-send; do
  cat >"$TMPDIR/bin/$stub" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$OMARCHY_SHELL_LOG"
SH
done

chmod +x "$TMPDIR/bin/"*

mkdir -p "$TMPDIR/home"

nightlight_cli() {
  HOME="$TMPDIR/home" \
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
    "$ROOT/bin/omarchy-toggle-nightlight" "$@"
}

config_cli() {
  rm -f "$STATE.killed"
  HOME="$TMPDIR/home" \
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
    "$ROOT/bin/omarchy-nightlight-config" "$@"
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

if rg -q 'omarchy.indicators' "$ROOT/bin/omarchy-toggle-nightlight"; then
  fail "nightlight toggle leaves indicator refresh to the nightlight service"
fi
pass "nightlight toggle leaves indicator refresh to the nightlight service"

# With the shell up, its service owns the toggle so the first turn-on can offer
# the schedule; the script must not also flip hyprsunset behind its back.
printf '6500\n' >"$STATE"
: >"$SHELL_LOG"
SHELL_TOGGLE_REPLY=enabled nightlight_cli >/dev/null
grep -Fqx 'nightlight toggle' "$SHELL_LOG" || fail "nightlight toggle hands off to the shell service"
[[ $(<"$STATE") == 6500 ]] || fail "nightlight toggle leaves hyprsunset to the shell service"
pass "nightlight toggle hands off to the shell service when it is running"

# ---------------------------------------------------------------- config

STATE_FILE="$TMPDIR/home/.local/state/omarchy/settings/nightlight.json"
CONFIG_FILE="$TMPDIR/home/.config/hypr/hyprsunset.conf"

[[ $(config_cli) == "No schedule set" ]] || fail "nightlight schedule reports when none was ever saved"
pass "nightlight schedule reports when none was ever saved"

[[ $(config_cli --json | jq -r .saved) == "false" ]] || fail "nightlight schedule json marks a missing file unsaved"
pass "nightlight schedule json marks a missing file unsaved"

: >"$SHELL_LOG"
config_cli set on 06:45 21:30 3600
[[ $(jq -c . "$STATE_FILE") == '{"scheduled":true,"day":"06:45","night":"21:30","temperature":3600}' ]] ||
  fail "nightlight schedule saves its state" "$(cat "$STATE_FILE")"
pass "nightlight schedule saves its state"

awk '/^profile/{p++} p==1 && /time =/{print $3}' "$CONFIG_FILE" | grep -Fqx '06:45' || fail "nightlight schedule writes the day profile" "$(cat "$CONFIG_FILE")"
awk '/^profile/{p++} p==1 && /identity = true/' "$CONFIG_FILE" | grep -q . || fail "nightlight schedule keeps the day profile untouched"
awk '/^profile/{p++} p==2 && /time =/{print $3}' "$CONFIG_FILE" | grep -Fqx '21:30' || fail "nightlight schedule writes the night profile"
awk '/^profile/{p++} p==2 && /temperature =/{print $3}' "$CONFIG_FILE" | grep -Fqx '3600' || fail "nightlight schedule writes the night warmth"
pass "nightlight schedule writes day and night hyprsunset profiles"

kill_line=$(grep -n 'pkill -x hyprsunset' "$SHELL_LOG" | cut -d: -f1 | head -n1)
start_line=$(grep -n 'setsid uwsm-app -- hyprsunset' "$SHELL_LOG" | cut -d: -f1 | head -n1)
[[ -n $kill_line && -n $start_line ]] && (( kill_line < start_line )) ||
  fail "nightlight schedule restarts hyprsunset to apply the profiles" "$(cat "$SHELL_LOG")"
pass "nightlight schedule restarts hyprsunset to apply the profiles"

grep -Fq 'Setup > Config > Night Light Config' "$SHELL_LOG" || fail "nightlight schedule tells where to change it later"
pass "nightlight schedule tells where to change it later"

[[ $(config_cli) == "Warm at 3600K from 21:30 to 06:45" ]] || fail "nightlight schedule describes a saved schedule"
pass "nightlight schedule describes a saved schedule"

printf '6500\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 3600 ]] || fail "nightlight toggle uses the saved warmth"
pass "nightlight toggle uses the saved warmth"

config_cli set off 06:45 21:30 3600
[[ $(jq -r .scheduled "$STATE_FILE") == "false" ]] || fail "nightlight schedule can be switched off"
(( $(grep -c '^profile' "$CONFIG_FILE") == 1 )) && grep -q 'identity = true' "$CONFIG_FILE" ||
  fail "nightlight schedule off restores the identity-only profile" "$(cat "$CONFIG_FILE")"
pass "nightlight schedule off restores the identity-only profile"

[[ $(config_cli) == "Schedule off" ]] || fail "nightlight schedule describes a switched-off schedule"
pass "nightlight schedule describes a switched-off schedule"

# Warmth is not a schedule setting: with the schedule off, the toggle still
# uses the saved warmth.
config_cli set off 06:45 21:30 3100
printf '6500\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 3100 ]] || fail "nightlight toggle uses the saved warmth with the schedule off"
pass "nightlight toggle uses the saved warmth with the schedule off"

before=$(cat "$STATE_FILE")
for bad in "maybe 07:00 20:00 4000" "on 7:00 20:00 4000" "on 07:00 24:00 4000" "on 07:00 07:00 4000" "on 07:00 20:00 6500" "on 07:00 20:00 2000" "on 07:00 20:00 warm"; do
  # shellcheck disable=SC2086
  if config_cli set $bad 2>/dev/null; then
    fail "nightlight schedule rejects: $bad"
  fi
done
[[ $(cat "$STATE_FILE") == "$before" ]] || fail "nightlight schedule leaves the saved state alone on bad input"
pass "nightlight schedule rejects bad times, equal starts, and out-of-range warmth"

: >"$SHELL_LOG"
config_cli edit
grep -Fqx 'shell summon omarchy.nightlight' "$SHELL_LOG" || fail "nightlight config edit opens the shell editor"
pass "nightlight config edit opens the shell editor"

grep -Fq '"action":"omarchy-nightlight-config edit"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu offers the night light config"
pass "the menu offers the night light config"

jq -e '(.kinds | index("overlay")) and .entryPoints.overlay == "Config.qml"' \
  "$ROOT/shell/plugins/services/nightlight/manifest.json" >/dev/null ||
  fail "the nightlight plugin ships its config overlay"
pass "the nightlight plugin ships its config overlay"
