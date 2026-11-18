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

# A daemon that is only up once pgrep has looked for it twice: launched after the first look
if [[ -n ${HYPRSUNSET_LOOKS:-} ]] && (( $(wc -l <"$HYPRSUNSET_LOOKS") < 2 )); then
  exit 1
fi

if [[ ${1:-} == "hyprsunset" && ${2:-} == "temperature" ]]; then
  if [[ -n ${3:-} ]]; then
    printf '%s\n' "$3" >"$HYPRSUNSET_STATE"
    printf 'false\n' >"$HYPRSUNSET_STATE.identity"
  else
    if [[ -n ${HYPRSUNSET_SLOW:-} && -s $HYPRSUNSET_SLOW ]]; then
      remaining=$(<"$HYPRSUNSET_SLOW")
      if (( remaining > 0 )); then
        printf '%s\n' "$((remaining - 1))" >"$HYPRSUNSET_SLOW"
        exit 1
      fi
    fi
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

chmod +x "$TMPDIR/bin/hyprctl" "$TMPDIR/bin/pgrep" "$TMPDIR/bin/omarchy-shell"

nightlight_cli() {
  PATH="$TMPDIR/bin:$PATH" \
  HYPRSUNSET_STATE="$STATE" \
  HYPRSUNSET_SLOW="${SLOW:-}" \
  HYPRSUNSET_LOOKS="${LOOKS:-}" \
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

[[ $(<"$STATE.identity") == "false" ]] || fail "nightlight toggle leaves identity when warming the screen"
pass "nightlight toggle leaves identity when warming the screen"

nightlight_cli >/dev/null
[[ $(<"$STATE") == 6500 ]] || fail "nightlight toggle restores daylight from night light"
pass "nightlight toggle restores daylight from night light"

[[ $(<"$STATE.identity") == "true" ]] || fail "nightlight toggle resets to the identity matrix when turning off"
pass "nightlight toggle resets to the identity matrix when turning off"

# hyprsunset owns its socket before it answers on it. A probe during that boot
# read as off, so the menu showed "Nightlight On" and the next toggle warmed
# the screen again instead of cooling it.
SLOW="$TMPDIR/slow"
printf '3\n' >"$SLOW"
[[ $(nightlight_status 4000 | jq -r .enabled) == "true" ]] || \
  fail "nightlight status waits for a booting hyprsunset to answer"
printf '3\n' >"$SLOW"
nightlight_cli >/dev/null
unset SLOW
[[ $(<"$STATE") == 6500 ]] || \
  fail "nightlight toggle reads a booting hyprsunset before choosing the direction"
pass "nightlight reads a booting hyprsunset before choosing the direction"

# hyprsunset's own default, as the shipped identity profile starts it
printf '6000\n' >"$STATE"
nightlight_cli >/dev/null
[[ $(<"$STATE") == 4000 ]] || fail "nightlight toggle warms the screen from hyprsunset's default"
pass "nightlight toggle warms the screen from hyprsunset's default"

rg -F '(temp === dayTemperature ? " && hyprctl hyprsunset identity" : "")' "$ROOT/shell/plugins/services/nightlight/Service.qml" >/dev/null ||
  fail "nightlight service resets to the identity matrix when turning off"
pass "nightlight service resets to the identity matrix when turning off"

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

# A hyprsunset another user is running answers pgrep but owns a socket this
# session's hyprctl can never reach, so it is no daemon to wait for.
rm -f "$STATE"
: >"$SHELL_LOG"
printf '#!/bin/bash\nfor arg in "$@"; do [[ $arg == "-u" ]] && exit 1; done\nexit 0\n' >"$TMPDIR/bin/pgrep"
[[ $(nightlight_cli --status | jq -r .enabled) == "false" ]] && ! grep -q '^sleep' "$SHELL_LOG" || \
  fail "nightlight status doesn't wait for another user's hyprsunset"
pass "nightlight status doesn't wait for another user's hyprsunset"

# The click that launches hyprsunset turns night light on, even when the daemon
# boots into a warm profile and answers by the time the toggle reads it.
LOOKS="$TMPDIR/looks"
: >"$LOOKS"
printf '#!/bin/bash\necho >>"$HYPRSUNSET_LOOKS"\n(( $(wc -l <"$HYPRSUNSET_LOOKS") > 1 ))\n' >"$TMPDIR/bin/pgrep"
printf '4000\n' >"$STATE"
nightlight_cli >/dev/null
unset LOOKS
[[ $(<"$STATE") == 4000 ]] || fail "launching hyprsunset into a warm profile still turns night light on"
pass "launching hyprsunset into a warm profile still turns night light on"
