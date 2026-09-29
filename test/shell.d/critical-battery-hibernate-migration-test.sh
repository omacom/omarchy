#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1790598129.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/omarchy-battery-present" <<'STUB'
#!/bin/bash
exit "${BATTERY_ABSENT:-0}"
STUB
cat >"$test_dir/bin/omarchy-hibernation-setup" <<'STUB'
#!/bin/bash
echo "setup $*" >>"$SETUP_CALLS"
STUB
chmod +x "$test_dir/bin/"*

export SETUP_CALLS="$test_dir/setup-calls"
export OMARCHY_RESUME_CONF="$test_dir/omarchy_resume.conf"

run_migration() {
  : >"$SETUP_CALLS"
  PATH="$test_dir/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

# A laptop that set up hibernation before gets setup rerun, which installs the
# critical battery drop-in.
echo "HOOKS+=(resume)" >"$OMARCHY_RESUME_CONF"
run_migration
[[ $(<"$SETUP_CALLS") == "setup " ]] || fail "migration reruns setup on a laptop with hibernation" "$(<"$SETUP_CALLS")"
pass "migration reruns setup on a laptop with hibernation"

# A desktop has no battery to protect.
BATTERY_ABSENT=1 run_migration
[[ ! -s $SETUP_CALLS ]] || fail "migration leaves a machine without a battery alone" "$(<"$SETUP_CALLS")"
pass "migration leaves a machine without a battery alone"

# Without hibernation set up, rerunning setup would offer to create a swapfile.
rm "$OMARCHY_RESUME_CONF"
run_migration
[[ ! -s $SETUP_CALLS ]] || fail "migration does not start hibernation setup on a machine without it" "$(<"$SETUP_CALLS")"
pass "migration does not start hibernation setup on a machine without it"

echo "# something else" >"$OMARCHY_RESUME_CONF"
run_migration
[[ ! -s $SETUP_CALLS ]] || fail "migration needs the resume hook, not just the file" "$(<"$SETUP_CALLS")"
pass "migration needs the resume hook, not just the file"
