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

unverified_signals=$(grep -nE '(^|[[:space:]])kill ([^-]|-[^0])[^#]*\$inhibit_pid' \
  "$ROOT/bin/omarchy-update-stay-awake" || true)
if [[ -n $unverified_signals ]]; then
  fail "inhibitor signals bypass identity verification" "$unverified_signals"
fi
grep -q 'signal_inhibitor .* KILL' "$ROOT/bin/omarchy-update-stay-awake" ||
  fail "delayed inhibitor cleanup revalidates the full identity before KILL"
pass "every inhibitor signal is identity-bound"

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
mkdir -m 755 "$state_dir"
if run_helper stop 2>/dev/null; then
  fail "permissive inhibitor state directory is rejected"
fi
rm -rf "$state_dir"
pass "unsafe inhibitor state directories are rejected"

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

for unsafe_kind in symlink permissive hardlink; do
  token=33333333333333333333333333333333
  start_identity_process "$token"
  prepare_state_dir
  record="1 $identity_pid $identity_start $identity_owner $token"
  case "$unsafe_kind" in
    symlink)
      printf '%s\n' "$record" >"$test_tmp/state-victim"
      chmod 600 "$test_tmp/state-victim"
      ln -s "$test_tmp/state-victim" "$state_dir/inhibit-pid"
      ;;
    permissive)
      write_inhibit_state "$record"
      chmod 644 "$state_dir/inhibit-pid"
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
[[ ! -e $state_dir/inhibit-pid ]] || fail "rollback removes published inhibitor state"
pass "state publication failures roll back a launched inhibitor"

# A record owned by another account is refused by the same owner, mode and
# link checks exercised above, and a forged record cannot name a victim
# because the random token and process start time are revalidated before any
# signal. Exercising the foreign-owner branch itself needs a second UID, which
# this fixture does not create.
