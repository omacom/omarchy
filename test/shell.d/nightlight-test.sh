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

# Hardware that cannot apply a CTM is the interesting second case, so make the
# capability probe switchable rather than assuming it always answers yes.
cat >"$TMPDIR/bin/omarchy-hw-nightlight" <<'SH'
#!/bin/bash
exit "${NIGHTLIGHT_SUPPORTED:-0}"
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
SH

NOTIFICATIONS="$TMPDIR/notifications"

chmod +x "$TMPDIR/bin/hyprctl" "$TMPDIR/bin/pgrep" "$TMPDIR/bin/omarchy-shell" \
  "$TMPDIR/bin/omarchy-hw-nightlight" "$TMPDIR/bin/omarchy-notification-send"

nightlight_cli() {
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
  NOTIFICATION_LOG="$NOTIFICATIONS" \
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

# On a display pipeline with no CTM support hyprsunset still answers "ok" and
# echoes the temperature back, so the toggle has to refuse up front rather than
# run its retry loop and claim a success the panel never showed.
printf '6500\n' >"$STATE"
: >"$NOTIFICATIONS"

NIGHTLIGHT_SUPPORTED=1 nightlight_cli >/dev/null 2>&1 &&
  fail "nightlight toggle exits non-zero on hardware that cannot apply a temperature"
[[ $(<"$STATE") == 6500 ]] ||
  fail "nightlight toggle leaves the temperature alone on unsupported hardware"
grep -Fq 'Nightlight unavailable' "$NOTIFICATIONS" ||
  fail "nightlight toggle tells the user why it did nothing"
pass "nightlight toggle refuses on hardware that cannot apply a temperature"

[[ $(NIGHTLIGHT_SUPPORTED=1 nightlight_status 4000 | jq -r .enabled) == "false" ]] ||
  fail "nightlight status reports disabled on unsupported hardware"
pass "nightlight status reports disabled on unsupported hardware"
