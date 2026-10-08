#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""

cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

# Stand in for the user manager and logind: a marker file is the running unit,
# flag files break one piece at a time, and every call is logged.
TMPDIR=$(mktemp -d)
stub_bin="$TMPDIR/bin"
unit="$TMPDIR/unit-active"
log="$TMPDIR/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/systemctl" <<STUB
#!/bin/bash
echo "systemctl \$*" >>"$log"
case "\$*" in
  *is-active*)
    [[ ! -f "$TMPDIR/query-broken" && -f "$unit" ]]
    ;;
  *MainPID*)
    if [[ -f "$unit" ]]; then echo 4242; else echo 0; fi
    ;;
  *stop*)
    [[ ! -f "$TMPDIR/stop-broken" ]] || exit 1
    [[ -f "$unit" ]] || exit 5
    rm -f "$unit"
    ;;
esac
STUB

cat >"$stub_bin/systemd-run" <<STUB
#!/bin/bash
echo "systemd-run \$*" >>"$log"
[[ ! -f "$TMPDIR/run-broken" ]] || exit 1
touch "$unit"
STUB

# The unit's inhibitor is listed under its MainPID unless logind withholds it.
# A shutdown in progress holds another lid-switch inhibitor under the same name.
cat >"$stub_bin/systemd-inhibit" <<STUB
#!/bin/bash
entries=()
if [[ -f "$unit" && ! -f "$TMPDIR/deny" ]]; then
  entries+=('{"who":"Omarchy","pid":4242,"what":"handle-lid-switch","mode":"block"}')
fi
if [[ -f "$TMPDIR/shutdown" ]]; then
  entries+=('{"who":"Omarchy","pid":999,"what":"sleep:idle:handle-lid-switch","mode":"block"}')
fi
(IFS=,; echo "[\${entries[*]}]")
STUB

printf '#!/bin/bash\necho "omarchy-shell $*" >>"%s"\n' "$log" >"$stub_bin/omarchy-shell"
chmod +x "$stub_bin"/*
export PATH="$stub_bin:$ROOT/bin:$PATH"

omarchy-toggle-lid-awake status | grep -q '"enabled":false' || fail "lid awake reports off by default"
pass "lid awake reports off by default"

omarchy-toggle-lid-awake on
[[ -f $unit ]] || fail "lid awake on starts the inhibitor unit"
grep -q -- '--what=handle-lid-switch' "$log" || fail "lid awake inhibits only the lid switch"
grep -q -- '--unit=omarchy-lid-awake' "$log" || fail "lid awake runs as the omarchy-lid-awake unit"
grep -q -- '--property=Restart=on-failure --property=RestartSec=1' "$log" || fail "lid awake restarts after an unexpected helper failure"
pass "lid awake on starts a lid-switch inhibitor"

grep -q 'omarchy-shell omarchy.indicators refresh' "$log" || fail "lid awake refreshes the bar indicator"
pass "lid awake refreshes the bar indicator"

grep -q 'omarchy-shell -q battery checkLidAwakeFloor' "$log" || fail "lid awake checks the battery floor immediately after enabling"
pass "lid awake checks the battery floor immediately after enabling"

: >"$log"
omarchy-toggle-lid-awake on
! grep -q 'systemd-run' "$log" || fail "lid awake on is idempotent"
pass "lid awake on is idempotent"

omarchy-toggle-lid-awake status | grep -q '"enabled":true' || fail "lid awake reports on"
pass "lid awake reports on"

omarchy-toggle-lid-awake
[[ ! -f $unit ]] || fail "lid awake toggle turns it off"
pass "lid awake toggle turns it off"

omarchy-toggle-lid-awake toggle
[[ -f $unit ]] || fail "lid awake toggle turns it on"
pass "lid awake toggle turns it on"

omarchy-toggle-lid-awake off
omarchy-toggle-lid-awake off
[[ ! -f $unit ]] || fail "lid awake off is idempotent"
pass "lid awake off is idempotent"

if omarchy-toggle-lid-awake bogus 2>/dev/null; then
  fail "lid awake rejects unknown arguments"
fi
pass "lid awake rejects unknown arguments"

touch "$TMPDIR/deny"
if omarchy-toggle-lid-awake on 2>/dev/null; then
  fail "lid awake on fails when logind withholds the inhibitor"
fi
[[ ! -f $unit ]] || fail "lid awake stops the unit when the inhibitor never appears"
pass "lid awake on fails when logind withholds the inhibitor"

touch "$TMPDIR/shutdown"
if omarchy-toggle-lid-awake on 2>/dev/null; then
  fail "lid awake on is not confirmed by another Omarchy lid-switch inhibitor"
fi
pass "lid awake on is not confirmed by another Omarchy lid-switch inhibitor"
rm -f "$TMPDIR/deny" "$TMPDIR/shutdown"

touch "$TMPDIR/run-broken"
if omarchy-toggle-lid-awake on 2>/dev/null; then
  fail "lid awake on fails when the unit cannot start"
fi
pass "lid awake on fails when the unit cannot start"
rm -f "$TMPDIR/run-broken"

omarchy-toggle-lid-awake on
touch "$TMPDIR/query-broken"
omarchy-toggle-lid-awake off
[[ ! -f $unit ]] || fail "lid awake off stops the unit when the status query fails"
pass "lid awake off stops the unit when the status query fails"
rm -f "$TMPDIR/query-broken"

omarchy-toggle-lid-awake on
touch "$TMPDIR/stop-broken"
if omarchy-toggle-lid-awake off 2>/dev/null; then
  fail "lid awake off fails when the unit cannot be stopped"
fi
pass "lid awake off fails when the unit cannot be stopped"

# The indicator follows the unit's journal instead of polling, so a failure,
# restart, or stop outside the toggle still reaches the bar.
indicator="$ROOT/shell/plugins/bar/indicators/LidAwake.qml"
grep -q '"setpriv", "--pdeathsig", "TERM", "journalctl", "--user", "--follow", "--lines=0", "--output=cat", "--unit=omarchy-lid-awake"' "$indicator" || fail "lid awake indicator follows its unit's journal"
grep -q 'onRead: root.refresh()' "$indicator" || fail "lid awake indicator refreshes on each journal entry"
grep -Pzq 'onStarted: \{[^}]*root\.refresh\(\)' "$indicator" || fail "lid awake indicator checks the unit once its follower is running"
grep -q 'if (root.lidAwake && !unitFollower.running' "$indicator" || fail "lid awake indicator starts following on first use"
! grep -Pzq 'id: unitFollower[^}]*running: true' "$indicator" || fail "lid awake indicator runs no follower until first use"
grep -q 'Math.min(root.followerRetryDelay \* 2, 300000)' "$indicator" || fail "lid awake indicator backs off restarting a follower that keeps failing"
grep -q 'followerRestart.start()' "$indicator" || fail "lid awake indicator restarts a follower that exits"
! grep -q 'repeat: true' "$indicator" || fail "lid awake indicator does not poll"
pass "lid awake indicator follows its unit instead of polling"
