#!/bin/bash

# Migration 1788124236 once hardened or disabled an exposed sshd from each
# account's own queue, outside the machine lock. It is now superseded by
# 1788163637, whose machine phase does the same under that lock
# (sshd-key-only-migration-test.sh covers it), so it must do nothing at all.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

migration="$ROOT/migrations/1788124236.sh"
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"
for command in sudo systemctl sshd install rm chmod ssh-keygen; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "%s" "$*" >>"$CALL_LOG"\n' "$command" >"$stub_bin/$command"
done
chmod +x "$stub_bin"/*

for state in keyless keyed legacy key-only; do
  home="$test_dir/$state/home"; mkdir -p "$home/.ssh"
  [[ $state != keyed ]] || { ssh-keygen -q -t ed25519 -N '' -f "$test_dir/$state/key"; cp "$test_dir/$state/key.pub" "$home/.ssh/authorized_keys"; }
  if ! HOME="$home" PATH="$stub_bin:$PATH" CALL_LOG="$test_dir/$state.calls" bash -euo pipefail "$migration" >/dev/null 2>&1; then
    fail "the superseded SSH migration failed for a $state account"
  fi
  [[ ! -e $test_dir/$state.calls ]] || fail "the superseded SSH migration acted for a $state account" "$(cat "$test_dir/$state.calls")"
done
[[ $(grep -Ev '^[[:space:]]*(#|$)' "$migration") == 'echo "Disable SSH password authentication, or sshd itself when no key is authorized"' ]] ||
  fail "the superseded SSH migration still does more than describe itself" "$(cat "$migration")"
pass "the superseded SSH migration does nothing, leaving the machine to the locked key-only migration"
