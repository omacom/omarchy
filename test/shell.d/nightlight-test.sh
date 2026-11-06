#!/bin/bash

# omarchy:exclusive

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

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/services/nightlight/Service.qml'), 'utf8')
const context = vm.createContext({
  root: {
    temperature: 4000,
    nightTemperature: 4000,
    dayTemperature: 6500,
    requestedSchedule: null
  },
  statusProbe: { running: false },
  scheduleProbe: { running: false },
  scheduleTimer: { stop() {}, restart() {} },
  applied: []
})

// Run the service's actual functions and exit handler, controlling only process completion order.
for (const match of source.matchAll(/^  function (\w+)\(([^)]*)\) \{([\s\S]*?)^  \}/gm)) {
  vm.runInContext(`root.${match[1]} = function(${match[2]}) {${match[3]}}`, context)
}
const statusExit = source.match(/id: statusProbe[\s\S]*?(onExited: function\(exitCode\) \{[\s\S]*?^    \})/m)
assert(statusExit !== null, 'nightlight status probe has an exit handler')
vm.runInContext(`finishStatus = ${statusExit[1].replace('onExited: ', '')}`, context)
vm.runInContext('root.applyTemperature = function(temp) { applied.push(temp); root.temperature = temp }', context)

context.root.refresh()
assertEqual(context.statusProbe.running, true, 'refresh reads the actual display temperature')
assertEqual(context.scheduleProbe.running, false, 'schedule waits for the display probe instead of using cached night temperature')

// The display reverted to daylight while asleep, although the cache still said 4000K.
context.root.temperature = 6500
context.statusProbe.running = false
context.finishStatus(0)
assertEqual(context.scheduleProbe.running, true, 'completed display probe starts schedule evaluation')
context.root.applySchedule({
  scheduled: true,
  night: true,
  nextEvent: 'sunrise',
  nextEventAt: '2026-08-31T06:25:00-07:00'
})
assertDeepEqual(context.applied, [4000], 'nighttime resume corrects a display reset despite the formerly warm cache')

context.scheduleProbe.running = false
context.root.requestedSchedule = false
context.finishStatus(0)
assertEqual(context.scheduleProbe.running, false, 'pending manual mode does not restart automatic scheduling')

context.root.requestedSchedule = null
context.finishStatus(1)
assertEqual(context.root.temperature, null, 'failed display probe invalidates cached temperature')
assertEqual(context.scheduleProbe.running, true, 'failed display probe still lets sunset mode restore hyprsunset')
JS

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/services/nightlight/Service.qml'), 'utf8')

function service(scheduled) {
  const context = vm.createContext({
    root: {
      scheduleLoaded: true,
      scheduled,
      requestedSchedule: null,
      nightTemperature: 4000,
      dayTemperature: 6500,
      temperature: 6500
    },
    statusProbe: { running: false },
    scheduleProbe: { running: false },
    scheduleTimer: { stop() {}, restart() {} },
    scheduleChangeProcess: { running: false, command: [] },
    warnings: []
  })
  context.console = { warn: message => context.warnings.push(message) }

  for (const match of source.matchAll(/^  function (\w+)\(([^)]*)\) \{([\s\S]*?)^  \}/gm)) {
    vm.runInContext(`root.${match[1]} = function(${match[2]}) {${match[3]}}`, context)
  }
  for (const key of Object.keys(context.root)) {
    Object.defineProperty(context, key, {
      get: () => context.root[key],
      set: value => { context.root[key] = value }
    })
  }
  const exits = {}
  for (const name of ['scheduleChangeProcess', 'statusProbe']) {
    const match = source.match(new RegExp(`id: ${name}\\b[\\s\\S]*?(onExited: function\\(exitCode\\) \\{[\\s\\S]*?^    \\})`, 'm'))
    if (match) exits[name] = vm.runInContext(`(${match[1].replace('onExited: ', '')})`, context)
  }
  const scheduleOutput = source.match(/id: scheduleProbe[\s\S]*?onStreamFinished: \{([\s\S]*?)^      \}/m)
  const finishSchedule = vm.runInContext(`(function(text) {${scheduleOutput[1]}})`, context)
  vm.runInContext('root.applyTemperature = function(temp) { root.temperature = temp }', context)

  let persisted = scheduled
  const writes = []
  function finishWrite(exitCode = 0) {
    const process = context.scheduleChangeProcess
    assertEqual(process.running, true, 'a mode write is in flight')
    const enabling = process.command[1] === 'enable'
    if (exitCode === 0) persisted = enabling
    writes.push(enabling)
    process.running = false
    exits.scheduleChangeProcess(exitCode)
  }
  function settle() {
    for (let count = 0; count < 5; count++) {
      if (!context.scheduleChangeProcess.running) break
      finishWrite()
    }
    assertEqual(context.root.requestedSchedule, null, 'the latest mode request settles')
    return persisted
  }
  return { context, finishWrite, settle, writes, finishStatus: exits.statusProbe, finishSchedule }
}

for (const warm of [true, false]) {
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(warm)
  assertEqual(test.settle(), false, `manual ${warm ? 'night light' : 'daylight'} wins over pending Sunset`)
  assertEqual(test.context.root.temperature, warm ? 4000 : 6500, 'the latest manual temperature is retained')
  assertDeepEqual(test.writes, [true, false], 'manual mode is persisted after the older enable completes')
}

{
  const test = service(true)
  test.context.root.setNightlight(false)
  test.context.root.setScheduleEnabled(true)
  assertEqual(test.settle(), true, 'Sunset wins over pending manual persistence')
  assertDeepEqual(test.writes, [false, true], 'Sunset waits for the older disable to complete')
}

{
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(true)
  test.context.root.setScheduleEnabled(true)
  assertEqual(test.settle(), true, 'Sunset wins after enable-manual-enable')
  assertDeepEqual(test.writes, [true], 'superseded requests do not cause extra writes')
}

{
  const test = service(true)
  test.context.root.setNightlight(true)
  test.context.root.setScheduleEnabled(true)
  test.context.root.setNightlight(false)
  assertEqual(test.settle(), false, 'manual mode wins after manual-enable-manual')
  assertEqual(test.context.root.temperature, 6500, 'the newest manual temperature wins too')
  assertDeepEqual(test.writes, [false], 'a superseded enable does not run')
}

{
  const test = service(false)
  test.context.root.setScheduleEnabled(true)
  test.finishStatus(0)
  assertEqual(test.context.scheduleProbe.running, false, 'status completion cannot evaluate an intermediate mode')
  test.context.root.setNightlight(false)
  test.finishSchedule(JSON.stringify({ scheduled: true, night: true }))
  assertEqual(test.context.root.scheduled, false, 'a stale solar response cannot reselect Sunset during a manual request')
  assertEqual(test.context.root.temperature, 6500, 'a stale solar response cannot override manual daylight')
  test.finishWrite(1)
  assertEqual(test.settle(), false, 'the latest manual request survives a failed older enable')
  assertEqual(test.context.warnings.length, 1, 'a failed mode write is reported')
}
JS

require_command python3

python3 - <<'PY'
import json
import os
import subprocess
import unittest
from datetime import datetime, timedelta
from pathlib import Path


class SolarScheduleTest(unittest.TestCase):
  def evaluate(self, zone, at):
    result = subprocess.run(
      [str(Path(os.environ["ROOT"]) / "bin/omarchy-nightlight-schedule"),
       "evaluate", "--at", at.isoformat() if isinstance(at, datetime) else at],
      env={
        **os.environ,
        "OMARCHY_NIGHTLIGHT_STATE": "/dev/null",
        "OMARCHY_NIGHTLIGHT_TIMEZONE": zone,
        "OMARCHY_ZONEINFO_DIR": "/usr/share/zoneinfo",
      },
      check=True,
      capture_output=True,
      text=True,
    )
    schedule = json.loads(result.stdout)
    self.assertNotIn("error", schedule)
    return schedule

  def test_advertised_sunset_changes_night_state(self):
    zone = "America/Los_Angeles"
    schedule = self.evaluate(zone, "2026-03-20T12:00:00-07:00")
    self.assertEqual(schedule["nextEvent"], "sunset")
    sunset = datetime.fromisoformat(schedule["nextEventAt"])
    self.assertTrue(self.evaluate(zone, sunset + timedelta(seconds=1))["night"])

  def test_apia_includes_todays_sunset(self):
    schedule = self.evaluate("Pacific/Apia", "2026-08-30T17:00:00+13:00")
    self.assertEqual(schedule["nextEvent"], "sunset")
    self.assertTrue(schedule["nextEventAt"].startswith("2026-08-30T18:"))

  def assert_transition(self, zone, schedule):
    event = datetime.fromisoformat(schedule["nextEventAt"])
    was_night = schedule["nextEvent"] == "sunrise"
    for offset in (-1, -0.000001, 0, 0.999999, 1):
      with self.subTest(zone=zone, event=event, offset=offset):
        at = event + timedelta(seconds=offset)
        result = self.evaluate(zone, at)
        self.assertEqual(result["night"], was_night if offset < 0 else not was_night)
        self.assertGreater(datetime.fromisoformat(result["nextEventAt"]), at)
        if offset < 0:
          self.assertEqual(result["nextEventAt"], schedule["nextEventAt"])
          self.assertEqual(result["nextEvent"], schedule["nextEvent"])

  def test_boundaries_across_seasons_timezones_and_dst(self):
    cases = (
      ("America/Los_Angeles", "2026-03-20"),
      ("America/Los_Angeles", "2026-06-21"),
      ("America/Los_Angeles", "2026-09-22"),
      ("America/Los_Angeles", "2026-12-21"),
      ("America/Los_Angeles", "2026-03-08"),
      ("America/Los_Angeles", "2026-11-01"),
      ("Europe/London", "2026-03-29"),
      ("Europe/London", "2026-10-25"),
      ("Pacific/Apia", "2026-08-30"),
      ("Pacific/Kiritimati", "2026-08-30"),
      ("Pacific/Honolulu", "2026-08-30"),
      ("Pacific/Auckland", "2026-08-30"),
      ("Pacific/Chatham", "2026-08-30"),
      ("Asia/Tokyo", "2026-08-30"),
      ("Australia/Sydney", "2026-04-05"),
      ("Australia/Sydney", "2026-10-04"),
    )
    for zone, day in cases:
      with self.subTest(zone=zone, day=day):
        schedule = self.evaluate(zone, day + "T00:00:00")
        self.assertEqual(schedule["nextEvent"], "sunrise")
        self.assertTrue(schedule["nextEventAt"].startswith(day))
        self.assert_transition(zone, schedule)
        sunset = self.evaluate(zone, schedule["nextEventAt"])
        self.assertEqual(sunset["nextEvent"], "sunset")
        self.assertTrue(sunset["nextEventAt"].startswith(day))
        self.assert_transition(zone, sunset)

  def test_polar_day_and_night_find_the_next_real_crossing(self):
    zone = "Arctic/Longyearbyen"
    for at, night, next_event in (
      ("2026-06-21T12:00:00", False, "sunset"),
      ("2026-12-21T12:00:00", True, "sunrise"),
    ):
      with self.subTest(at=at):
        schedule = self.evaluate(zone, at)
        self.assertEqual(schedule["night"], night)
        self.assertEqual(schedule["nextEvent"], next_event)
        event = datetime.fromisoformat(schedule["nextEventAt"])
        self.assertGreater((event.replace(tzinfo=None) - datetime.fromisoformat(at)).days, 20)
        self.assert_transition(zone, schedule)


unittest.main()
PY

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

if compositor_reachable && command -v quickshell >/dev/null 2>&1; then
  ulimit -c 0 2>/dev/null || true
  (
    test_tmp=$(mktemp -d)
    trap 'rm -rf "$test_tmp"' EXIT
    mkdir "$test_tmp/bin" "$test_tmp/home"
    cp "$SHELL_TEST_DIR/fixtures/nightlight-mode/shell.qml" "$test_tmp/shell.qml"
    cp "$SHELL_TEST_DIR/fixtures/nightlight-mode/schedule-command" "$test_tmp/bin/omarchy-nightlight-schedule"
    cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == "hyprsunset" && ${2:-} == "temperature" ]]; then
  if (( $# == 2 )) && [[ -f $HYPRSUNSET_AVAILABLE ]]; then
    cat "$HYPRSUNSET_STATE"
    exit 0
  fi
  if (( $# == 3 )); then
    printf '%s\n' "$3" >>"$HYPRSUNSET_CALL_LOG"
    if [[ -f $HYPRSUNSET_FAIL_NEXT ]]; then
      rm -f "$HYPRSUNSET_FAIL_NEXT"
      /bin/sleep 0.05
      exit 1
    fi
    if [[ -f $HYPRSUNSET_AVAILABLE ]]; then
      /bin/sleep 0.05
      printf '%s\n' "$3" >"$HYPRSUNSET_STATE"
      printf '%s\n' "$3" >>"$HYPRSUNSET_SUCCESS_LOG"
      exit 0
    fi
  fi
  /bin/sleep 0.05
fi
exit 1
SH
    printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/pgrep"
    printf '#!/bin/bash\n[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"\nexec /bin/bash "$@"\n' >"$test_tmp/bin/bash"
    chmod +x "$test_tmp/bin/"*
    : >"$test_tmp/calls"
    : >"$test_tmp/successes"
    printf '6500\n' >"$test_tmp/display"
    ln -s "$ROOT/shell/plugins/services/nightlight" "$test_tmp/Nightlight"
    ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

    output=$(HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" OMARCHY_NIGHTLIGHT_STATE="$test_tmp/mode" \
      HYPRSUNSET_CALL_LOG="$test_tmp/calls" HYPRSUNSET_STATE="$test_tmp/display" \
      HYPRSUNSET_SUCCESS_LOG="$test_tmp/successes" \
      HYPRSUNSET_AVAILABLE="$test_tmp/available" HYPRSUNSET_FAIL_NEXT="$test_tmp/fail-next" \
      timeout 10 quickshell -p "$test_tmp" --no-color 2>&1) || {
      printf '%s\n' "$output" >&2
      fail "nightlight mode persistence fixture exits cleanly"
    }
    if ! grep -q "RESULT pass" <<<"$output"; then
      printf '%s\n' "$output" >&2
      fail "failed Sunset commands recover and preserve newer manual requests"
    fi
    pass "failed Sunset commands recover and preserve newer manual requests"
  )
  (
    test_tmp=$(mktemp -d)
    trap 'rm -rf "$test_tmp"' EXIT

    cp "$SHELL_TEST_DIR/fixtures/nightlight-resume/shell.qml" "$test_tmp/shell.qml"
    mkdir "$test_tmp/Nightlight" "$test_tmp/home"
    cp "$ROOT/shell/plugins/services/nightlight/NightlightModel.js" "$test_tmp/Nightlight/"
    ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
    # Keep the real QML timers and scheduling code, replacing only the wall clock.
    sed 's/Date.now()/root.shell.now/g' "$ROOT/shell/plugins/services/nightlight/Service.qml" >"$test_tmp/Nightlight/Service.qml"

    output=$(HOME="$test_tmp/home" timeout 15 quickshell -p "$test_tmp" --no-color 2>&1) || {
      printf '%s\n' "$output" >&2
      fail "nightlight resume fixture exits cleanly"
    }

    if ! grep -q "RESULT pass" <<<"$output"; then
      printf '%s\n' "$output" >&2
      fail "sunset mode restores the correct temperature after sleep"
    fi

    pass "sunset mode restores the correct temperature after sleep"
  )
else
  skip "no compositor or Quickshell; skipping Night Light runtime tests"
fi
