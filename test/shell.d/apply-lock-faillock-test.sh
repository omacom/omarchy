#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-apply-lock writes the lock screen's PAM stack. pam_faillock's
# preauth check must not be silent: a locked account refuses the right
# password, and its notice is the only thing that tells the user why.
stack=$(awk '/omarchy-lock-password >\/dev\/null <<.EOF.$/ { inside = 1; next } inside && /^EOF$/ { exit } inside' "$ROOT/bin/omarchy-apply-lock")
[[ -n $stack ]] || fail "omarchy-apply-lock writes /etc/pam.d/omarchy-lock-password from a heredoc"

if grep -qE '^auth +required +pam_faillock\.so preauth deny=10 unlock_time=120$' <<<"$stack"; then
  pass "pam_faillock preauth runs without silent so a lockout is reported"
else
  fail "pam_faillock preauth runs without silent so a lockout is reported" "$stack"
fi

if grep -qE 'pam_faillock\.so authfail deny=10 unlock_time=120' <<<"$stack" && grep -qE 'pam_faillock\.so authsucc' <<<"$stack"; then
  pass "the tally is still kept (authfail and authsucc)"
else
  fail "the tally is still kept (authfail and authsucc)" "$stack"
fi

if ! grep -q 'silent' <<<"$stack"; then
  pass "nothing in the lock stack is silent"
else
  fail "nothing in the lock stack is silent" "$stack"
fi
