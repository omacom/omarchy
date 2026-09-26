#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
test_processes=()
test_runtime_created=""
cleanup_test() {
  for pid in "${test_processes[@]}"; do kill "$pid" 2>/dev/null || true; done
  [[ -z ${state_dir:-} ]] || rm -rf -- "$state_dir"
  [[ -z ${state_hardlink:-} ]] || rm -f -- "$state_hardlink"
  rm -rf -- "$test_tmp"
  [[ -z $test_runtime_created ]] || rmdir -- "$test_runtime_created" 2>/dev/null || true
}
trap cleanup_test EXIT

stub_bin="$test_tmp/bin"
mapped_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
if [[ ! -d $runtime_dir || -L $runtime_dir || $(stat -Lc '%u %a' "$runtime_dir" 2>/dev/null || true) != "$(id -u) 700" ]]; then
  if (( EUID != 0 )); then
    fail "test needs a private XDG runtime directory or root namespace"
  fi
  runtime_dir=$(mktemp -d -p /run omarchy-stay-awake-runtime.XXXXXXXX)
  chmod 0700 "$runtime_dir"
  test_runtime_created="$runtime_dir"
fi
test_run_id="test-$BASHPID-$RANDOM"
state_dir="$runtime_dir/omarchy-update-stay-awake-$test_run_id"
state_hardlink="$runtime_dir/.omarchy-update-stay-awake-hardlink-$test_run_id"
inhibitor_log="$test_tmp/inhibitors"
mkdir -p "$stub_bin" "$test_home" "$mapped_root/bin" "$mapped_root/default/omarchy/sudo-no-update"
: >"$inhibitor_log"

cat >"$stub_bin/pkexec" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
case ${1:-} in
  -h) echo 'usage: sudo [-bHkNnPS] command'; exit 0 ;;
  -k|-K|-v) exit 0 ;;
esac
background=0
while (( $# )); do
  case "$1" in
    -N|-n) shift ;;
    -b) background=1; shift ;;
    --) shift; break ;;
    *) break ;;
  esac
done
if (( background )); then
  "$@" &
else
  exec "$@"
fi
SH

cat >"$stub_bin/setpriv" <<'SH'
#!/bin/bash
while [[ ${1:-} == --* ]]; do
  case "$1" in
    --reuid|--regid) shift 2 ;;
    --clear-groups) shift ;;
    *) exit 90 ;;
  esac
done
exec "$@"
SH

cat >"$stub_bin/systemd-inhibit" <<'SH'
#!/bin/bash
[[ ${SYSTEMD_FAIL:-0} == "0" ]] || exit 42
printf '%s\n' "$$" >>"$INHIBITOR_LOG"
if [[ -n ${CREATE_BAD_IDLE:-} ]]; then
  ln -s "$CREATE_BAD_IDLE" "$TEST_STATE_DIR/idle-owner"
fi
trap 'exit 0' TERM
while [[ ${1:-} == --* ]]; do shift; done
exec "$@"
SH

cat >"$stub_bin/omarchy-toggle-idle" <<'SH'
#!/bin/bash
state_file="$HOME/.local/state/omarchy/indicators/stay-awake"
case "$1" in
  stay-awake)
    mkdir -p "$(dirname "$state_file")"
    touch "$state_file"
    ;;
  allow-idle)
    rm -f "$state_file"
    ;;
esac
SH
chmod +x "$stub_bin"/*
ln -s "$stub_bin/omarchy-toggle-idle" "$mapped_root/bin/omarchy-toggle-idle"

mapped_helper="$mapped_root/bin/omarchy-update-stay-awake"
cp "$ROOT/bin/omarchy-update-stay-awake" "$mapped_helper"
cp "$ROOT/bin/omarchy-security-functions" "$mapped_root/bin/omarchy-security-functions"
cp "$ROOT/default/omarchy/sudo-no-update/sudo" "$mapped_root/default/omarchy/sudo-no-update/sudo"
for mapped_file in \
  "$mapped_helper" \
  "$mapped_root/bin/omarchy-security-functions" \
  "$mapped_root/default/omarchy/sudo-no-update/sudo"; do
  sed -i \
    -e "s#/usr/bin/sudo#$stub_bin/sudo#g" \
    -e "s#/usr/bin/pkexec#$stub_bin/pkexec#g" \
    -e "s#/usr/bin/systemd-inhibit#$stub_bin/systemd-inhibit#g" \
    -e "s#/usr/bin/setpriv#$stub_bin/setpriv#g" \
    -e 's#state_dir="$state_base/omarchy-update-stay-awake"#state_dir="$state_base/omarchy-update-stay-awake-${OMARCHY_TEST_RUN_ID:?}"#' \
    "$mapped_file"
done
chmod +x "$mapped_helper" "$mapped_root/default/omarchy/sudo-no-update/sudo"

run_helper() {
  HOME="$test_home" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  INHIBITOR_LOG="$inhibitor_log" \
  TEST_STATE_DIR="$state_dir" \
  OMARCHY_TEST_RUN_ID="$test_run_id" \
  OMARCHY_PATH="$mapped_root" \
  PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" \
    "$mapped_helper" "$@"
}

wait_dead() {
  local pid="$1"

  for _ in {1..100}; do
    kill -0 "$pid" 2>/dev/null || return 0
    [[ $(awk '{ print $3 }' "/proc/$pid/stat" 2>/dev/null || true) == "Z" ]] && return 0
    sleep 0.02
  done
  return 1
}

prepare_state_dir() {
  rm -rf "$state_dir"
  mkdir -m 700 "$state_dir"
}

write_inhibit_state() {
  local record="$1"

  printf '%s\n' "$record" >"$state_dir/inhibit-pid"
  chmod 600 "$state_dir/inhibit-pid"
}

start_identity_process() {
  local token="$1"

  /usr/bin/bash -c 'trap "exit 0" TERM; while :; do sleep 0.05; done' \
    omarchy-test "--why=Omarchy update in progress [$token]" &
  identity_pid=$!
  test_processes+=("$identity_pid")
  identity_start=$(awk '{ print $22 }' "/proc/$identity_pid/stat")
  identity_owner=$(stat -Lc '%u' "/proc/$identity_pid")
}

run_helper start
[[ -s $state_dir/inhibit-pid ]] || fail "valid XDG runtime publishes inhibitor state"
read -r version valid_pid valid_start valid_owner valid_token <"$state_dir/inhibit-pid"
[[ $version == "1" && $valid_token =~ ^[0-9a-f]{32}$ ]] || fail "inhibitor state is an exact versioned identity"
[[ $(stat -Lc '%u %a %h' "$state_dir/inhibit-pid") == "$(id -u) 600 1" ]] ||
  fail "inhibitor state is private, caller-owned, and singly linked"
run_helper stop
wait_dead "$valid_pid" || fail "valid inhibitor identity is stopped"
[[ ! -e $state_dir ]] || fail "valid state is cleaned after stop"
pass "valid XDG runtime uses private atomic inhibitor state"

permissive_runtime="$test_tmp/permissive-runtime"
mkdir -m 755 "$permissive_runtime"
if HOME="$test_home" XDG_RUNTIME_DIR="$permissive_runtime" PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" \
  OMARCHY_TEST_RUN_ID="$test_run_id" "$mapped_helper" stop 2>/dev/null; then
  fail "permissive XDG runtime is rejected"
fi
symlink_runtime="$test_tmp/runtime-link"
ln -s "$runtime_dir" "$symlink_runtime"
if HOME="$test_home" XDG_RUNTIME_DIR="$symlink_runtime" PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" \
  OMARCHY_TEST_RUN_ID="$test_run_id" "$mapped_helper" stop 2>/dev/null; then
  fail "symlink XDG runtime is rejected"
fi
if HOME="$test_home" XDG_RUNTIME_DIR="$test_tmp/../${test_tmp##*/}/runtime" PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" \
  OMARCHY_TEST_RUN_ID="$test_run_id" "$mapped_helper" stop 2>/dev/null; then
  fail "non-canonical XDG runtime is rejected"
fi
pass "unsafe XDG runtime directories are rejected"

mkdir -m 700 "$test_tmp/state-target"
ln -s "$test_tmp/state-target" "$state_dir"
if run_helper stop 2>/dev/null; then
  fail "symlink inhibitor state directory is rejected"
fi
rm -f "$state_dir"
mkdir -m 777 "$state_dir"
chmod 777 "$state_dir"
if run_helper stop 2>/dev/null; then
  fail "writable-by-others inhibitor state directory is rejected"
fi
rm -rf "$state_dir"
pass "unsafe inhibitor state directories are rejected"

# Package replacement leaves the preceding helper's PID/start pair and its
# umask-derived modes for the newly installed stop command to consume.
idle_marker="$test_home/.local/state/omarchy/indicators/stay-awake"
for modes in '755 644' '750 640' '700 600'; do
  read -r directory_mode file_mode <<<"$modes"
  for idle_choice in update user; do
    prepare_state_dir
    chmod "$directory_mode" "$state_dir"
    sleep infinity &
    legacy_pid=$!
    test_processes+=("$legacy_pid")
    legacy_start=$(awk '{ print $22 }' "/proc/$legacy_pid/stat")
    printf '%s %s\n' "$legacy_pid" "$legacy_start" >"$state_dir/inhibit-pid"
    printf '123:456:789\n' >"$state_dir/idle-owner"
    chmod "$file_mode" "$state_dir/"{inhibit-pid,idle-owner}
    mkdir -p "${idle_marker%/*}"
    if [[ $idle_choice == "update" ]]; then
      cp "$state_dir/idle-owner" "$idle_marker"
    else
      printf 'user-choice\n' >"$idle_marker"
    fi
    run_helper stop || fail "legacy $modes cleanup fails after helper replacement"
    wait_dead "$legacy_pid" || fail "legacy $modes inhibitor survives cleanup"
    [[ ! -e $state_dir ]] || fail "legacy $modes state survives cleanup"
    if [[ $idle_choice == "update" ]]; then
      [[ ! -e $idle_marker ]] || fail "legacy cleanup leaves update-owned Stay Awake enabled"
    else
      [[ $(<"$idle_marker") == "user-choice" ]] || fail "legacy cleanup changes the user's Stay Awake choice"
      rm -f "$idle_marker"
    fi
  done
done

for legacy_record in stale multiline nul; do
  prepare_state_dir
  chmod 755 "$state_dir"
  sleep infinity &
  legacy_pid=$!
  test_processes+=("$legacy_pid")
  legacy_start=$(awk '{ print $22 }' "/proc/$legacy_pid/stat")
  case "$legacy_record" in
    stale) printf '%s %s\n' "$legacy_pid" "$((legacy_start + 1))" ;;
    multiline) printf '%s %s\nextra\n' "$legacy_pid" "$legacy_start" ;;
    nul) printf '%s\0 %s\n' "$legacy_pid" "$legacy_start" ;;
  esac >"$state_dir/inhibit-pid"
  chmod 644 "$state_dir/inhibit-pid"
  if [[ $legacy_record == "stale" ]]; then
    run_helper stop
  elif run_helper stop 2>/dev/null; then
    fail "malformed legacy $legacy_record record was accepted"
  fi
  kill -0 "$legacy_pid" || fail "legacy $legacy_record record signaled an unrelated process"
  kill "$legacy_pid"
  wait "$legacy_pid" 2>/dev/null || true
done
pass "legacy upgrade cleanup preserves process identity and the user's idle choice"

prepare_state_dir
printf 'not a record\n' >"$state_dir/inhibit-pid"
chmod 600 "$state_dir/inhibit-pid"
if run_helper stop 2>/dev/null; then
  fail "malformed inhibitor state is rejected"
fi

token=11111111111111111111111111111111
start_identity_process "$token"
prepare_state_dir
printf '1 %s %s %s %s\nextra\n' "$identity_pid" "$identity_start" "$identity_owner" "$token" >"$state_dir/inhibit-pid"
chmod 600 "$state_dir/inhibit-pid"
if run_helper stop 2>/dev/null; then
  fail "multiline inhibitor state is rejected"
fi
kill -0 "$identity_pid" 2>/dev/null || fail "multiline state cannot signal its target"

prepare_state_dir
write_inhibit_state "1 $identity_pid $((identity_start + 1)) $identity_owner $token"
run_helper stop
kill -0 "$identity_pid" 2>/dev/null || fail "reused PID state cannot signal its target"

prepare_state_dir
write_inhibit_state "1 $identity_pid $identity_start $identity_owner 22222222222222222222222222222222"
run_helper stop
kill -0 "$identity_pid" 2>/dev/null || fail "wrong process identity cannot signal its target"
kill "$identity_pid"
wait_dead "$identity_pid" || true
pass "malformed, multiline, reused-PID, and wrong-identity records are harmless"

retry_flag="$test_tmp/allow-termination"
token=44444444444444444444444444444444
/usr/bin/bash -c '
  trap "" TERM
  while [[ ! -e $1 ]]; do sleep 0.05; done
  trap "exit 0" TERM
  while :; do sleep 0.05; done
' omarchy-retry "$retry_flag" "--why=Omarchy update in progress [$token]" &
retry_pid=$!
test_processes+=("$retry_pid")
retry_start=$(awk '{ print $22 }' "/proc/$retry_pid/stat")
retry_owner=$(stat -Lc '%u' "/proc/$retry_pid")
prepare_state_dir
write_inhibit_state "1 $retry_pid $retry_start $retry_owner $token"
if run_helper stop 2>/dev/null; then
  fail "failed termination reports success"
fi
[[ -s $state_dir/inhibit-pid ]] || fail "failed termination retains authenticated retry state"
touch "$retry_flag"
sleep 0.1
run_helper stop
wait_dead "$retry_pid" || fail "retained inhibitor state permits a successful retry"
pass "failed termination retains its authenticated retry handle"

for unsafe_kind in symlink permissive hardlink legacy-symlink legacy-permissive legacy-hardlink; do
  token=33333333333333333333333333333333
  start_identity_process "$token"
  prepare_state_dir
  record="1 $identity_pid $identity_start $identity_owner $token"
  [[ $unsafe_kind != legacy-* ]] || record="$identity_pid $identity_start"
  case "${unsafe_kind#legacy-}" in
    symlink)
      printf '%s\n' "$record" >"$test_tmp/state-victim"
      chmod 600 "$test_tmp/state-victim"
      ln -s "$test_tmp/state-victim" "$state_dir/inhibit-pid"
      ;;
    permissive)
      write_inhibit_state "$record"
      if [[ $unsafe_kind == "legacy-permissive" ]]; then
        chmod 666 "$state_dir/inhibit-pid"
      else
        chmod 644 "$state_dir/inhibit-pid"
      fi
      ;;
    hardlink)
      write_inhibit_state "$record"
      ln "$state_dir/inhibit-pid" "$state_hardlink"
      ;;
  esac
  if run_helper stop 2>/dev/null; then
    fail "$unsafe_kind inhibitor state is rejected"
  fi
  kill -0 "$identity_pid" 2>/dev/null || fail "$unsafe_kind state cannot signal its target"
  kill "$identity_pid"
  wait_dead "$identity_pid" || true
  rm -f "$test_tmp/state-victim" "$state_hardlink"
done
pass "symlink, permissive, and multiply-linked records are harmless"

: >"$inhibitor_log"
run_helper start
first_pid=$(tail -n 1 "$inhibitor_log")
run_helper start
second_pid=$(tail -n 1 "$inhibitor_log")
[[ $first_pid != "$second_pid" ]] || fail "repeated start replaces the inhibitor"
wait_dead "$first_pid" || fail "repeated start stops the prior inhibitor"
run_helper stop
run_helper stop
wait_dead "$second_pid" || fail "repeated stop remains idempotent"
pass "repeated start and stop preserve one inhibitor"

: >"$inhibitor_log"
concurrent_jobs=()
for _ in {1..4}; do
  (run_helper start; run_helper stop) &
  concurrent_jobs+=("$!")
done
for job in "${concurrent_jobs[@]}"; do
  wait "$job" || fail "concurrent start and stop are serialized"
done
run_helper stop
while read -r pid; do
  [[ -n $pid ]] || continue
  wait_dead "$pid" || fail "concurrent operation leaves no inhibitor behind"
done <"$inhibitor_log"
pass "concurrent state operations are serialized"

if SYSTEMD_FAIL=1 run_helper start; then
  fail "failed systemd-inhibit launch reports success"
fi
[[ ! -e $state_dir/inhibit-pid ]] || fail "failed inhibitor launch publishes no PID state"
run_helper stop
pass "failed inhibitor launch leaves no stale process state"

: >"$inhibitor_log"
rollback_victim="$test_tmp/rollback-victim"
: >"$rollback_victim"
if CREATE_BAD_IDLE="$rollback_victim" run_helper start 2>/dev/null; then
  fail "unsafe idle publication reports success"
fi
rollback_pid=$(tail -n 1 "$inhibitor_log")
wait_dead "$rollback_pid" || fail "post-publication failure rolls the inhibitor back"
[[ ! -e $state_dir ]] || fail "rollback removes published inhibitor and idle ownership state"
pass "state publication failures roll back a launched inhibitor"

# Hold each cancellation window open, including publication before child exec,
# readiness before idle setup, and publication of the update-owned idle marker.
cp "$mapped_helper" "$test_tmp/helper-before-pause"
idle_marker="$test_home/.local/state/omarchy/indicators/stay-awake"
for cancel_phase in published ready idle-temporary idle user-idle; do
  rm -f "$test_tmp/cancel-ready" "$test_tmp/release-child"
  if [[ $cancel_phase == "user-idle" ]]; then
    mkdir -p "${idle_marker%/*}"
    printf 'user-choice\n' >"$idle_marker"
  fi
  python3 - "$mapped_helper" "$cancel_phase" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
pause = ': >"$TEST_CANCEL_READY"; while :; do /usr/bin/sleep 0.02; done'
if sys.argv[2] == 'published':
    anchor = '  while :; do\n    inhibit_record='
    edits = [(anchor, '  ' + pause + '\n' + anchor),
             ('      exec -a "$expected"',
              '      while [[ ! -e $TEST_RELEASE_CHILD ]]; do /usr/bin/sleep 0.02; done\n      exec -a "$expected"')]
elif sys.argv[2] == 'idle-temporary':
    anchor = '  temporary=$(mktemp "$state_dir/.${state_file##*/}.XXXXXXXX") || return 1'
    edits = [(anchor, anchor + '\n  if [[ $state_file == "$idle_owner_file" ]]; then ' + pause + '; fi')]
elif sys.argv[2] == 'idle':
    anchor = '''printf '%s\\n' "$idle_owner" >"$stay_awake_state"'''
    edits = [(anchor, '{ ' + anchor + ' && { ' + pause + '; }; }')]
else:
    anchor = '  if [[ ! -f $stay_awake_state ]]; then'
    edits = [(anchor, '  ' + pause + '\n' + anchor)]
for old, new in edits:
    assert s.count(old) == 1, old
    s = s.replace(old, new)
p.write_text(s)
PY
  (
    export HOME="$test_home" XDG_RUNTIME_DIR="$runtime_dir" OMARCHY_PATH="$mapped_root"
    export INHIBITOR_LOG="$inhibitor_log" OMARCHY_TEST_RUN_ID="$test_run_id"
    export TEST_CANCEL_READY="$test_tmp/cancel-ready" TEST_RELEASE_CHILD="$test_tmp/release-child"
    export PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin"
    exec "$mapped_helper" start
  ) >"$test_tmp/$cancel_phase-cancel.log" 2>&1 &
  cancelled_launcher=$!
  test_processes+=("$cancelled_launcher")
  for _ in {1..100}; do
    [[ -e $test_tmp/cancel-ready && -s $state_dir/inhibit-pid ]] && break
    sleep 0.02
  done
  [[ -e $test_tmp/cancel-ready && -s $state_dir/inhibit-pid ]] || fail "$cancel_phase cancellation reached its barrier"
  read -r _ published_pid _ <"$state_dir/inhibit-pid"
  test_processes+=("$published_pid")
  kill -TERM "$cancelled_launcher"
  cancelled_status=0
  wait "$cancelled_launcher" || cancelled_status=$?
  (( cancelled_status == 143 )) || fail "$cancel_phase launch preserves cancellation status"
  touch "$test_tmp/release-child"
  wait_dead "$published_pid" || fail "$cancel_phase cancellation leaked the held child"
  [[ ! -e $state_dir ]] || fail "$cancel_phase cancellation left launch state"
  if [[ $cancel_phase == "user-idle" ]]; then
    [[ $(<"$idle_marker") == "user-choice" ]] || fail "cancellation changed the user's Stay Awake choice"
    rm -f "$idle_marker"
  else
    [[ ! -e $idle_marker ]] || fail "$cancel_phase cancellation left Stay Awake enabled"
  fi
  cp "$test_tmp/helper-before-pause" "$mapped_helper"
done
pass "cancellation through idle setup stops the child and restores only update-owned idle state"

namespace_args=()
namespace_probe_error="$test_tmp/namespace-probe.err"
if (( EUID == 0 )); then
  namespace_args=(
    unshare --user --mount --fork
    --map-users=0:0:1 --map-users=1000:1000:2
    --map-groups=0:0:1 --map-groups=1000:1000:2
    --setuid=0 --setgid=0
  )
else
  subordinate_uid=$(awk -F: -v user="$(id -un)" '$1 == user { print $2; exit }' /etc/subuid 2>/dev/null || true)
  subordinate_gid=$(awk -F: -v user="$(id -un)" '$1 == user { print $2; exit }' /etc/subgid 2>/dev/null || true)
  if [[ $subordinate_uid =~ ^[0-9]+$ && $subordinate_gid =~ ^[0-9]+$ ]]; then
    namespace_args=(
      unshare --user --mount --fork
      "--map-users=0:$(id -u):1" "--map-users=1000:$subordinate_uid:2"
      "--map-groups=0:$(id -g):1" "--map-groups=1000:$subordinate_gid:2"
      --setuid=0 --setgid=0
    )
  fi
fi

namespace_capable=0
if (( ${#namespace_args[@]} > 0 )) &&
  "${namespace_args[@]}" /usr/bin/bash -c '
    set -e
    mount -t tmpfs -o mode=1777 tmpfs /tmp
    setpriv --reuid=1000 --regid=1000 --clear-groups true
    setpriv --reuid=1001 --regid=1001 --clear-groups true
  ' 2>"$namespace_probe_error"; then
  namespace_capable=1
fi

if (( namespace_capable == 0 )); then
  skip "cross-UID fallback probe: two-UID mount namespace unavailable"
else
  # Keep the protected entrypoint, shared helper and harmless command stubs
  # together, even when tmpfs hides a checkout or fixture under /tmp.
  tar -C "$test_tmp" -cf "$test_tmp/namespace-fixture.tar" bin omarchy
  if ! "${namespace_args[@]}" /usr/bin/bash -s -- "$test_tmp" "$test_run_id" \
    9<"$test_tmp/namespace-fixture.tar" <<'SH'
set -euo pipefail
fixture=$1
run_id=$2
mount -t tmpfs -o mode=1777 tmpfs /tmp
mkdir -m 755 "$fixture"
tar -C "$fixture" -xf /proc/self/fd/9
exec 9<&-
mkdir -m 700 /tmp/victim-home
chown 1000:1000 /tmp/victim-home

setpriv --reuid=1000 --regid=1000 --clear-groups sleep 30 &
victim_pid=$!
trap 'kill "$victim_pid" "${legacy_sudo_pid:-$victim_pid}" 2>/dev/null || true; wait "$victim_pid" 2>/dev/null || true' EXIT
victim_start=$(awk '{ print $22 }' "/proc/$victim_pid/stat")
state=/tmp/omarchy-1000/omarchy-update-stay-awake-$run_id

run_fallback() {
  local uid=$1 home=$2
  shift 2
  setpriv --reuid="$uid" --regid="$uid" --clear-groups /usr/bin/env -i \
    HOME="$home" OMARCHY_PATH="$fixture/omarchy" OMARCHY_TEST_RUN_ID="$run_id" \
    INHIBITOR_LOG="$home/inhibitors" PATH="$fixture/bin:/usr/bin:/bin" \
    "$fixture/omarchy/bin/omarchy-update-stay-awake" "$@"
}

setpriv --reuid=1001 --regid=1001 --clear-groups /usr/bin/bash -c '
  mkdir -m 755 /tmp/omarchy-1000 "$3"
  printf "%s %s\n" "$1" "$2" >"$3/inhibit-pid"
  chmod 644 "$3/inhibit-pid"
' attacker "$victim_pid" "$victim_start" "$state"

if run_fallback 1000 /tmp/victim-home stop 2>/tmp/refusal; then
  echo "foreign fallback state was accepted" >&2
  exit 1
fi
grep -q 'unsafe Omarchy update inhibitor state path' /tmp/refusal
kill -0 "$victim_pid"

rm -rf /tmp/omarchy-1000
# The old helper also left a readable fallback parent after a successful stop.
setpriv --reuid=1000 --regid=1000 --clear-groups mkdir -m 755 /tmp/omarchy-1000
run_fallback 1000 /tmp/victim-home start
[[ $(stat -Lc '%u %a' /tmp/omarchy-1000) == "1000 700" ]]
run_fallback 1000 /tmp/victim-home stop
[[ ! -e $state ]]

mkdir -m 700 "$state"
chown 1000:1000 "$state"
printf '1 %s %s 1000 %032d\n' "$victim_pid" "$victim_start" 0 \
  >"$state/inhibit-pid"
chown 1001:1001 "$state/inhibit-pid"
chmod 600 "$state/inhibit-pid"
if run_fallback 1000 /tmp/victim-home stop 2>/tmp/refusal; then
  echo "foreign state file was accepted" >&2
  exit 1
fi
grep -q 'unsafe Omarchy update sleep inhibitor state' /tmp/refusal
kill -0 "$victim_pid"

# A legacy-looking record owned by another account is still untrusted.
mkdir -m 700 "$state"
chown 1000:1000 "$state"
printf '%s %s\n' "$victim_pid" "$victim_start" >"$state/inhibit-pid"
chown 1001:1001 "$state/inhibit-pid"
chmod 644 "$state/inhibit-pid"
if run_fallback 1000 /tmp/victim-home stop 2>/tmp/refusal; then
  echo "foreign legacy state file was accepted" >&2
  exit 1
fi
kill -0 "$victim_pid"

# The old terminal helper recorded sudo, with the caller's real UID but an
# effective root UID. Its /proc owner is root; the caller can still signal it.
setpriv --ruid=1000 --euid=0 --regid=1000 --clear-groups sleep 30 &
legacy_sudo_pid=$!
for _ in {1..50}; do
  [[ $(awk '/^Uid:/ { print $2, $3 }' "/proc/$legacy_sudo_pid/status") == "1000 0" ]] && break
  sleep .02
done
[[ $(awk '/^Uid:/ { print $2, $3 }' "/proc/$legacy_sudo_pid/status") == "1000 0" ]]
mkdir -m 755 "$state"
chown 1000:1000 "$state"
printf '%s %s\n' "$legacy_sudo_pid" "$(awk '{ print $22 }' "/proc/$legacy_sudo_pid/stat")" >"$state/inhibit-pid"
chown 1000:1000 "$state/inhibit-pid"
chmod 644 "$state/inhibit-pid"
run_fallback 1000 /tmp/victim-home stop
[[ ! -e /proc/$legacy_sudo_pid || $(awk '{ print $3 }' "/proc/$legacy_sudo_pid/stat") == "Z" ]]
wait "$legacy_sudo_pid" 2>/dev/null || true

# Root may read the record, but must not signal a live legacy target whose
# real UID differs. Preserve the retry handle instead of treating it as dead.
mkdir -m 700 /tmp/root-home
root_state=/tmp/omarchy-0/omarchy-update-stay-awake-$run_id
mkdir -p "$root_state"
printf '%s %s\n' "$victim_pid" "$victim_start" >"$root_state/inhibit-pid"
chmod 644 "$root_state/inhibit-pid"
if run_fallback 0 /tmp/root-home stop 2>/tmp/refusal; then
  echo "legacy cleanup accepted another account's live process" >&2
  exit 1
fi
grep -q 'retained its state for recovery' /tmp/refusal
[[ -s $root_state/inhibit-pid ]]
kill -0 "$victim_pid"
rm "$root_state/inhibit-pid"

run_fallback 0 /tmp/root-home start
[[ $(stat -Lc '%u %a' /tmp/omarchy-0) == "0 700" ]]
run_fallback 0 /tmp/root-home stop
[[ ! -e /tmp/omarchy-0/omarchy-update-stay-awake-$run_id ]]
SH
  then
    fail "two-UID fallback probe failed after its capability check" "$(<"$namespace_probe_error")"
  fi
  pass "foreign UID fallback state cannot kill a victim and safe fallback works"
fi
