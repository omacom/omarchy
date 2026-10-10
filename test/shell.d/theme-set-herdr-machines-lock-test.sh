#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A private umask would make the fallback dir 700 without the chmod under test.
umask 022
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
state_home="$test_tmp/state"
lock_dir="$state_home/omarchy"
lock="$lock_dir/omarchy-theme-set-herdr-machines.lock"
mkdir -p "$test_tmp/home" "$stub_bin"

# No machines listed: the run stops after the toggle check, once the lock is held.
cat >"$stub_bin/herdr" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$stub_bin/herdr"

run_no_runtime_dir() {
  env -u XDG_RUNTIME_DIR \
    HOME="$test_tmp/home" XDG_STATE_HOME="$state_home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    timeout 5 omarchy-theme-set-herdr-machines
}

# A lock in world-writable /tmp can be opened read-only and held by another account,
# starving every theme sync, so without a session runtime dir it lives in private state.
run_no_runtime_dir >/dev/null 2>&1 || fail "runs without a session runtime dir"
[[ -f $lock ]] || fail "lock lands in the private state dir"
pass "lock lands in the private state dir"

[[ $(stat -c %a "$lock_dir") == "700" ]] || fail "fallback lock dir is private" "mode $(stat -c %a "$lock_dir")"
pass "fallback lock dir is private"

# Moving the lock must not lose it: a run waits while the lock is held.
exec 8<"$lock"
flock 8
status=0
run_no_runtime_dir >/dev/null 2>&1 || status=$?
flock -u 8
exec 8<&-
if (( status == 124 )); then
  pass "a held lock serializes runs"
else
  fail "a held lock serializes runs" "run exited $status instead of waiting on the lock"
fi
