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
full_name="Test User"
password=secret
useradd_status=0
usermod_status=0
chpasswd_status=0
cleanup_status=0
create_account=0

user_groups() { printf '%s' wheel; }
getent() { [[ -f $tmp_dir/account-created ]]; }
useradd() {
  [[ -f $PROVISIONING_DIR/setup-user ]] &&
    [[ $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] ||
    fail "username is pinned before useradd starts"
  printf '%s\n' "$*" >>"$tmp_dir/useradd.calls"
  if (( create_account )); then touch "$tmp_dir/account-created"; fi
  return "$useradd_status"
}
usermod() {
  printf '%s\n' "$*" >>"$tmp_dir/usermod.calls"
  return "$usermod_status"
}
chpasswd() {
  cat >>"$tmp_dir/chpasswd.calls"
  return "$chpasswd_status"
}
rm() {
  if (( cleanup_status )) && [[ ${*: -1} == "$PROVISIONING_DIR/setup-user" ]]; then
    return "$cleanup_status"
  fi
  command rm "$@"
}

# Run the real function with account-changing commands mocked. Redirect only
# its sudoers output so successful runs also stay entirely inside the fixture.
create_user_source=$(sed -n '/^create_user() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")
eval "${create_user_source//\/etc\/sudoers.d\/00-omarchy-wheel/$tmp_dir/wheel}"

run_create_user() {
  command rm -f "$tmp_dir/"*.calls "$tmp_dir/wheel"
  # Do not put create_user (or this helper) in an if/|| condition: that would
  # disable errexit inside the function and hide the production failure path.
  set +e
  (
    set -e
    create_user
  )
  status=$?
  set -e
}

for useradd_status in 3 9 42; do
  run_create_user
  (( status == useradd_status )) || fail "failed useradd status is preserved" "status: $status"
  [[ ! -e $PROVISIONING_DIR/setup-user ]] ||
    fail "failed useradd does not pin the rejected username"
  [[ ! -e $tmp_dir/chpasswd.calls ]] || fail "useradd failure stops before chpasswd"
  pass "useradd exit $useradd_status clears the pin and preserves its status"
done

useradd_status=0
create_account=1
run_create_user
(( status == 0 )) || fail "successful creation completes" "status: $status"
[[ $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] || fail "successful creation keeps the pin"
[[ -e $tmp_dir/wheel && -e $tmp_dir/chpasswd.calls ]] || fail "successful creation continues provisioning"
pass "successful account creation keeps the early username pin"

command rm -f "$tmp_dir/account-created" "$PROVISIONING_DIR/setup-user"
chpasswd_status=7
run_create_user
(( status == 7 )) || fail "later provisioning failure status is preserved" "status: $status"
[[ $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] ||
  fail "successful user creation pins the username before later provisioning can fail"
pass "a later chpasswd failure keeps the created account pinned"

# useradd can create the account and then fail while preparing its home.
command rm -f "$tmp_dir/account-created" "$PROVISIONING_DIR/setup-user"
useradd_status=12
run_create_user
(( status == 12 )) || fail "partial useradd failure status is preserved" "status: $status"
[[ -f $PROVISIONING_DIR/setup-user ]] || fail "a partially created account keeps its username pin"
[[ ! -e $tmp_dir/chpasswd.calls ]] || fail "partial creation failure stops before chpasswd"
pass "a useradd error after account creation keeps the account pinned"

chpasswd_status=0
run_create_user
(( status == 0 )) || fail "existing-user retry completes" "status: $status"
[[ -e $tmp_dir/usermod.calls && ! -e $tmp_dir/useradd.calls ]] || fail "existing-user retry uses usermod"
[[ $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] || fail "existing-user retry keeps the pin"
pass "an existing-user retry refreshes the pinned account without calling useradd"

usermod_status=6
run_create_user
(( status == 6 )) || fail "usermod failure status is preserved" "status: $status"
[[ -f $PROVISIONING_DIR/setup-user && ! -e $tmp_dir/chpasswd.calls ]] || fail "usermod failure keeps the pin and stops"
pass "an existing-user update failure retains the pin"

command rm -f "$tmp_dir/account-created" "$PROVISIONING_DIR/setup-user"
create_account=0
useradd_status=3
cleanup_status=73
run_create_user
(( status == 3 )) || fail "pin cleanup cannot mask useradd status" "status: $status"
[[ -f $PROVISIONING_DIR/setup-user ]] || fail "failed cleanup leaves the pin in place"
[[ ! -e $tmp_dir/chpasswd.calls ]] || fail "cleanup failure stops before chpasswd"
pass "a cleanup failure preserves the original useradd status under set -e"
