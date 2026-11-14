#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_root="$test_tmp/run-user"
state_dir="$test_tmp/state"
hyprctl_log="$test_tmp/hyprctl.log"
fake_hyprctl="$test_tmp/hyprctl"
signature="test-signature"
runtime_dir="$run_root/$EUID"

dead_signature="dead-signature"

mkdir -p "$runtime_dir/hypr/$signature" "$runtime_dir/hypr/$dead_signature"

cat >"$fake_hyprctl" <<'BASH'
#!/bin/bash

fixture_dir="${0%/*}"
printf '%s\t%s\n' "$XDG_RUNTIME_DIR" "$*" >>"$fixture_dir/hyprctl.log"
[[ ! -f $fixture_dir/hang ]] || sleep 30

case "$*" in
  *'--instance dead-signature '*)
    printf "Couldn't connect to %s/hypr/dead-signature/.socket.sock. (4)\n" "$XDG_RUNTIME_DIR"
    exit 4
    ;;
  *'-j instances')
    printf '[{"instance":"test-signature","pid":4242}]\n'
    ;;
  *'getoption misc.disable_autoreload'*)
    cat "$fixture_dir/disable.json"
    ;;
  *'getoption debug.suppress_errors'*)
    cat "$fixture_dir/suppress.json"
    ;;
  *)
    printf 'ok\n'
    ;;
esac
BASH
chmod 0755 "$fake_hyprctl"
printf '{"bool":false}\n' >"$test_tmp/disable.json"
printf '{"bool":false}\n' >"$test_tmp/suppress.json"

HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause 2>"$test_tmp/pause-stderr"

state_file="$state_dir/private/$EUID/$signature"
[[ -f $state_file ]] || fail "reload guard stores Hyprland state on pause"
expected_state=$(printf '%s\tfalse\tfalse' "$runtime_dir")
grep -Fx "$expected_state" "$state_file" >/dev/null || fail "reload guard records previous Hyprland reload settings"
grep -F 'hl.config({ misc = { disable_autoreload = true }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null || fail "reload guard pauses autoreload with hyprctl eval"
pass "reload guard pauses live Hyprland reloads"

[[ ! -e $state_dir/private/$EUID/$dead_signature ]] || fail "reload guard skips instances hyprctl cannot reach"
[[ ! -s $test_tmp/pause-stderr ]] || fail "reload guard pauses dead Hyprland instances quietly" "$(cat "$test_tmp/pause-stderr")"
pass "reload guard skips dead Hyprland instances quietly"

: >"$hyprctl_log"
HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_PROC_ROOT="$test_tmp/proc" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume

[[ ! -e $state_file ]] || fail "reload guard clears Hyprland state after resume"
grep -F -- '--instance test-signature reload' "$hyprctl_log" >/dev/null || fail "reload guard forces one Hyprland reload after package transaction"
grep -F 'hl.config({ misc = { disable_autoreload = false }, debug = { suppress_errors = false } })' "$hyprctl_log" >/dev/null || fail "reload guard restores previous Hyprland reload settings"
pass "reload guard resumes live Hyprland reloads"

# Once an upgrade replaces the binary under the running compositor, that one
# predates the new config, so reloading would show it errors for new keys.
proc_root="$test_tmp/proc"
mkdir -p "$proc_root/4242"
ln -s "/usr/bin/Hyprland (deleted)" "$proc_root/4242/exe"
run_guard() {
  HYPRCTL="$fake_hyprctl" \
    OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
    OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
    OMARCHY_HYPRLAND_RELOAD_GUARD_PROC_ROOT="$proc_root" \
    "$ROOT/bin/omarchy-hyprland-reload-guard" "$1"
}
run_guard pause
: >"$hyprctl_log"
run_guard resume
[[ ! -e $state_file ]] || fail "reload guard clears state for a compositor whose binary was replaced"
if grep -F -e '--instance test-signature reload' -e 'suppress_errors = false' "$hyprctl_log" >/dev/null; then
  fail "reload guard reloads a compositor whose binary was replaced" "$(cat "$hyprctl_log")"
fi
pass "reload guard leaves a compositor whose binary was replaced paused until it restarts"

# The modeless monitor recovery loop reloads on its own schedule, so it needs to
# ask whether a transaction is in flight.
rm -rf "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused before any transaction"

mkdir -p "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "an empty state directory is not a paused transaction"

touch "$state_dir/some-signature"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "reload guard reports itself paused during a transaction"
pass "reload guard reports whether a transaction is holding reloads"

rm -f "$proc_root/4242/exe"
rm -rf "$state_dir"
printf '{"bool":true}\n' >"$test_tmp/disable.json"
printf '{"bool":true}\n' >"$test_tmp/suppress.json"
run_guard pause
[[ $(stat -c %a "$state_dir/private") == "700" && $(stat -c %a "$state_file") == "600" ]] ||
  fail "saved reload settings are private"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "the public pause marker is visible while state is private"
: >"$hyprctl_log"
run_guard resume
grep -F 'hl.config({ misc = { disable_autoreload = true }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null ||
  fail "true settings survive pause and resume"
pass "reload guard preserves true settings and keeps state private"

# These inputs previously became Lua or were silently accepted as missing data.
printf '{"bool":false}\n' >"$test_tmp/disable.json"
for response in '{"bool":"false } }); INJECTED = true; --"}' '{"bool":"false"}' '{"bool":null}' '{"bool":0}' '{}' '{"bool":false} {"bool":true}'; do
  for option in disable suppress; do
    printf '{"bool":false}\n' >"$test_tmp/disable.json"
    printf '{"bool":false}\n' >"$test_tmp/suppress.json"
    printf '%s\n' "$response" >"$test_tmp/$option.json"
    : >"$hyprctl_log"
    run_guard pause
    [[ ! -e $state_file ]] || fail "invalid $option JSON created saved state" "$response"
    ! grep -F ' eval ' "$hyprctl_log" >/dev/null || fail "invalid $option JSON reached eval" "$response"
    run_guard resume
  done
done
printf '{"bool":false}\n' >"$test_tmp/disable.json"
printf '{"bool":false}\n' >"$test_tmp/suppress.json"
pass "reload guard rejects non-boolean and multiple JSON replies for both options"

# The first fixed resume may receive state written by the vulnerable pause.
mkdir -p "$state_dir"
printf '%s\tfalse\tfalse } }); INJECTED = true; --\n' "$runtime_dir" >"$state_dir/$signature"
: >"$hyprctl_log"
run_guard resume
[[ ! -s $hyprctl_log && ! -e $state_dir/$signature ]] || fail "malicious legacy state reached IPC or survived cleanup"
mkdir -p "$state_dir"
printf '%s\tfalse\ttrue\n' "$runtime_dir" >"$state_dir/$signature"
run_guard resume
grep -F 'hl.config({ misc = { disable_autoreload = false }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null ||
  fail "valid legacy state was not restored"
pass "reload guard validates and restores legacy state during its own upgrade"

run_guard pause
mv "$runtime_dir/hypr" "$runtime_dir/hypr-original"
ln -s "$runtime_dir/hypr-original" "$runtime_dir/hypr"
: >"$hyprctl_log"
run_guard resume
[[ ! -s $hyprctl_log && ! -e $state_file ]] || fail "resume followed a replaced Hyprland directory"
run_guard pause
[[ ! -s $hyprctl_log ]] || fail "pause discovered a symlinked Hyprland directory"
rm "$runtime_dir/hypr"
mv "$runtime_dir/hypr-original" "$runtime_dir/hypr"
pass "reload guard skips symlinked directories at pause and after replacement"

touch "$test_tmp/hang"
started=$SECONDS
run_guard pause
(( SECONDS - started < 6 )) || fail "an unresponsive socket held the package transaction"
[[ ! -e $state_file ]] || fail "an unresponsive socket created saved state"
rm "$test_tmp/hang"
pass "reload guard bounds waits for unresponsive IPC"

# Run this file under a root user namespace with subordinate UID/GID mappings
# for real kernel permission checks, without creating accounts or touching IPC
# in the development session. Ordinary runs retain all parser coverage above.
if (( EUID != 0 )) || ! setpriv --reuid=65534 --regid=65534 --clear-groups true 2>/dev/null; then
  skip "root with subordinate IDs unavailable; cross-user IPC isolation"
  exit 0
fi
require_command hyprctl
chmod 0755 "$test_tmp"
python - "$ROOT/bin/omarchy-hyprland-reload-guard" "$test_tmp" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
import time

guard, scratch = sys.argv[1:]
base = Path(scratch) / "ipc-users"
base.mkdir(mode=0o755)
state = Path(scratch) / "ipc-state"
signature = "test_1700000000_123"
processes = []
server = r'''
import json, os, socket, struct, sys
from pathlib import Path
instance = Path(sys.argv[1])
(instance / "hyprland.lock").write_text(f"{os.getpid()}\nwayland-9\n")
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as listener:
    listener.bind(str(instance / ".socket.sock"))
    listener.listen(8)
    while True:
        connection, _ = listener.accept()
        with connection:
            pid, uid, gid = struct.unpack("3i", connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))
            request = connection.recv(8192).decode()
            status = dict(line.split(":", 1) for line in Path(f"/proc/{pid}/status").read_text().splitlines() if ":" in line)
            credentials = {name: status[name].strip() for name in ("Groups", "CapInh", "CapPrm", "CapEff", "CapBnd", "CapAmb", "NoNewPrivs")}
            with (instance / "requests").open("a") as log:
                log.write(json.dumps({"uid": uid, "gid": gid, "request": request, "credentials": credentials}) + "\n")
            response = json.dumps({"bool": os.getuid() == 1}) if "getoption" in request else "ok"
            connection.sendall((response + "\n").encode())
'''

def as_user(uid, *args, **kwargs):
    return subprocess.run(["setpriv", f"--reuid={uid}", f"--regid={uid}", "--clear-groups", *args], **kwargs)

def requests(uid):
    path = base / str(uid) / "hypr" / signature / "requests"
    return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

def run(action):
    env = dict(os.environ, HYPRCTL="/usr/bin/hyprctl",
               OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT=str(base),
               OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR=str(state))
    subprocess.run([guard, action], env=env, check=True, timeout=40, capture_output=True)

try:
    for uid in (1, 65534):
        runtime = base / str(uid)
        for directory in (runtime, runtime / "hypr", runtime / "hypr" / signature):
            directory.mkdir(mode=0o700)
            os.chown(directory, uid, uid)
        instance = runtime / "hypr" / signature
        process = subprocess.Popen(["setpriv", f"--reuid={uid}", f"--regid={uid}", "--clear-groups",
                                    "/usr/bin/python", "-c", server, str(instance)], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        processes.append(process)
        for _ in range(100):
            if (instance / ".socket.sock").exists():
                break
            assert process.poll() is None, f"IPC fixture exited: {process.stderr.read().decode()}"
            time.sleep(0.02)
        assert (instance / ".socket.sock").exists(), "IPC fixture did not start"

    run("pause")
    for uid in (1, 65534):
        saved = state / "private" / str(uid) / signature
        assert saved.exists(), "identical signatures across UIDs collided"
        assert as_user(uid, "test", "-r", str(saved)).returncode != 0, "private state is readable by a desktop user"
        env = dict(os.environ, OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR=str(state))
        assert as_user(uid, guard, "paused", env=env).returncode == 0, "private state hid the transaction marker"
        assert requests(uid) and all(r["uid"] == uid and r["gid"] == uid for r in requests(uid)), "IPC borrowed root credentials"
        for request in requests(uid):
            credentials = request["credentials"]
            assert not credentials["Groups"], "IPC retained supplementary groups"
            assert all(int(credentials[name], 16) == 0 for name in ("CapInh", "CapPrm", "CapEff", "CapBnd", "CapAmb")), "IPC retained capabilities"
            assert credentials["NoNewPrivs"] == "1", "IPC can regain privileges"
    print("ok - real IPC uses each owner's credentials and isolates identical session signatures")

    # Keep every directory genuine and owned by its user. Only replace the
    # socket, so directory checks alone cannot stop the confused deputy.
    attacker_socket = base / "65534" / "hypr" / signature / ".socket.sock"
    victim_socket = base / "1" / "hypr" / signature / ".socket.sock"
    as_user(65534, "rm", str(attacker_socket), check=True)
    as_user(65534, "ln", "-s", str(victim_socket), str(attacker_socket), check=True)
    run("resume")
    victim_requests = requests(1)
    assert all(r["uid"] == 1 for r in victim_requests), "redirected IPC reached another account"
    assert not any("suppress_errors = false" in r["request"] for r in victim_requests), "attacker state reached the victim"
    assert not state.exists(), "cross-user state or pause marker survived resume"
    print("ok - real kernel permissions block socket replacement into another user's compositor")

    # One account's timeout allowance must neither starve another account nor
    # renew when legacy entries revisit its UID after processing someone else.
    budget_base = Path(scratch) / "budget-users"
    budget_base.mkdir(mode=0o755)
    budget_state = Path(scratch) / "budget-state"
    budget_hyprctl = Path(scratch) / "budget-hyprctl"
    budget_hyprctl.write_text('''#!/bin/bash
printf '%s\\n' "$*" >>"$XDG_RUNTIME_DIR/requests"
[[ ! -f $XDG_RUNTIME_DIR/stall ]] || sleep 30
case "$*" in
  *'-j instances') printf '[]\\n' ;;
  *'getoption'*) printf '{"bool":false}\\n' ;;
  *) printf 'ok\\n' ;;
esac
''')
    budget_hyprctl.chmod(0o755)
    for uid in (1, 65534):
        for directory in (budget_base / str(uid), budget_base / str(uid) / "hypr"):
            directory.mkdir(mode=0o700)
            os.chown(directory, uid, uid)
        for name in ("current", "legacy-a", "legacy-z"):
            directory = budget_base / str(uid) / "hypr" / name
            directory.mkdir(mode=0o700)
            os.chown(directory, uid, uid)

    def budget_run(action):
        env = dict(os.environ, HYPRCTL=str(budget_hyprctl),
                   OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT=str(budget_base),
                   OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR=str(budget_state))
        subprocess.run([guard, action], env=env, check=True, timeout=40, capture_output=True)

    def budget_requests(uid):
        path = budget_base / str(uid) / "requests"
        return path.read_text() if path.exists() else ""

    (budget_base / "1" / "stall").touch()
    budget_run("pause")
    assert (budget_state / "private" / "65534" / "current").exists(), "hostile IPC prevented healthy pause"
    (budget_base / "1" / "stall").unlink()
    budget_run("pause")
    # Move genuine saved state into the old layout to exercise the first update.
    (budget_state / "private" / "1" / "legacy-a").rename(budget_state / "legacy-a")
    (budget_state / "private" / "65534" / "legacy-z").rename(budget_state / "legacy-z")
    for uid in (1, 65534):
        (budget_base / str(uid) / "requests").write_text("")
    (budget_base / "1" / "stall").touch()
    budget_run("resume")
    assert "--instance current reload" in budget_requests(65534), "hostile IPC prevented healthy restore"
    assert "--instance legacy-z reload" in budget_requests(65534), "hostile IPC prevented healthy legacy restore"
    assert "--instance legacy-a" not in budget_requests(1), "legacy state renewed an exhausted account's allowance"
    (budget_base / "1" / "stall").unlink()
    budget_run("pause")
    (budget_state / "private" / "1" / "legacy-a").rename(budget_state / "legacy-a")
    for uid in (1, 65534):
        (budget_base / str(uid) / "requests").write_text("")
    (budget_base / "65534" / "stall").touch()
    budget_run("resume")
    assert "--instance legacy-a reload" in budget_requests(1), "another account's IPC time consumed healthy legacy allowance"
    assert not budget_state.exists(), "per-account timeout left a stale transaction marker"
    print("ok - hostile IPC cannot consume another account's pause or legacy restore allowance")
finally:
    for process in processes:
        process.terminate()
    for process in processes:
        process.wait(timeout=5)
PY
