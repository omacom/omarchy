#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"; rm -f /tmp/omarchy-theme-set-herdr-machines.lock' EXIT

test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_home/.local/state/omarchy/current" "$stub_bin" "$test_tmp/state"

# No machines listed: the run stops after the toggle check, but the lock is
# taken (and the serialization comment enforced) before that.
cat >"$stub_bin/herdr" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$stub_bin/herdr"

run_no_runtime_dir() {
  env -u XDG_RUNTIME_DIR \
    HOME="$test_home" XDG_STATE_HOME="$test_tmp/state" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    timeout 10 omarchy-theme-set-herdr-machines
}

# A fixed lock name in world-writable /tmp is a name any other local account
# can pre-create. As a symlink it redirects the truncating open.
echo precious >"$test_tmp/victim"
ln -s "$test_tmp/victim" /tmp/omarchy-theme-set-herdr-machines.lock
run_no_runtime_dir >/dev/null 2>&1
rm -f /tmp/omarchy-theme-set-herdr-machines.lock
[[ $(cat "$test_tmp/victim") == "precious" ]] || fail "lock open follows a pre-planted /tmp symlink" "victim file was truncated"
pass "lock open ignores a pre-planted /tmp symlink"

# Held by another account, the same lock starves every theme sync forever.
exec 8>/tmp/omarchy-theme-set-herdr-machines.lock
flock 8
if run_no_runtime_dir >/dev/null 2>&1; then
  flock -u 8
  exec 8>&-
  rm -f /tmp/omarchy-theme-set-herdr-machines.lock
  pass "a lock held by another account cannot starve theme sync"
else
  flock -u 8
  exec 8>&-
  rm -f /tmp/omarchy-theme-set-herdr-machines.lock
  fail "a lock held by another account cannot starve theme sync" "run timed out waiting on the /tmp lock"
fi

# The fixed lock still serializes: it lives under the session runtime dir.
lock_dir="$test_tmp/state/omarchy/omarchy-theme-set-herdr-machines.lock"
[[ -f $lock_dir ]] || fail "lock lands in the per-user runtime dir"
pass "lock lands in the per-user runtime dir"
