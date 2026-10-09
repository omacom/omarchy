#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

hook="$tmpdir/unmount-fuse"
users="$tmpdir/users"
mock_bin="$tmpdir/bin"
call_dir="$tmpdir/calls"
boundary_log="$tmpdir/boundaries"
mkdir -p "$mock_bin" "$call_dir"

# Redirect only the hook's fixed enumeration root. Closed Unix sockets retain
# their filesystem type; no listener, user bus or privileged service is needed.
python3 - "$ROOT/default/systemd/system-sleep/unmount-fuse" "$hook" "$users" <<'PY'
from pathlib import Path
import shlex, socket, sys

source, destination, users = map(Path, sys.argv[1:])
text = source.read_text()
if text.count('/run/user/*') != 1:
  raise SystemExit('Expected exactly one user-root redirect in the sleep hook')
destination.write_text(text.replace('/run/user/*', shlex.quote(str(users)) + '/*'))
for uid in ['1000', '1001', '1002', '1003', '1004']:
  (users / uid).mkdir(parents=True)
for uid in ['1000', '1001']:
  with socket.socket(socket.AF_UNIX) as bus:
    bus.bind(str(users / uid / 'bus'))
(users / '1002' / 'bus').write_text('not a socket\n')
(users / '1003' / 'bus').mkdir()
PY

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
number=1
[[ ! -f $TEST_CALL_DIR/count ]] || number=$(( $(<"$TEST_CALL_DIR/count") + 1 ))
printf '%s\n' "$number" >"$TEST_CALL_DIR/count"
printf '%s\0' "$@" >"$TEST_CALL_DIR/systemd-run.$number"
for arg in "$@"; do
  if [[ -n ${TEST_FAIL_UID:-} && $arg == "--uid=$TEST_FAIL_UID" ]]; then
    exit 1
  fi
done
SH

# Record unexpected boundaries without ever invoking the host's commands.
for cmd in sudo systemctl fusermount3 fusermount; do
  cat >"$mock_bin/$cmd" <<SH
#!/bin/bash
printf '%s %s\n' "$cmd" "\$*" >>"\$TEST_BOUNDARY_LOG"
SH
done
chmod +x "$mock_bin/"*

run_resume() {
  rm -f "$call_dir/count" "$call_dir/"systemd-run.*
  : >"$boundary_log"
  resume_status=0
  # A leftover child holds this pipe open. Poisoned inherited bus variables
  # must not replace the explicit destination environment for either user.
  PATH="$mock_bin:$PATH" TEST_CALL_DIR="$call_dir" TEST_BOUNDARY_LOG="$boundary_log" \
    TEST_FAIL_UID="${TEST_FAIL_UID:-}" DBUS_SESSION_BUS_ADDRESS="unix:path=$tmpdir/decoy-bus" \
    XDG_RUNTIME_DIR="$tmpdir/decoy-runtime" \
    timeout 2 bash -o pipefail -c 'bash "$1" post suspend | cat' _ "$hook" >/dev/null || resume_status=$?
}

assert_schedule() {
  local number=$1 uid=$2
  local -a actual expected=(
    --quiet --no-block --collect --on-active=5 --timer-property=AccuracySec=1s "--uid=$uid"
    "--setenv=DBUS_SESSION_BUS_ADDRESS=unix:path=$users/$uid/bus"
    "--setenv=XDG_RUNTIME_DIR=$users/$uid"
    systemctl --user restart gvfs-daemon.service
  )
  [[ -f $call_dir/systemd-run.$number ]] || fail "resume schedules synthetic user $uid"
  mapfile -d '' -t actual <"$call_dir/systemd-run.$number"
  [[ ${#actual[@]} == ${#expected[@]} ]] || fail "user $uid receives exactly the restart arguments"
  local i
  for i in "${!expected[@]}"; do
    [[ ${actual[i]} == "${expected[i]}" ]] ||
      fail "user $uid receives its own scoped timer and bus environment" "argument $i: ${actual[i]}"
  done
}

run_resume
assert_schedule 1 1000
pass "resume scopes the first synthetic user's restart and environment"
assert_schedule 2 1001
pass "resume scopes the second synthetic user's restart and environment"

(( resume_status == 0 )) || fail "resume leaves nothing running behind the hook"
pass "resume leaves nothing running behind the hook"
[[ ! -s $boundary_log ]] || fail "resume never invokes sudo or direct service commands" "$(cat "$boundary_log")"
pass "resume never invokes sudo or direct service commands"
[[ $(<"$call_dir/count") == "2" ]] || fail "non-socket and absent bus paths are skipped"
pass "non-socket and absent bus paths are skipped"

TEST_FAIL_UID=1000 run_resume
(( resume_status == 0 )) || fail "one scheduling failure does not fail the resume hook"
assert_schedule 1 1000
assert_schedule 2 1001
[[ $(<"$call_dir/count") == "2" && ! -s $boundary_log ]] || fail "one failure still schedules only the other eligible user"
pass "one user's scheduling failure does not hide the second user's restart"

rm -rf "$users/"*
run_resume
(( resume_status == 0 )) || fail "resume without user buses succeeds"
[[ ! -f $call_dir/count && ! -s $boundary_log ]] || fail "resume without user buses schedules nothing"
pass "resume without user buses schedules nothing"
