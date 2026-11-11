#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-user-switch locks this desktop, then opens the other person's
# running session, or the login screen when they have none.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP=$tmp
mkdir -p "$tmp/bin"
fake() { cat >"$tmp/bin/$1"; chmod +x "$tmp/bin/$1"; }

fake omarchy-user-list <<'SH'
#!/bin/bash
printf 'dhh adult (you)\nemma child\nbob adult\n'
SH
fake id <<'SH'
#!/bin/bash
echo dhh
SH
fake omarchy-system-lock <<'SH'
#!/bin/bash
echo lock >>"$TEST_TMP/calls"
[[ -n ${TEST_NO_LOCK:-} ]] || touch "$TEST_TMP/locked"
SH
fake omarchy-hyprland-session-locked <<'SH'
#!/bin/bash
[[ -f $TEST_TMP/locked ]]
SH
fake sleep <<'SH'
#!/bin/bash
true
SH
fake loginctl <<'SH'
#!/bin/bash
if [[ $1 == "list-sessions" ]]; then
  echo '[{"session":"2","user":"dhh","seat":"seat0","class":"user","tty":"'"${TEST_MY_TTY:-tty2}"'"},{"session":"5","user":"emma","seat":null,"class":"manager"},{"session":"6","user":"emma","seat":"seat0","class":"user"},{"session":"9","user":"bob","seat":null,"class":"user"}]'
else
  echo "loginctl $*" >>"$TEST_TMP/calls"
fi
SH
fake omarchy-notification-send <<'SH'
#!/bin/bash
echo "notify $*" >>"$TEST_TMP/calls"
SH
fake busctl <<'SH'
#!/bin/bash
echo "busctl ${*: -1}" >>"$TEST_TMP/calls"
SH
export PATH="$tmp/bin:$PATH" OMARCHY_PATH=$ROOT

switch() {
  rm -f "$tmp/calls" "$tmp/locked"
  "$ROOT/bin/omarchy-user-switch" "$@"
}

switch emma
[[ $(cat "$tmp/calls") == $'lock\nloginctl activate 6' ]] || fail "switching to someone signed in locks this desktop, then opens theirs" "$(cat "$tmp/calls")"
pass "switching to someone signed in locks this desktop, then opens their graphical session"

switch bob
[[ $(cat "$tmp/calls") == $'lock\nbusctl SwitchToGreeter' ]] || fail "switching to someone with no desktop opens the login screen" "$(cat "$tmp/calls")"
pass "switching to someone with no desktop running opens the login screen"

# A desktop holding the first console, as an automatic login's does, would
# strand itself under SDDM's greeter; it is offered a logout instead.
TEST_MY_TTY=tty1 switch bob
[[ $(grep -c . "$tmp/calls") == 1 ]] && grep -q '^notify .*Log out to let bob sign in.*--exec omarchy-system logout' "$tmp/calls" ||
  fail "a desktop on the first console offers a logout instead of a greeter" "$(cat "$tmp/calls")"
TEST_MY_TTY=tty1 switch emma
[[ $(cat "$tmp/calls") == $'lock\nloginctl activate 6' ]] || fail "someone already signed in is still switched to from the first console"
pass "from the first console, someone not signed in is offered a logout instead of a greeter that would strand the desktop"

if TEST_NO_LOCK=1 switch emma 2>/dev/null; then fail "a desktop that did not lock switches nothing"; fi
[[ $(cat "$tmp/calls") == "lock" ]] || fail "nothing is switched when this desktop did not lock" "$(cat "$tmp/calls")"
pass "a desktop that did not lock switches nothing"

if switch dhh 2>/dev/null || switch nobody 2>/dev/null; then fail "only someone else can be switched to"; fi
pass "only someone else with an account can be switched to"
