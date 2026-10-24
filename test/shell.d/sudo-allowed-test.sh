#!/bin/bash
#
# omarchy-sudo-allowed answers "is this an administrator" for the steps only an
# administrator can take. Omarchy's administrators are the members of wheel, so
# the answer comes from the session's groups and nothing else.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

command="$ROOT/bin/omarchy-sudo-allowed"

# Stub id so the session's groups are controllable.
mkdir -p "$TMPDIR/bin"
cat >"$TMPDIR/bin/id" <<'STUB'
#!/bin/bash
[[ $* == "-nG" ]] || exit 9
printf '%s\n' "$STUB_GROUPS"
STUB
chmod +x "$TMPDIR/bin/id"

run() { # GROUPS [args...]
  env PATH="$TMPDIR/bin:$PATH" STUB_GROUPS="$1" bash "$command" "${@:2}"
}

run "ors wheel" || fail "a wheel member is an administrator"
run "wheel" || fail "wheel as the only group is an administrator"
pass "members of wheel are administrators"

run "bob" && fail "an account outside wheel is not an administrator"
run "bob input video" && fail "other groups don't make an administrator"
pass "accounts outside wheel are not administrators"

# Only the exact group counts: a similar name is someone else's group.
run "bob wheel-users" && fail "wheel-users is not wheel"
run "bob nowheel" && fail "nowheel is not wheel"
pass "only the exact wheel group counts"

status=0
run "ors wheel" extra 2>/dev/null || status=$?
(( status == 2 )) || fail "an argument is a usage error (exit 2), got $status"
pass "arguments are rejected"
