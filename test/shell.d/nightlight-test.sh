#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const nightlight = requireFromRoot('shell/plugins/services/nightlight/NightlightModel.js')
const fs = require('fs')
const vm = require('vm')
const service = fs.readFileSync(process.env.ROOT + '/shell/plugins/services/nightlight/Service.qml', 'utf8')
const handler = service.match(/id: applyProcess\s+onExited: function\(([^)]*)\) \{([\s\S]*?)\n    \}/)
function complete(code, status, pending = false) {
  const calls = []
  const root = { hasPendingTemperature: pending, pendingTemperature: 6500,
    refresh() { calls.push('refresh') }, runApply(temp) { calls.push(temp) } }
  vm.runInNewContext('(function(' + handler[1] + ') {' + handler[2] + '})', { root, Qt: { callLater(fn) { fn() } } })(code, status)
  return JSON.stringify(calls)
}
assertEqual(complete(0, 0), '[]', 'successful apply avoids a redundant status process')
assertEqual(complete(1, 0), '["refresh"]', 'failed apply reconciles daemon state')
assertEqual(complete(0, 1), '["refresh"]', 'crashed apply reconciles daemon state')
assertEqual(complete(1, 0, true), '[6500]', 'queued temperature runs before failure reconciliation')
assertEqual(complete(0, 0, true), '[6500]', 'queued temperature runs after success')


const streamHandler = service.match(/id: statusProbe[\s\S]*?onStreamFinished: \{([\s\S]*?)\n      \}/)[1]
function probeResult(probeRevision, stateRevision) {
  const root = { probeRevision, stateRevision, temperature: 4000, stateLoaded: true }
  vm.runInNewContext('(function() {' + streamHandler + '})()', { root, text: '6500', NightlightModel: nightlight })
  return root.temperature
}
assertEqual(probeResult(0, 1), 4000, 'probe predating an apply cannot overwrite its requested state')
assertEqual(probeResult(1, 1), 6500, 'current probe still reconciles external state')
const refreshHandler = service.match(/function refresh\(\) \{([\s\S]*?)\n  \}/)[1]
const probeTestState = { refreshPending: false, stateRevision: 2, probeRevision: 1 }
const statusProbe = { running: false }, applyProcess = { running: true }
vm.runInNewContext('(function() {' + refreshHandler + '})()', { root: probeTestState, statusProbe, applyProcess })
assert(probeTestState.refreshPending && !statusProbe.running, 'refresh during an apply waits for completion')
applyProcess.running = false
vm.runInNewContext('(function() {' + refreshHandler + '})()', { root: probeTestState, statusProbe, applyProcess })
assert(!probeTestState.refreshPending && statusProbe.running && probeTestState.probeRevision === 2, 'deferred refresh captures the latest revision')


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
