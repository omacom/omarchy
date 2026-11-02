#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Setup > Users asks everything in the shell's menu: each omarchy-user-*
# command takes its answers from omarchy-menu-select and omarchy-menu-input,
# asks passwords masked, says how it went in a notification, and hands the
# helper only what it was given.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP=$tmp
mkdir -p "$tmp/bin"
fake() { cat >"$tmp/bin/$1"; chmod +x "$tmp/bin/$1"; }

# The menus answer from a queue, one line per question, and log each prompt.
fake omarchy-menu-input <<'SH'
#!/bin/bash
masked=no; [[ " $* " == *" --password "* ]] && masked=yes
echo "input $masked $1" >>"$TEST_TMP/asked"
answer=$(head -n 1 "$TEST_TMP/answers"); sed -i 1d "$TEST_TMP/answers"
[[ $answer == ESC ]] && exit 1
printf '%s\n' "$answer"
SH
fake omarchy-menu-select <<'SH'
#!/bin/bash
echo "select $1" >>"$TEST_TMP/asked"
answer=$(head -n 1 "$TEST_TMP/answers"); sed -i 1d "$TEST_TMP/answers"
[[ $answer == ESC ]] && exit 1
printf '%s\n' "$answer"
SH
fake omarchy-notification-send <<'SH'
#!/bin/bash
urgency=normal
while [[ $1 == -* ]]; do [[ $1 == -u ]] && urgency=$2; shift 2; done
echo "$urgency $*" >>"$TEST_TMP/notified"
SH
# sudo as an adult has it: a password every time, read from stdin with -S, and
# no approval carried between calls; -n runs only what needs none, as a
# child's password-self grant does.
fake sudo <<'SH'
#!/bin/bash
[[ $# == 1 && ( $1 == -k || $1 == -K ) ]] && exit 0
[[ $1 == -k ]] && shift
if [[ $1 == -n ]]; then
  shift
  [[ $1 == omarchy-user-helper && $2 == password-self ]] && exec "$@"
  exit 1
fi
if [[ $1 == -S ]]; then
  shift; [[ $1 == -p ]] && shift 2
  IFS= read -r given; [[ $given == ownerpw ]] || exit 1
  [[ $1 == -v ]] && exit 0
  exec "$@"
fi
exit 1
SH
fake omarchy-user-helper <<'SH'
#!/bin/bash
{ echo "args: $*"; cat; } >"$TEST_TMP/helper"
[[ -z ${TEST_HELPER_REFUSES:-} ]] || { echo "Someone already has that password." >&2; exit 1; }
SH
fake omarchy-user-list <<'SH'
#!/bin/bash
printf 'dhh adult (you)\nemma child\n'
SH
export PATH="$tmp/bin:$PATH" OMARCHY_PATH=$ROOT

run() {
  local command=$1; shift
  rm -f "$tmp/asked" "$tmp/notified" "$tmp/helper"
  printf '%s\n' "$@" >"$tmp/answers"
  "$ROOT/bin/$command" "${run_args[@]}" >/dev/null 2>&1 && status=0 || status=$?
}

run_args=()
run omarchy-user-add Child 'Emma!' emma abc kidpass1 kidpass1 ownerpw
(( status == 0 )) || fail "adding a child through the menu succeeds" "$(cat "$tmp/notified" 2>/dev/null)"
[[ $(cat "$tmp/helper") == $'args: add child emma\nownerpw\nkidpass1' ]] || fail "the helper gets the role, the name, and both passwords on stdin" "$(cat "$tmp/helper")"
[[ $(grep -c '^input yes' "$tmp/asked") == 4 && $(grep -c '^input no' "$tmp/asked") == 2 ]] || fail "every password is asked masked, and only the name in the clear" "$(cat "$tmp/asked")"
grep -q '^critical .*lowercase letters' "$tmp/notified" && grep -q '^critical .*at least 6' "$tmp/notified" || fail "a bad name and a short password are said, and asked again" "$(cat "$tmp/notified")"
grep -q '^normal Added emma' "$tmp/notified" || fail "the result is said in a notification"
pass "Add asks who, the name and the passwords in the menu, says what was wrong, and hands the helper what it was given"

run omarchy-user-add Adult bob bobpass1 bobpass2 bobpass1 bobpass1 wrongpw
(( status != 0 )) && [[ ! -e $tmp/helper ]] || fail "a wrong own password reaches no helper"
grep -q '^critical .*didn.t match' "$tmp/notified" && grep -q "^critical That password wasn't right" "$tmp/notified" || fail "a mismatch and a wrong own password are said" "$(cat "$tmp/notified")"
pass "a confirmation that does not match is asked again, and a wrong own password stops before the helper"

run omarchy-user-add Adult bob bobpass1 bobpass1 ESC
(( status != 0 )) && [[ ! -e $tmp/helper ]] || fail "dismissing the menu stops the add"
pass "dismissing a prompt stops the add"

TEST_HELPER_REFUSES=1 run omarchy-user-add Adult bob bobpass1 bobpass1 ownerpw
(( status != 0 )) && grep -q '^critical Nothing was changed Someone already has that password.' "$tmp/notified" || fail "the helper's refusal is said" "$(cat "$tmp/notified")"
pass "the helper's refusal reaches the person in a notification"

run_args=(emma)
run omarchy-user-delete Delete 'Keep their files' ownerpw
[[ $(cat "$tmp/helper") == $'args: delete emma\nownerpw' ]] || fail "keeping the files deletes the account alone" "$(cat "$tmp/helper")"
run omarchy-user-delete Delete 'Delete their files too' ownerpw
[[ $(head -1 "$tmp/helper") == "args: delete emma --delete-home" ]] || fail "deleting the files too asks the helper for that"
run omarchy-user-delete Cancel
(( status != 0 )) && [[ ! -e $tmp/helper ]] || fail "Cancel deletes nothing"
pass "Delete confirms in the menu, asks about the files, and Cancel deletes nothing"

run omarchy-user-themes '["Kids","General"]' ownerpw
[[ $(cat "$tmp/helper") == $'args: themes emma\nownerpw\nkids\ngeneral' ]] || fail "the ticked collections reach the helper" "$(cat "$tmp/helper")"
run omarchy-user-themes '[]'
(( status != 0 )) && [[ ! -e $tmp/helper ]] && grep -q 'Pick at least one' "$tmp/notified" || fail "ticking nothing is refused"
pass "Themes ticks collections in the menu, and ticking none is refused"

run omarchy-user-apps '[]' ownerpw
(( status == 0 )) && [[ $(cat "$tmp/helper") == $'args: apps emma\nownerpw' ]] || fail "unticking every app clears the list and succeeds" "status $status: $(cat "$tmp/helper" 2>/dev/null)"
pass "unticking every app clears the list, and the command says it worked"

# A child changing their own password goes through their passwordless grant,
# with no password of theirs read by sudo.
fake id <<'SH'
#!/bin/bash
case $1 in -un) echo emma ;; -nG) echo "emma omarchy-child" ;; *) exec /usr/bin/id "$@" ;; esac
SH
run_args=()
run omarchy-user-password kidpass1 kidpass2 kidpass2
(( status == 0 )) && [[ $(cat "$tmp/helper") == $'args: password-self\nkidpass1\nkidpass2' ]] || fail "a child's own change reaches password-self with their current and new password" "$(cat "$tmp/helper" 2>/dev/null)"
pass "a child changes their own password through the passwordless grant"
