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
assertEqual(nightlight.temperaturesFromConfig(undefined).night, 4000, 'nightlight defaults night temperature without config')
assertEqual(nightlight.temperaturesFromConfig(undefined).day, 6500, 'nightlight defaults day temperature without config')
assertEqual(nightlight.temperaturesFromConfig({ night: 2700, day: 4000 }).night, 2700, 'nightlight reads night temperature from config')
assertEqual(nightlight.temperaturesFromConfig({ night: 2700, day: 4000 }).day, 4000, 'nightlight reads day temperature from config')
assertEqual(nightlight.temperaturesFromConfig({ night: 'warm', day: 4000 }).night, 4000, 'nightlight ignores a non-numeric night temperature')
assertEqual(nightlight.temperaturesFromConfig({ night: 5000, day: 4000 }).day, 6500, 'nightlight falls back when night is not below day')
assertEqual(nightlight.isNightlight(4000, 4000), false, 'nightlight reports the configured day temperature as disabled')
assertEqual(nightlight.isNightlight(2700, 4000), true, 'nightlight reports below-day temperatures as enabled')
assertEqual(nightlight.isNightlight(6000, 6500), false, 'nightlight keeps identity disabled with a default day temperature')
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
  XDG_CONFIG_HOME="$TMPDIR/config" \
  OMARCHY_PATH="$ROOT" \
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

# Custom temperatures from shell.json: a warm day baseline that still toggles.
mkdir -p "$TMPDIR/config/omarchy"
jq '.nightlight = { night: 2700, day: 4000 }' "$ROOT/config/omarchy/shell.json" >"$TMPDIR/config/omarchy/shell.json"

[[ $(nightlight_status 4000 | jq -r .enabled) == "false" ]] || fail "nightlight status reports the configured day temperature as disabled"
pass "nightlight status reports the configured day temperature as disabled"

[[ $(nightlight_status 2700 | jq -r .enabled) == "true" ]] || fail "nightlight status reports the configured night temperature as enabled"
pass "nightlight status reports the configured night temperature as enabled"

printf '4000\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 2700 ]] || fail "nightlight toggle warms to the configured night temperature"
pass "nightlight toggle warms to the configured night temperature"

nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle restores the configured day temperature"
pass "nightlight toggle restores the configured day temperature"

# Inverted or invalid values fall back to the defaults.
jq '.nightlight = { night: 5000, day: 4000 }' "$ROOT/config/omarchy/shell.json" >"$TMPDIR/config/omarchy/shell.json"
printf '6500\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle ignores an inverted temperature pair"
pass "nightlight toggle ignores an inverted temperature pair"
