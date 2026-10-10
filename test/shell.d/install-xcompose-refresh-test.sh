#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

run_xcompose() {
  env -u OMARCHY_USER_NAME -u OMARCHY_USER_EMAIL \
    HOME="$test_home" bash -eE -c 'source "$1"' bash "$ROOT/install/user/xcompose.sh"
}

# A runtime refresh without install inputs keeps the existing file.
printf '# my custom header\n<Multi_key> <space> <n> : "Jane Doe"\n<Multi_key> <space> <e> : "jane@example.com"\n' \
  >"$test_home/.XCompose"
before=$(cat "$test_home/.XCompose")
run_xcompose
[[ $(cat "$test_home/.XCompose") == "$before" ]] \
  || fail "refresh without install inputs keeps the existing ~/.XCompose"
pass "refresh without install inputs keeps the existing ~/.XCompose"

# Install inputs still seed a fresh file.
rm -f "$test_home/.XCompose"
HOME="$test_home" OMARCHY_USER_NAME="Jane Doe" OMARCHY_USER_EMAIL="jane@example.com" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/xcompose.sh"
grep -q '<Multi_key> <space> <n> : "Jane Doe"' "$test_home/.XCompose" \
  || fail "install inputs seed the identification lines"
grep -q '<Multi_key> <space> <e> : "jane@example.com"' "$test_home/.XCompose" \
  || fail "install inputs seed the email line"
pass "install inputs seed a fresh ~/.XCompose"

# Install inputs still refresh an existing file.
HOME="$test_home" OMARCHY_USER_NAME="John Doe" OMARCHY_USER_EMAIL="john@example.com" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/user/xcompose.sh"
grep -q '<Multi_key> <space> <n> : "John Doe"' "$test_home/.XCompose" \
  || fail "install inputs refresh an existing ~/.XCompose"
pass "install inputs refresh an existing ~/.XCompose"
