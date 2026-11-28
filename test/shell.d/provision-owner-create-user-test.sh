#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export PROVISIONING_DIR="$tmp_dir/provisioning"
export OMARCHY_PATH="$tmp_dir/omarchy"
mkdir -p "$PROVISIONING_DIR" "$OMARCHY_PATH/install/helpers"
printf 'BROWSER_POLICY_MANAGED_DIRS=()\n' >"$OMARCHY_PATH/install/helpers/browser-policy.sh"

username=tester
password=secret
create_account=0

user_groups() { printf '%s' wheel; }
getent() { [[ -f $tmp_dir/account-created ]]; }
useradd() {
  if (( create_account )); then touch "$tmp_dir/account-created"; fi
  return "$useradd_status"
}
usermod() { :; }
chpasswd() { cat >/dev/null; }

# Run the real function with the account commands mocked and its sudoers
# write redirected into the fixture.
create_user_source=$(sed -n '/^create_user() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")
eval "${create_user_source//\/etc\/sudoers.d\/00-omarchy-wheel/$tmp_dir/wheel}"

run_create_user() {
  # Do not put create_user in an if/|| condition: that would disable errexit
  # inside the function and hide the production failure path.
  set +e
  (
    set -e
    create_user
  )
  status=$?
  set -e
}

# useradd rejects the name without creating an account, e.g. exit 9 for a name
# taken by an existing group. Try again must ask for another username.
useradd_status=9
run_create_user
(( status == 9 )) || fail "a rejected username keeps useradd's status" "status: $status"
[[ ! -e $PROVISIONING_DIR/setup-user ]] || fail "a rejected username is not pinned for the retry"
pass "a rejected username is cleared so the retry can choose another"

# useradd can create the account and then fail, e.g. while preparing its home.
# The pin must stay so the retry resumes that account.
create_account=1
useradd_status=12
run_create_user
(( status == 12 )) || fail "a partial creation keeps useradd's status" "status: $status"
[[ -f $PROVISIONING_DIR/setup-user && $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] || fail "a partially created account keeps its username pin"
pass "a useradd error after the account exists keeps the pin"
