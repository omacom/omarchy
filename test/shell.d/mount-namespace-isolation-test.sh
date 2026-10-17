#!/bin/bash
# Every test that mounts must do so in a namespace of its own. Mounting on the
# caller's namespace hides the live /run, /var and /home -- the checkout with
# them -- for the rest of the machine's uptime.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

MOUNTING_TESTS=(windows-vm-mount-boundary-test.sh windows-vm-compose-test.sh)

# A test that reaches its mounts on the caller's namespace would wreck the
# machine running this suite, so the probes below stub mount(8) out of the way
# first. A regression then records a call instead of landing one.
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
cat >"$stub_dir/mount" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MOUNT_CALLS"
exit 1
STUB
chmod +x "$stub_dir/mount"
real_unshare=$(command -v unshare || true)
cat >"$stub_dir/unshare" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_UNSHARE_CALLS"
STUB
chmod +x "$stub_dir/unshare"

# Every mounting test gates on a marker variable it sets before re-execing
# itself into the namespace, so uid alone can never be the gate: root arrives
# with EUID 0 already and would otherwise skip straight past the unshare.
for test_name in "${MOUNTING_TESTS[@]}"; do
  test_file="$SHELL_TEST_DIR/$test_name"
  [[ -f $test_file ]] || fail "mounting test is present: $test_name"

  guard_line=$(grep -m1 -nE '^if \[\[ \$\{OMARCHY_[A-Z_]+:-0\} != 1 \]\]; then' "$test_file" | cut -d: -f1 || true)
  [[ -n $guard_line ]] || fail "$test_name gates its namespace re-exec on a marker variable, not on uid"

  mount_line=$(grep -m1 -nE '^[[:space:]]*mount (-t|--)' "$test_file" | cut -d: -f1 || true)
  if [[ -n $mount_line ]]; then
    (( mount_line > guard_line )) || fail "$test_name mounts before entering its own namespace"
  fi

  pass "$test_name enters its namespace before mounting anything"
done

# Losing the namespace must stop the run rather than fall through to the
# mounts. Hand the boundary probe its own namespace id as the caller's, which
# is what a re-exec that silently stopped isolating would leave behind.
calls="$stub_dir/calls"
: >"$calls"
status=0
output=$(
  PATH="$stub_dir:$PATH" \
    OMARCHY_TEST_MOUNT_CALLS="$calls" \
    OMARCHY_WINDOWS_BOUNDARY_NAMESPACE=1 \
    OMARCHY_WINDOWS_BOUNDARY_CALLER_MOUNT_NS=$(readlink /proc/self/ns/mnt) \
    bash "$SHELL_TEST_DIR/windows-vm-mount-boundary-test.sh" 2>&1
) || status=$?

(( status != 0 )) || fail "boundary probe refuses to run in the caller's mount namespace" "$output"
[[ $output == *"still in the caller's mount namespace"* ]] ||
  fail "boundary probe names the missing isolation when it refuses" "$output"
[[ ! -s $calls ]] || fail "boundary probe mounted nothing while refusing" "$(cat "$calls")"
pass "boundary probe fails closed in the caller's mount namespace instead of mounting"

# An unset caller namespace is the same hazard wearing a different hat: the
# marker says the re-exec happened, nothing proves where it landed.
: >"$calls"
status=0
output=$(
  env -u OMARCHY_WINDOWS_BOUNDARY_CALLER_MOUNT_NS \
    PATH="$stub_dir:$PATH" \
    OMARCHY_TEST_MOUNT_CALLS="$calls" \
    OMARCHY_WINDOWS_BOUNDARY_NAMESPACE=1 \
    bash "$SHELL_TEST_DIR/windows-vm-mount-boundary-test.sh" 2>&1
) || status=$?

(( status != 0 )) || fail "boundary probe refuses to run without a recorded caller namespace" "$output"
[[ ! -s $calls ]] || fail "boundary probe mounted nothing without a recorded caller namespace" "$(cat "$calls")"
pass "boundary probe fails closed when the caller namespace was never recorded"

# The marker guard alone proves nothing about the first pass: a root path that
# dropped its unshare would keep the guard and fall straight through to the
# mounts. So run the probe's first pass as uid 0 -- directly when the runner is
# root, through a user namespace otherwise -- with unshare stubbed to record
# the re-exec it is asked for, and require that it re-execs into a private
# mount namespace before mounting anything.
unshare_calls="$stub_dir/unshare-calls"
: >"$calls"
: >"$unshare_calls"
as_root=()
if (( EUID != 0 )); then
  if [[ -n $real_unshare ]] && "$real_unshare" --user --map-root-user true 2>/dev/null; then
    as_root=("$real_unshare" --user --map-root-user)
  else
    skip "user namespace unavailable; cannot run the boundary probe's first pass as uid 0"
    exit 0
  fi
fi
probe="$SHELL_TEST_DIR/windows-vm-mount-boundary-test.sh"
status=0
output=$(
  env -u OMARCHY_WINDOWS_BOUNDARY_NAMESPACE -u OMARCHY_WINDOWS_BOUNDARY_CALLER_MOUNT_NS \
    PATH="$stub_dir:$PATH" \
    OMARCHY_TEST_MOUNT_CALLS="$calls" \
    OMARCHY_TEST_UNSHARE_CALLS="$unshare_calls" \
    "${as_root[@]}" bash "$probe" 2>&1
) || status=$?

(( status == 0 )) || fail "boundary probe's root first pass hands off to its re-exec" "$output"
[[ ! -s $calls ]] || fail "boundary probe's root first pass mounted nothing" "$(cat "$calls")"
grep -qxF -- "--mount --propagation private bash $probe" "$unshare_calls" ||
  fail "boundary probe's root first pass re-execs into a private mount namespace" "$(cat "$unshare_calls")$output"
pass "boundary probe re-execs into a private mount namespace when it starts as root"
