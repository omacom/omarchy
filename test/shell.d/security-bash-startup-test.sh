#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

check=omarchy_security_require_privileged_bash_startup
printf '#!/bin/bash -p\nsource "%s"\n%s && ( %s )\n' "$ROOT/bin/omarchy-security-functions" "$check" "$check" >"$test_tmp/entrypoint"
# Privileged mode turned on after startup: the mode is set, the proof is not.
printf 'set -p\nsource "%s"\n%s\n' "$ROOT/bin/omarchy-security-functions" "$check" >"$test_tmp/late"
chmod +x "$test_tmp/entrypoint"

"$test_tmp/entrypoint" || fail "a script started as bash -p passes the startup check, from a subshell too"
pass "a script started as bash -p passes the startup check, from a subshell too"

for arguments in "" "-p"; do
  if /usr/bin/bash "$test_tmp/late" $arguments; then
    fail "bash that only turned -p on later is rejected" "arguments: $arguments"
  fi
done
if /usr/bin/bash "$test_tmp/entrypoint"; then
  fail "a script not started with -p is rejected"
fi
pass "bash not started with -p is rejected, whatever its other arguments"

# arch-chroot runs the installer in a new PID namespace under the outer /proc,
# so the caller's own PID is not the number /proc knows it by.
in_new_pid_namespace=(unshare --user --map-root-user --fork --pid)
if "${in_new_pid_namespace[@]}" /usr/bin/true 2>/dev/null; then
  "${in_new_pid_namespace[@]}" /usr/bin/bash -c "for i in {1..50}; do /usr/bin/true; done; '$test_tmp/entrypoint'; exit" </dev/null ||
    fail "the startup check passes in a new PID namespace under the outer /proc"
  if "${in_new_pid_namespace[@]}" /usr/bin/bash -c "for i in {1..50}; do /usr/bin/true; done; /usr/bin/bash '$test_tmp/late' -p; exit" </dev/null; then
    fail "bash that only turned -p on later is rejected in a new PID namespace"
  fi
  pass "the startup check sees its caller in a new PID namespace, as under arch-chroot"
else
  skip "a new PID namespace needs unprivileged user namespaces"
fi
