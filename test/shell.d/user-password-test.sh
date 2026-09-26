#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -r "$tmp_dir"' EXIT

cat >"$tmp_dir/gum" <<'EOF'
#!/bin/bash
# confirm: TEST_CONFIRM=0 means decline, otherwise accept.
if [[ $1 == "confirm" ]]; then
  (( ${TEST_CONFIRM:-1} ))
  exit
fi
IFS= read -r line <"$TEST_INPUTS"
tail -n +2 "$TEST_INPUTS" >"$TEST_INPUTS.next"
mv "$TEST_INPUTS.next" "$TEST_INPUTS"
printf '%s\n' "$line"
EOF

cat >"$tmp_dir/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >"$TEST_ARGS"
cat >"$TEST_STDIN"
EOF

cat >"$tmp_dir/id" <<'EOF'
#!/bin/bash
if [[ $1 == "-nG" ]]; then
  printf '%s\n' "${TEST_GROUPS:-tester wheel}"
  exit 0
fi
if [[ $1 == "-un" ]]; then
  printf '%s\n' "${USER:-tester}"
  exit 0
fi
exec /usr/bin/id "$@"
EOF

cat >"$tmp_dir/passwd" <<'EOF'
#!/bin/bash
if [[ $1 == "-S" ]]; then
  printf 'root %s 01/01/1970 0 99999 7 -1\n' "${TEST_ROOT_STATUS:-P}"
  exit 0
fi
printf 'passwd\n' >"$TEST_ARGS"
printf '%s\n' "$@" >>"$TEST_ARGS"
EOF

chmod +x "$tmp_dir/gum" "$tmp_dir/sudo" "$tmp_dir/id" "$tmp_dir/passwd"
export PATH="$tmp_dir:$ROOT/bin:$PATH"
export USER=tester
export TEST_ARGS="$tmp_dir/args" TEST_INPUTS="$tmp_dir/inputs" TEST_STDIN="$tmp_dir/stdin"
export TEST_GROUPS="tester wheel" TEST_ROOT_STATUS=P TEST_CONFIRM=1

printf '\n' >"$TEST_INPUTS"
if "$ROOT/bin/omarchy-user-password" >/dev/null; then
  fail "user password rejects an empty passphrase"
fi
[[ ! -e $TEST_ARGS ]] || fail "user password does not run chpasswd for an empty passphrase"

printf 'secret123\n*\n' >"$TEST_INPUTS"
if "$ROOT/bin/omarchy-user-password" >/dev/null; then
  fail "user password rejects a mismatched confirmation"
fi
[[ ! -e $TEST_ARGS ]] || fail "user password does not run chpasswd for a mismatched confirmation"

printf 'new password\nnew password\n' >"$TEST_INPUTS"
"$ROOT/bin/omarchy-user-password" >/dev/null

[[ $(<"$TEST_ARGS") == "chpasswd" ]] || fail "user password runs chpasswd" "$(cat "$TEST_ARGS")"
[[ $(<"$TEST_STDIN") == $'tester:new password\nroot:new password' ]] ||
  fail "user password sets the same passphrase on the login user and on root" "$(cat "$TEST_STDIN")"
pass "user password rejects empty and mismatched passphrases and updates user and root together"

# Locked root: declining the confirm updates the user only.
rm -f "$TEST_ARGS" "$TEST_STDIN"
TEST_ROOT_STATUS=L TEST_CONFIRM=0
printf 'only-user\nonly-user\n' >"$TEST_INPUTS"
"$ROOT/bin/omarchy-user-password" >/dev/null
[[ $(<"$TEST_STDIN") == $'tester:only-user' ]] ||
  fail "declining locked-root confirm leaves root unchanged" "$(cat "$TEST_STDIN")"
pass "user password skips locked root when confirm is declined"

# Non-wheel falls back to passwd.
rm -f "$TEST_ARGS" "$TEST_STDIN"
TEST_GROUPS="tester" TEST_ROOT_STATUS=P
"$ROOT/bin/omarchy-user-password" >/dev/null
[[ $(<"$TEST_ARGS") == $'passwd' ]] ||
  fail "non-wheel user password falls back to passwd" "$(cat "$TEST_ARGS")"
pass "non-wheel user password falls back to passwd"

grep -Fq 'omarchy-user-password' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "password menu updates user and root through omarchy-user-password"
if grep -Fq 'omarchy-launch-floating-terminal-with-presentation passwd' "$ROOT/default/omarchy/omarchy-menu.jsonc"; then
  fail "password menu no longer runs passwd alone"
fi
grep -Fq 'GROUP_DESCRIPTIONS[user]=' "$ROOT/bin/omarchy" ||
  fail "omarchy lists the user command group"
pass "password menu points at omarchy-user-password"
