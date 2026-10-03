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

if rg -q 'omarchy.indicators' "$ROOT/bin/omarchy-toggle-nightlight"; then
  fail "nightlight toggle leaves indicator refresh to the nightlight service"
fi
pass "nightlight toggle leaves indicator refresh to the nightlight service"

# === --setup: write hyprsunset.conf with sunrise/sunset at the user's loc ===
# Bug-hunting coverage: confirms the script uses the location already on
# disk (weather.json), converts UTC ISO timestamps to machine-local HH:MM,
# and writes a hyprsunset.conf the user can leave alone.
SETUP_HOME=$(mktemp -d)
mkdir -p "$SETUP_HOME/bin" "$SETUP_HOME/.local/state/omarchy/settings" "$SETUP_HOME/.config/hypr"

# Stored location already on disk (set via omarchy weather location --set).
printf '{"name":"Portland","latitude":45.52,"longitude":-122.68}\n' \
  >"$SETUP_HOME/.local/state/omarchy/settings/weather.json"

# Open-Meteo stub: returns today's sunrise/sunset in UTC, in the format the
# real API actually emits (ISO 8601 with no trailing `Z`). The script must
# add `Z` itself; a stub that pretends the API already did so would mask
# the regression where the user sees the UTC clock value unchanged.
OPEN_METEO="$SETUP_HOME/open-meteo.json"
cat >"$OPEN_METEO" <<'JSON'
{"daily":{"sunrise":["2026-09-26T13:30:00"],"sunset":["2026-09-27T01:30:00"]}}
JSON

# curl stub: only Open-Meteo is called when weather.json already has coords.
cat >"$SETUP_HOME/bin/curl" <<SH
#!/bin/bash
case "\$*" in
  *api.open-meteo.com*) cat "$OPEN_METEO" ;;
  *wttr.in*) echo "wttr.in should not be called when coords are stored" >&2; exit 1 ;;
  *) echo "unexpected curl: \$*" >&2; exit 1 ;;
esac
SH
chmod +x "$SETUP_HOME/bin/curl"

PATH="$SETUP_HOME/bin:$PATH" HOME="$SETUP_HOME" OPEN_METEO="$OPEN_METEO" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null
[[ -f $SETUP_HOME/.config/hypr/hyprsunset.conf ]] \
  || fail "--setup writes ~/.config/hypr/hyprsunset.conf"
pass "--setup writes hyprsunset.conf from the stored location"

# Sunrise 13:30 UTC -> 06:30 PDT (or whatever the host machine reports).
# We don't assert a specific local time because the test runs in the
# machine's TZ; we just confirm the file has HH:MM, not raw ISO timestamps.
grep -qE 'time = [0-9]{1,2}:[0-9]{2}' "$SETUP_HOME/.config/hypr/hyprsunset.conf" \
  || fail "hyprsunset.conf has machine-local HH:MM, not raw ISO"
pass "--setup produces machine-local HH:MM in hyprsunset.conf"

grep -q 'temperature = 4000' "$SETUP_HOME/.config/hypr/hyprsunset.conf" \
  || fail "sunset profile uses the night temperature (4000)"
pass "--setup sunset profile uses the night temperature"

# The Open-Meteo stub returns 13:30 UTC sunrise and 01:30 UTC sunset. Whatever
# the host's TZ, both must convert to the same calendar day from a hyprsunset
# perspective: sunrise HH:MM < 12 (morning) and sunset HH:MM > 12 (evening).
# This is the dogfood regression: without the `Z`-append fix, the script
# returned 13:30 and 01:30 literally — the screen would tint at 1:30 AM and
# go untinted at 1:30 PM, exactly backwards.
sunrise_hm=$(grep -A1 'profile' "$SETUP_HOME/.config/hypr/hyprsunset.conf" \
  | grep 'time' | head -1 | grep -oE '[0-9]{1,2}:[0-9]{2}')
sunset_hm=$(grep 'temperature' "$SETUP_HOME/.config/hypr/hyprsunset.conf" -B1 \
  | grep 'time' | head -1 | grep -oE '[0-9]{1,2}:[0-9]{2}')
sunrise_h=${sunrise_hm%%:*}
sunset_h=${sunset_hm%%:*}
(( sunrise_h < 12 )) || fail "--setup sunrise is in the morning (got $sunrise_hm)"
(( sunset_h  >= 12 )) || fail "--setup sunset is in the evening (got $sunset_hm)"
pass "--setup converts Open-Meteo UTC to local time (sunrise=$sunrise_hm sunset=$sunset_hm, not UTC clock values)"

# Polar region: Open-Meteo returns literal null sunrise/sunset. --setup
# must exit 1 and not write a broken conf.
POLAR_HOME=$(mktemp -d)
mkdir -p "$POLAR_HOME/bin" "$POLAR_HOME/.local/state/omarchy/settings" "$POLAR_HOME/.config/hypr"
printf '{"name":"Polar","latitude":85.0,"longitude":0.0}\n' \
  >"$POLAR_HOME/.local/state/omarchy/settings/weather.json"
POLAR_RESP="$POLAR_HOME/polar.json"
cat >"$POLAR_RESP" <<'JSON'
{"daily":{"sunrise":[null],"sunset":[null]}}
JSON
cat >"$POLAR_HOME/bin/curl" <<SH
#!/bin/bash
cat "$POLAR_RESP"
SH
chmod +x "$POLAR_HOME/bin/curl"
set +e
PATH="$POLAR_HOME/bin:$PATH" HOME="$POLAR_HOME" OPEN_METEO="$POLAR_RESP" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null 2>"$POLAR_HOME/err"
rc=$?
set -e
(( rc == 1 )) || fail "--setup exits 1 on polar-region response (got $rc)"
grep -qi polar "$POLAR_HOME/err" \
  || fail "--setup error mentions the polar-region cause"
[[ ! -f $POLAR_HOME/.config/hypr/hyprsunset.conf ]] \
  || fail "--setup must not write hyprsunset.conf when sunrise/sunset are missing"
pass "--setup rejects polar-region response without writing a broken conf"
rm -rf "$POLAR_HOME"

# No location, no network: --setup exits 1 with a hint to set one.
NOLOC_HOME=$(mktemp -d)
mkdir -p "$NOLOC_HOME/bin" "$NOLOC_HOME/.local/state/omarchy/settings" "$NOLOC_HOME/.config/hypr"
cat >"$NOLOC_HOME/bin/curl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$NOLOC_HOME/bin/curl"
set +e
PATH="$NOLOC_HOME/bin:$PATH" HOME="$NOLOC_HOME" \
  "$ROOT/bin/omarchy-toggle-nightlight" --setup >/dev/null 2>"$NOLOC_HOME/err"
rc=$?
set -e
(( rc == 1 )) || fail "--setup exits 1 with no location and no network (got $rc)"
grep -qi 'omarchy weather location' "$NOLOC_HOME/err" \
  || fail "--setup error points the user at omarchy weather location --set"
pass "--setup exits 1 with a useful hint when no location is reachable"
rm -rf "$NOLOC_HOME"

# === --reset: restore Omarchy's stock conf, back up user edits =========
RESET_HOME=$(mktemp -d)
mkdir -p "$RESET_HOME/bin" "$RESET_HOME/.config/hypr"
mkdir -p "$RESET_HOME/omarchy/config/hypr"
cat >"$RESET_HOME/omarchy/config/hypr/hyprsunset.conf" <<'EOF'
profile {
    time = 07:00
    identity = true
}
EOF
cat >"$RESET_HOME/.config/hypr/hyprsunset.conf" <<'EOF'
profile {
    time = 21:30
    temperature = 3500
}
EOF

PATH="$RESET_HOME/bin:$PATH" HOME="$RESET_HOME" OMARCHY_PATH="$RESET_HOME/omarchy" \
  "$ROOT/bin/omarchy-toggle-nightlight" --reset >/dev/null
grep -q 'time = 07:00' "$RESET_HOME/.config/hypr/hyprsunset.conf" \
  || fail "--reset restores Omarchy's stock hyprsunset.conf"
pass "--reset restores Omarchy's stock hyprsunset.conf"

backup=$(ls "$RESET_HOME/.config/hypr/"hyprsunset.conf.bak.* 2>/dev/null | head -1)
[[ -n $backup ]] || fail "--reset backs up the user's previous hyprsunset.conf"
grep -q '21:30' "$backup" \
  || fail "--reset backup contains the user's previous hyprsunset.conf"
pass "--reset backs up the user's previous hyprsunset.conf before clobbering it"
rm -rf "$RESET_HOME"
