#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

rules="$ROOT/default/hypr/apps/system.lua"

grep -Fq 'o.window("gcr-prompter"' "$rules" ||
  fail "system window rules include gcr-prompter" "$(grep -n gcr "$rules" || true)"
pass "system window rules include gcr-prompter"

block=$(awk '/o.window\("gcr-prompter"/, /^\}\)/' "$rules")

grep -Fq 'float = true' <<<"$block" || fail "gcr-prompter floats" "$block"
grep -Fq 'center = true' <<<"$block" || fail "gcr-prompter is centered" "$block"
grep -Fq 'pin = true' <<<"$block" || fail "gcr-prompter is pinned across workspaces" "$block"
grep -Fq 'stay_focused = true' <<<"$block" || fail "gcr-prompter stays focused" "$block"
grep -Fq 'group = "deny"' <<<"$block" || fail "gcr-prompter is denied auto_group" "$block"

if grep -Fq 'floating-window' <<<"$block"; then
  fail "gcr-prompter does not use the 875x600 floating-window tag" "$block"
fi
pass "gcr-prompter floats, pins, and stays focused without the large float size"
