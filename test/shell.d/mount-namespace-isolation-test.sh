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

# Every mounting test gates on a marker variable it sets before re-execing
# itself into the namespace, so uid alone can never be the gate: root arrives
# with EUID 0 already and would otherwise skip straight past the unshare.
for test_name in "${MOUNTING_TESTS[@]}"; do
  test_file="$SHELL_TEST_DIR/$test_name"
  [[ -f $test_file ]] || fail "mounting test is present: $test_name"

  guard_line=$(grep -nE '^if \[\[ \$\{OMARCHY_[A-Z_]+:-0\} != 1 \]\]; then' "$test_file" | head -1 | cut -d: -f1)
  [[ -n $guard_line ]] || fail "$test_name gates its namespace re-exec on a marker variable, not on uid"

  mount_line=$(grep -nE '^[[:space:]]*mount (-t|--)' "$test_file" | head -1 | cut -d: -f1)
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
  PATH="$stub_dir:$PATH" \
    OMARCHY_TEST_MOUNT_CALLS="$calls" \
    OMARCHY_WINDOWS_BOUNDARY_NAMESPACE=1 \
    bash "$SHELL_TEST_DIR/windows-vm-mount-boundary-test.sh" 2>&1
) || status=$?

(( status != 0 )) || fail "boundary probe refuses to run without a recorded caller namespace" "$output"
[[ ! -s $calls ]] || fail "boundary probe mounted nothing without a recorded caller namespace" "$(cat "$calls")"
pass "boundary probe fails closed when the caller namespace was never recorded"
