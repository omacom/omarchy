#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-user-functions against a fake system: passwd, group and shadow files
# the account tools edit, and a cryptsetup whose key slots are a table of
# passwords. The owner, dhh, starts with slot 0 and root's password, as an
# encrypted install leaves them.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP=$tmp
mkdir -p "$tmp/bin"

fake() {
  cat >"$tmp/bin/$1"
  chmod +x "$tmp/bin/$1"
}

fake getent <<'SH'
#!/bin/bash
file=$TEST_TMP/$1
if [[ -n ${2:-} ]]; then
  awk -F: -v key="$2" '$1 == key || ($3 == key && key ~ /^[0-9]+$/) { print; found = 1; exit } END { exit !found }' "$file"
else
  cat "$file"
fi
SH

fake id <<'SH'
#!/bin/bash
flag=$1
[[ ${2:-} == "--" ]] && shift
who=$2
entry=$(awk -F: -v key="$who" '$1 == key || $3 == key { print; exit }' "$TEST_TMP/passwd")
[[ -n $entry ]] || exit 1
IFS=: read -r name _ uid _ <<<"$entry"
case $flag in
  -u) echo "$uid" ;;
  -un) echo "$name" ;;
  -nG) { echo "$name"; awk -F: -v user="$name" '{ n = split($4, m, ","); for (i = 1; i <= n; i++) if (m[i] == user) print $1 }' "$TEST_TMP/group"; } | paste -sd' ' - ;;
esac
SH

fake useradd <<'SH'
#!/bin/bash
[[ -n ${TEST_FAIL_USERADD:-} ]] && exit 1
while (( $# > 1 )); do
  case $1 in
    -G) groups=$2; shift 2 ;;
    -s) shell=$2; shift 2 ;;
    *) shift ;;
  esac
done
name=$1
uid=$(awk -F: 'BEGIN { max = 999 } $3 >= 1000 && $3 < 60000 && $3 > max { max = $3 } END { print max + 1 }' "$TEST_TMP/passwd")
echo "$name:x:$uid:$uid::/home/$name:$shell" >>"$TEST_TMP/passwd"
echo "$name:!:20000::::::" >>"$TEST_TMP/shadow"
for group in ${groups//,/ }; do
  awk -F: -v OFS=: -v g="$group" -v u="$name" '$1 == g { $4 = ($4 == "" ? u : $4 "," u) } { print }' "$TEST_TMP/group" >"$TEST_TMP/group.new"
  mv "$TEST_TMP/group.new" "$TEST_TMP/group"
done
SH

fake userdel <<'SH'
#!/bin/bash
name=${!#}
grep -q "^$name:" "$TEST_TMP/passwd" || exit 6
for file in passwd shadow; do
  grep -v "^$name:" "$TEST_TMP/$file" >"$TEST_TMP/$file.new" || true
  mv "$TEST_TMP/$file.new" "$TEST_TMP/$file"
done
awk -F: -v OFS=: -v u="$name" '{ n = split($4, m, ","); out = ""; for (i = 1; i <= n; i++) if (m[i] != u) out = (out == "" ? m[i] : out "," m[i]); $4 = out; print }' "$TEST_TMP/group" >"$TEST_TMP/group.new"
mv "$TEST_TMP/group.new" "$TEST_TMP/group"
[[ $1 == "-r" ]] && echo "$name" >>"$TEST_TMP/homes-removed"
true
SH

fake groupadd <<'SH'
#!/bin/bash
echo "${!#}:x:900:" >>"$TEST_TMP/group"
SH

fake chpasswd <<'SH'
#!/bin/bash
[[ -n ${TEST_FAIL_CHPASSWD:-} ]] && exit 1
while IFS= read -r line; do
  user=${line%%:*}
  password=${line#*:}
  hash=$(printf '%s' "$password" | perl -e 'local $/; my $p = <STDIN>; my @c = ("a".."z"); my $s = join "", map { $c[rand @c] } 1..8; print crypt($p, "\$6\$$s\$")')
  awk -F: -v OFS=: -v u="$user" -v h="$hash" '$1 == u { $2 = h } { print }' "$TEST_TMP/shadow" >"$TEST_TMP/shadow.new"
  mv "$TEST_TMP/shadow.new" "$TEST_TMP/shadow"
done
SH

fake usermod <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/usermod"
SH

fake pkill <<'SH'
#!/bin/bash
exit 1
SH

fake loginctl <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/loginctl"
SH

fake findmnt <<'SH'
#!/bin/bash
cat "$TEST_TMP/root-source"
SH

fake lsblk <<'SH'
#!/bin/bash
cat "$TEST_TMP/root-ancestry"
SH

# x86 resolves luks-slots to nothing; a platform that records slots prints
# its recorder.
fake omarchy-lifecycle-dispatch <<'SH'
#!/bin/bash
[[ -n ${TEST_SLOT_RECORDER:-} ]] && echo "$TEST_SLOT_RECORDER"
exit 0
SH

# Key slots are lines of "<slot><TAB><password>".
fake cryptsetup <<'SH'
#!/bin/bash
slots=$TEST_TMP/slots
slot_for() {
  awk -F'\t' -v p="$1" '$2 == p { print $1; exit }' "$slots"
}
case $1 in
  luksUUID) echo "uuid-root" ;;
  isLuks) exit 0 ;;
  luksDump)
    [[ -n ${TEST_FAIL_DUMP:-} ]] && exit 1
    echo "Keyslots:"
    cut -f1 "$slots" | sort -n | sed 's/.*/  &: luks2/'
    echo "Tokens:"
    ;;
  open)
    password=$(cat)
    only=""
    args=("$@")
    for (( i = 0; i < ${#args[@]}; i++ )); do
      [[ ${args[i]} == "--key-slot" ]] && only=${args[i+1]}
    done
    if [[ -n $only ]]; then
      [[ $(awk -F'\t' -v s="$only" '$1 == s { print $2 }' "$slots") == "$password" ]] || exit 2
      exit 0
    fi
    slot=$(slot_for "$password")
    [[ -n $slot ]] || { echo "No key available with this passphrase."; exit 2; }
    echo "Key slot $slot unlocked."
    ;;
  luksAddKey)
    [[ -n ${TEST_FAIL_ADDKEY:-} ]] && exit 1
    args=("$@")
    for (( i = 0; i < ${#args[@]}; i++ )); do
      [[ ${args[i]} == "--key-file" ]] && current=$(cat "${args[i+1]}")
      [[ ${args[i]} == "--key-slot" ]] && slot=${args[i+1]}
    done
    new=$(cat "${args[-1]}")
    [[ -n $(slot_for "$current") ]] || exit 2
    [[ -n $slot ]] || exit 98
    ! cut -f1 "$slots" | grep -qx "$slot" || exit 1
    printf '%s\t%s\n' "$slot" "$new" >>"$slots"
    [[ -n ${TEST_CRASH_AFTER_ADDKEY:-} ]] && exit 1
    true
    ;;
  luksKillSlot)
    slot=${!#}
    awk -F'\t' -v s="$slot" '$1 != s' "$slots" >"$slots.new"
    mv "$slots.new" "$slots"
    ;;
  *) exit 99 ;;
esac
SH

fake fake-web-apply <<'SH'
#!/bin/bash
echo applied >>"$TEST_TMP/web-applied"
SH

fake fake-screen-time <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/screen-time"
SH

fake fake-rebuild <<'SH'
#!/bin/bash
echo rebuilt >>"$TEST_TMP/rebuilt"
SH

fake omarchy-user-apps-apply <<'SH'
#!/bin/bash
echo $(( $(cat "$TEST_TMP/apps-applied" 2>/dev/null || echo 0) + 1 )) >"$TEST_TMP/apps-applied"
SH

export PATH="$tmp/bin:$PATH"

reset_system() {
  rm -rf "$tmp/etc" "$tmp/var" "$tmp/run/rate"
  rm -f "$tmp/homes-removed" "$tmp/loginctl" "$tmp/usermod" "$tmp/apps-applied" "$tmp/rebuilt" "$tmp/screen-time"
  printf 'root:x:0:0::/root:/bin/bash\nnobody:x:65534:65534::/:/usr/bin/nologin\ndhh:x:1000:1000::/home/dhh:/bin/bash\n' >"$tmp/passwd"
  printf 'root:x:0:\nwheel:x:998:dhh\ndhh:x:1000:\n' >"$tmp/group"
  printf 'root:!:20000::::::\nnobody:!:20000::::::\ndhh:!:20000::::::\n' >"$tmp/shadow"
  printf '0\townerpw\n' >"$tmp/slots"
  if [[ ${1:-encrypted} == "encrypted" ]]; then
    echo '/dev/mapper/root[/@]' >"$tmp/root-source"
    printf '/dev/mapper/root crypt btrfs\n/dev/nvme0n1p2 part crypto_LUKS\n' >"$tmp/root-ancestry"
  else
    echo '/dev/nvme0n1p2' >"$tmp/root-source"
    printf '/dev/nvme0n1p2 part btrfs\n' >"$tmp/root-ancestry"
  fi
  printf 'dhh:ownerpw\n' | chpasswd
  printf 'root:ownerpw\n' | chpasswd
}

# Each call runs the library fresh in a subshell, as each helper run does.
users() {
  (
    umask 077   # as the helper runs
    export USERS_DIR=$tmp/etc/omarchy/users USERS_JOURNAL=$tmp/var/journal USERS_LOCK=$tmp/run/lock
    export USERS_SHADOW=$tmp/shadow USERS_SUDOERS_DIR=$tmp/etc/sudoers.d USERS_LIFECYCLE_DISPATCH=omarchy-lifecycle-dispatch USERS_REFUSAL_DELAY=0 USERS_SDDM_CONF=$tmp/etc/sddm.conf USERS_BLOCKED_DIR=$tmp/etc/omarchy/blocked-apps USERS_BLOCKED_DEFAULT=$ROOT/default/omarchy/child-blocked-apps USERS_APPS_APPLY=omarchy-user-apps-apply USERS_REBUILD_BOOT=fake-rebuild USERS_SCREEN_TIME_ADMIN=fake-screen-time USERS_WEB_DIR=$tmp/etc/omarchy/web-allowlist USERS_WEB_APPLY=fake-web-apply USERS_THEME_SETTINGS=$tmp/etc/omarchy/theme-collections USERS_THEME_COLLECTIONS=$ROOT/default/omarchy/theme-collections USERS_RATE_DIR=$tmp/run/rate
    mkdir -p "$USERS_SUDOERS_DIR"
    source "$ROOT/bin/omarchy-user-functions"
    users_load_drive
    "$@"
  )
}

opens() {
  [[ $(awk -F'\t' -v p="$1" '$2 == p { print $1; exit }' "$tmp/slots") == "$2" ]]
}

login_is() {
  users users_password_matches "$2" "$1"
}

map_line() {
  awk -v u="$1" '$4 == u { print $1, $2, $3, $4 }' "$tmp/etc/omarchy/users/slots"
}

reset_system
users users_add dhh child emma kidpass ownerpw 2>"$tmp/err" || fail "an adult adds a child" "$(cat "$tmp/err")"
[[ $(grep '^omarchy-child:' "$tmp/group" | cut -d: -f4) == "emma" ]] || fail "the child is in omarchy-child" "$(cat "$tmp/group")"
[[ $(grep '^wheel:' "$tmp/group" | cut -d: -f4) == "dhh" ]] || fail "the child is not in wheel"
login_is emma kidpass || fail "the child's login password is set"
opens kidpass 1 || fail "the child's password opens its own slot" "$(cat "$tmp/slots")"
[[ $(map_line dhh) == "uuid-root 0 1000 dhh" && $(map_line emma) == "uuid-root 1 1001 emma" ]] || fail "the map records the owner's and the child's slots" "$(cat "$tmp/etc/omarchy/users/slots")"
[[ $(cat "$tmp/etc/omarchy/users/root") == "dhh" ]] || fail "root's holder is the owner whose password root has"
[[ $(cat "$tmp/etc/sudoers.d/00-omarchy-wheel") == "%wheel ALL=(ALL:ALL) ALL" ]] || fail "the wheel grant is written for later adults"
[[ ! -e $tmp/var/journal ]] || fail "a finished add leaves no journal"
users users_map_valid || fail "the map is valid after an add"
[[ $(users users_list) == $'dhh adult yes\nemma child yes' ]] || fail "list names each account, its role and whether it is in sync" "$(users users_list)"
[[ $(cat "$tmp/etc/omarchy/blocked-apps/emma") == "$(grep -v '^#' "$ROOT/default/omarchy/child-blocked-apps" | sort -u)" ]] || fail "a new child starts with the shipped blocked apps" "$(cat "$tmp/etc/omarchy/blocked-apps/emma")"
[[ $(stat -c %a "$tmp/etc/omarchy/blocked-apps/emma") == "644" ]] || fail "the child's session can read their blocked list"
[[ $(cat "$tmp/apps-applied") == "1" ]] || fail "the blocked list is enforced once written"
[[ $(stat -c %a "$tmp/etc/omarchy") == "755" && $(stat -c %a "$tmp/etc/omarchy/blocked-apps") == "755" ]] || fail "the settings a session reads sit under directories it can reach" "$(stat -c '%a %n' "$tmp/etc/omarchy" "$tmp/etc/omarchy/blocked-apps")"
[[ $(stat -c %a "$tmp/etc/omarchy/users") == "700" ]] || fail "the slot map's directory stays root's alone"
pass "an adult adds a child: own account, own slot, mapped, not in wheel, starting with the shipped blocked apps"

expect_refused() {
  local description=$1 message=$2
  shift 2
  if users "$@" 2>"$tmp/err"; then
    fail "$description"
  fi
  grep -qF "$message" "$tmp/err" || fail "$description: says why" "$(cat "$tmp/err")"
}

expect_refused "a five-character password is refused" "at least 6 characters" users_add dhh child five five5 ownerpw
expect_refused "another account's password is refused" "already unlocks this computer" users_add dhh child five ownerpw ownerpw
printf '7\tleftover1\n' >>"$tmp/slots"
expect_refused "a password still opening an old slot is refused" "already unlocks this computer" users_add dhh child five leftover1 ownerpw
awk -F'\t' '$1 != 7' "$tmp/slots" >"$tmp/slots.new" && mv "$tmp/slots.new" "$tmp/slots"
expect_refused "a child can't add a user" "Only a grown-up" users_add emma child five fivepass kidpass
expect_refused "a wrong caller password is refused" "isn't the password that unlocks this computer for dhh" users_add dhh child five fivepass wrongpw
expect_refused "an existing name is refused" "already a user or group named emma" users_add dhh child emma fivepass ownerpw
expect_refused "a name with capitals is refused" "lowercase" users_add dhh child Emma fivepass ownerpw
! getent passwd five >/dev/null || fail "no refused add leaves an account"
[[ $(wc -l <"$tmp/slots") == 2 ]] || fail "no refused add leaves a slot" "$(cat "$tmp/slots")"
pass "passwords must be six characters and nobody else's, on the disk as well as in shadow; only adults add"

TEST_SLOT_RECORDER=/usr/lib/omarchy-mac/luks-slots expect_refused "a platform that records slots refuses a second person's slot" "boot checks" users_add dhh child five fivepass ownerpw
pass "a platform whose boot checks record key slots refuses another person's slot"

users users_password emma emma newkid1 kidpass 2>"$tmp/err" || fail "a child changes their own password" "$(cat "$tmp/err")"
login_is emma newkid1 || fail "the child's login password changed"
! opens kidpass 1 || fail "the old child password no longer opens the disk" "$(cat "$tmp/slots")"
[[ -n $(awk -F'\t' '$2 == "newkid1"' "$tmp/slots") ]] || fail "the new child password opens a slot"
[[ $(map_line emma | cut -d' ' -f2) == "$(awk -F'\t' '$2 == "newkid1" { print $1 }' "$tmp/slots")" ]] || fail "the map follows the child's new slot"
login_is root ownerpw || fail "a child's change leaves root alone"
expect_refused "a child can't change someone else's password" "Only a grown-up" users_password emma dhh hijacked newkid1
expect_refused "the current password is refused as the new one" "already emma's password" users_password emma emma newkid1 newkid1
pass "a child changes their own password: login, slot and map together, and nobody else's"

users users_password dhh emma reset123 ownerpw 2>"$tmp/err" || fail "an adult resets a child's password" "$(cat "$tmp/err")"
login_is emma reset123 || fail "the reset sets the child's login"
[[ -z $(awk -F'\t' '$2 == "newkid1"' "$tmp/slots") ]] || fail "the reset retires the forgotten password's slot"
users users_in_sync emma || fail "the reset child is in sync"
pass "an adult resets a child's forgotten password with their own"

users users_password dhh dhh owner-new ownerpw 2>"$tmp/err" || fail "the owner changes their own password" "$(cat "$tmp/err")"
login_is root owner-new || fail "root's password follows its holder"
opens owner-new 0 || [[ -n $(awk -F'\t' '$2 == "owner-new"' "$tmp/slots") ]] || fail "the owner's new password opens the disk"
[[ -z $(awk -F'\t' '$2 == "ownerpw"' "$tmp/slots") ]] || fail "the owner's old password no longer opens the disk"
pass "root's password follows the owner whose password it was"

expect_refused "you can't delete yourself" "signed in as" users_delete dhh dhh owner-new no
expect_refused "a child can't delete" "Only a grown-up" users_delete emma dhh reset123 no
users users_add dhh adult bob bobpass1 owner-new 2>"$tmp/err" || fail "an adult adds an adult" "$(cat "$tmp/err")"
[[ $(grep '^wheel:' "$tmp/group" | cut -d: -f4) == "dhh,bob" ]] || fail "an added adult is in wheel"
users users_delete bob dhh bobpass1 no 2>"$tmp/err" || fail "another adult deletes root's holder" "$(cat "$tmp/err")"
login_is root bobpass1 || fail "deleting root's holder hands root to the adult who deleted them"
[[ $(cat "$tmp/etc/omarchy/users/root") == "bob" ]] || fail "the holder file names the new holder"
[[ -z $(awk -F'\t' '$2 == "owner-new"' "$tmp/slots") ]] || fail "the deleted adult's slot is gone"
! getent passwd dhh >/dev/null || fail "the deleted account is gone"
[[ ! -e $tmp/homes-removed ]] || fail "the home is kept unless asked"
grep -qx 'terminate-user dhh' "$tmp/loginctl" || fail "the deleted user's sessions are ended"
[[ -z $(map_line dhh) ]] || fail "the deleted user leaves the map"
users users_map_valid || fail "the map is valid after a delete"
expect_refused "a child can't delete the last adult" "Only a grown-up" users_delete emma bob reset123 no
pass "deletion: never yourself, never the last adult, and root never keeps a deleted person's password"

echo 'emma ALL=(ALL) NOPASSWD: ALL' >"$tmp/etc/sudoers.d/99-omarchy-permanent-nopasswd-1001"
users users_delete bob emma bobpass1 yes 2>"$tmp/err" || fail "an adult deletes a child" "$(cat "$tmp/err")"
[[ ! -e $tmp/etc/sudoers.d/99-omarchy-permanent-nopasswd-1001 ]] || fail "a deleted user's passwordless grant goes with them"
grep -qx emma "$tmp/homes-removed" || fail "the home is removed when asked"
[[ $(wc -l <"$tmp/slots") == 1 ]] || fail "only the remaining adult's slot is left" "$(cat "$tmp/slots")"
pass "deleting a user removes their slot, map entry, passwordless grant and, when asked, their home"

reset_system
TEST_FAIL_CHPASSWD=1 users users_add dhh child emma kidpass ownerpw 2>/dev/null && fail "an add whose password can't be set fails"
! getent passwd emma >/dev/null || fail "a failed add removes the half-made account"
[[ $(wc -l <"$tmp/slots") == 1 ]] || fail "a failed add removes the slot it added" "$(cat "$tmp/slots")"
[[ ! -e $tmp/var/journal ]] || fail "a rolled-back add leaves no journal"
pass "an add that fails part way rolls back its account and slot"

users users_add dhh child emma kidpass ownerpw 2>/dev/null
TEST_FAIL_CHPASSWD=1 users users_password dhh emma reset123 ownerpw 2>/dev/null && fail "a change whose password can't be set fails"
login_is emma kidpass || fail "a failed change keeps the old login"
opens kidpass 1 || fail "a failed change keeps the old slot"
[[ -z $(awk -F'\t' '$2 == "reset123"' "$tmp/slots") ]] || fail "a failed change removes the new slot" "$(cat "$tmp/slots")"
pass "a password change that fails before the account changes keeps the old password everywhere"

# Interrupted after chpasswd but before the journal said so: shadow itself
# says the account took the new password, so it rolls forward.
before=$(users users_fingerprint emma)
printf '2\tforward1\n' >>"$tmp/slots"
printf 'emma:forward1\n' | chpasswd
mkdir -p "$tmp/var"
printf 'op=password\nuser=emma\nuuid=uuid-root\nold_slot=1\nslot=2\nold_fp=%s\nphase=key\n' "$before" >"$tmp/var/journal"
users users_finish 2>"$tmp/err" || fail "finishing an interrupted change" "$(cat "$tmp/err")"
[[ $(map_line emma | cut -d' ' -f2) == "2" ]] || fail "a change whose account took the new password rolls forward to the new slot"
! opens kidpass 1 || fail "rolling forward retires the old slot"
users users_in_sync emma || fail "rolled forward, the account is in sync"
pass "a change interrupted after the account took the new password is finished, not undone, whatever the phase said"

# Killed after luksAddKey, before anything else: the slot was journaled before
# the key went in, so it is taken back.
reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
TEST_CRASH_AFTER_ADDKEY=1 users users_password dhh emma reset123 ownerpw 2>/dev/null && fail "a change whose key step fails fails"
[[ -z $(awk -F'\t' '$2 == "reset123"' "$tmp/slots") ]] || fail "a key added before the step failed is taken back" "$(cat "$tmp/slots")"
login_is emma kidpass && opens kidpass 1 || fail "the old password still works everywhere"
TEST_CRASH_AFTER_ADDKEY=1 users users_add dhh child zoe zoepass1 ownerpw 2>/dev/null && fail "an add whose key step fails fails"
[[ -z $(awk -F'\t' '$2 == "zoepass1"' "$tmp/slots") ]] && ! getent passwd zoe >/dev/null || fail "an add whose key went in before the failure leaves neither key nor account"
pass "a key that reached the disk before its step failed is never left behind"

TEST_FAIL_DUMP=1 users users_delete dhh emma ownerpw yes 2>/dev/null && fail "a delete that can't read the disk's slots fails"
[[ -f $tmp/var/journal ]] || fail "the unfinished delete stays journaled"
opens kidpass 1 || fail "nothing claimed the slot was gone"
users users_finish 2>"$tmp/err" || fail "the delete finishes once the disk can be read" "$(cat "$tmp/err")"
! opens kidpass 1 && ! getent passwd emma >/dev/null || fail "the finished delete removed the slot and the account"
grep -q -- '-L -e 1 emma' "$tmp/usermod" || fail "the account is locked before it is torn down"
pass "a disk whose slots can't be read stops a delete instead of passing as revoked, and a later run finishes it"

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
printf 'emma:drifted1\n' | chpasswd
expect_refused "a reset to a password still in a slot is refused" "already unlocks this computer" users_password dhh emma kidpass ownerpw
pass "a reset to a password still in someone's slot is refused, so no slot is ever duplicated"

printf 'dhh:drifted2\n' | chpasswd
users users_password dhh dhh resynced1 ownerpw 2>"$tmp/err" || fail "an owner whose login drifted resyncs with the password that unlocks the computer" "$(cat "$tmp/err")"
login_is dhh resynced1 && [[ -n $(awk -F'\t' '$2 == "resynced1"' "$tmp/slots") ]] && users users_in_sync dhh || fail "the resynced owner is in step"
pass "someone whose login password was changed with passwd gets back in step with the password that unlocks the computer"

printf 'op=delete\nuser=emma\nuuid=uuid-elsewhere\nslot=1\nphase=remove\n' >"$tmp/var/journal"
expect_refused "a journal from another disk is refused" "another disk" users_finish
opens kidpass 1 || fail "a journal from another disk removes nothing"
rm -f "$tmp/var/journal"
pass "a journal recording another disk is never replayed on this one"

reset_system
mkdir -p "$tmp/etc"
printf '[Autologin]\nUser=dhh\n' >"$tmp/etc/sddm.conf"
expect_refused "an autologin in sddm.conf blocks a second person" "logs someone in automatically" users_add dhh child emma kidpass ownerpw
rm -f "$tmp/etc/sddm.conf"
pass "a second person is never given a disk key while /etc/sddm.conf logs someone in"

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
printf 'emma:outofband\n' | chpasswd
! users users_in_sync emma || fail "a password changed with passwd is out of sync"
[[ $(users users_list | grep emma) == "emma child no" ]] || fail "list marks the drifted account"
pass "a password changed outside Setup > Users shows as out of sync"

reset_system unencrypted
users users_add dhh child emma kidpass ownerpw 2>"$tmp/err" || fail "an unencrypted install adds a child" "$(cat "$tmp/err")"
login_is emma kidpass || fail "the unencrypted child can log in"
[[ $(wc -l <"$tmp/slots") == 1 && ! -e $tmp/etc/omarchy/users/slots ]] || fail "an unencrypted install touches no slots"
[[ $(users users_list) == $'dhh adult -\nemma child -' ]] || fail "list shows no sync on an unencrypted install" "$(users users_list)"
pass "an unencrypted install adds users without disk slots"

if /usr/bin/bash "$ROOT/bin/omarchy-user-helper" list 2>/dev/null; then
  fail "the helper refuses a Bash not started with -p"
fi
pass "the helper refuses to start outside a privileged Bash"

# --- omarchy-login-select, before every SDDM start ---

sddm_dir=$tmp/etc/sddm.conf.d
slot_record=$tmp/run/omarchy/luks-slot

# Both ExecStartPre steps, as systemd runs them: the clear must succeed for
# SDDM to start at all, the choice may fail.
select_login() {
  (
    export USERS_JOURNAL=$tmp/var/journal USERS_SHADOW=$tmp/shadow USERS_LIFECYCLE_DISPATCH=omarchy-lifecycle-dispatch
    export LOGIN_SELECT_USERS_DIR=$tmp/etc/omarchy/users LOGIN_SELECT_SDDM_DIR=$sddm_dir LOGIN_SELECT_SDDM_CONF=$tmp/etc/sddm.conf LOGIN_SELECT_SLOT_RECORD=$slot_record
    "$ROOT/bin/omarchy-login-select" --clear || exit 1
    "$ROOT/bin/omarchy-login-select" || true
  )
}

static_owner_autologin() {
  mkdir -p "$sddm_dir"
  printf '[Autologin]\nUser=dhh\nSession=omarchy.desktop\n' >"$sddm_dir/autologin.conf"
}

record_slot() {
  mkdir -p "${slot_record%/*}"
  echo "$1" >"$slot_record"
}

# Whom SDDM logs in: the last User= under [Autologin] across its drop-ins in
# name order, then /etc/sddm.conf, which outranks them all.
autologin_user() {
  local user="" file
  for file in "$sddm_dir"/*.conf "$tmp/etc/sddm.conf"; do
    [[ -f $file ]] || continue
    user=$(awk -F= -v u="$user" '/^\[/ { s = $0 } s == "[Autologin]" && $1 == "User" { u = $2 } END { print u }' "$file")
  done
  echo "$user"
}

reset_system
static_owner_autologin
select_login
[[ $(autologin_user) == "dhh" ]] || fail "before anyone is added, the installer's autologin stands"
pass "before Setup > Users adds anyone, login selection leaves the installer's autologin alone"

users users_add dhh child emma kidpass ownerpw 2>/dev/null
select_login
[[ -z $(autologin_user) ]] || fail "with two accounts and no unlock record, the owner's static autologin is gone"
pass "the moment a second person has a disk key, the owner's static autologin is gone"

record_slot "uuid-root 1"
select_login
[[ $(autologin_user) == "emma" ]] || fail "the slot that unlocked the disk picks its account"
grep -qx 'Relogin=false' "$sddm_dir/zz-omarchy-autologin.conf" || fail "the autologin never logs back in after a logout"
select_login
[[ -z $(autologin_user) ]] || fail "a second SDDM start in the same boot shows the login screen"
pass "the unlocking slot picks its account once, and a restarted SDDM shows the login screen"

record_slot "uuid-root 0"
select_login
[[ $(autologin_user) == "dhh" ]] || fail "the owner's slot picks the owner"
record_slot "uuid-other 1"
select_login
[[ -z $(autologin_user) ]] || fail "a record for another volume picks nobody"
record_slot "uuid-root 9"
select_login
[[ -z $(autologin_user) ]] || fail "an unmapped slot picks nobody"
printf 'emma:outofband\n' | chpasswd
record_slot "uuid-root 1"
select_login
[[ -z $(autologin_user) ]] || fail "a drifted account is not picked by its old slot"
pass "a record for another volume, an unmapped slot, or a drifted account shows the login screen"

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
printf 'op=add\nuser=x\nphase=account\n' >"$tmp/var/journal"
record_slot "uuid-root 1"
select_login
[[ -z $(autologin_user) ]] || fail "an unfinished change picks nobody"
rm -f "$tmp/var/journal"
echo "uuid-root 1 1001 emma x" >>"$tmp/etc/omarchy/users/slots"
record_slot "uuid-root 1"
select_login
[[ -z $(autologin_user) ]] || fail "a map naming a slot twice picks nobody"
pass "an unfinished change or an inconsistent map shows the login screen"

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
users users_delete dhh emma ownerpw yes 2>/dev/null
select_login
[[ $(autologin_user) == "dhh" ]] || fail "back to one account, its autologin returns"
pass "back to one account on an encrypted disk, that account is logged in again"

reset_system unencrypted
users users_add dhh child emma kidpass ownerpw 2>/dev/null
static_owner_autologin
select_login
[[ -z $(autologin_user) ]] || fail "an unencrypted install with users shows the login screen"
pass "an unencrypted install with people added always shows the login screen"

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
mkdir -p "$sddm_dir"
printf '[Autologin]\nUser=dhh\n' >"$sddm_dir/50-someone.conf"
select_login
[[ -z $(autologin_user) ]] || fail "another drop-in naming the owner is overridden" "$(autologin_user)"
record_slot "uuid-root 1"
select_login
[[ $(autologin_user) == "emma" ]] || fail "the chosen account outranks another drop-in"
pass "the managed drop-in sorts last and always names a user, empty or chosen, over any other drop-in"

printf '[Autologin]\nUser=dhh\n' >"$tmp/etc/sddm.conf"
if select_login 2>/dev/null; then
  fail "an autologin in sddm.conf on a machine with two people stops SDDM instead of opening the owner's desktop"
fi
pass "an autologin in /etc/sddm.conf, which no drop-in outranks, stops SDDM rather than open the owner's desktop"

# --- A grown-up's password on a child's lock screen ---

fake logger <<'SH'
#!/bin/bash
echo "$*" >>"$TEST_TMP/logger"
SH

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
users users_adult_check emma ownerpw 2>/dev/null || fail "an adult's password opens a child's lock screen"
grep -q "accepted dhh's password in emma's session" "$tmp/logger" || fail "an adult's unlock is logged"
if users users_adult_check emma kidpass 2>/dev/null; then fail "the child's own password is not a grown-up's"; fi
if users users_adult_check dhh ownerpw 2>/dev/null; then fail "an adult's session does not take another adult's password through this"; fi
pass "a child's lock screen opens with any adult's password, logged, and only a child's"

for i in 1 2 3 4 5; do users users_adult_check emma "guess$i" 2>/dev/null && fail "a wrong guess is refused"; done
if users users_adult_check emma ownerpw 2>/dev/null; then fail "five misses lock out even the right password for a while"; fi
printf '0 0\n' >"$tmp/run/rate/adult-check-1001"
users users_adult_check emma ownerpw 2>/dev/null || fail "once the lockout is over the right password works"
[[ ! -f $tmp/run/rate/adult-check-1001 ]] || fail "a success clears the count"
pass "five wrong grown-up passwords lock a child's lock screen out of that path for a while"

# --- Blocked apps ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
printf 'Steam\nGoogle Messages\n' | users users_apps dhh emma ownerpw 2>"$tmp/err" || fail "an adult sets a child's blocked apps" "$(cat "$tmp/err")"
[[ $(cat "$tmp/etc/omarchy/blocked-apps/emma") == $'Google Messages\nSteam' ]] || fail "the list is written as given" "$(cat "$tmp/etc/omarchy/blocked-apps/emma")"
[[ $(cat "$tmp/apps-applied") == "2" ]] || fail "a changed list is enforced"
printf 'Steam\n' | users users_apps emma emma kidpass 2>/dev/null && fail "a child can't change a blocked list"
printf '../../etc/passwd\n' | users users_apps dhh emma ownerpw 2>/dev/null && fail "only desktop ids go on a list"
pass "only an adult sets someone's blocked apps, and only desktop ids"

users users_delete dhh emma ownerpw yes 2>/dev/null
[[ ! -e $tmp/etc/omarchy/blocked-apps/emma ]] || fail "a deleted person's blocked list goes with them"
[[ $(cat "$tmp/apps-applied") == "3" ]] || fail "their ACLs are removed before the account"
pass "deleting someone takes their blocked list and its ACLs with them"

# --- Theme collections ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
printf 'kids\ngeneral\n' | users users_themes dhh emma ownerpw 2>"$tmp/err" || fail "an adult picks a child's theme collections" "$(cat "$tmp/err")"
[[ $(cat "$tmp/etc/omarchy/theme-collections/emma") == $'general\nkids' ]] || fail "the picked collections are written"
[[ $(stat -c %a "$tmp/etc/omarchy/theme-collections/emma") == "644" ]] || fail "the child's session can read their collections"
printf 'kids\n' | users users_themes emma emma kidpass 2>/dev/null && fail "a child can't change their collections"
printf 'adults-only\n' | users users_themes dhh emma ownerpw 2>/dev/null && fail "only shipped collections can be picked"
printf '' | users users_themes dhh emma ownerpw 2>/dev/null && fail "at least one collection is picked"
users users_delete dhh emma ownerpw yes 2>/dev/null
[[ ! -e $tmp/etc/omarchy/theme-collections/emma ]] || fail "a deleted person's collections go with them"
pass "only an adult picks someone's theme collections, from those shipped, and they go with the person"

# --- Boot image ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
users users_add dhh adult bob bobpass1 ownerpw 2>/dev/null
[[ $(cat "$tmp/rebuilt") == "rebuilt" ]] || fail "the boot image is rebuilt once, the first time someone is added" "$(cat "$tmp/rebuilt" 2>/dev/null)"
reset_system unencrypted
users users_add dhh child emma kidpass ownerpw 2>/dev/null
[[ ! -e $tmp/rebuilt ]] || fail "an unencrypted machine has no unlock to record"
pass "the boot image is rebuilt once on an encrypted machine when the first person is added, never on an unencrypted one"

# --- Screen time ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
users users_add dhh adult bob bobpass1 ownerpw 2>/dev/null
[[ $(cat "$tmp/screen-time") == $'on\nadd emma' ]] || fail "a new child is put under screen time, and an adult is not" "$(cat "$tmp/screen-time")"
users users_delete dhh emma ownerpw yes 2>/dev/null
[[ $(tail -1 "$tmp/screen-time") == "remove emma" ]] || fail "a deleted child leaves screen time"
pass "a new child is under screen time from the start, and leaves it when deleted"

# --- Web allowlist on delete ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
mkdir -p "$tmp/etc/omarchy/web-allowlist" && printf 'on\nkhanacademy.org\n' >"$tmp/etc/omarchy/web-allowlist/emma"
rm -f "$tmp/web-applied"
users users_delete dhh emma ownerpw yes 2>/dev/null
[[ ! -e $tmp/etc/omarchy/web-allowlist/emma && -s $tmp/web-applied ]] || fail "a deleted child's web allowlist and its rules go with them"
pass "deleting someone takes their web allowlist and its uid's rules with them"

# --- A child's own password changes are rate-limited ---

reset_system
users users_add dhh child emma kidpass ownerpw 2>/dev/null
users users_password emma emma kidpass2 kidpass 2>/dev/null || fail "a child changes their password"
users users_password emma emma ownerpw kidpass2 2>/dev/null && fail "a grown-up's password is refused as a child's new one"
users users_password emma emma kidpass3 kidpass2 2>/dev/null || fail "a third change in the hour goes through"
expect_refused "a fourth try in an hour is refused" "three password changes this hour" users_password emma emma kidpass4 kidpass3
users users_password dhh emma reset123 ownerpw 2>/dev/null || fail "a grown-up still resets a child's password"
pass "a child's own password changes are three an hour, refused tries included, so they test nobody's password quickly"

# --- Recovery finishes what an add or a delete left ---

reset_system
printf '#!/bin/bash\n[[ -n ${TEST_FAIL_SETUP:-} ]] && exit 1\necho "$*" >>"$TEST_TMP/screen-time"\n' >"$tmp/bin/fake-screen-time"
TEST_FAIL_SETUP=1 users users_add dhh child emma kidpass ownerpw 2>/dev/null && fail "an add whose child setup fails reports it"
[[ -f $tmp/var/journal ]] || fail "the unfinished child setup stays journaled"
users users_finish 2>"$tmp/err" || fail "a later run finishes the child's setup" "$(cat "$tmp/err")"
[[ $(cat "$tmp/screen-time") == $'on\nadd emma' && -f $tmp/etc/omarchy/blocked-apps/emma && ! -f $tmp/var/journal ]] ||
  fail "a recovered add leaves the child under screen time with their blocked apps"
pass "an add stopped after the child's password still ends with their screen time and blocked apps"

reset_system
users users_add dhh adult bob bobpass1 ownerpw 2>/dev/null
mkdir -p "$tmp/var"
printf 'op=delete\nuser=dhh\nuid=1000\nuuid=uuid-root\nslot=0\nhome=no\nroot_to=bob\nphase=handoff\n' >"$tmp/var/journal"
users users_finish 2>/dev/null || fail "a delete stopped mid-handoff is finished"
grep -qx -- '-L root' "$tmp/usermod" || fail "root is locked when its handoff is in doubt"
[[ $(cat "$tmp/etc/omarchy/users/root") == "bob" ]] && ! getent passwd dhh >/dev/null || fail "the holder is the adult who deleted, and the delete finishes"
pass "a delete stopped mid-handoff locks root, names the new holder, and finishes"

# --- The login screen finds the account by its password ---

reset_system
users users_add dhh child emma kidpass1 ownerpw 2>/dev/null
[[ $(users users_password_owner kidpass1) == emma && $(users users_password_owner ownerpw) == dhh ]] || fail "each password names its own account"
! users users_password_owner nobodys1 >/dev/null || fail "a password that is nobody's names no account"
pass "a password names the one account it belongs to, and nobody's names none"

# The login screen only ends an attempt early for an owner with no failed
# logins on record, so a lockout never hides behind a faster refusal.
cat >"$tmp/bin/fake-faillock" <<'SH'
#!/bin/bash
[[ ${TEST_FAILLOCK:-} == broken ]] && exit 1
printf '%s:\nWhen                Type  Source  Valid\n' "$2"
[[ ${TEST_FAILLOCK:-} == failed ]] && printf '2026-10-28 15:07:52 SVC   sddm    V\n'
true
SH
chmod +x "$tmp/bin/fake-faillock"
export USERS_FAILLOCK=fake-faillock
! users users_has_failed_logins dhh || fail "an account with an empty tally has no failed logins"
TEST_FAILLOCK=failed users users_has_failed_logins dhh || fail "a recorded failure counts"
TEST_FAILLOCK=broken users users_has_failed_logins dhh || fail "a tally that cannot be read counts as failures"
unset USERS_FAILLOCK
pass "only an owner with a clean failed-login tally is matched early, and an unreadable tally is not clean"
