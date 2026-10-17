#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

lock_bin="$ROOT/bin/omarchy-update-lock"
test_bin="$ROOT/bin"
export PATH="$test_bin:$PATH"

t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT

# A planted symlink at the lock path must not hand the truncating open to the
# link target: the lock file is only ever created by update-lock itself, so a
# link here is always foreign.
echo "precious" >"$t/victim.txt"
ln -s "$t/victim.txt" "$t/omarchy-update.lock"
if XDG_RUNTIME_DIR="$t" "$lock_bin" run true 2>"$t/err"; then
  fail "update-lock refuses a symlinked lock path"
fi
[[ $(<"$t/victim.txt") == "precious" ]] || fail "symlink target is left untouched"
grep -q "omarchy-update.lock" "$t/err" || fail "refusal names the lock path"
pass "update-lock refuses a symlinked lock path"

# A planted FIFO must not hang lock acquisition either.
rm -f "$t/omarchy-update.lock"
mkfifo "$t/omarchy-update.lock"
fifo_status=0
timeout 5 env XDG_RUNTIME_DIR="$t" "$lock_bin" run true 2>"$t/fifo-err" || fifo_status=$?
[[ $fifo_status == 1 ]] ||
  fail "update-lock refuses a FIFO without hanging" "status $fifo_status"
grep -q "non-regular update lock" "$t/fifo-err" ||
  fail "FIFO refusal names the invalid lock" "$(cat "$t/fifo-err")"
pass "update-lock refuses a FIFO promptly"

# The normal path still works: the lock is acquired, the command runs, and a
# second acquirer is excluded.
rm -f "$t/omarchy-update.lock"
XDG_RUNTIME_DIR="$t" "$lock_bin" run true || fail "update-lock runs a command under a fresh lock"
[[ -f $t/omarchy-update.lock ]] || fail "lock file is created"
XDG_RUNTIME_DIR="$t" "$lock_bin" held && fail "lock is not held outside run"
pass "update-lock normal acquire/run/held behavior is unchanged"

# XDG_RUNTIME_DIR is only safe when owned and private; a user-provided
# shared directory or a symlink must not be accepted as a lock directory.
shared_runtime="$t/shared-runtime"
mkdir -m 700 "$shared_runtime"
chmod 777 "$shared_runtime"
if XDG_RUNTIME_DIR="$shared_runtime" "$lock_bin" run true 2>"$t/shared-err"; then
  fail "update-lock rejects a world-writable runtime directory"
fi
[[ ! -e "$shared_runtime/omarchy-update.lock" ]] ||
  fail "rejected runtime directory never receives a lock file"
grep -q "private ownership/mode" "$t/shared-err" ||
  fail "rejected runtime directory gives a useful diagnostic"
chmod 700 "$shared_runtime"
XDG_RUNTIME_DIR="$shared_runtime" "$lock_bin" run true ||
  fail "a private runtime directory still admits the update lock"
runtime_link="$t/runtime-link"
ln -s "$shared_runtime" "$runtime_link"
if XDG_RUNTIME_DIR="$runtime_link" "$lock_bin" run true 2>"$t/runtime-link-err"; then
  fail "update-lock rejects a symlinked runtime directory"
fi
pass "runtime lock location requires private ownership and mode"

# Run fallback checks with a test-only copy of the helper. Never delete or
# replace the *live* /tmp/omarchy-lock-$UID directory: a running update could
# hold that lock, and unlinking it would defeat mutual exclusion.
fallback_dir="$t/fallback-lock-dir"
helper_dir="$t/helpers"
mkdir -p "$helper_dir"
helper=$(<"$ROOT/bin/omarchy-lock-dir")
fallback_statement='dir="/tmp/omarchy-lock-$UID"'
[[ $helper == *"$fallback_statement"* ]] ||
  fail "fixture finds the expected fallback path in the current helper"
replacement="dir=\"$fallback_dir\""
printf '%s\n' "${helper/"$fallback_statement"/$replacement}" >"$helper_dir/omarchy-lock-dir"
chmod +x "$helper_dir/omarchy-lock-dir"
[[ $(<"$helper_dir/omarchy-lock-dir") != *"$fallback_statement"* ]] ||
  fail "fixture isolates fallback lock directory"
fallback_path="$helper_dir:$test_bin:$PATH"
if ! env -u XDG_RUNTIME_DIR PATH="$fallback_path" "$lock_bin" run true 2>"$t/fallback-err"; then
  fail "update-lock works without XDG_RUNTIME_DIR" "$(cat "$t/fallback-err")"
fi
[[ -f $fallback_dir/omarchy-update.lock ]] || fail "fallback lock file is created in the private dir"
[[ $(stat -c %a "$fallback_dir") == "700" ]] || fail "fallback lock dir is mode 700" "$(stat -c %a "$fallback_dir")"
pass "update-lock falls back to a private per-UID lock directory"

# A failed chmod on a pre-existing fallback directory must never be
# ignored: leaving it world-writable makes the lock-path check racy.
chmod 777 "$fallback_dir"
chmod_stub="$t/failing-chmod"
mkdir -p "$chmod_stub"
printf '#!/bin/bash\nexit 1\n' >"$chmod_stub/chmod"
chmod +x "$chmod_stub/chmod"
if env -u XDG_RUNTIME_DIR PATH="$chmod_stub:$fallback_path" "$lock_bin" run true 2>"$t/chmod-err"; then
  fail "update-lock rejects an unprotected inherited fallback directory"
fi
grep -q "cannot protect fallback lock directory" "$t/chmod-err" ||
  fail "failed fallback chmod gives a useful diagnostic"
[[ $(stat -c %a "$fallback_dir") == "777" ]] ||
  fail "failed chmod scenario preserves fixture's original mode"
rm -f "$chmod_stub/chmod"
chmod 700 "$fallback_dir"
pass "failed fallback chmod blocks lock acquisition"

# A planted symlink at the fallback directory itself must be refused, not
# followed: following it would hand us an attacker-chosen location.
rm -f "$fallback_dir/omarchy-update.lock"
rmdir "$fallback_dir" ||
  fail "fixture can remove only its own empty fallback directory"
ln -s "$t" "$fallback_dir"
if env -u XDG_RUNTIME_DIR PATH="$fallback_path" "$lock_bin" run true 2>"$t/dirlink-err"; then
  fail "update-lock refuses a symlinked fallback lock directory"
fi
grep -q "refusing" "$t/dirlink-err" || fail "refusal explains itself" "$(cat "$t/dirlink-err")"
rm -f "$fallback_dir"
pass "update-lock refuses a symlinked fallback lock directory"
