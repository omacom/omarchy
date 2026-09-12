#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

rules_file="$ROOT/etc/polkit-1/rules.d/omarchy-nm-modify-system.rules"
nm_rule="org.freedesktop.NetworkManager.rules"

[[ -f $rules_file ]] || fail "omarchy-settings ships a polkit drop-in for system NetworkManager connections"

base=$(basename "$rules_file")
[[ $base < $nm_rule ]] ||
  fail "polkit drop-in basename sorts before NetworkManager's YES rule" \
    "$base would lose to $nm_rule"

# Comments and blanks dropped. A YES on this action, or AUTH_ADMIN_KEEP on some
# other action, would leave the file looking related while missing the grant.
active=$(grep -vE '^[[:space:]]*(//|$)' "$rules_file")
[[ $active == *'org.freedesktop.NetworkManager.settings.modify.system'* ]] ||
  fail "polkit drop-in names settings.modify.system"
[[ $active == *'polkit.Result.AUTH_ADMIN_KEEP'* ]] ||
  fail "polkit drop-in restores AUTH_ADMIN_KEEP"
[[ $active != *'polkit.Result.YES'* ]] ||
  fail "polkit drop-in must not return YES"
[[ $active != *modify.own* ]] ||
  fail "polkit drop-in must not touch personal connections"

pass "system NetworkManager connections require auth_admin_keep"
