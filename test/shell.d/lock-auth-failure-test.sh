#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

service="$ROOT/shell/plugins/lock/Service.qml"

grep -F 'if (passwordPam.responseVisible) return' "$service" >/dev/null ||
  fail "password respond refuses echo-on / consent prompts"
pass "password respond is gated on echo-off prompts"

# The shared helper must check responseVisible before respond().
awk '
  /function respondToPasswordPrompt\(\)/ { in_fn=1 }
  in_fn {
    buf = buf $0 "\n"
    if (/^  \}/) { print buf; exit }
  }
' "$service" >"$TMPDIR/respond-fn.txt"
grep -F 'passwordPam.respond(pendingPassword)' "$TMPDIR/respond-fn.txt" >/dev/null ||
  fail "respondToPasswordPrompt calls respond()"
grep -F 'responseVisible' "$TMPDIR/respond-fn.txt" >/dev/null ||
  fail "respondToPasswordPrompt checks responseVisible"
pass "respondToPasswordPrompt is the gated respond path"

# handlePasswordFailure must not early-return on !lockRequested — that is the
# silent "Checking…" then blank field path when the lock drops mid-PAM.
awk '
  /function handlePasswordFailure\(\)/ { in_fn=1 }
  in_fn {
    buf = buf $0 "\n"
    if (/^  \}/) { print buf; exit }
  }
' "$service" >"$TMPDIR/failure-fn.txt"
if grep -E 'if \(!lockRequested\) return' "$TMPDIR/failure-fn.txt" >/dev/null; then
  fail "handlePasswordFailure still bails when lockRequested is false"
fi
grep -F 'failureMessage = "Authentication failed' "$TMPDIR/failure-fn.txt" >/dev/null ||
  fail "handlePasswordFailure still sets the failure string"
pass "handlePasswordFailure surfaces failure without lockRequested"

# password PamContext must call handlePasswordFailure on non-success without
# requiring lockRequested first.
awk '
  /id: passwordPam/ { in_pam=1 }
  in_pam {
    buf = buf $0 "\n"
    if (/^  PamContext \{/ && seen++) { exit }
    if (/^  \}/ && /PamContext/ == 0) {
      # closing brace of PamContext at indent 2 — track depth
    }
  }
' "$service" >/dev/null

password_pam=$(awk '
  /id: passwordPam/ { grab=1 }
  grab { print }
  grab && /^  \}$/ { exit }
' "$service")
[[ -n $password_pam ]] || fail "password PamContext is present"
grep -F 'root.handlePasswordFailure()' <<<"$password_pam" >/dev/null ||
  fail "password PamContext failure path calls handlePasswordFailure"
if grep -E 'if \(!root\.lockRequested\) return' <<<"$password_pam" >/dev/null; then
  fail "password onCompleted still returns early when lockRequested is false"
fi
pass "password PAM completion still reports failure after a dropped lock"
