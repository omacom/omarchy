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

# --setup and --reset. The network, hyprsunset and the session are stubbed and
# everything else is the real command, --reset's refresh helpers included. The
# machine's time zone is pinned because hyprsunset is given machine-local times.
SETUP="$TMPDIR/setup"
mkdir -p "$SETUP/bin"
CONF="$SETUP/home/.config/hypr/hyprsunset.conf"
AUTOSTART="$SETUP/home/.config/hypr/autostart.lua"
OPEN_METEO="$SETUP/open-meteo.json"
WTTR="$SETUP/wttr.json"
CURL_LOG="$SETUP/curl.log"
RESTART_LOG="$SETUP/restart.log"

cat >"$SETUP/bin/curl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CURL_LOG"
case "$*" in
  *api.open-meteo.com*) [[ -f $OPEN_METEO ]] && cat "$OPEN_METEO" ;;
  *wttr.in*) [[ -f $WTTR ]] && cat "$WTTR" ;;
  *) exit 1 ;;
esac
SH

cat >"$SETUP/bin/hyprctl" <<'SH'
#!/bin/bash
[[ -n ${HYPRSUNSET_UP:-} ]] && echo 6500
SH

cat >"$SETUP/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
echo restart >>"$RESTART_LOG"
SH

printf '#!/bin/bash\nexit 0\n' >"$SETUP/bin/sleep"
chmod +x "$SETUP/bin/"*

nl_setup() {
  HOME="$SETUP/home" OMARCHY_PATH="$ROOT" TZ="${NL_TZ:-PST8PDT}" HYPRSUNSET_UP="${NL_UP-1}" \
  OPEN_METEO="$OPEN_METEO" WTTR="$WTTR" CURL_LOG="$CURL_LOG" RESTART_LOG="$RESTART_LOG" \
  PATH="$SETUP/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-toggle-nightlight" "$@"
}

# A user as shipped: the stock hyprsunset.conf and autostart.lua, no location
fresh_home() {
  rm -rf "$SETUP/home" "$OPEN_METEO" "$WTTR"
  mkdir -p "$SETUP/home/.config/hypr" "$SETUP/home/.local/state/omarchy/settings"
  cp "$ROOT/config/hypr/hyprsunset.conf" "$ROOT/config/hypr/autostart.lua" "$SETUP/home/.config/hypr/"
  : >"$CURL_LOG"
  : >"$RESTART_LOG"
}

# Open-Meteo's real shape: UTC with no trailing Z, the evening's sunset on the next date
open_meteo() {
  printf '{"daily":{"sunrise":["%s"],"sunset":["%s"]}}\n' "$1" "$2" >"$OPEN_METEO"
}

conf_times() {
  grep -oE 'time = [0-9:]+' "$CONF" | tr '\n' ' '
}

backups() {
  compgen -G "$CONF.bak.*" || true
}

store_location() {
  printf '%s\n' "$1" >"$SETUP/home/.local/state/omarchy/settings/weather.json"
}

fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
open_meteo 2026-09-26T13:30 2026-09-27T01:30
nl_setup --setup >/dev/null || fail "--setup succeeds from a stored location"
[[ $(conf_times) == "time = 06:30 time = 18:30 " ]] || fail "--setup writes the sun times in the machine's time zone" "$(<"$CONF")"
grep -A2 'time = 06:30' "$CONF" | grep -q 'identity = true' || fail "--setup clears the tint at sunrise"
grep -A2 'time = 18:30' "$CONF" | grep -q 'temperature = 4000' || fail "--setup tints at sunset"
pass "--setup schedules sunrise and sunset in the machine's time zone"

grep -q 'latitude=45.52&longitude=-122.68' "$CURL_LOG" && grep -q 'timezone=UTC' "$CURL_LOG" || fail "--setup asks Open-Meteo for the stored coordinates in UTC"
! grep -q 'wttr.in' "$CURL_LOG" || fail "--setup does not look the location up when coordinates are stored"
pass "--setup uses the stored coordinates without a location lookup"

[[ $(wc -l <"$RESTART_LOG") == 1 ]] || fail "--setup restarts hyprsunset once so it loads the schedule"
[[ $(grep -c 'launch_on_start("hyprsunset")' "$AUTOSTART") == 1 ]] || fail "--setup starts hyprsunset with the session"
pass "--setup restarts hyprsunset and starts it at login"

[[ -z $(backups) ]] || fail "--setup does not back up the shipped hyprsunset.conf"
NL_TZ=CET-1CEST nl_setup --setup >/dev/null || fail "--setup can run again"
[[ $(conf_times) == "time = 15:30 time = 03:30 " ]] || fail "--setup follows the machine's time zone" "$(<"$CONF")"
[[ -z $(backups) && $(grep -c 'launch_on_start("hyprsunset")' "$AUTOSTART") == 1 ]] || fail "running --setup again replaces its own config and adds no second autostart line"
pass "--setup can be run again without backups or duplicate autostart lines"

# No stored location: wttr.in places the IP address in one request
fresh_home
printf '{"nearest_area":[{"areaName":[{"value":"Victoria"}],"latitude":"48.433","longitude":"-123.350"}]}\n' >"$WTTR"
open_meteo 2026-09-26T14:07 2026-09-27T02:00
nl_setup --setup >/dev/null || fail "--setup succeeds with no stored location"
[[ $(grep -c 'wttr.in' "$CURL_LOG") == 1 ]] || fail "--setup places the IP address with one wttr.in request"
grep -q 'wttr.in/?format=j1' "$CURL_LOG" || fail "--setup asks wttr.in about this IP address"
grep -q 'latitude=48.433&longitude=-123.350' "$CURL_LOG" || fail "--setup uses the coordinates wttr.in found"
grep -q 'Location: Victoria' "$CONF" || fail "--setup names the detected location"
out=$(nl_setup --setup) || fail "--setup succeeds again with no stored location"
grep -q 'Victoria (48.433, -123.350)' <<<"$out" || fail "--setup shows which coordinates it scheduled for" "$out"
grep -q 'weather location --set' <<<"$out" || fail "--setup says how to correct the place" "$out"
pass "--setup detects the location with a single wttr.in request and shows where it landed"

# A stored name without coordinates is resolved by name, not by IP address
fresh_home
store_location '{"name":"New York"}'
printf '{"nearest_area":[{"areaName":[{"value":"Manhattan"}],"latitude":"40.714","longitude":"-74.006"}]}\n' >"$WTTR"
open_meteo 2026-09-26T10:55 2026-09-26T23:05
nl_setup --setup >/dev/null || fail "--setup succeeds with a stored name"
grep -q 'wttr.in/New%20York?format=j1' "$CURL_LOG" || fail "--setup looks up the stored name"
grep -q 'Location: New York' "$CONF" || fail "--setup keeps the stored name"
pass "--setup resolves a stored name without coordinates"

# Nothing is written when there is nothing to schedule
# Open-Meteo has no null for these: polar night repeats one time, polar day runs midnight to midnight
for polar in "polar night|2026-12-21T00:00|2026-12-21T00:00" "polar day|2026-06-21T00:00|2026-06-22T00:00"; do
  IFS='|' read -r label sunrise sunset <<<"$polar"
  fresh_home
  store_location '{"name":"Longyearbyen","latitude":78.22,"longitude":15.65}'
  open_meteo "$sunrise" "$sunset"
  rc=0
  err=$(nl_setup --setup 2>&1 >/dev/null) || rc=$?
  (( rc == 1 )) || fail "--setup exits 1 for $label (got $rc)"
  grep -qi 'polar' <<<"$err" || fail "--setup says why there is nothing to schedule for $label"
  cmp -s "$CONF" "$ROOT/config/hypr/hyprsunset.conf" && [[ ! -s $RESTART_LOG ]] || fail "--setup leaves the config alone for $label"
  ! grep -q 'launch_on_start("hyprsunset")' "$AUTOSTART" || fail "--setup does not start hyprsunset for $label"
done
pass "--setup refuses polar day and night without touching anything"

fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
rc=0
err=$(nl_setup --setup 2>&1 >/dev/null) || rc=$?
(( rc == 1 )) && grep -qi 'connection' <<<"$err" && cmp -s "$CONF" "$ROOT/config/hypr/hyprsunset.conf" || fail "--setup fails cleanly when Open-Meteo can't be reached"
open_meteo nonsense nonsense
rc=0
nl_setup --setup >/dev/null 2>&1 || rc=$?
(( rc == 1 )) && cmp -s "$CONF" "$ROOT/config/hypr/hyprsunset.conf" || fail "--setup rejects timestamps it can't read"
pass "--setup fails without writing when the sun times are missing or unreadable"

fresh_home
rc=0
err=$(nl_setup --setup 2>&1 >/dev/null) || rc=$?
(( rc == 1 )) && grep -q 'omarchy weather location --set' <<<"$err" || fail "--setup points at 'omarchy weather location --set' when no location can be found"
pass "--setup tells the user how to set a location when none can be found"

# A config the user wrote is kept; autostart lines the user wrote are respected
fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
open_meteo 2026-09-26T13:30 2026-09-27T01:30
printf 'profile {\n    time = 21:30\n    temperature = 3500\n}\n' >"$CONF"
printf 'o.launch_on_start("my-service")' >"$AUTOSTART"
nl_setup --setup >/dev/null || fail "--setup succeeds over a hand-written config"
[[ $(grep -c 'time = 21:30' "$(backups)") == 1 ]] || fail "--setup keeps a hand-written hyprsunset.conf as a backup"
[[ $(sed -n 1p "$AUTOSTART") == 'o.launch_on_start("my-service")' && $(grep -c 'launch_on_start' "$AUTOSTART") == 2 ]] || fail "--setup appends to an autostart.lua with no trailing newline without joining lines" "$(<"$AUTOSTART")"
pass "--setup backs up a hand-written config and appends cleanly to autostart.lua"

fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
open_meteo 2026-09-26T13:30 2026-09-27T01:30
printf -- '-- mine\no.launch_on_start("hyprsunset")\n' >"$AUTOSTART"
nl_setup --setup >/dev/null || fail "--setup succeeds with hyprsunset already in autostart.lua"
[[ $(grep -c 'launch_on_start("hyprsunset")' "$AUTOSTART") == 1 ]] || fail "--setup leaves an autostart line the user wrote alone"
printf -- '-- o.launch_on_start("hyprsunset")\n' >"$AUTOSTART"
nl_setup --setup >/dev/null || fail "--setup succeeds with hyprsunset commented out in autostart.lua"
[[ $(grep -c '^o.launch_on_start("hyprsunset")' "$AUTOSTART") == 1 ]] || fail "--setup adds the line when only a commented-out one exists"
pass "--setup respects hyprsunset autostart lines the user wrote"

# hyprsunset can die right after a restart; the schedule is still saved
fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
open_meteo 2026-09-26T13:30 2026-09-27T01:30
rc=0
err=$(NL_UP= nl_setup --setup 2>&1 >/dev/null) || rc=$?
(( rc == 0 )) && grep -q 'next login' <<<"$err" && [[ -n $(conf_times) ]] || fail "--setup says when hyprsunset didn't come back up"
pass "--setup reports a hyprsunset that didn't start"

# --reset: back to the shipped config and the shipped autostart.lua
fresh_home
store_location '{"name":"Portland","latitude":45.52,"longitude":-122.68}'
open_meteo 2026-09-26T13:30 2026-09-27T01:30
printf 'o.launch_on_start("my-service")\n' >"$AUTOSTART"
nl_setup --setup >/dev/null || fail "--setup succeeds before --reset"
: >"$RESTART_LOG"
nl_setup --reset >/dev/null || fail "--reset succeeds"
cmp -s "$CONF" "$ROOT/config/hypr/hyprsunset.conf" || fail "--reset restores Omarchy's hyprsunset.conf"
grep -q 'Generated by' "$(backups)" || fail "--reset keeps the config it replaced as a backup"
[[ $(<"$AUTOSTART") == 'o.launch_on_start("my-service")' ]] || fail "--reset removes only the autostart line --setup added" "$(<"$AUTOSTART")"
[[ -s $RESTART_LOG ]] || fail "--reset restarts hyprsunset so the schedule stops applying"
pass "--reset restores the default config and removes the autostart line --setup added"

# === P1 regression: a hand-edited --setup output is backed up on re-run ===
# Greptile review found that nl_backup_conf treated the "# Generated by"
# marker alone as proof of untouched, so a user who edited a profile time
# kept the marker and lost the edit on the next --setup. We now also verify
# a hash of the body matches the one in the marker.
P1_HOME=$(mktemp -d)
mkdir -p "$P1_HOME/bin" "$P1_HOME/.local/state/omarchy/settings" "$P1_HOME/.config/hypr"
printf '{"name":"Portland","latitude":45.52,"longitude":-122.68}\n' \
  >"$P1_HOME/.local/state/omarchy/settings/weather.json"
P1_OPEN_METEO="$P1_HOME/open-meteo.json"
printf '{"daily":{"sunrise":["2026-09-26T13:30:00"],"sunset":["2026-09-27T01:30:00"]}}\n' \
  >"$P1_OPEN_METEO"
cat >"$P1_HOME/bin/curl" <<SH
#!/bin/bash
cat "$P1_OPEN_METEO"
SH
chmod +x "$P1_HOME/bin/curl"
# Stub the restart helper so this never touches a developer's live
# hyprsunset on the host. Greptile flagged that earlier versions of these
# tests killed and restarted the user's running night light.
cat >"$P1_HOME/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
:
SH
chmod +x "$P1_HOME/bin/omarchy-restart-hyprsunset"

PATH="$P1_HOME/bin:$PATH" HOME="$P1_HOME" NL_TZ="PST8PDT" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null
[[ -f $P1_HOME/.config/hypr/hyprsunset.conf ]] \
  || fail "first --setup wrote hyprsunset.conf (precondition for the P1 edit-backup test)"

# Hand-edit a profile time. The "Generated by" header stays, so the
# old marker-only check would still skip the backup.
sed -i 's/temperature = 4000/temperature = 3200/' \
  "$P1_HOME/.config/hypr/hyprsunset.conf"
grep -q 'temperature = 3200' "$P1_HOME/.config/hypr/hyprsunset.conf" \
  || fail "user edit landed (precondition for the P1 edit-backup test)"

PATH="$P1_HOME/bin:$PATH" HOME="$P1_HOME" NL_TZ="PST8PDT" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null
p1_backup=$(ls "$P1_HOME/.config/hypr/"hyprsunset.conf.bak.* 2>/dev/null | head -1)
[[ -n $p1_backup ]] || fail "second --setup backs up the user-edited conf (P1 regression)"
grep -q 'temperature = 3200' "$p1_backup" \
  || fail "the backup preserves the user's hand edit (got $(cat "$p1_backup"))"
grep -q 'temperature = 4000' "$P1_HOME/.config/hypr/hyprsunset.conf" \
  || fail "second --setup writes the new schedule after backing up the edit"
pass "second --setup backs up a user-edited conf rather than overwriting it (P1)"
rm -rf "$P1_HOME"

# === P2 regression: --setup exits 1 when the conf cannot be written ===
# Greptile review found that the script restarted hyprsunset and reported
# success even when the conf write itself failed. We now write through a
# temp file, return early if anything fails, and never reach the restart.
P2_HOME=$(mktemp -d)
mkdir -p "$P2_HOME/bin" "$P2_HOME/.local/state/omarchy/settings" "$P2_HOME/.config/hypr"
printf '{"name":"Portland","latitude":45.52,"longitude":-122.68}\n' \
  >"$P2_HOME/.local/state/omarchy/settings/weather.json"
cat >"$P2_HOME/bin/curl" <<'SH'
#!/bin/bash
echo '{"daily":{"sunrise":["2026-09-26T13:30:00"],"sunset":["2026-09-27T01:30:00"]}}'
SH
chmod +x "$P2_HOME/bin/curl"
# Stub the restart helper so this never touches a developer's live
# hyprsunset on the host. (The P2 test fails before the restart would run
# anyway, but a stray stub keeps the test safe in case the failure path
# ever changes.)
cat >"$P2_HOME/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
:
SH
chmod +x "$P2_HOME/bin/omarchy-restart-hyprsunset"
# No existing hyprsunset.conf, so nl_backup_conf is a no-op. Locking the
# parent dir down to 555 makes mktemp fail (the first write step the new
# code actually checks).
chmod 555 "$P2_HOME/.config/hypr"
set +e
PATH="$P2_HOME/bin:$PATH" HOME="$P2_HOME" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null 2>"$P2_HOME/err"
rc=$?
set -e
chmod 755 "$P2_HOME/.config/hypr"
(( rc == 1 )) || fail "--setup exits 1 when the conf cannot be written (P2 regression; got $rc)"
[[ ! -f $P2_HOME/.config/hypr/hyprsunset.conf ]] \
  || fail "--setup does not write hyprsunset.conf when the write fails"
# The exact failure point depends on the sandbox: the autostart append
# happens before the conf write (so a locked parent dir fails there
# first), but the test's intent is just "the script reports a useful
# error and stops before writing the conf."
grep -qiE "couldn't|permission denied|temp file" "$P2_HOME/err" \
  || fail "--setup names the failed step in the error (got: $(cat "$P2_HOME/err"))"
pass "--setup exits 1 and leaves no conf behind when the write fails (P2)"
rm -rf "$P2_HOME"

# === P2 regression: --reset must not announce success when the restore fails ===
# Greptile found that reset_conf called omarchy-refresh-hyprsunset without
# checking its return, so a failed config restore would still reach the
# autostart line removal and the "back to default" message. Now reset_conf
# calls omarchy-refresh-config directly and stops on any error.
RESET_FAIL_HOME=$(mktemp -d)
mkdir -p "$RESET_FAIL_HOME/bin" "$RESET_FAIL_HOME/.config/hypr"
mkdir -p "$RESET_FAIL_HOME/omarchy/config/hypr"
# Stock conf at the Omarchy path; the user has a hand-written conf.
cat >"$RESET_FAIL_HOME/omarchy/config/hypr/hyprsunset.conf" <<'EOF'
profile {
    time = 07:00
    identity = true
}
EOF
printf 'profile {\n    time = 21:30\n    temperature = 3500\n}\n' >"$RESET_FAIL_HOME/.config/hypr/hyprsunset.conf"
printf 'o.launch_on_start("hyprsunset") -- omarchy toggle nightlight --setup\n' >"$RESET_FAIL_HOME/.config/hypr/autostart.lua"
# Stub omarchy-refresh-config to fail the way a missing stock file would.
cat >"$RESET_FAIL_HOME/bin/omarchy-refresh-config" <<'SH'
#!/bin/bash
echo "Not a shipped user config: $1" >&2
exit 1
SH
chmod +x "$RESET_FAIL_HOME/bin/omarchy-refresh-config"
# Stub the restart so this never touches a live hyprsunset.
cat >"$RESET_FAIL_HOME/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
:
SH
chmod +x "$RESET_FAIL_HOME/bin/omarchy-restart-hyprsunset"

set +e
PATH="$RESET_FAIL_HOME/bin:$PATH" HOME="$RESET_FAIL_HOME" OMARCHY_PATH="$RESET_FAIL_HOME/omarchy" \
  "$ROOT/bin/omarchy-toggle-nightlight" --reset >/dev/null 2>"$RESET_FAIL_HOME/err"
rc=$?
set -e
(( rc == 1 )) || fail "--reset exits 1 when the conf restore fails (P2 regression; got $rc)"
# The autostart line --setup added must still be there: --reset must not
# have removed it as part of a "successful" reset that didn't actually
# restore the conf.
grep -q 'omarchy toggle nightlight --setup' "$RESET_FAIL_HOME/.config/hypr/autostart.lua" \
  || fail "--reset leaves the autostart line alone when the conf restore fails"
# The user's hand-written conf must also be untouched.
grep -q 'time = 21:30' "$RESET_FAIL_HOME/.config/hypr/hyprsunset.conf" \
  || fail "--reset leaves the existing conf alone when the restore fails"
grep -qi "couldn't restore" "$RESET_FAIL_HOME/err" \
  || fail "--reset explains the failed step (got: $(cat "$RESET_FAIL_HOME/err"))"
pass "--reset exits 1 and leaves both the conf and the autostart line alone on restore failure (P2)"
rm -rf "$RESET_FAIL_HOME"

# === P1 regression: --setup updates a symlinked conf without replacing the link ===
# Greptile review found that mv -f over a symlink replaces the symlink with
# a regular file, breaking dotfile managers (Stow, chezmoi, etc.) whose
# workflow assumes the link survives every edit. The fix resolves the
# symlink and writes through the target, keeping the link itself intact.
SYM_HOME=$(mktemp -d)
mkdir -p "$SYM_HOME/bin" "$SYM_HOME/dotfiles/.config/hypr" \
         "$SYM_HOME/.config/hypr" \
         "$SYM_HOME/.local/state/omarchy/settings"
# Set up the symlink the way a Stow-style setup would: the user's
# ~/.config/hypr/hyprsunset.conf is a symlink into a dotfiles dir.
cat >"$SYM_HOME/dotfiles/.config/hypr/hyprsunset.conf" <<'EOF'
profile {
    time = 07:00
    identity = true
}
EOF
ln -s "$SYM_HOME/dotfiles/.config/hypr/hyprsunset.conf" \
   "$SYM_HOME/.config/hypr/hyprsunset.conf"
# Autostart as a regular file (script can append to it).
: >"$SYM_HOME/.config/hypr/autostart.lua"
printf '{"name":"Portland","latitude":45.52,"longitude":-122.68}\n' \
  >"$SYM_HOME/.local/state/omarchy/settings/weather.json"
SYM_OPEN_METEO="$SYM_HOME/open-meteo.json"
printf '{"daily":{"sunrise":["2026-09-26T13:30:00"],"sunset":["2026-09-27T01:30:00"]}}\n' \
  >"$SYM_OPEN_METEO"
cat >"$SYM_HOME/bin/curl" <<SH
#!/bin/bash
cat "$SYM_OPEN_METEO"
SH
chmod +x "$SYM_HOME/bin/curl"
cat >"$SYM_HOME/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
:
SH
chmod +x "$SYM_HOME/bin/omarchy-restart-hyprsunset"
PATH="$SYM_HOME/bin:$PATH" HOME="$SYM_HOME" TZ="PST8PDT" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null
# The symlink itself must still be a symlink (not replaced).
[[ -L $SYM_HOME/.config/hypr/hyprsunset.conf ]] \
  || fail "--setup leaves the hyprsunset.conf symlink intact (P1 regression; symlink was replaced with a regular file)"
# The target file (what the symlink points at) must contain the new
# schedule, not the shipped default.
grep -q 'time = 06:30' "$SYM_HOME/dotfiles/.config/hypr/hyprsunset.conf" \
  || fail "--setup writes the new schedule to the symlink target, not the shipped default"
pass "--setup updates a symlinked hyprsunset.conf without replacing the link (P1)"
rm -rf "$SYM_HOME"

# === P2 regression: a failed conf write does not leave an autostart line ===
# Greptile review found that an earlier reorder (autostart first, conf
# second) left a newly added login line in place when the subsequent
# conf write failed, so the user's next login started hyprsunset with
# the old (possibly hand-edited) config. setup_conf now writes the conf
# first and the autostart second: if the conf write fails, the
# autostart has not been touched and --setup exits 1 with a clean
# state.
ROLLBACK_HOME=$(mktemp -d)
mkdir -p "$ROLLBACK_HOME/bin" "$ROLLBACK_HOME/.local/state/omarchy/settings" \
         "$ROLLBACK_HOME/.config/hypr"
printf '{"name":"Portland","latitude":45.52,"longitude":-122.68}\n' \
  >"$ROLLBACK_HOME/.local/state/omarchy/settings/weather.json"
ROLLBACK_OPEN_METEO="$ROLLBACK_HOME/open-meteo.json"
printf '{"daily":{"sunrise":["2026-09-26T13:30:00"],"sunset":["2026-09-27T01:30:00"]}}\n' \
  >"$ROLLBACK_OPEN_METEO"
cat >"$ROLLBACK_HOME/bin/curl" <<SH
#!/bin/bash
cat "$ROLLBACK_OPEN_METEO"
SH
chmod +x "$ROLLBACK_HOME/bin/curl"
cat >"$ROLLBACK_HOME/bin/omarchy-restart-hyprsunset" <<'SH'
#!/bin/bash
:
SH
chmod +x "$ROLLBACK_HOME/bin/omarchy-restart-hyprsunset"
# Existing autostart has the user's my-service line but no hyprsunset one.
printf -- 'o.launch_on_start("my-service")\n' >"$ROLLBACK_HOME/.config/hypr/autostart.lua"
# Lock the conf dir down so the conf write fails.
chmod 555 "$ROLLBACK_HOME/.config/hypr"
set +e
PATH="$ROLLBACK_HOME/bin:$PATH" HOME="$ROLLBACK_HOME" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null 2>"$ROLLBACK_HOME/err"
rc=$?
set -e
chmod 755 "$ROLLBACK_HOME/.config/hypr"
(( rc == 1 )) || fail "--setup exits 1 when the conf write fails (P2 regression; got $rc)"
# The user's my-service line must still be there, and no hyprsunset
# line should have been left behind by a half-finished --setup.
grep -q 'o\.launch_on_start("my-service")' "$ROLLBACK_HOME/.config/hypr/autostart.lua" \
  || fail "--setup keeps the user's existing autostart line on conf-write failure"
! grep -q 'o\.launch_on_start("hyprsunset")' "$ROLLBACK_HOME/.config/hypr/autostart.lua" \
  || fail "--setup does not add a hyprsunset autostart line when the conf write fails"
grep -qi 'temp file\|mkdir' "$ROLLBACK_HOME/err" \
  || fail "--setup names the failed step in the rollback error (got: $(cat "$ROLLBACK_HOME/err"))"
pass "--setup does not add an autostart line when the conf write fails (P2)"
rm -rf "$ROLLBACK_HOME"
