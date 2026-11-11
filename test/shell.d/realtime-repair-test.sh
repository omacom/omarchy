#!/bin/bash
#
# omarchy-realtime-repair, which the rtkit migration runs, must leave no
# logged-in user's process with a hard RLIMIT_RTTIME of 0 at the moment rtkit
# lands or after the portals restart, must touch nothing else, must fail, so
# the repair fails, whenever it could not repair or inspect
# something, must record the machine-wide repair so other users' runs need no
# sudo, and must do nothing on a second run.
#
# Only the system boundary is stubbed: /proc/<pid>/{status,stat,limits} under
# a fake proc root, prlimit rewriting them, sudo, loginctl, the D-Bus and
# systemd answers, the package helpers and the PipeWire process lookup.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

repair_command="$ROOT/bin/omarchy-realtime-repair"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
state="$test_dir/state"
proc_root="$test_dir/proc"
calls="$test_dir/calls"
mkdir -p "$stub_bin"

# The caller is a stubbed regular user, whoever runs the suite: as root, the
# caller and root's own services would otherwise be the same account.
me=omarchy-test
my_uid=1000
other_uid=1001

cat >"$stub_bin/id" <<'STUB'
#!/bin/bash
case $* in
  -u) echo "$MY_UID" ;;
  -un) echo "$ME" ;;
  *) exit 2 ;;
esac
STUB

# Writes a fake process: pid uid start-time soft hard.
cat >"$stub_bin/fake-proc" <<'STUB'
#!/bin/bash
mkdir -p "$OMARCHY_PROC_ROOT/$1"
printf 'Name:\tfake\nUid:\t%s\t%s\t%s\t%s\n' "$2" "$2" "$2" "$2" >"$OMARCHY_PROC_ROOT/$1/status"
echo "$1 (fake proc) S $(printf '0 %.0s' {1..18})$3 0 0" >"$OMARCHY_PROC_ROOT/$1/stat"
echo "Max realtime timeout $4 $5 us" >"$OMARCHY_PROC_ROOT/$1/limits"
STUB
cat >"$stub_bin/loginctl" <<'STUB'
#!/bin/bash
[[ $* == "list-users --no-legend" ]] || exit 2
[[ -z ${LOGINCTL_FAILS:-} ]] || exit 1
cat "$STATE/users"
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
# Every case appends here, so the last check covers the whole run.
[[ $1 == "-n" ]] || { echo "sudo without -n: $*" >>"$CALLS"; echo "$*" >>"${CALLS%/*}/prompting-sudo"; exit 1; }
shift
[[ -z ${NO_SUDO:-} ]] || exit 1
# Cached sudo that expires while pacman runs.
[[ -z ${SUDO_EXPIRES_AT_INSTALL:-} || ! -e $STATE/rtkit ]] || exit 1
# The process scan must run as root, or hidepid hides other users' processes.
[[ $* != *SCAN_ROOT* ]] || echo scan >>"$STATE/root-scans"
[[ -z ${STALE_BEFORE_PRLIMIT:-} || $* != *PROC_ROOT* ]] || sed -i 's/ 0 us$/ 100000 us/' "$OMARCHY_PROC_ROOT/$STALE_BEFORE_PRLIMIT/limits"
[[ -z ${OWNER_CHANGES_BEFORE_PRLIMIT:-} || $* != *PROC_ROOT* ]] || sed -i 's/^Uid:.*/Uid:\t0\t0\t0\t0/' "$OMARCHY_PROC_ROOT/$OWNER_CHANGES_BEFORE_PRLIMIT/status"
AS_ROOT=1 exec "$@"
STUB
cat >"$stub_bin/prlimit" <<'STUB'
#!/bin/bash
pid=${2:?} limit=${3#--rttime=}
echo "prlimit $pid" >>"$CALLS"
sed -i "s/^Max realtime timeout .*/Max realtime timeout ${limit%:*} ${limit#*:} us/" "$OMARCHY_PROC_ROOT/$pid/limits"
# An app that keeps starting clients at the stale portal's zero.
if [[ -n ${ZEROS_KEEP_COMING:-} ]]; then
  next=$(( $(cat "$STATE/spawned" 2>/dev/null || echo 100) + 1 ))
  echo "$next" >"$STATE/spawned"
  fake-proc "$next" 1000 "${next}00" 0 0
fi
STUB
cat >"$stub_bin/busctl" <<'STUB'
#!/bin/bash
user=$(id -un)
for arg; do [[ $arg == "--machine="* ]] && { user=${arg#--machine=}; user=${user%@}; }; done
# Only root reaches another user's manager or bus.
[[ $user == $(id -un) || -n ${AS_ROOT:-} ]] || exit 1
case $* in
  *RealtimeKit1*) [[ -e $STATE/rtkit && ! -e $STATE/rtkit-masked ]] && echo "x $RTKIT_BUDGET" ;;
  *portal.Realtime*) [[ -e $STATE/portal-$user ]] && echo "x $(<"$STATE/portal-$user")" ;;
  *) exit 2 ;;
esac
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
user=$(id -un)
for arg; do [[ $arg == "--machine="* ]] && { user=${arg#--machine=}; user=${user%@}; }; done
# Only root reaches another user's manager or bus.
[[ $user == $(id -un) || -n ${AS_ROOT:-} ]] || exit 1
case $* in
  *"show -p ActiveState --value xdg-desktop-portal.service")
    [[ -z ${PORTAL_SHOW_FAILS:-} ]] || exit 1
    cat "$STATE/portal-state-$user" 2>/dev/null || echo active ;;
  *"restart xdg-desktop-portal.service")
    echo "restart portal $user" >>"$CALLS"
    # A client that read the old portal just before it went away.
    [[ -z ${ZERO_DURING_RESTART:-} || -e $OMARCHY_PROC_ROOT/77 ]] || fake-proc 77 1000 7700 0 0
    [[ -z ${PORTAL_RESTART_FAILS:-} && ${PORTAL_RESTART_FAILS_FOR:-} != $user ]] || exit 1
    [[ -n ${PORTAL_STAYS_ZERO:-} ]] || cat "$STATE/budget" >"$STATE/portal-$user" ;;
  *"show -p MainPID --value pipewire.service")
    [[ -z ${MAINPID_FAILS:-} ]] || exit 1
    if [[ -e $STATE/pipewire ]]; then echo 500; else echo 0; fi ;;
  *"try-restart pipewire.service pipewire-pulse.service wireplumber.service")
    echo "restart audio" >>"$CALLS"
    echo RR >"$STATE/pipewire" ;;
  "mask --runtime rtkit-daemon.service") [[ -n ${AS_ROOT:-} ]] && touch "$STATE/rtkit-masked" ;;
  "unmask --runtime rtkit-daemon.service") [[ -n ${AS_ROOT:-} ]] && rm -f "$STATE/rtkit-masked" ;;
  "reset-failed rtkit-daemon.service") [[ -n ${AS_ROOT:-} ]] ;;
  *) exit 2 ;;
esac
STUB
cat >"$stub_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
[[ ! -e $STATE/rtkit ]]
STUB
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $* == "-S --needed --noconfirm -- rtkit" ]] || exit 2
# pacman's own lock: a second transaction fails at once instead of waiting.
if [[ -e $STATE/db.lck ]]; then
  echo "error: failed to init transaction (unable to lock database)" >&2
  exit 1
fi
touch "$STATE/db.lck"
trap 'rm -f "$STATE/db.lck"' EXIT
# Hold the transaction until another repair says it waits, or for 10 s.
if [[ -n ${PACMAN_HOLD_FOR:-} ]]; then
  for _ in {1..100}; do
    ! grep -q "Waiting for another realtime repair" "$PACMAN_HOLD_FOR" 2>/dev/null || break
    sleep 0.1
  done
fi
[[ -e $STATE/rtkit-masked ]] || echo "rtkit installed unmasked" >>"$CALLS"
[[ -z ${PACMAN_FAILS:-} ]] || exit 1
# rtkit can make any user's zero-limit thread realtime from here on.
for dir in "$OMARCHY_PROC_ROOT"/*; do
  [[ $(awk '/^Uid:/ { print $2 }' "$dir/status") != "0" ]] || continue
  [[ $(awk '/^Max realtime timeout/ { print $5 }' "$dir/limits") == "0" ]] && echo "zero at install ${dir##*/}" >>"$CALLS"
done
touch "$STATE/rtkit"
echo "$RTKIT_BUDGET" >"$STATE/budget"
STUB
# pgrep finds the server (500) and the speaker tuning host (501), which is
# also named pipewire; only systemd's MainPID tells them apart.
cat >"$stub_bin/pgrep" <<'STUB'
#!/bin/bash
[[ -e $STATE/pipewire ]] && printf '500\n501\n'
STUB
cat >"$stub_bin/ps" <<'STUB'
#!/bin/bash
for arg; do
  case $arg in
    *500*) cat "$STATE/pipewire" ;;&
    *501*) cat "$STATE/tuning-host" 2>/dev/null ;;
  esac
done
STUB
chmod +x "$stub_bin"/*

# A session without rtkit: the shell and a terminal at a hard zero, another
# logged-in user's process at a hard zero, root logged in too with a service
# at a hard zero, a process with a limit of its own, both portals reporting
# zero, PipeWire not realtime.
fresh_machine() {
  rm -rf "$state" "$proc_root" "$calls"
  mkdir -p "$state" "$proc_root"
  touch "$calls"
  printf '0 root no active\n%s %s no active\n%s user2 no active\n' "$my_uid" "$me" "$other_uid" >"$state/users"
  echo 0 >"$state/portal-$me"
  echo 0 >"$state/portal-user2"
  echo TS >"$state/pipewire"
  local fake="$stub_bin/fake-proc"
  OMARCHY_PROC_ROOT=$proc_root "$fake" 10 "$my_uid" 1000 0 0
  OMARCHY_PROC_ROOT=$proc_root "$fake" 11 "$my_uid" 1100 0 0
  OMARCHY_PROC_ROOT=$proc_root "$fake" 12 "$my_uid" 1200 50000 100000
  OMARCHY_PROC_ROOT=$proc_root "$fake" 20 "$other_uid" 2000 0 0
  OMARCHY_PROC_ROOT=$proc_root "$fake" 30 0 3000 0 0
}

# The caller's session bus; a run without one has no session to repair.
runtime_dir="$test_dir/runtime"
mkdir -p "$runtime_dir"
python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$runtime_dir/bus"

repair() {
  XDG_RUNTIME_DIR=${run_runtime_dir:-$runtime_dir} DBUS_SESSION_BUS_ADDRESS='' \
    OMARCHY_PROC_ROOT=$proc_root OMARCHY_REALTIME_REPAIR_PENDING=$state/pending \
    OMARCHY_REALTIME_REPAIR_LOCK=$state/lock \
    STATE=$state CALLS=$calls RTKIT_BUDGET=200000 MY_UID=${run_uid:-$my_uid} ME=${run_user:-$me} \
    PATH="$stub_bin:$ROOT/bin:$PATH" "$repair_command" >"${run_out:-$test_dir/out}" 2>&1
}

hard_of() {
  awk '/^Max realtime timeout/ { print $5 }' "$proc_root/$1/limits"
}

fresh_machine
ZERO_DURING_RESTART=1 repair || fail "the repair succeeds on a fresh machine" "$(cat "$test_dir/out")"
! grep -q '^zero at install' "$calls" || fail "no process has a zero budget when rtkit lands" "$(cat "$calls")"
pass "no process has a zero budget when rtkit lands"
[[ $(hard_of 10):$(hard_of 11):$(hard_of 20) == "200000:200000:200000" ]] ||
  fail "logged-in users' zeros, another user's included, get rtkit's budget" "$(hard_of 10) $(hard_of 11) $(hard_of 20)"
pass "logged-in users' zeros, another user's included, get rtkit's budget"
[[ -s $state/root-scans ]] || fail "the process scan runs as root, so hidepid cannot hide other users' zeros"
pass "the process scan runs as root, so hidepid cannot hide other users' zeros"
[[ $(hard_of 77) == "200000" ]] || fail "a zero that appears while the portal restarts is raised"
pass "a zero that appears while the portal restarts is raised"
[[ $(hard_of 30):$(hard_of 12) == "0:100000" ]] || fail "root's services and other limits are left alone"
! grep -qx "restart portal root" "$calls" || fail "root's portal is left alone"
pass "root's services and other limits are left alone"
grep -qx "restart portal $me" "$calls" && grep -qx "restart portal user2" "$calls" ||
  fail "each logged-in user's zero-budget portal restarts" "$(cat "$calls")"
grep -qx "restart audio" "$calls" || fail "the audio units restart while PipeWire is not realtime"
pass "each user's stale portal and the audio units restart"

# A laptop with a speaker tuning: its host, also named pipewire, already got
# realtime from rtkit while the server did not, which still needs the restart.
fresh_machine
echo RR >"$state/tuning-host"
repair || fail "the repair succeeds with a speaker tuning host" "$(cat "$test_dir/out")"
grep -qx "restart audio" "$calls" || fail "the audio units restart when only the tuning host is realtime"
pass "the audio units restart when only the tuning host is realtime"

: >"$calls"
repair || fail "a second run succeeds" "$(cat "$test_dir/out")"
[[ ! -s $calls ]] || fail "a second run restarts nothing and raises nothing" "$(cat "$calls")"
pass "a second run restarts nothing and raises nothing"

fresh_machine
if LOGINCTL_FAILS=1 repair; then fail "the repair fails when loginctl fails"; fi
[[ ! -e $state/rtkit ]] || fail "rtkit is not installed while the users are unknown"
pass "the repair fails when loginctl fails"

fresh_machine
echo activating >"$state/portal-state-$me"
if repair; then fail "the repair fails while a portal is activating"; fi
pass "the repair fails while a portal is activating"

fresh_machine
if PORTAL_SHOW_FAILS=1 repair; then fail "the repair fails when a portal's state cannot be read"; fi
pass "the repair fails when a portal's state cannot be read"

fresh_machine
echo inactive >"$state/portal-state-$me"
repair || fail "a stopped portal is left to start with rtkit's budget" "$(cat "$test_dir/out")"
! grep -qx "restart portal $me" "$calls" || fail "a stopped portal is not restarted"
pass "a stopped portal is left to start with rtkit's budget"

fresh_machine
if PORTAL_RESTART_FAILS=1 repair; then fail "the repair fails when a portal restart fails"; fi
[[ -e $state/pending ]] || fail "a failed repair stays recorded as unfinished"
pass "the repair fails when a portal restart fails"

fresh_machine
if PORTAL_STAYS_ZERO=1 repair; then fail "the repair fails while a portal still reports zero"; fi
pass "the repair fails while a portal still reports zero"

fresh_machine
rm "$proc_root/11/limits"
if repair; then fail "the repair fails when a live process's limits cannot be read"; fi
pass "the repair fails when a live process's limits cannot be read"

fresh_machine
rm "$proc_root/11/stat"
if repair; then fail "the repair fails when a live process's start time cannot be read"; fi
pass "the repair fails when a live process's start time cannot be read"

fresh_machine
rm "$proc_root/20/status"
if repair; then fail "the repair fails when a live process's owner cannot be read"; fi
pass "the repair fails when a live process's owner cannot be read"

fresh_machine
if NO_SUDO=1 repair; then fail "the repair fails without sudo"; fi
grep -q "next omarchy update finishes it" "$test_dir/out" || fail "it says the next update finishes it" "$(cat "$test_dir/out")"
! grep -q '^prlimit\|^sudo without' "$calls" || fail "nothing is raised and nothing prompts without sudo" "$(cat "$calls")"
pass "the repair fails without sudo, and says why"

fresh_machine
for pid in 10 11 20; do sed -i 's/ 0 0 us$/ 200000 200000 us/' "$proc_root/$pid/limits"; done
if NO_SUDO=1 repair; then fail "with no zeros to raise, rtkit is still not installed without sudo"; fi
[[ ! -e $state/rtkit ]] || fail "with no zeros to raise, rtkit is still not installed without sudo"
pass "with no zeros to raise, rtkit is still not installed without sudo"

fresh_machine
STALE_BEFORE_PRLIMIT=11 repair || fail "a limit set by someone else is not an error" "$(cat "$test_dir/out")"
[[ $(hard_of 11) == "100000" ]] || fail "a limit set by someone else after the scan is not overwritten" "$(hard_of 11)"
pass "a limit set by someone else after the scan is not overwritten"

fresh_machine
OWNER_CHANGES_BEFORE_PRLIMIT=11 repair || fail "a process that changed owner is not an error" "$(cat "$test_dir/out")"
[[ $(hard_of 11) == "0" ]] || fail "a PID that now belongs to someone else is left alone" "$(hard_of 11)"
pass "a PID that now belongs to someone else is left alone"

fresh_machine
printf '11 (odd ) name\nwith a newline) S %s1300 0 0\n' "$(printf '0 %.0s' {1..18})" >"$proc_root/11/stat"
repair || fail "a process whose name holds a newline is repaired" "$(cat "$test_dir/out")"
[[ $(hard_of 11) == "200000" ]] || fail "a process whose name holds a newline is repaired" "$(hard_of 11)"
pass "a process whose name holds a newline is repaired"

# Once one admin's run has repaired the machine, a second user's run, or one
# from the login notifier without cached sudo, only fixes that user's own
# session.
fresh_machine
repair || fail "the repair succeeds on a fresh machine" "$(cat "$test_dir/out")"
[[ ! -e $state/pending ]] || fail "the finished machine-wide repair is recorded"
: >"$calls"
echo 0 >"$state/portal-$me"
echo TS >"$state/pipewire"
NO_SUDO=1 repair || fail "on a repaired machine, a run needs no sudo" "$(cat "$test_dir/out")"
grep -qx "restart portal $me" "$calls" && grep -qx "restart audio" "$calls" ||
  fail "on a repaired machine, a run restarts its own zero-budget portal and audio" "$(cat "$calls")"
! grep -qx "restart portal user2" "$calls" && ! grep -q '^prlimit' "$calls" ||
  fail "on a repaired machine, a run touches only its own session" "$(cat "$calls")"
pass "on a repaired machine, a run repairs its own session without sudo"

# A fresh install, or rtkit installed by hand: no machine-wide repair is
# pending, so a run repairs only its own session and needs sudo only for its
# own zeros. Other users' runs repair theirs.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
for pid in 10 11 20; do sed -i 's/ 0 0 us$/ 200000 200000 us/' "$proc_root/$pid/limits"; done
echo 200000 >"$state/portal-$me"
NO_SUDO=1 repair || fail "with rtkit already installed and no zeros, a run needs no sudo" "$(cat "$test_dir/out")"
pass "with rtkit already installed and no zeros, a run needs no sudo"

fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
if NO_SUDO=1 repair; then fail "with rtkit installed by hand, the user's own zeros need sudo"; fi
repair || fail "the repair succeeds with rtkit installed by hand" "$(cat "$test_dir/out")"
[[ $(hard_of 10):$(hard_of 20) == "200000:0" ]] && grep -qx "restart portal $me" "$calls" && ! grep -qx "restart portal user2" "$calls" ||
  fail "with rtkit installed by hand, a run repairs only its own session" "$(hard_of 10) $(hard_of 20) $(cat "$calls")"
pass "with rtkit installed by hand, a run repairs only its own session"

# An install run that stopped after the install, here on a failed portal
# restart, runs the machine-wide repair again on the retry.
fresh_machine
if PORTAL_RESTART_FAILS=1 repair; then fail "the repair fails when a portal restart fails"; fi
: >"$calls"
repair || fail "the retry succeeds" "$(cat "$test_dir/out")"
grep -qx "restart portal user2" "$calls" && [[ ! -e $state/pending ]] ||
  fail "the retry repairs every logged-in user's portal and finishes" "$(cat "$calls")"
pass "a retry after the install repairs every logged-in user's portal and finishes"

# A client that read the user's stale portal just before its restart, with
# rtkit already installed.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
ZERO_DURING_RESTART=1 repair || fail "the repair succeeds with rtkit installed by hand" "$(cat "$test_dir/out")"
[[ $(hard_of 77) == "200000" ]] || fail "a zero that appears while the user's own portal restarts is raised" "$(hard_of 77)"
pass "a zero that appears while the user's own portal restarts is raised"

# A user's own zeros are raised even when their portal cannot be repaired.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
if PORTAL_RESTART_FAILS=1 repair; then fail "the repair fails when the user's portal restart fails"; fi
[[ $(hard_of 10):$(hard_of 11) == "200000:200000" ]] ||
  fail "a user's own zeros are raised before their portal repair" "$(hard_of 10) $(hard_of 11)"
pass "a user's own zeros are raised before their portal repair"

# A zero handed out after the machine-wide repair, by a portal whose one read
# of rtkit failed, is raised for this user only, and needs sudo to raise.
fresh_machine
repair || fail "the repair succeeds on a fresh machine" "$(cat "$test_dir/out")"
OMARCHY_PROC_ROOT=$proc_root "$stub_bin/fake-proc" 13 "$my_uid" 1300 0 0
OMARCHY_PROC_ROOT=$proc_root "$stub_bin/fake-proc" 21 "$other_uid" 2100 0 0
if NO_SUDO=1 repair; then fail "a later zero of the user's own needs sudo to raise"; fi
repair || fail "a later zero of the user's own is raised" "$(cat "$test_dir/out")"
[[ $(hard_of 13):$(hard_of 21) == "200000:0" ]] ||
  fail "a later zero is raised for this user only" "$(hard_of 13) $(hard_of 21)"
pass "a later zero is raised for this user only, with sudo"

fresh_machine
repair || fail "the repair succeeds on a fresh machine" "$(cat "$test_dir/out")"
if MAINPID_FAILS=1 repair; then fail "the repair fails when PipeWire's main process cannot be read"; fi
pass "the repair fails when PipeWire's main process cannot be read"

# omarchy-upgrade-to-quattro runs the repair as root: the machine-wide part
# alone, since root has no desktop session of its own.
fresh_machine
run_uid=0 run_user=root repair || fail "the repair succeeds as root" "$(cat "$test_dir/out")"
[[ $(hard_of 10):$(hard_of 20):$(hard_of 30) == "200000:200000:0" ]] && [[ -e $state/rtkit && ! -e $state/pending ]] ||
  fail "as root, the repair raises the users' zeros, installs rtkit and finishes" "$(hard_of 10) $(hard_of 20) $(hard_of 30)"
grep -qx "restart portal $me" "$calls" && grep -qx "restart portal user2" "$calls" && ! grep -qx "restart audio" "$calls" ||
  fail "as root, the repair restarts the users' portals and leaves the audio units to each user" "$(cat "$calls")"
pass "as root, the repair does the machine-wide part alone"

# A zero handed out while one portal restarts is raised even when a later
# portal fails, and the repair still fails.
fresh_machine
if ZERO_DURING_RESTART=1 PORTAL_RESTART_FAILS_FOR=user2 repair; then fail "the repair fails when one user's portal fails"; fi
[[ $(hard_of 77) == "200000" && -e $state/pending ]] ||
  fail "a zero from an earlier portal restart is raised before the repair fails" "$(hard_of 77)"
pass "a zero from an earlier portal restart is raised before the repair fails"

fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
if ZERO_DURING_RESTART=1 PORTAL_RESTART_FAILS=1 repair; then fail "the repair fails when the user's own portal fails"; fi
[[ $(hard_of 77) == "200000" ]] ||
  fail "a zero from the user's own failed portal restart is raised" "$(hard_of 77)"
pass "a zero from the user's own failed portal restart is raised"

# Root with rtkit already installed and no repair pending, as when rtkit was
# installed by hand: the sweep still runs, so the users' own runs need no sudo.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
run_uid=0 run_user=root repair || fail "the repair succeeds as root with rtkit installed" "$(cat "$test_dir/out")"
[[ $(hard_of 10):$(hard_of 20) == "200000:200000" ]] && grep -qx "restart portal user2" "$calls" ||
  fail "as root, the repair sweeps a machine that already had rtkit" "$(hard_of 10) $(hard_of 20) $(cat "$calls")"
pass "as root, the repair sweeps a machine that already had rtkit"

# Root with no regular user logged in, as from a root console.
fresh_machine
printf '0 root no active\n' >"$state/users"
run_uid=0 run_user=root repair || fail "the repair succeeds as root with no user logged in" "$(cat "$test_dir/out")"
[[ -e $state/rtkit && ! -e $state/pending ]] && ! grep -q '^restart portal' "$calls" ||
  fail "with no user logged in, the repair installs rtkit and restarts no portal" "$(cat "$calls")"
pass "with no user logged in, the repair installs rtkit and restarts no portal"

# A user who is not logged in: their zeros are raised, and there is no portal
# or audio to repair.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
run_runtime_dir=$test_dir/no-session repair || fail "the repair succeeds without a session bus" "$(cat "$test_dir/out")"
[[ $(hard_of 10) == "200000" ]] && ! grep -q '^restart' "$calls" ||
  fail "without a session bus, the repair raises the user's zeros and restarts nothing" "$(hard_of 10) $(cat "$calls")"
pass "without a session bus, the repair raises the user's zeros and restarts nothing"

# Nothing in any case ran sudo in a way that could prompt.
[[ ! -s $test_dir/prompting-sudo ]] || fail "the repair only runs sudo -n" "$(cat "$test_dir/prompting-sudo")"
pass "the repair only runs sudo -n"

# rtkit stays masked through its own install, so nothing can be made realtime
# mid-transaction, and is released afterwards, also when the install fails.
fresh_machine
repair || fail "the repair succeeds on a fresh machine" "$(cat "$test_dir/out")"
! grep -qx "rtkit installed unmasked" "$calls" && [[ ! -e $state/rtkit-masked ]] ||
  fail "rtkit is masked during its install and released after" "$(cat "$calls")"
pass "rtkit is masked during its install and released after"

fresh_machine
if PACMAN_FAILS=1 repair; then fail "the repair fails when rtkit does not install"; fi
[[ ! -e $state/rtkit-masked && -e $state/pending ]] ||
  fail "a failed install releases rtkit and stays pending"
pass "a failed install releases rtkit and stays pending"

# Under hidepid=1 a user sees entries it cannot read; its own sweep skips
# them. Root, which raises any zeros the user has, reads every entry.
fresh_machine
touch "$state/rtkit"
echo 200000 >"$state/budget"
for pid in 10 11; do sed -i 's/ 0 0 us$/ 200000 200000 us/' "$proc_root/$pid/limits"; done
rm "$proc_root/20/status"
repair || fail "a user's own run skips entries it cannot read" "$(cat "$test_dir/out")"
pass "a user's own run skips entries it cannot read"

# Sudo that expires during the install leaves rtkit masked, which grants
# nothing, says so, and the next run with sudo releases it.
fresh_machine
if SUDO_EXPIRES_AT_INSTALL=1 repair; then fail "the repair fails when sudo expires during the install"; fi
[[ -e $state/rtkit-masked && -e $state/pending ]] && grep -q "rtkit stays masked until the next omarchy update or a reboot" "$test_dir/out" ||
  fail "a mask that cannot be released stays pending and says so" "$(cat "$test_dir/out")"
repair || fail "the next run with sudo succeeds" "$(cat "$test_dir/out")"
[[ ! -e $state/rtkit-masked && ! -e $state/pending ]] ||
  fail "the next run with sudo releases rtkit and finishes"
pass "a mask left by expired sudo says so, and the next run with sudo releases it"

# An app that keeps starting clients at a zero stops the repair before rtkit
# lands, and the error says how to finish it.
fresh_machine
if ZEROS_KEEP_COMING=1 repair; then fail "the repair fails while zeros keep coming"; fi
[[ ! -e $state/rtkit ]] && grep -q "close the apps that keep starting them, then run the update again" "$test_dir/out" ||
  fail "while zeros keep coming, rtkit is not installed and the error says how to finish" "$(cat "$test_dir/out")"
pass "while zeros keep coming, rtkit is not installed and the error says how to finish"

# Two users' updates at once: the second waits for the first, instead of
# failing on pacman's lock and releasing rtkit in the middle of its install.
fresh_machine
PACMAN_HOLD_FOR=$test_dir/out-second repair &
first=$!
for _ in {1..50}; do
  [[ ! -e $state/db.lck ]] || break
  sleep 0.1
done
[[ -e $state/db.lck ]] || fail "the first repair reaches its install" "$(cat "$test_dir/out")"
second=0
run_uid=$other_uid run_user=user2 run_runtime_dir=$test_dir/no-session run_out=$test_dir/out-second repair || second=$?
first_status=0
wait "$first" || first_status=$?
(( first_status == 0 && second == 0 )) ||
  fail "two repairs at once both succeed" "$first_status $second $(cat "$test_dir/out" "$test_dir/out-second")"
! grep -qx "rtkit installed unmasked" "$calls" && [[ ! -e $state/rtkit-masked && ! -e $state/pending ]] ||
  fail "a second repair at once does not release rtkit during the first one's install" "$(cat "$calls")"
grep -q "Waiting for another realtime repair to finish" "$test_dir/out-second" ||
  fail "the second repair says it waits" "$(cat "$test_dir/out-second")"
pass "a second repair at once waits instead of releasing rtkit mid-install"

# With a umask of 077, sudo would create the lock as root's alone, and no
# user could open it again.
fresh_machine
(umask 077 && repair) || fail "the repair succeeds with a umask of 077" "$(cat "$test_dir/out")"
[[ $(stat -c %a "$state/lock") == "644" ]] || fail "the lock stays readable by every user" "$(stat -c %a "$state/lock")"
pass "the lock stays readable by every user"
