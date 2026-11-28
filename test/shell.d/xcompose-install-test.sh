#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# install/user/xcompose.sh seeds ~/.XCompose. Since #16288 the installer no
# longer collects a Git identity, so a fresh install runs this leaf with
# OMARCHY_USER_NAME/OMARCHY_USER_EMAIL unset: it must not write empty
# Compose -> Space -> n/e rules, and `omarchy setup git` fills the shortcuts
# in when the identity is saved.

run_xcompose_install() {
  local home=$1
  # Production runs install leaves with `bash -eE` (run_logged in
  # install/helpers/logging.sh) — no `set -u`, so unset identity variables
  # expand empty, which is exactly the mechanism the issue reports.
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    bash -eE -c 'source "$ROOT/install/user/xcompose.sh"'
}

has_empty_identity_rule() {
  grep -q '<Multi_key> <space> <[ne]> : ""' "$HOME/.XCompose"
}

# --- Fresh install with no identity collected ---

home="$test_tmp/empty"
mkdir "$home"
HOME="$home" run_xcompose_install "$home"

[[ -f $home/.XCompose ]] || fail "the install seeds ~/.XCompose"
grep -q 'include "/usr/share/omarchy/default/xcompose"' "$home/.XCompose" ||
  fail "the seeded ~/.XCompose keeps the default Compose include"
HOME="$home" has_empty_identity_rule &&
  fail "a fresh install without an identity seeds empty Compose shortcuts" \
    "empty rules: $(grep '<Multi_key> <space>' "$home/.XCompose")"
pass "a fresh install without an identity seeds no empty Compose shortcuts"

# --- Identity collected by the caller is still seeded ---

home="$test_tmp/identity"
mkdir "$home"
OMARCHY_USER_NAME="Jane Doe" OMARCHY_USER_EMAIL="jane@example.com" \
  HOME="$home" run_xcompose_install "$home"

HOME="$home" has_empty_identity_rule &&
  fail "a seeded identity must not produce empty rules"
grep -q '<Multi_key> <space> <n> : "Jane Doe"' "$home/.XCompose" ||
  fail "the install seeds the name shortcut when the caller provides one"
grep -q '<Multi_key> <space> <e> : "jane@example.com"' "$home/.XCompose" ||
  fail "the install seeds the email shortcut when the caller provides one"
pass "an identity provided by the caller is still seeded into ~/.XCompose"

# --- A name without an email seeds no empty email rule ---

home="$test_tmp/partial"
mkdir "$home"
OMARCHY_USER_NAME="Jane Doe" OMARCHY_USER_EMAIL='' \
  HOME="$home" run_xcompose_install "$home"

grep -q '<Multi_key> <space> <n> : "Jane Doe"' "$home/.XCompose" ||
  fail "the install seeds the name shortcut when only a name is given"
HOME="$home" has_empty_identity_rule &&
  fail "a missing email must not seed an empty email rule" \
    "rules: $(grep '<Multi_key> <space>' "$home/.XCompose")"
pass "a name without an email seeds no empty email rule"
