#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d) || fail "a temporary directory can be created"
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# The account tools edit fixture passwd and group files, so each command sees
# what the one before it changed. Every call is recorded in calls.log.
cat >"$mock_bin/getent" <<'SH'
#!/bin/bash
file="$OMARCHY_TEST_DIR/$1"
if [[ -n ${2:-} ]]; then
  grep "^$2:" "$file"
else
  cat "$file"
fi
SH

# sudo -l -U reports full sudo for a wheel member once the wheel drop-in exists,
# and for anyone a file in sudoers.d names. Anything else runs as given.
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
echo "sudo $*" >>"$OMARCHY_TEST_DIR/calls.log"
if [[ $1 == "-l" && $2 == "-U" ]]; then
  echo "User $3 may run the following commands on test:"
  if [[ -e $OMARCHY_SUDOERS_DIR/00-omarchy-wheel ]] && grep -qE "^wheel:.*[:,]$3(,|$)" "$OMARCHY_TEST_DIR/group"; then
    echo "    (ALL) ALL"
  fi
  # A rule naming the user is listed as sudo prints it: its tags and all.
  sed -n "s/^$3 ALL=(\([^)]*\)) \(.*\)$/    (\1) \2/p" "$OMARCHY_SUDOERS_DIR"/* 2>/dev/null
  echo "    (root) NOPASSWD: /usr/bin/omarchy-dns Cloudflare"
  exit 0
fi
# -S takes the password from stdin; the commands check it against its hash.
while [[ ${1:-} == -* ]]; do
  case "$1" in
  -S) read -r _ || true ;;
  -p) shift ;;
  esac
  shift
done
# Another command finishing while this one waits for sudo: the first `sudo true`
# runs $OMARCHY_TEST_DIR/meanwhile once.
if [[ ${1:-} == "true" && -f $OMARCHY_TEST_DIR/meanwhile ]]; then
  bash "$OMARCHY_TEST_DIR/meanwhile"
  rm -f "$OMARCHY_TEST_DIR/meanwhile"
fi
exec "$@"
SH

cat >"$mock_bin/visudo" <<'SH'
#!/bin/bash
echo "visudo $*" >>"$OMARCHY_TEST_DIR/calls.log"
[[ -z ${OMARCHY_TEST_VISUDO_FAIL:-} && $(cat "${!#}") == "%wheel ALL=(ALL:ALL) ALL" ]]
SH

cat >"$mock_bin/useradd" <<'SH'
#!/bin/bash
echo "useradd $*" >>"$OMARCHY_TEST_DIR/calls.log"
groups="" shell="" uid=""
while (( $# > 1 )); do
  case "$1" in
  -m) ;;
  -s) shell="$2"; shift ;;
  -G) groups="$2"; shift ;;
  -u) uid="$2"; shift ;;
  esac
  shift
done
name="$1"
[[ -z ${OMARCHY_TEST_USERADD_FAIL:-} ]] || { echo "useradd: cannot create $name" >&2; exit 1; }
# Like the real one: the lowest free UID.
[[ -n $uid ]] || uid=$(awk -F: '$3 >= 1000 && $3 < 60000 { taken[$3] = 1 } END { for (u = 1000; u in taken; u++); print u }' "$OMARCHY_TEST_DIR/passwd")
mkdir -p "$OMARCHY_TEST_DIR/home/$name"
echo "$name $uid" >>"$OMARCHY_TEST_DIR/home_owners"
echo "$name:x:$uid:$uid::$OMARCHY_TEST_DIR/home/$name:$shell" >>"$OMARCHY_TEST_DIR/passwd"
echo "$name:x:$uid:" >>"$OMARCHY_TEST_DIR/group"
if [[ $groups == "wheel" ]]; then
  sed -i -E "/^wheel:/ { s/:$/:$name/; t; s/$/,$name/ }" "$OMARCHY_TEST_DIR/group"
fi
SH

# Home folders keep their owner's UID (recorded in home_owners) after the
# account is gone; anything else stat answers for real.
cat >"$mock_bin/stat" <<'SH'
#!/bin/bash
if [[ $1 == "-c" && $2 == "%u" ]]; then
  shift 2
  for dir in "$@"; do
    awk -v name="${dir##*/}" '$1 == name { print $2; found = 1 } END { if (!found) print 0 }' "$OMARCHY_TEST_DIR/home_owners"
  done
  exit 0
fi
exec /usr/bin/stat "$@"
SH

cat >"$mock_bin/chpasswd" <<'SH'
#!/bin/bash
echo "chpasswd $*" >>"$OMARCHY_TEST_DIR/calls.log"
cat >>"$OMARCHY_TEST_DIR/chpasswd.log"
[[ -z ${OMARCHY_TEST_CHPASSWD_FAIL:-} ]]
SH

# The disk: encrypted when $OMARCHY_TEST_DIR/encrypted exists, its password in
# disk_password. omarchy-drive-password sets it to OMARCHY_TEST_NEW_DISK.
cat >"$mock_bin/findmnt" <<'SH'
#!/bin/bash
if [[ -e $OMARCHY_TEST_DIR/encrypted ]]; then echo /dev/mapper/root; else echo /dev/vda2; fi
SH

# NAME TYPE FSTYPE up from /. With $OMARCHY_TEST_DIR/undecidable, / sits on an
# encryption layer whose LUKS device the listing can't name.
cat >"$mock_bin/lsblk" <<'SH'
#!/bin/bash
if [[ -e $OMARCHY_TEST_DIR/undecidable ]]; then
  printf '/dev/mapper/root crypt btrfs\n/dev/vda disk \n'
elif [[ -e $OMARCHY_TEST_DIR/encrypted ]]; then
  printf '/dev/mapper/root crypt btrfs\n/dev/vda2 part crypto_LUKS\n/dev/vda disk \n'
else
  printf '/dev/vda2 part btrfs\n/dev/vda disk \n'
fi
SH

# The commands run as an administrator unless $OMARCHY_TEST_DIR/not_admin says
# otherwise.
cat >"$mock_bin/omarchy-sudo-allowed" <<'SH'
#!/bin/bash
[[ ! -e $OMARCHY_TEST_DIR/not_admin ]]
SH

# A wrong passphrase is status 2 and an empty one 1, as with the real one. From
# the OMARCHY_TEST_CRYPTSETUP_ERROR_AT-th check on, it can't tell (an I/O error).
cat >"$mock_bin/cryptsetup" <<'SH'
#!/bin/bash
# luksDump shows as many keys as $OMARCHY_TEST_DIR/disk_keys says, one by default.
if [[ $1 == "luksDump" ]]; then
  printf 'LUKS header information\nVersion:        2\n\nKeyslots:\n'
  for (( slot = 0; slot < $(cat "$OMARCHY_TEST_DIR/disk_keys" 2>/dev/null || echo 1); slot++ )); do
    printf '  %s: luks2\n\tKey:        512 bits\n' "$slot"
  done
  printf 'Tokens:\nDigests:\n'
  exit 0
fi
[[ $1 == "open" && " $* " == *" --test-passphrase "* ]] || exit 9
count=$(( $(cat "$OMARCHY_TEST_DIR/cryptsetup.count" 2>/dev/null || echo 0) + 1 ))
echo "$count" >"$OMARCHY_TEST_DIR/cryptsetup.count"
(( ${OMARCHY_TEST_CRYPTSETUP_ERROR_AT:-0} == 0 || count < OMARCHY_TEST_CRYPTSETUP_ERROR_AT )) || exit 3
passphrase=$(cat)
[[ -n $passphrase ]] || exit 1
[[ $passphrase == "$(cat "$OMARCHY_TEST_DIR/disk_password")" ]] || exit 2
SH

# find, failing with OMARCHY_TEST_FIND_FAIL, as on an unreadable directory.
cat >"$mock_bin/find" <<'SH'
#!/bin/bash
[[ -z ${OMARCHY_TEST_FIND_FAIL:-} ]] || exit 1
exec /usr/bin/find "$@"
SH

# mv, failing with OMARCHY_TEST_MV_FAIL, as on a full or read-only disk.
cat >"$mock_bin/mv" <<'SH'
#!/bin/bash
[[ -z ${OMARCHY_TEST_MV_FAIL:-} ]] || exit 1
exec /usr/bin/mv "$@"
SH

# The current and new disk passwords arrive on stdin, as with the real one.
cat >"$mock_bin/omarchy-drive-password" <<'SH'
#!/bin/bash
echo "omarchy-drive-password $*" >>"$OMARCHY_TEST_DIR/calls.log"
[[ $1 == "--system-stdin" ]] || exit 9
# The real one refuses while a change it recorded earlier is unfinished.
if [[ -n ${OMARCHY_TEST_DRIVE_PENDING:-} ]]; then
  echo "The last password change for /dev/vda2 stopped part way. Run omarchy-drive-password to finish it first."
  exit 1
fi
IFS= read -r current
IFS= read -r new
[[ -z ${OMARCHY_TEST_DRIVE_FAIL:-} && $current == "$(cat "$OMARCHY_TEST_DIR/disk_password")" ]] || exit 1
[[ -n ${OMARCHY_TEST_DRIVE_NOOP:-} ]] || printf '%s' "$new" >"$OMARCHY_TEST_DIR/disk_password"
SH

# passwd: root's status and lock, and the administrator changing their own
# password to OMARCHY_TEST_NEW_LOGIN.
cat >"$mock_bin/passwd" <<'SH'
#!/bin/bash
case "${1:-}" in
-S) echo "root $(cat "$OMARCHY_TEST_DIR/root_status") 2026-10-12 -1 -1 -1 -1" ;;
-l) echo "passwd -l $2" >>"$OMARCHY_TEST_DIR/calls.log"; echo L >"$OMARCHY_TEST_DIR/root_status" ;;
"")
  echo "passwd (own)" >>"$OMARCHY_TEST_DIR/calls.log"
  hash=$(printf '%s\n' "$OMARCHY_TEST_NEW_LOGIN" | perl -e 'my $p = <STDIN>; chomp $p; print crypt($p, q($6$testsalt$))')
  awk -F: -v user="$SUDO_USER" -v hash="$hash" 'BEGIN { OFS = ":" } $1 == user { $2 = hash } 1' \
    "$OMARCHY_TEST_DIR/shadow" >"$OMARCHY_TEST_DIR/shadow.new" && mv "$OMARCHY_TEST_DIR/shadow.new" "$OMARCHY_TEST_DIR/shadow"
  ;;
esac
SH

# gum answers from a queue, one line per prompt: "yes"/"no" for confirm, the
# text for input and choose. Every prompt is logged.
cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
echo "gum $*" >>"$OMARCHY_TEST_DIR/gum.log"
# Out of answers is someone pressing Esc.
[[ -s $OMARCHY_TEST_DIR/answers ]] || exit 130
answer=$(head -n 1 "$OMARCHY_TEST_DIR/answers")
sed -i 1d "$OMARCHY_TEST_DIR/answers"
if [[ $1 == "confirm" ]]; then
  [[ $answer == "yes" ]]
else
  printf '%s\n' "$answer"
fi
SH

# With OMARCHY_TEST_USERDEL_HOME_FAIL, it removes the account and then fails on
# the home folder (status 12), as the real one does.
cat >"$mock_bin/userdel" <<'SH'
#!/bin/bash
echo "userdel $*" >>"$OMARCHY_TEST_DIR/calls.log"
name="${!#}"
sed -i "/^$name:/d" "$OMARCHY_TEST_DIR/passwd" "$OMARCHY_TEST_DIR/group"
sed -i -E "/^wheel:/ { s/([:,])$name(,|$)/\1/; s/,$// }" "$OMARCHY_TEST_DIR/group"
if [[ $1 == "-r" && -n ${OMARCHY_TEST_USERDEL_HOME_FAIL:-} ]]; then
  echo "userdel: error removing directory /home/$name" >&2
  exit 12
elif [[ $1 == "-r" ]]; then
  rm -rf "${OMARCHY_TEST_DIR:?}/home/${name:?}"
  echo "userdel: $name mail spool (/var/spool/mail/$name) not found" >&2
fi
SH

cat >"$mock_bin/gpasswd" <<'SH'
#!/bin/bash
echo "gpasswd $*" >>"$OMARCHY_TEST_DIR/calls.log"
name="$2"
case "$1" in
-a) sed -i -E "/^wheel:/ { s/:$/:$name/; t; s/$/,$name/ }" "$OMARCHY_TEST_DIR/group" ;;
-d) sed -i -E "/^wheel:/ { s/([:,])$name(,|$)/\1/; s/,$// }" "$OMARCHY_TEST_DIR/group" ;;
esac
echo "Adding/removing user $name"
SH

# Users with programs running are listed in procs; signing out clears them.
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
grep -qxF "$2" "$OMARCHY_TEST_DIR/procs"
SH

# A user in outside_session also has programs that signing out doesn't end.
cat >"$mock_bin/loginctl" <<'SH'
#!/bin/bash
echo "loginctl $*" >>"$OMARCHY_TEST_DIR/calls.log"
if [[ $1 == "terminate-user" ]] && ! grep -qxF "$2" "$OMARCHY_TEST_DIR/outside_session"; then
  sed -i "/^$2$/d" "$OMARCHY_TEST_DIR/procs"
fi
SH

cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
echo "pkill $*" >>"$OMARCHY_TEST_DIR/calls.log"
sed -i "/^$3$/d" "$OMARCHY_TEST_DIR/procs"
SH

cat >"$mock_bin/chmod" <<'SH'
#!/bin/bash
echo "chmod $*" >>"$OMARCHY_TEST_DIR/calls.log"
SH

cat >"$mock_bin/logger" <<'SH'
#!/bin/bash
[[ $1 == "-t" && $2 == "omarchy-user" && $3 == "--" ]] || exit 1
echo "$4" >>"$OMARCHY_TEST_DIR/journal"
SH

chmod +x "$mock_bin"/*

reset_fixtures() {
  rm -rf "${test_tmp:?}/home" "$test_tmp/sudoers.d" "$test_tmp/calls.log" "$test_tmp/journal" "$test_tmp/chpasswd.log" "$test_tmp/encrypted" "$test_tmp/undecidable" "$test_tmp/not_admin" "$test_tmp/cryptsetup.count" "$test_tmp/disk_keys" "$test_tmp/state"
  mkdir -p "$test_tmp/home/alice" "$test_tmp/home/bob" "$test_tmp/sudoers.d"
  # The owner, alice, was installed from the ISO: sudo by name, no wheel rule.
  echo "alice ALL=(ALL) ALL" >"$test_tmp/sudoers.d/04_alice"
  : >"$test_tmp/calls.log"
  : >"$test_tmp/journal"
  printf 'alice 1000\nbob 1001\n' >"$test_tmp/home_owners"
  : >"$test_tmp/procs"
  : >"$test_tmp/outside_session"
  : >"$test_tmp/answers"
  : >"$test_tmp/gum.log"
  echo P >"$test_tmp/root_status"
  printf 'alicepw' >"$test_tmp/disk_password"
  printf '[Autologin]\nUser=alice\nSession=omarchy.desktop\n' >"$test_tmp/autologin.conf"
  # alice's login password is alicepw, as the installer would have the disk.
  printf 'alice:%s:20000::::::\n' "$(printf 'alicepw\n' | perl -e 'my $p = <STDIN>; chomp $p; print crypt($p, q($6$testsalt$))')" >"$test_tmp/shadow"

  cat >"$test_tmp/passwd" <<EOF
root:x:0:0::/root:/usr/bin/bash
alpm:x:970:970:Arch Linux Package Management:/:/usr/bin/nologin
alice:x:1000:1000::$test_tmp/home/alice:/bin/bash
bob:x:1001:1001::$test_tmp/home/bob:/bin/bash
svc:x:1002:1002::/home/svc:/usr/bin/nologin
carl:x:1004:1004::$test_tmp/home/carl:/bin/bash
EOF

  cat >"$test_tmp/group" <<'EOF'
root:x:0:root
wheel:x:998:alice
alice:x:1000:
bob:x:1001:
svc:x:1002:
carl:x:1004:
staff:x:1500:
EOF
}

# Runs an omarchy-user command as alice, an administrator. Callers capture or
# discard stdout, so the commands never see a terminal and never prompt.
run_user() {
  local command="$1"
  shift
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE=/nonexistent OMARCHY_TEST_DIR="$test_tmp" \
    SUDO_USER=${RUN_AS:-alice} OMARCHY_LOGIN_DEFS=/dev/null OMARCHY_SUDOERS_DIR="$test_tmp/sudoers.d" \
    OMARCHY_SDDM_AUTOLOGIN="$test_tmp/autologin.conf" OMARCHY_USER_LOCK="$test_tmp/user.lock" OMARCHY_HOME_ROOT="$test_tmp/home" XDG_STATE_HOME="$test_tmp/state" \
    "$ROOT/bin/omarchy-user-$command" "$@"
}

wheel_members() {
  grep '^wheel:' "$test_tmp/group" | cut -d: -f4
}

has_user() {
  grep -q "^$1:" "$test_tmp/passwd"
}

# --- omarchy user add ---

reset_fixtures
output=$(printf 's3cret pass:word\n' | run_user add carol --password-stdin 2>&1) ||
  fail "add creates a user with a password from stdin" "$output"
grep -Eq '^carol:x:[0-9]+:[0-9]+::.*/home/carol:/bin/bash$' "$test_tmp/passwd" ||
  fail "add creates a user with a password from stdin" "$(cat "$test_tmp/passwd")"
[[ $(cat "$test_tmp/chpasswd.log") == "carol:s3cret pass:word" ]] ||
  fail "add creates a user with a password from stdin" "$(cat "$test_tmp/chpasswd.log")"
[[ $(wheel_members) == "alice" ]] || fail "a new user isn't an administrator by default" "$(wheel_members)"
[[ $output == *"Added carol (administrator: no)"* ]] || fail "add reports what it did" "$output"
pass "add creates a user with a password from stdin"

grep -qF "s3cret" "$test_tmp/calls.log" && fail "the password never appears on a command line" "$(cat "$test_tmp/calls.log")"
pass "the password never appears on a command line"

[[ $(cat "$test_tmp/journal") == "login user 'carol' added by alice (administrator: no)" ]] ||
  fail "add writes one plain journal line naming who did it" "$(cat "$test_tmp/journal")"
pass "add writes one plain journal line naming who did it"

reset_fixtures
printf 'pw\n' | run_user add dave --admin --password-stdin >/dev/null ||
  fail "add --admin puts the user in wheel"
[[ $(wheel_members) == "alice,dave" ]] || fail "add --admin puts the user in wheel" "$(wheel_members)"
[[ $(cat "$test_tmp/sudoers.d/00-omarchy-wheel") == "%wheel ALL=(ALL:ALL) ALL" ]] ||
  fail "add --admin gives wheel sudo on an install that granted it only by name"
pass "add --admin puts the user in wheel and gives wheel sudo"

reset_fixtures
if printf 'pw\n' | OMARCHY_TEST_VISUDO_FAIL=1 run_user add dave --admin --password-stdin >/dev/null 2>&1; then
  fail "add --admin stops when the sudo rule doesn't validate"
fi
has_user dave && fail "add --admin stops when the sudo rule doesn't validate"
[[ -z $(ls "$test_tmp/sudoers.d" | grep -v 04_alice) ]] ||
  fail "a rule that doesn't validate leaves nothing in sudoers.d" "$(ls "$test_tmp/sudoers.d")"
pass "add --admin stops when the sudo rule doesn't validate, and leaves nothing behind"

reset_fixtures
if printf 'pw\n' | OMARCHY_TEST_MV_FAIL=1 run_user add dave --admin --password-stdin >/dev/null 2>&1; then
  fail "add --admin stops when the sudo rule can't be put in place"
fi
has_user dave && fail "add --admin stops when the sudo rule can't be put in place"
pass "add --admin stops when the sudo rule can't be put in place"

reset_fixtures
printf 'pw\n' | run_user add carol --password-stdin >/dev/null || fail "add without --admin leaves sudoers alone"
[[ $(ls "$test_tmp/sudoers.d") == "04_alice" ]] || fail "add without --admin leaves sudoers alone" "$(ls "$test_tmp/sudoers.d")"
pass "add without --admin leaves sudoers alone"

reset_fixtures
for name in Eve 1x a.b 'a b' -x x\$ "$(printf 'a%.0s' {1..33})"; do
  if printf 'pw\n' | run_user add "$name" --password-stdin >/dev/null 2>&1; then
    fail "add rejects the invalid name '$name'"
  fi
done
grep -q useradd "$test_tmp/calls.log" && fail "add rejects invalid names before changing anything"
pass "add rejects invalid names before changing anything"

for name in bob root staff; do
  if printf 'pw\n' | run_user add "$name" --password-stdin >/dev/null 2>&1; then
    fail "add refuses a name already used by a user or group: $name"
  fi
done
grep -q useradd "$test_tmp/calls.log" && fail "add refuses a name already used by a user or group"
pass "add refuses a name already used by a user or group"

if printf '\n' | run_user add carol --password-stdin >/dev/null 2>&1; then
  fail "add refuses an empty password"
fi
has_user carol && fail "add refuses an empty password"
pass "add refuses an empty password"

output=$(run_user add carol 2>&1) && fail "add without a terminal needs --password-stdin"
[[ $output == *"--password-stdin"* ]] || fail "add without a terminal needs --password-stdin" "$output"
run_user add --password-stdin >/dev/null 2>&1 && fail "add without a terminal needs a name"
pass "add without a terminal needs a name and --password-stdin"

reset_fixtures
if printf 'pw\n' | OMARCHY_TEST_CHPASSWD_FAIL=1 run_user add carol --password-stdin >/dev/null 2>&1; then
  fail "add rolls back the user when the password can't be set"
fi
has_user carol && fail "add rolls back the user when the password can't be set" "$(cat "$test_tmp/passwd")"
[[ -s $test_tmp/journal ]] && fail "a rolled-back add writes no journal line"
pass "add rolls back the user when the password can't be set"

# --- omarchy user remove ---

reset_fixtures
run_user remove bob >/dev/null 2>&1 && fail "remove without a terminal needs --yes"
has_user bob || fail "remove without a terminal needs --yes"
pass "remove without a terminal needs --yes"

output=$(run_user remove bob --yes 2>&1) || fail "remove deletes the account and keeps the home folder" "$output"
has_user bob && fail "remove deletes the account and keeps the home folder"
[[ -d $test_tmp/home/bob ]] || fail "remove deletes the account and keeps the home folder"
grep -qx "userdel bob" "$test_tmp/calls.log" || fail "remove deletes the account and keeps the home folder" "$(cat "$test_tmp/calls.log")"
pass "remove deletes the account and keeps the home folder"

[[ $(cat "$test_tmp/journal") == "login user 'bob' removed by alice, home folder $test_tmp/home/bob kept" ]] ||
  fail "remove writes one plain journal line" "$(cat "$test_tmp/journal")"
pass "remove writes one plain journal line"

reset_fixtures
echo bob >"$test_tmp/procs"
output=$(run_user remove bob --delete-home --yes 2>&1) || fail "remove --delete-home signs the user out and deletes the home folder" "$output"
grep -qx "loginctl terminate-user bob" "$test_tmp/calls.log" &&
  grep -qx "userdel -r bob" "$test_tmp/calls.log" &&
  [[ ! -e $test_tmp/home/bob ]] ||
  fail "remove --delete-home signs the user out and deletes the home folder" "$(cat "$test_tmp/calls.log")"
[[ $output != *"mail spool"* ]] || fail "userdel's missing mail spool warning is hidden" "$output"
grep -q pkill "$test_tmp/calls.log" && fail "remove only kills programs that outlast signing out"
pass "remove --delete-home signs the user out and deletes the home folder"

reset_fixtures
echo bob >"$test_tmp/procs"
echo bob >"$test_tmp/outside_session"
output=$(run_user remove bob --yes 2>&1) || fail "remove stops programs that signing out leaves running" "$output"
grep -qx "pkill -KILL -u bob" "$test_tmp/calls.log" && ! has_user bob ||
  fail "remove stops programs that signing out leaves running" "$(cat "$test_tmp/calls.log")"
pass "remove stops programs that signing out leaves running"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
output=$(run_user remove alice --yes 2>&1) && fail "remove refuses your own account"
[[ $output == *"your own account"* ]] || fail "remove refuses your own account" "$output"
for name in root svc nobody; do
  if run_user remove "$name" --yes >/dev/null 2>&1; then
    fail "remove refuses system accounts and unknown users: $name"
  fi
done
grep -q userdel "$test_tmp/calls.log" && fail "remove refuses yourself, system accounts and unknown users"
pass "remove refuses yourself, system accounts and unknown users"

reset_fixtures
output=$(RUN_AS=root run_user remove alice --yes 2>&1) && fail "remove refuses the last administrator"
[[ $output == *"last administrator"* ]] || fail "remove refuses the last administrator" "$output"
has_user alice || fail "remove refuses the last administrator"
pass "remove refuses the last administrator"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
RUN_AS=bob run_user remove alice --yes >/dev/null 2>&1 || fail "remove drops the installer's sudo grant for the name"
[[ ! -e $test_tmp/sudoers.d/04_alice ]] || fail "remove drops the installer's sudo grant for the name"
pass "remove drops the installer's sudo grant for the name"

# --- omarchy user admin ---

reset_fixtures
output=$(run_user admin bob on 2>&1) || fail "admin on adds the user to wheel" "$output"
[[ $(wheel_members) == "alice,bob" ]] || fail "admin on adds the user to wheel" "$(wheel_members)"
[[ -e $test_tmp/sudoers.d/00-omarchy-wheel && ! -e $test_tmp/sudoers.d/00-omarchy-wheel.new ]] ||
  fail "admin on gives wheel sudo" "$(ls "$test_tmp/sudoers.d")"
grep -qx "chmod 0440 $test_tmp/sudoers.d/00-omarchy-wheel.new" "$test_tmp/calls.log" ||
  fail "the wheel rule is made read-only before it goes live" "$(cat "$test_tmp/calls.log")"
[[ $(tail -1 "$test_tmp/journal") == "login user 'bob' made an administrator by alice" ]] ||
  fail "admin on writes one plain journal line" "$(cat "$test_tmp/journal")"
pass "admin on adds the user to wheel and gives wheel sudo"

: >"$test_tmp/calls.log"
output=$(run_user admin bob on 2>&1) || fail "admin on for an administrator changes nothing" "$output"
[[ $output == "bob is already an administrator." ]] || fail "admin on for an administrator changes nothing" "$output"
grep -q gpasswd "$test_tmp/calls.log" && fail "admin on for an administrator changes nothing"
pass "admin on for an administrator changes nothing"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
output=$(run_user admin bob on 2>&1) || fail "admin on gives wheel sudo for a member who had none" "$output"
[[ $output == "bob is already an administrator." && -e $test_tmp/sudoers.d/00-omarchy-wheel ]] ||
  fail "admin on gives wheel sudo for a member who had none" "$output"
pass "admin on gives wheel sudo for a member who had none"

echo bob >"$test_tmp/procs"
output=$(run_user admin bob off 2>&1) || fail "admin off removes the user from wheel" "$output"
[[ $(wheel_members) == "alice" ]] || fail "admin off removes the user from wheel" "$(wheel_members)"
[[ $output == *"keep sudo until bob logs out"* ]] || fail "admin off warns that open sessions keep sudo" "$output"
grep -q terminate-user "$test_tmp/calls.log" && fail "admin off signs nobody out without asking"
pass "admin off removes the user from wheel and warns that open sessions keep sudo"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
run_user admin alice off >/dev/null 2>&1 && fail "admin off refuses your own account"
RUN_AS=bob run_user admin bob off >/dev/null 2>&1 && fail "admin off refuses your own account"
pass "admin off refuses your own account"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
echo "%wheel ALL=(ALL:ALL) ALL" >"$test_tmp/sudoers.d/00-omarchy-wheel"
output=$(RUN_AS=bob run_user admin alice off 2>&1) || fail "admin off also drops the installer's sudo grant" "$output"
[[ $(wheel_members) == "bob" && ! -e $test_tmp/sudoers.d/04_alice ]] ||
  fail "admin off also drops the installer's sudo grant" "$(wheel_members); $(ls "$test_tmp/sudoers.d")"
pass "admin off also drops the installer's sudo grant"

reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
printf '# kept by hand\nalice ALL=(ALL) ALL\n' >"$test_tmp/sudoers.d/04_alice"
output=$(RUN_AS=bob run_user admin alice off 2>&1) && fail "admin off reports a sudo grant it didn't write"
[[ $output == *"another sudo rule"* && -e $test_tmp/sudoers.d/04_alice ]] ||
  fail "admin off reports a sudo grant it didn't write, and leaves it alone" "$output"
pass "admin off reports a sudo grant it didn't write, and leaves it alone"

reset_fixtures
output=$(RUN_AS=root run_user admin alice off 2>&1) && fail "admin off refuses the last administrator"
[[ $output == *"last administrator"* ]] || fail "admin off refuses the last administrator" "$output"
pass "admin off refuses the last administrator"

reset_fixtures
sed -i 's/^bob:x:1001:1001:/bob:x:1001:998:/' "$test_tmp/passwd"
output=$(run_user admin bob off 2>&1) && fail "admin off explains a primary group of wheel"
[[ $output == *"primary group"* ]] || fail "admin off explains a primary group of wheel" "$output"
pass "admin off explains a primary group of wheel"

reset_fixtures
run_user admin svc on >/dev/null 2>&1 && fail "admin refuses system accounts"
run_user admin root on >/dev/null 2>&1 && fail "admin refuses system accounts"
pass "admin refuses system accounts"

run_user admin bob >/dev/null 2>&1 && fail "admin without a terminal needs on or off"
run_user admin bob maybe >/dev/null 2>&1 && fail "admin rejects anything but on or off"
run_user admin bob on off >/dev/null 2>&1 && fail "admin rejects a third word"
grep -q gpasswd "$test_tmp/calls.log" && fail "admin changes nothing on bad arguments"
pass "admin rejects incomplete or bad arguments"

# Another command can change the account while this one waits for sudo: the
# decision is made on what holds under the lock.
reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
printf 'sed -i -E "/^wheel:/ s/,bob(,|$)/\\1/" "%s/group"\n' "$test_tmp" >"$test_tmp/meanwhile"
if output=$(run_user admin bob on 2>&1); then fail "admin on goes on after bob was demoted meanwhile"; fi
[[ $output == *"changed while this was waiting"* && $(wheel_members) == "alice" ]] ||
  fail "admin on stops when bob was demoted while it waited" "$output; $(wheel_members)"
rm -f "$test_tmp/meanwhile"
pass "admin decides on the account as it is under the lock"

# on and off are valid names too, so the first word is always the name.
reset_fixtures
printf 'on:x:1005:1005::%s/home/on:/bin/bash\n' "$test_tmp" >>"$test_tmp/passwd"
printf 'on:x:1005:\n' >>"$test_tmp/group"
mkdir -p "$test_tmp/home/on"
output=$(run_user admin on on 2>&1) || fail "an account named on can be made an administrator" "$output"
[[ $(wheel_members) == "alice,on" ]] || fail "admin on on makes the account named on an administrator" "$(wheel_members)"
output=$(run_user admin on off 2>&1) || fail "an account named on can lose administrator rights" "$output"
[[ $(wheel_members) == "alice" ]] || fail "admin on off takes the account named on out of wheel" "$(wheel_members)"
pass "an account named on is a name, not a state"

# --- running as root ---

# Under sudo or in a root shell the session's OMARCHY_PATH is gone. A user
# namespace stands in for root where the system allows one.
if unshare -r true 2>/dev/null; then
  for command in add remove admin; do
    if output=$(env -u OMARCHY_PATH unshare -r "$ROOT/bin/omarchy-user-$command" bob 2>&1); then
      fail "$command refuses to run as root"
    fi
    [[ $output == *"run this as your user"* ]] || fail "$command explains why it won't run as root" "$output"
  done
  pass "add, remove and admin refuse to run as root, with a clear reason"
else
  skip "add, remove and admin refuse to run as root (no user namespaces here)"
fi

# --- the second account, and back to one ---

# The switch-overs need a terminal, so these run under script(1), which gives
# the command a real one. gum answers from the queue in $test_tmp/answers.
run_tty() {
  local command="$1" cmd status
  shift
  printf -v cmd '%q ' "$ROOT/bin/omarchy-user-$command" "$@"
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE=/nonexistent OMARCHY_TEST_DIR="$test_tmp" \
    SUDO_USER=${RUN_AS:-alice} OMARCHY_LOGIN_DEFS=/dev/null OMARCHY_SUDOERS_DIR="$test_tmp/sudoers.d" \
    OMARCHY_SDDM_AUTOLOGIN="$test_tmp/autologin.conf" OMARCHY_USER_LOCK="$test_tmp/user.lock" OMARCHY_HOME_ROOT="$test_tmp/home" XDG_STATE_HOME="$test_tmp/state" \
    script -qefc "$cmd" /dev/null </dev/null >"$test_tmp/tty.out" 2>&1
  status=$?
  tr -d '\r' <"$test_tmp/tty.out"
  return "$status"
}

answers() {
  printf '%s\n' "$@" >"$test_tmp/answers"
}

only_alice() {
  sed -i -E '/^(bob|carl):/d' "$test_tmp/passwd" "$test_tmp/group"
}

password_prompts() {
  grep -c -- "--password" "$test_tmp/gum.log"
}

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
if output=$(printf 'pw\n' | run_user add carol --password-stdin 2>&1); then
  fail "the second account needs a terminal"
fi
[[ $output == *"add it in a terminal"* ]] || fail "the second account says it needs a terminal" "$output"
has_user carol && fail "the second account needs a terminal"
[[ $(cat "$test_tmp/root_status") == "P" && -e $test_tmp/autologin.conf ]] || fail "the second account needs a terminal, and nothing changes without one"
pass "the second account needs a terminal, and nothing changes without one"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
output=$(run_tty add carol) || fail "a second account with a new shared disk password" "$output"
has_user carol &&
  [[ $(cat "$test_tmp/disk_password") == "sharedpw" ]] &&
  [[ $(cat "$test_tmp/root_status") == "L" ]] &&
  [[ ! -e $test_tmp/autologin.conf ]] ||
  fail "a second account with a new shared disk password: disk changed, root locked, autologin off" "$output"
[[ $output == *"Give carol the disk password"* ]] || fail "the administrator is reminded to share the disk password" "$output"
grep -q "Your password also unlocks the disk" "$test_tmp/gum.log" || fail "the administrator is asked which password to change" "$(cat "$test_tmp/gum.log")"
grep -q "confirm .*Continue?$" "$test_tmp/gum.log" && [[ $output == *"the disk password is shared"* ]] ||
  fail "the administrator is told what changes and asked to continue" "$output"
grep -q "disk password changed by alice" "$test_tmp/journal" && grep -q "root account locked by alice" "$test_tmp/journal" &&
  grep -q "automatic login turned off by alice" "$test_tmp/journal" || fail "each change writes a journal line" "$(cat "$test_tmp/journal")"
pass "a second account with a new shared disk password: disk changed, root locked, autologin off"

[[ $(password_prompts) == 5 ]] || fail "the second account asks for five passwords: yours, theirs twice, the shared one twice" "$(cat "$test_tmp/gum.log")"
grep -qx "omarchy-drive-password --system-stdin" "$test_tmp/calls.log" || fail "the disk change gets both passwords from the command" "$(cat "$test_tmp/calls.log")"
pass "the second account asks for each password once: yours, theirs twice, the shared one twice"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" alicepw alicepw sharedpw sharedpw
output=$(run_tty add carol) || fail "your own password is refused as the shared disk password" "$output"
[[ $output == *"That's your own password"* && $(cat "$test_tmp/disk_password") == "sharedpw" ]] ||
  fail "your own password is refused as the shared disk password" "$output"
pass "your own password is refused as the shared disk password"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new password for me" newalicepw newalicepw
output=$(run_tty add carol) || fail "a second account with a new password for the administrator" "$output"
has_user carol && [[ $(cat "$test_tmp/disk_password") == "alicepw" ]] && grep -qx "alice:newalicepw" "$test_tmp/chpasswd.log" ||
  fail "a second account with a new password for the administrator keeps the disk password" "$output"
pass "a second account with a new password for the administrator keeps the disk password"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new password for me" alicepw alicepw newalicepw newalicepw
output=$(run_tty add carol) || fail "a new own password that unlocks the disk is refused" "$output"
[[ $output == *"That one unlocks the disk"* ]] && grep -qx "alice:newalicepw" "$test_tmp/chpasswd.log" ||
  fail "a new own password that unlocks the disk is refused" "$output"
pass "a new own password that unlocks the disk is refused"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes wrongpw alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
output=$(run_tty add carol) || fail "a mistyped own password is asked again" "$output"
[[ $output == *"That isn't your password"* ]] && has_user carol || fail "a mistyped own password is asked again" "$output"
pass "a mistyped own password is asked again"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
printf 'otherdiskpw' >"$test_tmp/disk_password"
answers yes alicepw no carolpw carolpw
output=$(run_tty add carol) || fail "already separate passwords need no change" "$output"
has_user carol && ! grep -q "choose" "$test_tmp/gum.log" && ! grep -q "omarchy-drive-password --system-stdin" "$test_tmp/calls.log" &&
  [[ $(cat "$test_tmp/root_status") == "L" ]] || fail "already separate passwords need no change, but root is still locked" "$output"
pass "already separate passwords need no change, but root is still locked"

reset_fixtures
only_alice
answers yes alicepw no carolpw carolpw
output=$(run_tty add carol) || fail "an unencrypted install skips the disk" "$output"
has_user carol && ! grep -q "choose" "$test_tmp/gum.log" && [[ $output != *"disk password"* ]] ||
  fail "an unencrypted install skips the disk" "$output"
pass "an unencrypted install skips the disk"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers no
if run_tty add carol >/dev/null; then fail "declining the switch-over adds no one"; fi
has_user carol && fail "declining the switch-over adds no one"
[[ $(cat "$test_tmp/root_status") == "P" && -e $test_tmp/autologin.conf ]] || fail "declining the switch-over changes nothing"
pass "declining the switch-over adds no one and changes nothing"

reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if OMARCHY_TEST_DRIVE_FAIL=1 run_tty add carol >/dev/null; then fail "a disk password that didn't change stops the switch-over"; fi
has_user carol && fail "a disk password that didn't change stops the switch-over"
[[ $(cat "$test_tmp/root_status") == "P" ]] || fail "a disk password that didn't change leaves root alone"
pass "a disk password that didn't change stops the switch-over and adds no one"

# omarchy-drive-password can also finish without changing anything, so the
# result is checked, not its exit status.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if output=$(OMARCHY_TEST_DRIVE_NOOP=1 run_tty add carol); then fail "an unchanged disk stops the switch-over"; fi
[[ $output == *"The disk password didn't change"* ]] && ! has_user carol ||
  fail "an unchanged disk stops the switch-over" "$output"
pass "an unchanged disk stops the switch-over"

reset_fixtures
answers no carolpw carolpw
output=$(run_tty add carol) || fail "a third account changes nothing about unlocking" "$output"
! grep -q "Continue" "$test_tmp/gum.log" && [[ $(cat "$test_tmp/root_status") == "P" ]] ||
  fail "a third account changes nothing about unlocking" "$(cat "$test_tmp/gum.log")"
pass "a third account changes nothing about unlocking"

# Back to one: alice and bob, with the disk on the shared password and root locked.
two_accounts() {
  reset_fixtures
  sed -i -E '/^carl:/d' "$test_tmp/passwd" "$test_tmp/group"
  printf 'sharedpw' >"$test_tmp/disk_password"
  echo L >"$test_tmp/root_status"
  rm -f "$test_tmp/autologin.conf"
}

two_accounts
touch "$test_tmp/encrypted"
run_user remove bob --yes >/dev/null 2>&1 && fail "leaving one account needs a terminal"
has_user bob || fail "leaving one account needs a terminal, and nothing is removed without one"
pass "leaving one account needs a terminal, and nothing is removed without one"

two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes sharedpw
output=$(run_tty remove bob) || fail "back to one account re-couples disk, root and login" "$output"
! has_user bob &&
  [[ $(cat "$test_tmp/disk_password") == "alicepw" ]] &&
  grep -qx "root:alicepw" "$test_tmp/chpasswd.log" &&
  grep -qx "User=alice" "$test_tmp/autologin.conf" ||
  fail "back to one account re-couples disk, root and login" "$output; $(cat "$test_tmp/calls.log")"
[[ $output == *"your password will unlock the disk and root again"* && $output == *"Your password unlocks the disk and root again"* ]] ||
  fail "back to one account says what it will do, and what it did" "$output"
[[ $(tail -n 1 "$test_tmp/journal") == "login user 'bob' removed by alice"* ]] || fail "the account is removed, and logged, after the switch back" "$(cat "$test_tmp/journal")"
pass "back to one account re-couples disk, root and login, and logs in automatically again"

[[ $(password_prompts) == 2 ]] || fail "back to one account asks for two passwords: yours and the shared disk one" "$(cat "$test_tmp/gum.log")"
pass "back to one account asks for two passwords: yours and the shared disk one"

# The switch back comes first and every step of it can be repeated, so when it
# stops midway (here the disk password prompt is dismissed) the account is
# still there, and running the command again finishes the job.
two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes
if output=$(run_tty remove bob); then fail "a dismissed disk password prompt stops the removal" "$output"; fi
has_user bob && [[ $(cat "$test_tmp/disk_password") == "sharedpw" && $output == *"run this again to finish"* ]] ||
  fail "a stopped switch back keeps the account and says how to finish" "$output"
answers alicepw yes sharedpw
output=$(run_tty remove bob) || fail "running the removal again finishes the job" "$output"
! has_user bob && [[ $(cat "$test_tmp/disk_password") == "alicepw" ]] && grep -qx "User=alice" "$test_tmp/autologin.conf" ||
  fail "running the removal again finishes the job" "$output; $(cat "$test_tmp/calls.log")"
pass "a stopped switch back keeps the account, and running the removal again finishes it"

two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes wrongdiskpw sharedpw
output=$(run_tty remove bob) || fail "a mistyped disk password is asked again" "$output"
[[ $output == *"That doesn't unlock the disk"* && $(cat "$test_tmp/disk_password") == "alicepw" ]] ||
  fail "a mistyped disk password is asked again" "$output"
pass "a mistyped disk password is asked again"

two_accounts
touch "$test_tmp/encrypted"
printf 'alicepw' >"$test_tmp/disk_password"
answers alicepw yes
output=$(run_tty remove bob) || fail "a disk already on the administrator's password is left alone" "$output"
! grep -q "omarchy-drive-password --system-stdin" "$test_tmp/calls.log" && grep -qx "root:alicepw" "$test_tmp/chpasswd.log" ||
  fail "a disk already on the administrator's password is left alone" "$(cat "$test_tmp/calls.log")"
pass "a disk already on the administrator's password is left alone"

two_accounts
answers alicepw yes
output=$(run_tty remove bob) || fail "back to one account on an unencrypted install" "$output"
grep -qx "root:alicepw" "$test_tmp/chpasswd.log" && [[ ! -e $test_tmp/autologin.conf ]] ||
  fail "back to one account on an unencrypted install sets root but no automatic login" "$output"
pass "back to one account on an unencrypted install sets root but no automatic login"

two_accounts
touch "$test_tmp/encrypted"
answers wrongpw wrongpw
if run_tty remove bob >/dev/null; then :; fi
has_user bob || fail "nothing is removed before the administrator's password checks out"
pass "nothing is removed before the administrator's password checks out"

# Accounts that aren't administrators are told so before sudo is asked for a
# password it would refuse.
reset_fixtures
touch "$test_tmp/not_admin"
for command in "add carol --password-stdin" "remove bob --yes" "admin bob on"; do
  if output=$(RUN_AS=bob run_user $command <<<"carolpw" 2>&1); then fail "a non-administrator can't run $command"; fi
  [[ $output == *"only an administrator"* ]] || fail "a non-administrator is told who can run $command" "$output"
done
! has_user carol && has_user bob && ! grep -q "^sudo" "$test_tmp/calls.log" ||
  fail "a non-administrator changes nothing and never reaches sudo" "$(cat "$test_tmp/calls.log")"
pass "accounts that aren't administrators are told so, before sudo"

# A hand-written rule with tags, exceptions or a group still gives full sudo.
for rule in "alice ALL=(ALL) SETENV: ALL" "alice ALL=(ALL) NOPASSWD:SETENV: ALL, !/usr/bin/passwd" \
  "alice ALL=(root : root) NOPASSWD: ALL" "alice ALL=(ALL : ALL) ALL" \
  "alice ALL=(root, postgres) ALL" "alice ALL=(postgres, root : wheel) NOPASSWD: ALL"; do
  reset_fixtures
  sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
  printf '%s\n' "$rule" >"$test_tmp/sudoers.d/04_alice"
  output=$(RUN_AS=bob run_user admin alice off 2>&1) && fail "admin off misses the full sudo in '$rule'"
  [[ $output == *"another sudo rule"* ]] || fail "admin off misses the full sudo in '$rule'" "$output"
done
pass "admin off notices full sudo whatever its tags or group"

# Sudoless Docker is root without a password too.
reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
echo "docker:x:970:bob" >>"$test_tmp/group"
if output=$(run_user admin bob off 2>&1); then fail "admin off passes over the docker group"; fi
[[ $(wheel_members) == "alice" && $output == *"still in the docker group"* ]] || fail "admin off warns about the docker group" "$output; $(wheel_members)"
pass "admin off warns when the account keeps root through the docker group"

# Three tries for your own password, as sudo gives, so a wrong one can't be
# typed until the login lockout takes the account.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes wrong1 wrong2 wrong3 alicepw
if output=$(run_tty add carol); then fail "three wrong passwords stop the command"; fi
[[ $output == *"Nothing was changed"* ]] && ! has_user carol && [[ $(cat "$test_tmp/root_status") == "P" ]] ||
  fail "three wrong passwords stop the command, changing nothing" "$output"
[[ $(password_prompts) == 3 ]] || fail "your own password is asked three times at most" "$(cat "$test_tmp/gum.log")"
pass "three wrong own passwords stop the command"

# When / sits on an encryption layer whose LUKS device can't be told, nothing
# can check a password against the disk, so the switch refuses rather than
# treating the disk as unencrypted (and leaving the owner's password on it).
reset_fixtures
only_alice
touch "$test_tmp/encrypted" "$test_tmp/undecidable"
answers yes alicepw no carolpw carolpw
if output=$(run_tty add carol); then fail "an undecidable system disk stops the switch-over"; fi
[[ $output == *"Couldn't tell which drive holds the system"* ]] && ! has_user carol && [[ $(cat "$test_tmp/root_status") == "P" ]] ||
  fail "an undecidable system disk stops the switch-over before anything changes" "$output"
pass "an undecidable system disk stops the switch-over"

# The disk password is asked before the other account is signed out, so a
# switch back that stops there costs nobody their unsaved work.
two_accounts
touch "$test_tmp/encrypted"
echo bob >"$test_tmp/procs"
# A removal confirmed twice over (the sign-out too), with no disk password:
# nothing may be signed out before the switch back has that password.
answers alicepw yes yes
if output=$(run_tty remove bob); then fail "a dismissed disk password prompt stops the removal"; fi
has_user bob && grep -qx bob "$test_tmp/procs" && ! grep -q "terminate-user" "$test_tmp/calls.log" ||
  fail "nobody is signed out before the switch back has what it needs" "$output; $(cat "$test_tmp/calls.log")"
pass "the disk password is asked before anyone is signed out"

# On an unencrypted install the announcement promises only what happens.
two_accounts
answers alicepw yes
output=$(run_tty remove bob) || fail "back to one account on an unencrypted install" "$output"
[[ $output == *"root will have your password again"* && $output != *"logged in automatically"* ]] ||
  fail "an unencrypted install is told only about root" "$output"
pass "an unencrypted install is promised only what happens"

# One account change at a time: a held lock turns the commands away.
reset_fixtures
exec 8<>"$test_tmp/user.lock"
flock -x 8
for command in "add carol --password-stdin" "remove bob --yes" "admin bob on"; do
  if output=$(run_user $command <<<"carolpw" 2>&1); then fail "$command runs while another account change holds the lock"; fi
  [[ $output == *"another account change is in progress"* ]] || fail "$command says another change is in progress" "$output"
done
exec 8<&-
! has_user carol && has_user bob && ! grep -q "useradd\|userdel\|gpasswd" "$test_tmp/calls.log" ||
  fail "a held lock stops every change" "$(cat "$test_tmp/calls.log")"
pass "one account change at a time"

# A kept home folder keeps its owner's UID, so a later account never gets
# that UID (and with it the files).
reset_fixtures
output=$(run_user remove bob --yes 2>&1) || fail "remove keeps the home folder" "$output"
[[ -d $test_tmp/home/bob ]] || fail "remove keeps the home folder"
output=$(run_user add carol --password-stdin <<<"carolpw" 2>&1) || fail "add after a kept home" "$output"
[[ $(grep "^carol:" "$test_tmp/passwd" | cut -d: -f3) == "1003" ]] ||
  fail "a new account never gets the UID of a kept home folder" "$(cat "$test_tmp/passwd")"
grep -q "useradd .*-u 1003 " "$test_tmp/calls.log" || fail "the UID is chosen by omarchy user add" "$(cat "$test_tmp/calls.log")"
pass "a new account never gets the UID of a kept home folder"

# Passwordless-sudo grants name the account by UID and would pass on with it.
for command in "remove bob --delete-home --yes" "admin bob off"; do
  reset_fixtures
  sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
  echo "bob ALL=(ALL) NOPASSWD: ALL" >"$test_tmp/sudoers.d/99-omarchy-nopasswd-1001"
  echo "bob ALL=(ALL) NOPASSWD: ALL" >"$test_tmp/sudoers.d/99-omarchy-permanent-nopasswd-1001"
  echo "carl ALL=(ALL) NOPASSWD: ALL" >"$test_tmp/sudoers.d/99-omarchy-nopasswd-1004"
  output=$(run_user $command 2>&1) || fail "$command with passwordless grants" "$output"
  [[ ! -e $test_tmp/sudoers.d/99-omarchy-nopasswd-1001 && ! -e $test_tmp/sudoers.d/99-omarchy-permanent-nopasswd-1001 ]] ||
    fail "$command drops bob's passwordless sudo grants" "$(ls "$test_tmp/sudoers.d")"
  [[ -e $test_tmp/sudoers.d/99-omarchy-nopasswd-1004 ]] || fail "$command leaves other accounts' grants alone"
  grep -q "passwordless sudo grant of 'bob'" "$test_tmp/journal" || fail "$command logs the dropped grant" "$(cat "$test_tmp/journal")"
done
pass "removal and demotion drop the account's passwordless sudo grants"

# The grants go before the account, or its wheel membership, does: a removal or
# demotion that stops leaves none behind.
for command in "remove bob --delete-home --yes:userdel" "admin bob off:gpasswd -d bob wheel"; do
  reset_fixtures
  sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
  echo "bob ALL=(ALL) NOPASSWD: ALL" >"$test_tmp/sudoers.d/99-omarchy-nopasswd-1001"
  output=$(run_user ${command%%:*} 2>&1) || fail "${command%%:*} with a passwordless grant" "$output"
  grant_line=$(grep -n "rm -fv -- .*99-omarchy-nopasswd-1001" "$test_tmp/calls.log" | head -1 | cut -d: -f1)
  change_line=$(grep -n "${command#*:}" "$test_tmp/calls.log" | head -1 | cut -d: -f1)
  [[ -n $grant_line && -n $change_line ]] && (( grant_line < change_line )) ||
    fail "${command%%:*} drops the grants before the account changes" "$(cat "$test_tmp/calls.log")"
done
pass "the grants go before the account, or its administrator rights, do"

# userdel can remove the account and then fail on its home folder: the grants
# are already gone, and the command says what is left to do.
reset_fixtures
echo "bob ALL=(ALL) NOPASSWD: ALL" >"$test_tmp/sudoers.d/99-omarchy-nopasswd-1001"
echo "bob ALL=(ALL) ALL" >"$test_tmp/sudoers.d/05_bob"
if output=$(OMARCHY_TEST_USERDEL_HOME_FAIL=1 run_user remove bob --delete-home --yes 2>&1); then fail "a home folder userdel couldn't delete fails the command"; fi
! has_user bob && [[ ! -e $test_tmp/sudoers.d/99-omarchy-nopasswd-1001 && ! -e $test_tmp/sudoers.d/05_bob && $output == *"removed 'bob', but couldn't delete"* ]] ||
  fail "a home folder userdel couldn't delete leaves no grant, and says what's left" "$output; $(ls "$test_tmp/sudoers.d")"
pass "a home folder userdel couldn't delete leaves no grant behind"

# A grant cleanup that fails stops the command before the account, or its
# administrator rights, change.
reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
echo "bob ALL=(ALL) ALL" >"$test_tmp/sudoers.d/05_bob"
for command in "remove bob --yes" "admin bob off"; do
  if output=$(OMARCHY_TEST_FIND_FAIL=1 run_user $command 2>&1); then fail "$command goes on when the grants can't be read"; fi
  has_user bob && [[ $(wheel_members) == "alice,bob" && -e $test_tmp/sudoers.d/05_bob && $output == *"couldn't remove the sudo grants naming 'bob'"* ]] ||
    fail "$command stops before anything changes when the grants can't be read" "$output; $(wheel_members)"
done
pass "a grant cleanup that fails stops the removal and the demotion"

# Every question is answered before anything changes: declining to sign the
# other account out leaves the machine as it was, still multi-user.
two_accounts
touch "$test_tmp/encrypted"
echo bob >"$test_tmp/procs"
answers alicepw yes no
if output=$(run_tty remove bob); then fail "declining the sign-out stops the removal"; fi
has_user bob && [[ $(cat "$test_tmp/root_status") == "L" && ! -e $test_tmp/autologin.conf && $(cat "$test_tmp/disk_password") == "sharedpw" ]] &&
  ! grep -q "terminate-user\|userdel" "$test_tmp/calls.log" ||
  fail "declining the sign-out changes nothing" "$output; $(cat "$test_tmp/calls.log")"
pass "declining the sign-out leaves the machine multi-user"

# The switch comes first and the account second: a stop leaves one account
# with more protection, never a second account with less, and the next run
# continues. A creation that fails after the switch says so.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if output=$(OMARCHY_TEST_USERADD_FAIL=1 run_tty add carol); then fail "a failed useradd fails the command"; fi
! has_user carol && [[ $(cat "$test_tmp/root_status") == "L" && ! -e $test_tmp/autologin.conf && $(cat "$test_tmp/disk_password") == "sharedpw" ]] &&
  [[ $output == *"now set up for several accounts, so run this again"* ]] ||
  fail "a creation that fails after the switch leaves the protections and says what to do" "$output; $(cat "$test_tmp/calls.log")"
: >"$test_tmp/calls.log"
answers yes alicepw no carolpw carolpw
output=$(run_tty add carol) || fail "running the add again after a failed creation" "$output"
has_user carol && ! grep -q "omarchy-drive-password --system-stdin\|passwd -l" "$test_tmp/calls.log" || fail "the next run adds the account without switching again" "$output; $(cat "$test_tmp/calls.log")"
pass "a creation that fails after the switch keeps the protections, and the next run finishes"
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if output=$(OMARCHY_TEST_DRIVE_NOOP=1 run_tty add carol); then fail "a stopped switch fails the command"; fi
! has_user carol && ! grep -q "useradd" "$test_tmp/calls.log" && [[ $output == *"run this again to continue"* ]] ||
  fail "a stopped switch adds no account" "$output; $(cat "$test_tmp/calls.log")"
pass "a stopped switch adds no account, and says to run again"

# A disk password change stopped part way earlier (a killed terminal, a power
# cut) must be finished by a person before the disk takes another; the add
# says so instead of promising that running it again continues.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if output=$(OMARCHY_TEST_DRIVE_PENDING=1 run_tty add carol); then fail "an unfinished disk password change stops the add"; fi
! has_user carol && [[ $output == *"stopped part way"* && $output == *"once it's finished with omarchy-drive-password, run this again"* && $output != *"run this again to continue"* ]] ||
  fail "an unfinished disk password change tells the administrator to finish it first" "$output"
pass "an unfinished disk password change is pointed at omarchy-drive-password"
two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes sharedpw
if output=$(OMARCHY_TEST_DRIVE_PENDING=1 run_tty remove bob); then fail "an unfinished disk password change stops the removal"; fi
has_user bob && [[ $output == *"once it's finished with omarchy-drive-password, run this again"* && $output != *"run this again to finish"* ]] ||
  fail "an unfinished disk password change stops the removal and points at omarchy-drive-password" "$output"
pass "the removal points at omarchy-drive-password too"

# A change that stopped between enrolling the new key and retiring the old one
# leaves both opening the disk, so the remaining administrator's password
# already works. The old shared password would boot into their desktop once
# automatic login is back, so with a second key on the disk it stays off, and
# the command says why. Everything else goes back to one account.
two_accounts
touch "$test_tmp/encrypted"
printf 'alicepw' >"$test_tmp/disk_password"
echo 2 >"$test_tmp/disk_keys"
answers alicepw yes
output=$(run_tty remove bob) || fail "a second key on the disk doesn't stop the removal" "$output"
! has_user bob && [[ ! -e $test_tmp/autologin.conf && $output == *"The disk also opens with another key, so you won't be logged in automatically"* ]] &&
  grep -qx "root:alicepw" "$test_tmp/chpasswd.log" ||
  fail "a second key on the disk keeps automatic login off, and says why" "$output"
pass "a second key on the disk keeps automatic login off, and says why"

# A change of yours that stopped part way is finished first, even where the
# switch would have no new disk password change of its own to make.
two_accounts
touch "$test_tmp/encrypted"
printf 'alicepw' >"$test_tmp/disk_password"
mkdir -p "$test_tmp/state/omarchy"
echo "phase=record" >"$test_tmp/state/omarchy/drive-password.state"
answers alicepw yes
if output=$(run_tty remove bob); then fail "your unfinished change stops the removal"; fi
has_user bob && [[ ! -e $test_tmp/autologin.conf && $output == *"once it's finished with omarchy-drive-password, run this again"* ]] ||
  fail "your unfinished change stops the removal before anything changes" "$output"
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
printf 'otherpw' >"$test_tmp/disk_password"
mkdir -p "$test_tmp/state/omarchy"
echo "phase=record" >"$test_tmp/state/omarchy/drive-password.state"
answers yes alicepw no carolpw carolpw
if output=$(run_tty add carol); then fail "your unfinished change stops the add"; fi
! has_user carol && [[ $output == *"once it's finished with omarchy-drive-password, run this again"* ]] || fail "your unfinished change stops the add" "$output"
pass "a disk password change of yours that stopped part way is finished first"

# A home that holds the note of an unfinished disk password change isn't
# deleted: finishing that change needs it, also when the administrator who
# started it was demoted since.
reset_fixtures
sed -i 's/^wheel:x:998:alice$/wheel:x:998:alice,bob/' "$test_tmp/group"
mkdir -p "$test_tmp/home/bob/.local/state/omarchy"
echo "phase=record" >"$test_tmp/home/bob/.local/state/omarchy/drive-password.state"
if output=$(run_user remove bob --delete-home --yes 2>&1); then fail "removal deletes a home holding an unfinished change's note"; fi
has_user bob && [[ -e $test_tmp/home/bob/.local/state/omarchy/drive-password.state && $output == *"unfinished disk password change"* ]] ||
  fail "removal keeps a home holding an unfinished change's note, and says why" "$output"
output=$(run_user remove bob --yes 2>&1) || fail "removal without --delete-home goes on" "$output"
! has_user bob && [[ -e $test_tmp/home/bob/.local/state/omarchy/drive-password.state ]] || fail "removal without --delete-home keeps the note" "$output"
reset_fixtures
mkdir -p "$test_tmp/home/bob/.local/state/omarchy"
echo "phase=record" >"$test_tmp/home/bob/.local/state/omarchy/drive-password.state"
if output=$(run_user remove bob --delete-home --yes 2>&1); then fail "removal deletes a demoted administrator's home holding the note"; fi
has_user bob && [[ -e $test_tmp/home/bob ]] || fail "removal keeps a demoted administrator's home holding the note" "$output"
pass "a home holding an unfinished disk password change isn't deleted"

# Every question comes before anything changes, the wheel rule for --admin too.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw carolpw carolpw
if output=$(run_tty add carol --admin); then fail "leaving the disk password question cancels the add"; fi
! has_user carol && [[ ! -e $test_tmp/sudoers.d/00-omarchy-wheel ]] ||
  fail "cancelling the switch's questions writes no wheel rule" "$output; $(ls "$test_tmp/sudoers.d")"
pass "the wheel rule for --admin waits until the switch's questions are answered"

# Everyone who starts the computer knows the disk password, so no account may
# be given it: not on its own, and not as the shared one chosen in the switch.
reset_fixtures
touch "$test_tmp/encrypted"
if output=$(printf 'alicepw\n' | run_user add dave --password-stdin 2>&1); then fail "add takes the disk password for an account"; fi
! has_user dave && [[ $output == *"unlocks the disk"* ]] || fail "add refuses the disk password for an account" "$output"
answers no alicepw alicepw davepw davepw
output=$(run_tty add dave) || fail "add asks again after the disk password" "$output"
has_user dave && [[ $output == *"That one unlocks the disk"* ]] && grep -qx "dave:davepw" "$test_tmp/chpasswd.log" ||
  fail "add asks again after the disk password, and takes the next one" "$output; $(cat "$test_tmp/chpasswd.log")"
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" carolpw carolpw sharedpw sharedpw
output=$(run_tty add carol) || fail "the switch asks again after the new account's password" "$output"
has_user carol && [[ $output == *"That's the new account's password"* && $(cat "$test_tmp/disk_password") == "sharedpw" ]] ||
  fail "the shared disk password can't be the new account's" "$output"
# Where the system disk can't be told, no password can be checked against it.
reset_fixtures
touch "$test_tmp/encrypted" "$test_tmp/undecidable"
if output=$(printf 'davepw\n' | run_user add dave --password-stdin 2>&1); then fail "add goes on when the system disk can't be told"; fi
! has_user dave && [[ $output == *"Couldn't tell which drive holds the system"* ]] || fail "add refuses when the system disk can't be told" "$output"
pass "no account is given the disk password"

# cryptsetup reports a wrong passphrase as status 2. Any other failure is no
# answer, so the switches stop rather than read it as one: as "doesn't open",
# the add would skip the split and have the administrator share their own
# password.
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
if output=$(OMARCHY_TEST_CRYPTSETUP_ERROR_AT=1 run_tty add carol); then fail "a cryptsetup error stops the add"; fi
! has_user carol && [[ $(cat "$test_tmp/disk_password") == "alicepw" && $output == *"Couldn't check a password"* && $output != *"Give carol"* ]] &&
  ! grep -q "passwd -l" "$test_tmp/calls.log" ||
  fail "a cryptsetup error stops the add before anything changes" "$output; $(cat "$test_tmp/calls.log")"
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new password for me" newalicepw newalicepw newalicepw newalicepw
if output=$(OMARCHY_TEST_CRYPTSETUP_ERROR_AT=3 run_tty add carol); then fail "a cryptsetup error while checking a new password stops the add"; fi
! has_user carol && [[ $output == *"Couldn't check a password"* ]] && ! grep -q "chpasswd" "$test_tmp/calls.log" &&
  [[ $(grep -c "input --password" "$test_tmp/gum.log") == 5 ]] ||
  fail "a cryptsetup error while checking a new password stops the add without asking again" "$output; $(cat "$test_tmp/calls.log")"
pass "a cryptsetup error stops the add, rather than counting as a wrong password"

two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes sharedpw
if output=$(OMARCHY_TEST_CRYPTSETUP_ERROR_AT=1 run_tty remove bob); then fail "a cryptsetup error stops the removal"; fi
has_user bob && [[ ! -e $test_tmp/autologin.conf && $output == *"Couldn't check a password"* ]] &&
  ! grep -q "chpasswd\|omarchy-drive-password --system-stdin" "$test_tmp/calls.log" ||
  fail "a cryptsetup error stops the removal before anything changes" "$output; $(cat "$test_tmp/calls.log")"
two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes sharedpw sharedpw
if output=$(OMARCHY_TEST_CRYPTSETUP_ERROR_AT=2 run_tty remove bob); then fail "a cryptsetup error checking the current disk password stops the removal"; fi
has_user bob && [[ $output == *"Couldn't check a password"* && $output != *"Try again"* ]] && ! grep -q "omarchy-drive-password --system-stdin" "$test_tmp/calls.log" ||
  fail "a cryptsetup error checking the current disk password stops the removal without asking again" "$output; $(cat "$test_tmp/calls.log")"
pass "a cryptsetup error stops the removal, rather than counting as a wrong password"

# An empty answer is a wrong password, asked again, not an error.
two_accounts
touch "$test_tmp/encrypted"
answers alicepw yes "" sharedpw
output=$(run_tty remove bob) || fail "an empty disk password is asked again" "$output"
! has_user bob && [[ $output == *"That doesn't unlock the disk. Try again."* ]] || fail "an empty disk password is asked again" "$output"
pass "an empty disk password is asked again"

# Passwords live in variables, so neither command traces under bash -x.
run_traced() {
  local cmd
  printf -v cmd '%q ' bash -x "$ROOT/bin/omarchy-user-$1" "${@:2}"
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_LANGUAGE_FILE=/nonexistent OMARCHY_TEST_DIR="$test_tmp" \
    SUDO_USER=alice OMARCHY_LOGIN_DEFS=/dev/null OMARCHY_SUDOERS_DIR="$test_tmp/sudoers.d" \
    OMARCHY_SDDM_AUTOLOGIN="$test_tmp/autologin.conf" OMARCHY_USER_LOCK="$test_tmp/user.lock" OMARCHY_HOME_ROOT="$test_tmp/home" XDG_STATE_HOME="$test_tmp/state" \
    script -qefc "$cmd" /dev/null </dev/null 2>&1 | tr -d '\r'
}
reset_fixtures
only_alice
touch "$test_tmp/encrypted"
answers yes alicepw no carolpw carolpw "A new disk password, to share" sharedpw sharedpw
output=$(run_traced add carol) || true
has_user carol && [[ $output != *alicepw* && $output != *carolpw* && $output != *sharedpw* ]] ||
  fail "omarchy user add traces no password" "$output"
answers alicepw yes sharedpw
output=$(run_traced remove carol) || true
! has_user carol && [[ $output != *alicepw* && $output != *sharedpw* ]] ||
  fail "omarchy user remove traces no password" "$output"
pass "neither command traces a password under bash -x"

# The lock file is root's alone, so only an administrator can hold the lock.
reset_fixtures
rm -f "$test_tmp/user.lock"
output=$(run_user add carol --password-stdin <<<"carolpw" 2>&1) || fail "add creates the lock file" "$output"
[[ $(/usr/bin/stat -c '%a' "$test_tmp/user.lock") == "600" ]] || fail "the lock file is readable by nobody else" "$(ls -l "$test_tmp/user.lock")"
pass "the lock file is root's alone"
