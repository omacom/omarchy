#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# sudoers.d: later lexical name wins for duplicate Defaults. Omarchy's
# passwd_tries drop-in must sort *before* common user overrides like
# 99-passwd-tries so a stricter value can stick (#12397).

packaged="$ROOT/etc/sudoers.d/10-omarchy-passwd-tries"
old_name="$ROOT/etc/sudoers.d/omarchy-passwd-tries"

[[ -f $packaged ]] || fail "packaged passwd_tries drop-in is 10-omarchy-passwd-tries"
[[ ! -e $old_name ]] || fail "old omarchy-passwd-tries name is gone from the tree"

rules=$(grep -vE '^[[:space:]]*(#|$)' "$packaged")
[[ $rules == 'Defaults passwd_tries=10' ]] ||
  fail "passwd_tries drop-in still ships Defaults passwd_tries=10" "got: $rules"

if command -v visudo >/dev/null; then
  visudo -cf "$packaged" >/dev/null || fail "passwd_tries sudoers file parses"
fi

# Lexical last-wins simulation (same rule sudo uses for includedir).
winning_passwd_tries() {
  local dir="$1"
  local line value=""
  local f
  while IFS= read -r f; do
    [[ -f $f ]] || continue
    while IFS= read -r line || [[ -n $line ]]; do
      [[ $line =~ ^Defaults[[:space:]]+passwd_tries=([0-9]+)[[:space:]]*$ ]] || continue
      value="${BASH_REMATCH[1]}"
    done <"$f"
  done < <(printf '%s\n' "$dir"/* | LC_ALL=C sort)
  printf '%s' "$value"
}

stock_dir=$(mktemp -d)
trap 'rm -rf "$stock_dir"' EXIT

# Stock naming (pre-fix): omarchy-* sorts after 99-* → package wins incorrectly.
printf 'Defaults passwd_tries=10\n' >"$stock_dir/omarchy-passwd-tries"
printf 'Defaults passwd_tries=3\n' >"$stock_dir/99-passwd-tries"
[[ $(winning_passwd_tries "$stock_dir") == 10 ]] ||
  fail "stock naming lets omarchy-passwd-tries override 99-passwd-tries"

# Fixed naming: 10-* sorts before 99-* → user wins.
rm -f "$stock_dir"/*
printf 'Defaults passwd_tries=10\n' >"$stock_dir/10-omarchy-passwd-tries"
printf 'Defaults passwd_tries=3\n' >"$stock_dir/99-passwd-tries"
[[ $(winning_passwd_tries "$stock_dir") == 3 ]] ||
  fail "10-omarchy-passwd-tries lets 99-passwd-tries win"

# Migration leaves a customized old file alone (body check).
mig="$ROOT/migrations/1789838300.sh"
grep -F 'omarchy-passwd-tries' "$mig" >/dev/null ||
  fail "migration mentions the old sudoers path"
grep -F 'Defaults passwd_tries=10' "$mig" >/dev/null ||
  fail "migration only removes the stock one-liner"

pass "passwd_tries sudoers sorts before user overrides"
