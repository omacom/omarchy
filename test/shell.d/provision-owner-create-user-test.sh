#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export PROVISIONING_DIR="$tmp_dir/provisioning"
mkdir -p "$PROVISIONING_DIR"

username=tester
full_name=
password=secret

user_groups() { printf '%s' wheel; }
getent() { return 2; }
usermod() { return 0; }

# Load the real function while keeping every account-changing command mocked.
eval "$(sed -n '/^create_user() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")"

useradd() { return 3; }
chpasswd() { return 99; }

set +e
(
  set -e
  create_user
)
status=$?
set -e

((status == 3)) || fail "failed useradd status is preserved" "status: $status"
[[ ! -e $PROVISIONING_DIR/setup-user ]] ||
  fail "failed useradd does not pin the rejected username"
pass "a useradd rejection leaves the next setup attempt free to choose another username"

useradd() { return 0; }
chpasswd() { return 7; }

set +e
(
  set -e
  create_user
)
status=$?
set -e

((status == 7)) || fail "later provisioning failure status is preserved" "status: $status"
[[ $(<"$PROVISIONING_DIR/setup-user") == "$username" ]] ||
  fail "successful user creation pins the username before later provisioning can fail"
pass "a created account is pinned before later provisioning steps can fail"
