#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-face-match"
sudoers_file="$ROOT/default/sudoers.d/omarchy-face-match"
rule='%wheel ALL=(root) NOPASSWD: /usr/bin/omarchy-face-match ""'

# The grant serves the lock screen alone, so the setup installs it only when
# the face is wanted there; shipped under etc/ it would reach every machine.
[[ ! -e $ROOT/etc/sudoers.d/omarchy-face-match ]] || fail "the face grant does not ship into /etc unconditionally"
pass "the face grant ships as a default the setup installs, not under etc/"

# Exactly one rule, matched whole. The empty argument string is what makes
# sudoers refuse any argument at all; dropping it would read as "any arguments".
rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == "$rule" ]] || fail "the face sudoers file carries exactly the no-argument rule and nothing else" "got: $rules"
if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "the face sudoers rule parses"
fi
grep -Fx 'PACKAGED_PATH=/usr/bin/omarchy-face-match' "$helper" >/dev/null || fail "the helper elevates the path the sudoers rule names"
# shellcheck disable=SC2016 # the literal is what the helper's source says
grep -Fx '  exec sudo -n "$PACKAGED_PATH"' "$helper" >/dev/null || fail "the helper elevates without arguments and without prompting"
gated=$(grep -A1 -E '^if \(\( EUID == 0 \)\); then$' "$helper" || true)
[[ $gated == *"export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"* ]] || fail "the helper pins PATH to trusted directories only when it holds root"
pass "the face sudoers rule grants the packaged helper alone, with no arguments"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
seclib="$test_tmp/security"
log="$test_tmp/calls.log"
output="$test_tmp/output"
copy="$test_tmp/face-match.sh"
mkdir -p "$stub_bin" "$seclib/howdy"
sed -e "s|^security_lib=/usr/lib/security$|security_lib=$seclib|" "$helper" >"$copy"
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
exit "${TEST_SUDO_STATUS:-0}"
SH
chmod +x "$stub_bin/sudo"

if (( EUID == 0 )); then
  skip "running as root; the session-user phase cannot be exercised"
  exit 0
fi

# Howdy's tree is readable by root only; an unreadable compare.py stands in.
: >"$seclib/howdy/compare.py"
chmod 000 "$seclib/howdy/compare.py"

# invoke <PAM_USER> [args...]
invoke() {
  local status=0 user=$1
  shift
  : >"$log"
  TEST_LOG="$log" PAM_USER="$user" PATH="$stub_bin:/usr/bin:/bin" bash "$copy" "$@" </dev/null >"$output" 2>&1 || status=$?
  return "$status"
}

me=$(id -un)
invoke "$me" || fail "the session user's conversation elevates" "$(cat "$output")"
[[ $(<"$log") == "sudo -n /usr/bin/omarchy-face-match" ]] || fail "elevation runs the packaged copy through sudo -n with no arguments" "$(cat "$log")"
pass "the session user's conversation elevates the packaged helper through the grant"

TEST_SUDO_STATUS=1 invoke "$me" && fail "a refused grant fails the attempt"
pass "a refused grant fails the attempt instead of prompting"

invoke root && fail "another account must not be matched from a session"
[[ -z $(<"$log") ]] || fail "another account never reaches sudo" "$(cat "$log")"
grep -q 'not the session user' "$output" || fail "the mismatch is explained" "$(cat "$output")"
invoke "" && fail "an empty PAM_USER fails"
invoke "$me" extra && fail "arguments are refused"
invoke "$me" --hint || fail "--hint is the one accepted argument"
[[ -z $(<"$log") ]] || fail "refused invocations never reach sudo" "$(cat "$log")"
pass "only the session user's own account is ever elevated, and never with arguments"
