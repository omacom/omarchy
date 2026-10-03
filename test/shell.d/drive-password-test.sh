#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-drive-password against fake drives. findmnt and lsblk describe a
# system drive under / and a data drive, and blkid has the empty cache a user
# sees until root runs blkid in that boot; cryptsetup is either a slot-table fake
# or the real binary on file-backed volumes; chpasswd records the accounts. Each
# cryptsetup and chpasswd call is a crash point, so a run can be killed after
# every step and rerun, like a power loss. The runs repeat on an Apple fixture,
# where a fake boot package records the owner's slot through the real
# omarchy-lifecycle-dispatch; on the x86 fixture that is a no-op.

# Root's dispatcher ignores the fixtures and sees this machine.
if (( EUID == 0 )) && [[ $("$ROOT/bin/omarchy-hw-platform") == "apple-silicon" ]]; then
  skip "running as root on Apple Silicon, where dispatch ignores fixtures; skipping"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

old_password=old-password
new_password='new pass:word'
recovery_key=recovery-passphrase
data_password=data-password
journal=$tmp/state/omarchy/drive-password.state

mkdir -p "$tmp/bin" "$tmp/real" "$tmp/dev"

cat >"$tmp/crash.sh" <<'SH'
crash_point() {
  local count
  count=$(( $(cat "$TEST_TMP/steps") + 1 ))
  echo "$count" >"$TEST_TMP/steps"
  printf '%s %s\n' "$count" "$1" >>"$TEST_TMP/trace"
  if (( count == ${CRASH_AT:-0} )); then
    kill -9 "$TEST_PID"
    # An orphan outlives the script for a moment, like a cryptsetup child.
    if [[ -n ${CRASH_ORPHAN:-} ]]; then sleep 1; else kill -9 $$; fi
  fi
}
SH

cat >"$tmp/bin/blkid" <<'SH'
#!/bin/bash
exit 2
SH

cat >"$tmp/bin/findmnt" <<'SH'
#!/bin/bash
[[ $* == "-no SOURCE /" && -z ${TEST_FINDMNT_FAIL:-} ]] || exit 1
echo '/dev/mapper/root[/@]'
SH

cat >"$tmp/bin/lsblk" <<'SH'
#!/bin/bash
if [[ $1 == "-dno" && $2 == "UUID" ]]; then
  cat "$3.uuid"
  exit
fi
if [[ $* == "-nrpo NAME,FSTYPE" ]]; then
  echo "/dev/fake-disk "
  while IFS= read -r drive; do
    printf '%s crypto_LUKS\n/dev/mapper/%s btrfs\n' "$drive" "${drive##*/}"
  done <"$TEST_TMP/drives"
  exit
fi
[[ $* == "-nsrpo NAME,TYPE,FSTYPE /dev/mapper/root" ]] || exit 98
cat "$TEST_TMP/root-ancestry"
SH

cat >"$tmp/bin/omarchy-drive-select" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$TEST_TMP/offered"
cat "$TEST_TMP/select"
SH

cat >"$tmp/bin/gum" <<'SH'
#!/bin/bash
[[ $1 == "input" ]] || exit 97
printf '%s\n' "$*" >>"$TEST_TMP/prompts"
[[ -s $TEST_TMP/inputs ]] || exit 130
# Another key enrolled while the owner types the new password.
if [[ -n ${TEST_ENROLL_AT_PROMPT:-} && $* == *"$TEST_ENROLL_AT_PROMPT"* ]]; then
  printf '3\tlater-key\n' >>"$TEST_ENROLL_DEVICE.slots"
fi
head -n 1 "$TEST_TMP/inputs"
sed -i '1d' "$TEST_TMP/inputs"
SH

# Runs as the caller, closing every descriptor above stderr as sudo does.
cat >"$tmp/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/sudo-calls"
for fd in /proc/$$/fd/*; do
  fd=${fd##*/}
  (( fd > 2 && fd != 255 )) && eval "exec $fd>&-" 2>/dev/null
done
exec "$@"
SH

cat >"$tmp/bin/chpasswd" <<'SH'
#!/bin/bash
source "$TEST_TMP/crash.sh"
IFS= read -r line
name=${line%%:*}
crash_point "chpasswd $name"
[[ $name != "${TEST_CHPASSWD_FAIL:-}" ]] || exit 1
{
  grep -v "^$name	" "$TEST_TMP/accounts" || true
  printf '%s\t%s\n' "$name" "${line#*:}"
} >"$TEST_TMP/accounts.next"
mv -f "$TEST_TMP/accounts.next" "$TEST_TMP/accounts"
crash_point "$name password set"
SH

# A LUKS1-style volume as a table of "slot<TAB>passphrase" lines next to the
# device: luksChangeKey adds the new key to a free slot, then removes the old,
# and luksKillSlot needs a key that opens another slot, as cryptsetup does.
cat >"$tmp/bin/cryptsetup" <<'SH'
#!/bin/bash
source "$TEST_TMP/crash.sh"

slot_of() {
  local slot key
  while IFS=$'\t' read -r slot key; do
    [[ $key == "$1" && $slot != "${2:-}" ]] && { echo "$slot"; return; }
  done <"$slots"
}

op=$1
shift
key_file="" token_type="" positional=()
while (( $# )); do
  case $1 in
    --key-file) key_file=$2; shift 2 ;;
    --token-type) token_type=$2; shift 2 ;;
    --pbkdf | --iter-time) shift 2 ;;
    -*) shift ;;
    *) positional+=("$1"); shift ;;
  esac
done
slots=${positional[0]}.slots
[[ -f $slots ]] || { echo "Device ${positional[0]} does not exist or access denied."; exit 4; }
if [[ $key_file == "-" ]]; then key=$(cat); elif [[ -n $key_file ]]; then key=$(cat "$key_file"); fi

[[ $op != "isLuks" ]] || exit 1
if [[ $op == "luksDump" ]]; then
  echo "Keyslots:"
  cut -f1 "$slots" | sed 's/^/  /; s/$/: luks2/'
  [[ -z ${TEST_TOKEN_SLOT:-} ]] || printf 'Tokens:\n  0: luks2-keyring\n\tKeyslot:    %s\n' "$TEST_TOKEN_SLOT"
  printf 'Digests:\n  0: pbkdf2\n'
  exit 0
fi

crash_point "cryptsetup $op"
[[ $op != "open" || -z ${TEST_OPEN_FAIL:-} ]] || exit 1
# An enrolled token unlocks its slot whatever key is given, unless the allowed
# token types exclude it, as with cryptsetup.
if [[ $op == "open" && -z $token_type && -n ${TEST_TOKEN_SLOT:-} ]]; then
  echo "Key slot $TEST_TOKEN_SLOT unlocked."
  exit 0
fi
target=""
[[ $op == "luksKillSlot" ]] && target=${positional[1]}
slot=$(slot_of "$key" "$target")
[[ -n $slot ]] || { echo "No key available with this passphrase."; exit 2; }

case $op in
  open) echo "Key slot $slot unlocked." ;;
  luksChangeKey)
    [[ -z ${TEST_CHANGE_FAIL:-} ]] || exit 1
    for (( next = 0; next < 32; next++ )); do
      cut -f1 "$slots" | grep -qx "$next" || break
    done
    printf '%s\t%s\n' "$next" "$(cat "${positional[1]}")" >>"$slots"
    crash_point "new key added"
    [[ -z ${TEST_CHANGE_PARTIAL:-} ]] || exit 137
    awk -F'\t' -v s="$slot" '$1 != s' "$slots" >"$slots.next"
    mv -f "$slots.next" "$slots"
    crash_point "old key removed"
    ;;
  luksKillSlot)
    [[ -z ${TEST_KILL_FAIL:-} ]] || exit 1
    awk -F'\t' -v s="$target" '$1 != s' "$slots" >"$slots.next"
    mv -f "$slots.next" "$slots"
    crash_point "slot $target killed"
    ;;
  *) exit 1 ;;
esac
SH

# The real cryptsetup, keeping the command's KDF but at a fast cost, counting
# the same crash points.
cat >"$tmp/real/cryptsetup" <<'SH'
#!/bin/bash
source "$TEST_TMP/crash.sh"
args=()
while (( $# )); do
  case $1 in
    --iter-time) shift 2 ;;
    *) args+=("$1"); shift ;;
  esac
done
if [[ ${args[0]} == "luksChangeKey" ]]; then
  if [[ " ${args[*]} " == *" argon2id "* ]]; then
    args+=(--pbkdf-force-iterations 4 --pbkdf-memory 32768)
  else
    args+=(--pbkdf-force-iterations 1000)
  fi
fi
[[ ${args[0]} == "luksDump" || ${args[0]} == "isLuks" ]] || crash_point "cryptsetup ${args[0]}"
[[ ${args[0]} != "open" || -z ${TEST_OPEN_FAIL:-} ]] || exit 1
status=0
"$REAL_CRYPTSETUP" "${args[@]}" || status=$?
if (( status == 0 )) && [[ ${args[0]} == "luksChangeKey" || ${args[0]} == "luksKillSlot" ]]; then
  crash_point "${args[0]} done"
fi
exit "$status"
SH

chmod +x "$tmp"/bin/* "$tmp/real/cryptsetup"

# The boot package's luks-slots, run by dispatch with an empty environment: it
# records its arguments and is a crash point like the rest.
fake_platform "$tmp/x86" generic
fake_platform "$tmp/apple" apple-silicon
mkdir -p "$tmp/lifecycle/usr/lib/omarchy/mac-boot"
cat >"$tmp/lifecycle/usr/lib/omarchy/mac-boot/luks-slots" <<SH
#!/bin/bash
# --owner names the recorded owner slot, read-only; setup recorded slot 0. A Mac
# set up before slots were recorded has none (4); a record the header doesn't
# hold is a failure (1).
if [[ \$1 == --owner ]]; then
  [[ ! -e $tmp/owner-query-fail ]] || { echo "The LUKS header has no key in the recorded owner slot 0." >&2; exit 1; }
  [[ ! -e $tmp/owner-query-garbage ]] || { echo "slot zero"; exit 0; }
  [[ ! -e $tmp/owner-slot ]] || { cat "$tmp/owner-slot"; exit 0; }
  [[ ! -e $tmp/owner-unrecorded ]] || { echo "No owner key slot is recorded." >&2; exit 4; }
  echo 0
  exit 0
fi
[[ ! -e $tmp/record-fail ]] || exit 1
printf '%s\n' "\$*" >>"$tmp/slot-record"
[[ \$1 != owner=* ]] || echo "\${1#owner=}" >"$tmp/owner-slot"
count=\$(( \$(cat "$tmp/steps") + 1 ))
echo "\$count" >"$tmp/steps"
printf '%s slots recorded\n' "\$count" >>"$tmp/trace"
if (( count == \$(cat "$tmp/crash-at") )); then
  kill -9 "\$PPID"
  kill -9 \$\$
fi
SH
chmod 755 "$tmp/lifecycle/usr/lib/omarchy/mac-boot/luks-slots"
chmod -R go-w "$tmp/lifecycle"

export TEST_TMP=$tmp OMARCHY_PATH=$ROOT XDG_STATE_HOME=$tmp/state SUDO_USER=owner OMARCHY_LIFECYCLE_ROOT=$tmp/lifecycle
base_path=$PATH
platform=x86

# The command's PATH for this backend on this platform fixture.
use() {
  backend=$1 platform=$2
  export OMARCHY_PROC_ROOT=$tmp/$platform/proc
  if [[ $backend == "fake" ]]; then
    export PATH="$tmp/$platform/bin:$tmp/bin:$ROOT/bin:$base_path"
  else
    export PATH="$tmp/$platform/bin:$tmp/real:$tmp/bin:$ROOT/bin:$base_path"
  fi
}
data=$tmp/dev/data

# The slot the key opens, or nothing.
opens() {
  local device=$1 key=$2 slot k
  if [[ $backend == "fake" ]]; then
    while IFS=$'\t' read -r slot k; do
      [[ $k == "$key" ]] && { echo "$slot"; return; }
    done <"$device.slots"
  else
    LC_ALL=C "$REAL_CRYPTSETUP" open --test-passphrase --verbose --key-file <(printf '%s' "$key") "$device" 2>&1 |
      grep -o 'Key slot [0-9]* unlocked' | grep -o '[0-9]*' || true
  fi
}

account() {
  awk -F'\t' -v n="$1" '$1 == n { print $2 }' "$tmp/accounts"
}

volume() {
  local device=$1 key=$2 extra=${3:-}
  echo "uuid-$(basename "$device")" >"$device.uuid"
  if [[ $backend == "fake" ]]; then
    : >"$device"
    printf '0\t%s\n' "$key" >"$device.slots"
    [[ -z $extra ]] || printf '1\t%s\n' "$extra" >>"$device.slots"
  else
    rm -f "$device"
    truncate -s 32M "$device"
    "$REAL_CRYPTSETUP" luksFormat -q --type "$backend" --pbkdf pbkdf2 --pbkdf-force-iterations 1000 "$device" <(printf '%s' "$key")
    if [[ -n $extra ]]; then
      "$REAL_CRYPTSETUP" luksAddKey --pbkdf pbkdf2 --pbkdf-force-iterations 1000 --key-file <(printf '%s' "$key") "$device" <(printf '%s' "$extra")
    fi
  fi
}

# / on the system drive, which also holds a recovery key; a data drive beside it.
fixture() {
  rm -rf "$tmp/state" "$tmp/output" "$tmp/trace" "$tmp/offered" "$tmp"/dev/* "$tmp/slot-record" "$tmp/record-fail" "$tmp/owner-slot" "$tmp/owner-query-fail" "$tmp/owner-query-garbage" "$tmp/owner-unrecorded"
  unset TEST_ENROLL_AT_PROMPT TEST_ENROLL_DEVICE TEST_OPEN_FAIL TEST_CHPASSWD_FAIL TEST_CHANGE_FAIL TEST_CHANGE_PARTIAL TEST_KILL_FAIL TEST_FINDMNT_FAIL TEST_TOKEN_SLOT CRASH_ORPHAN
  system=$tmp/dev/system
  recovery=${1-$recovery_key}
  volume "$system" "$old_password" "$recovery"
  volume "$data" "$data_password"
  printf 'owner\t%s\nroot\t%s\n' "$old_password" "$old_password" >"$tmp/accounts"
  printf '%s\n%s\n' "$system" "$data" >"$tmp/drives"
  printf '/dev/mapper/root crypt btrfs\n%s part crypto_LUKS\n/dev/fake-disk disk \n' "$system" >"$tmp/root-ancestry"
  echo "$system" >"$tmp/select"
  : >"$tmp/prompts"
  : >"$tmp/sudo-calls"
}

# One run of the command: an optional crash step, then answers for its prompts.
attempt() {
  local crash_at=$1
  shift
  if (( $# )); then printf '%s\n' "$@" >"$tmp/inputs"; else : >"$tmp/inputs"; fi
  echo 0 >"$tmp/steps"
  echo "$crash_at" >"$tmp/crash-at"
  : >"$tmp/trace"
  {
    CRASH_AT=$crash_at bash -c 'TEST_PID=$$ exec bash ${TEST_TRACE:+-x} "$0"' "$ROOT/bin/omarchy-drive-password"
  } >>"$tmp/output" 2>&1
}

consistent() {
  local context=$1 password=$2 other=$old_password
  [[ $password == "$old_password" ]] && other=$new_password
  [[ $(account owner) == "$password" && $(account root) == "$password" ]] ||
    fail "$backend: $context: the login and root passwords are the disk password" "$(cat "$tmp/accounts" "$tmp/output")"
  [[ -n $(opens "$system" "$password") ]] || fail "$backend: $context: the disk opens with that password" "$(cat "$tmp/output")"
  [[ -z $(opens "$system" "$other") ]] || fail "$backend: $context: the other password no longer opens the disk" "$(cat "$tmp/trace" "$tmp/output")"
  [[ -z $recovery || -n $(opens "$system" "$recovery") ]] || fail "$backend: $context: the recovery key still opens the disk"
  [[ ! -e $journal ]] || fail "$backend: $context: the journal is gone" "$(cat "$journal")"
  recorded "$context" "$password"
}

# On Apple the boot package holds the slot the owner's password opens: recorded
# whenever the key moved. x86 records nothing and runs no extra sudo.
recorded() {
  local context=$1 password=$2 slot
  if [[ $platform == "apple" ]]; then
    slot=$(opens "$system" "$password")
    if [[ -s $tmp/slot-record ]]; then
      [[ $(tail -n 1 "$tmp/slot-record") == "owner=$slot" ]] ||
        fail "$backend: apple: $context: the owner's slot is recorded" "$(cat "$tmp/slot-record")"
    else
      [[ $slot == "0" ]] || fail "$backend: apple: $context: a key that moved is recorded" "$(cat "$tmp/trace")"
    fi
  else
    [[ ! -e $tmp/slot-record ]] && ! grep -q 'lifecycle-dispatch' "$tmp/sudo-calls" ||
      fail "$backend: x86: $context: no slot is recorded and no dispatch runs under sudo"
  fi
}

said() {
  grep -Fq "$1" "$tmp/output" || fail "$backend: the command says: $1" "$(cat "$tmp/output")"
}

no_secrets() {
  local file
  for file in "$journal" "$tmp/sudo-calls" "$tmp/prompts"; do
    [[ -e $file ]] || continue
    ! grep -Fq -e "$old_password" -e "$new_password" -e "$recovery_key" -e "$data_password" "$file" ||
      fail "$backend: $1: $(basename "$file") holds no password" "$(cat "$file")"
  done
}

# Between runs the disk and the accounts may disagree only while the journal
# says so, and the accounts never take a password the disk does not.
recoverable() {
  local context=$1 login
  login=$(account owner)
  [[ -n $(opens "$system" "$login") || -e $journal ]] ||
    fail "$backend: $context: a disk that no longer opens with the login password is journaled" "$(cat "$tmp/trace")"
  [[ $login == "$old_password" || -n $(opens "$system" "$login") ]] ||
    fail "$backend: $context: the login password changes only after the disk takes it" "$(cat "$tmp/trace")"
  [[ ! -e $journal || $(stat -c %a "$journal") == "600" ]] || fail "$backend: $context: the journal is private"
  no_secrets "$context"
}

backends=(fake)
if REAL_CRYPTSETUP=$(command -v cryptsetup); then
  export REAL_CRYPTSETUP
  backends+=(luks2 luks1)
else
  skip "cryptsetup is not installed; skipping the file-backed volume runs"
fi

matrix=()
for backend in "${backends[@]}"; do
  matrix+=("$backend x86" "$backend apple")
done

for run_spec in "${matrix[@]}"; do
  use $run_spec

  fixture
  attempt 0 "$old_password" "$new_password" "$new_password" || fail "$backend: changing the system disk password succeeds" "$(cat "$tmp/output")"
  consistent "uninterrupted" "$new_password"
  [[ $(opens "$data" "$data_password") == "0" ]] || fail "$backend: the data drive is untouched"
  first_account=$(grep -n 'chpasswd' "$tmp/trace" | head -1 | cut -d: -f1)
  last_luks=$(grep -n 'cryptsetup' "$tmp/trace" | tail -1 | cut -d: -f1)
  (( last_luks < first_account )) || fail "$backend: the disk key changes and is verified before any account" "$(cat "$tmp/trace")"
  grep -Fq 'login password for owner and root' "$tmp/output" || fail "$backend: the command says the login password follows the system disk"
  no_secrets "uninterrupted"
  total_steps=$(cat "$tmp/steps")
  (( total_steps >= 6 )) || fail "$backend: every change is a crash point" "$(cat "$tmp/trace")"
  pass "$backend: the system disk key changes and verifies first, then the login and root passwords follow"

  fixture
  if attempt 0 "not-the-password" "$new_password" "$new_password"; then fail "$backend: a wrong current password fails the command"; fi
  said "That password does not open $system."
  ! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "$backend: a wrong current password changes nothing"
  [[ -n $(opens "$system" "$old_password") && $(account owner) == "$old_password" ]] || fail "$backend: a wrong current password leaves the disk and accounts"
  pass "$backend: a wrong current password is refused before anything changes"

  fixture ""
  attempt 0 "$old_password" "$new_password" "$new_password" || fail "$backend: a single-slot system disk changes" "$(cat "$tmp/output")"
  consistent "single slot" "$new_password"
  pass "$backend: a disk with one key slot keeps it through the change"

  fixture
  echo "$data" >"$tmp/select"
  attempt 0 "$data_password" "$new_password" "$new_password" || fail "$backend: changing a data drive password succeeds" "$(cat "$tmp/output")"
  [[ -n $(opens "$data" "$new_password") && -z $(opens "$data" "$data_password") ]] || fail "$backend: the data drive takes the new password"
  [[ $(account owner) == "$old_password" && $(account root) == "$old_password" ]] || fail "$backend: a data drive leaves the login and root passwords alone"
  [[ -n $(opens "$system" "$old_password") ]] || fail "$backend: a data drive change leaves the system disk alone"
  ! grep -q '^chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "$backend: a data drive change runs no chpasswd and keeps no journal"
  ! grep -Fq 'login password' "$tmp/output" || fail "$backend: a data drive change does not mention the login password"
  pass "$backend: changing a non-root encrypted drive's password leaves the login unchanged"

  # Killed after each step, the owner runs the command again and answers with a
  # password that opens the disk now: the new one, or the old one while it still
  # works. Each rerun is itself killed after each of its steps until one finishes.
  for (( step = 1; step <= total_steps; step++ )); do
    for answer in "$new_password" "$old_password"; do
      fixture
      if attempt "$step" "$old_password" "$new_password" "$new_password"; then fail "$backend: the run is killed at step $step"; fi
      point=$(sed -n "${step}p" "$tmp/trace")
      recoverable "killed after '$point'"
      if [[ ! -e $journal ]]; then
        if [[ $(account owner) == "$new_password" ]]; then
          consistent "killed after '$point'" "$new_password"
        else
          consistent "killed after '$point'" "$old_password"
        fi
        continue
      fi
      [[ -n $(opens "$system" "$answer") ]] || continue
      if grep -qx 'phase=accounts' "$journal" && [[ $answer == "$old_password" ]]; then
        if attempt 0 "$answer"; then fail "$backend: after '$point' a confirmed change refuses the old password"; fi
        [[ -e $journal ]] || fail "$backend: after '$point' a refused rerun keeps the journal"
        answer=$new_password
      fi
      for (( again = 1; ; again++ )); do
        status=0
        attempt "$again" "$answer" || status=$?
        (( status == 0 )) && break
        (( status == 137 )) || fail "$backend: the rerun after '$point' finishes" "$(cat "$tmp/output")"
        recoverable "rerun after '$point' killed at step $again"
      done
      consistent "rerun with $answer after '$point'" "$answer"
      no_secrets "rerun after '$point'"
    done
  done
  pass "$backend $platform: killed after each of $total_steps steps, and each rerun after each of its own, the disk, login and root end on one password"
done

use fake x86

fixture
printf '%s\n%s\n%s\n' "$system" "$data" "$data" >"$tmp/drives"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a fresh boot finds the system disk without a blkid cache" "$(cat "$tmp/output")"
[[ $(cat "$tmp/offered") == "$system"$'\n'"$data" ]] || fail "each LUKS drive lsblk names is offered once" "$(cat "$tmp/offered")"
consistent "fresh boot" "$new_password"
pass "before root has run blkid, every LUKS drive is offered once and the system disk changes"

fixture
printf '5\t%s\n' tpm-sealed-key >>"$system.slots"
export TEST_TOKEN_SLOT=5
if attempt 0 "not-the-password" "$new_password" "$new_password"; then fail "an enrolled token does not stand in for the current password"; fi
said "That password does not open $system."
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a disk with an enrolled token changes its password" "$(cat "$tmp/output")"
consistent "beside an enrolled token" "$new_password"
[[ $(opens "$system" tpm-sealed-key) == "5" ]] || fail "the token's slot is left alone"
pass "an enrolled token never answers for a password, and its slot is left alone"

fixture
export TEST_CHANGE_FAIL=1
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a failed luksChangeKey fails the command"; fi
[[ $(account owner) == "$old_password" && $(account root) == "$old_password" ]] || fail "a failed luksChangeKey leaves both accounts alone"
! grep -q '^chpasswd' "$tmp/sudo-calls" || fail "a failed luksChangeKey runs no chpasswd"
[[ -n $(opens "$system" "$old_password") && ! -e $journal ]] || fail "a failed luksChangeKey leaves the disk and no journal"
pass "a failed LUKS change leaves the login and root passwords unchanged"

fixture
export TEST_CHANGE_PARTIAL=1
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a luksChangeKey that dies after adding the new key is finished" "$(cat "$tmp/output")"
consistent "luksChangeKey died after adding the new key" "$new_password"
pass "a luksChangeKey that dies between keys has its old key retired before the accounts change"

fixture
export TEST_CHANGE_PARTIAL=1 TEST_KILL_FAIL=1
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a failed retirement fails the command"; fi
[[ -e $journal && $(account owner) == "$old_password" ]] || fail "a failed retirement keeps the journal and the accounts"
unset TEST_CHANGE_PARTIAL TEST_KILL_FAIL
if attempt 0 "$recovery_key"; then fail "an unconfirmed change refuses the recovery key"; fi
said "That password does not finish the change"
[[ -e $journal && $(account owner) == "$old_password" && -n $(opens "$system" "$recovery_key") ]] || fail "refusing the recovery key changes nothing"
attempt 0 "$new_password" || fail "the rerun retires the old key and finishes" "$(cat "$tmp/output")"
consistent "rerun after a failed retirement" "$new_password"
pass "before the change is confirmed a rerun refuses the recovery key and retires the old key"

fixture
export TEST_CHANGE_PARTIAL=1 TEST_KILL_FAIL=1
attempt 0 "$old_password" "$new_password" "$new_password" || true
unset TEST_CHANGE_PARTIAL TEST_KILL_FAIL
attempt 0 "$old_password" || fail "the rerun with the old password rolls back" "$(cat "$tmp/output")"
consistent "rollback with the old password" "$old_password"
pass "a rerun with the old password removes the half-added new key"

fixture
attempt 0 "$old_password" "$new_password" "$new_password"
chpasswd_step=$(grep -n 'chpasswd owner' "$tmp/trace" | cut -d: -f1)
fixture
attempt "$chpasswd_step" "$old_password" "$new_password" "$new_password" || true
grep -qx 'phase=accounts' "$journal" || fail "a crash before the accounts leaves the confirmed phase" "$(cat "$journal" "$tmp/trace")"
if attempt 0 "$recovery_key"; then fail "a confirmed change refuses the recovery key"; fi
said "That password does not finish the change"
[[ -e $journal && $(account owner) == "$old_password" ]] || fail "refusing the recovery key changes no account"
if attempt 0 "not-the-password"; then fail "a rerun refuses a password that opens nothing"; fi
for suffix in "" .slots .uuid; do
  mv "$system$suffix" "$tmp/dev/renumbered$suffix"
done
system=$tmp/dev/renumbered
printf '/dev/mapper/root crypt btrfs\n%s part crypto_LUKS\n/dev/fake-disk disk \n' "$system" >"$tmp/root-ancestry"
attempt 0 "$new_password" || fail "the confirmed change finishes on a renumbered disk" "$(cat "$tmp/output")"
consistent "rerun after a confirmed change" "$new_password"
pass "once the new key is confirmed only its slot finishes the accounts, on the disk found by UUID"

fixture
export TEST_OPEN_FAIL=1
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a disk that cannot be checked fails the command"; fi
said "Could not check the password against $system."
! grep -q 'luksChangeKey' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "a disk that cannot be checked is not changed"
pass "the current password is checked before anything changes"

fixture
export TEST_CHPASSWD_FAIL=root
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a failed root password change fails the command"; fi
[[ $(account owner) == "$new_password" && $(account root) == "$old_password" && -e $journal ]] ||
  fail "a failed root password change keeps the journal"
unset TEST_CHPASSWD_FAIL
attempt 0 "$new_password" || fail "the rerun sets the root password" "$(cat "$tmp/output")"
consistent "rerun after a failed root password change" "$new_password"
pass "a failed account change is finished by the next run"

fixture
attempt "$chpasswd_step" "$old_password" "$new_password" "$new_password" || true
export TEST_FINDMNT_FAIL=1
if attempt 0 "$new_password"; then fail "a run that cannot find / fails"; fi
said "Could not tell which drive holds the system."
[[ -e $journal && $(account owner) == "$old_password" ]] || fail "a run that cannot find / keeps the journal and the accounts"
unset TEST_FINDMNT_FAIL
attempt 0 "$new_password" || fail "the rerun finishes once / is found" "$(cat "$tmp/output")"
consistent "rerun after a failed root lookup" "$new_password"
pass "a failed root lookup changes nothing and keeps the journal"

fixture
attempt 0 "$old_password" "$new_password" "$new_password"
change_step=$(grep -n 'cryptsetup luksChangeKey' "$tmp/trace" | cut -d: -f1)
fixture
export CRASH_ORPHAN=1
attempt "$change_step" "$old_password" "$new_password" "$new_password" || true
unset CRASH_ORPHAN
if attempt 0 "$old_password"; then fail "a rerun waits for a luksChangeKey the killed run left behind"; fi
attempt 0 "$new_password" || fail "the rerun finishes after the orphaned change" "$(cat "$tmp/output")"
consistent "orphaned luksChangeKey" "$new_password"
pass "a luksChangeKey that outlives its run finishes before the rerun reads the disk"

fixture
printf '/dev/mapper/root crypt btrfs\n%s part \n/dev/fake-disk disk \n' "$system" >"$tmp/root-ancestry"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a crypt layer without a named LUKS partition fails"; fi
said "Could not tell which drive holds the system."
! grep -q 'luksChangeKey' "$tmp/sudo-calls" || fail "an unresolved crypt layer changes nothing"
pass "a crypt layer whose LUKS partition cannot be named fails closed"

fixture
mkdir -p "${journal%/*}"
printf 'uuid=uuid-system\nold_slot=0\nslots=\nphase=luks\n' >"$journal"
if attempt 0 "$recovery_key"; then fail "a journal without slots refuses to finish"; fi
said "is unreadable"
[[ -e $journal && $(account owner) == "$old_password" && -n $(opens "$system" "$old_password") ]] || fail "an unreadable journal changes nothing"
pass "a journal without its slot list is refused rather than trusted"

fixture
export TEST_CHANGE_PARTIAL=1 TEST_KILL_FAIL=1
attempt 0 "$old_password" "$new_password" "$new_password" || true
unset TEST_CHANGE_PARTIAL TEST_KILL_FAIL
printf '3\tlater-key\n' >>"$system.slots"
if attempt 0 "$new_password"; then fail "a disk that gained two slots refuses to finish"; fi
said "changed since the interrupted change"
[[ -e $journal && -n $(opens "$system" "later-key") && -n $(opens "$system" "$old_password") ]] || fail "a disk that gained two slots is left alone"
pass "a rerun never removes a slot enrolled after the interrupted change"

fixture
mkdir -p "${journal%/*}"
exec {held}>"${journal%/*}/drive-password.lock"
flock -n "$held"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a second run waits for the first"; fi
exec {held}>&-
grep -Fq 'Another drive password change is running.' "$tmp/output" && ! grep -q 'luksChangeKey' "$tmp/sudo-calls" ||
  fail "a second run changes nothing while another holds the lock"
pass "two runs never interleave"

fixture
export TEST_TRACE=1
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a traced run succeeds" "$(cat "$tmp/output")"
unset TEST_TRACE
! grep -Fq -e "$old_password" -e "$new_password" "$tmp/output" || fail "tracing never shows a password" "$(cat "$tmp/output")"
pass "bash -x does not trace passwords"

fixture
SUDO_USER=root
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "the system disk needs a login user"; fi
said "Run omarchy-drive-password as the user who logs in"
[[ ! -s $tmp/sudo-calls && ! -e $journal && -n $(opens "$system" "$old_password") ]] || fail "without a login user nothing changes"
echo "$data" >"$tmp/select"
attempt 0 "$data_password" "$new_password" "$new_password" || fail "a data drive changes without a login user" "$(cat "$tmp/output")"
SUDO_USER=owner
pass "the system disk password changes only for a known login user"

fixture
printf '/dev/mapper/root lvm btrfs\n/dev/mapper/cryptlvm crypt LVM2_member\n%s part crypto_LUKS\n/dev/fake-disk disk \n' "$system" >"$tmp/root-ancestry"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "an LVM-on-LUKS system disk changes" "$(cat "$tmp/output")"
consistent "LVM on LUKS" "$new_password"
pass "the system disk is found beneath an LVM volume group"

fixture
printf '/dev/mapper/root part ext4\n/dev/fake-disk disk \n' >"$tmp/root-ancestry"
echo "$data" >"$tmp/drives"
attempt 0 "$data_password" "$new_password" "$new_password" || fail "an unencrypted root still changes a data drive" "$(cat "$tmp/output")"
[[ $(account owner) == "$old_password" && -n $(opens "$data" "$new_password") ]] || fail "an unencrypted root keeps the login password"
pass "with / unencrypted, every encrypted drive changes alone"

fixture
mkdir -p "${journal%/*}"
printf 'uuid=uuid-elsewhere\nphase=accounts\nslot=0\n' >"$journal"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a journal for another disk does not block a change" "$(cat "$tmp/output")"
consistent "stale journal" "$new_password"
pass "a journal for a disk that is not / is dropped"

fixture
if attempt 0 "$old_password" ""; then fail "an empty password is refused"; fi
said "Password cannot be empty."
if attempt 0 "$old_password" "secret123" "*"; then fail "a mismatched confirmation is refused"; fi
said "Passwords do not match."
if attempt 0 "$old_password" "$old_password" "$old_password"; then fail "the current password is refused as the new one"; fi
said "The new password is the current one."
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal && $(account owner) == "$old_password" ]] ||
  fail "refused passwords change nothing"
pass "drive password rejects empty, mismatched and unchanged passphrases before changing anything"

# Only the owner's slot changes the system disk. A second key an earlier setup
# added (a recovery key) is refused before anything changes, and so is a change
# the boot package cannot vouch for.
use fake apple
fixture
if attempt 0 "$recovery_key" "$new_password" "$new_password"; then fail "apple: a key in another slot is refused"; fi
said "That password opens another key slot on the system disk"
said "The system disk password did not change."
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal && ! -e $tmp/slot-record ]] || fail "apple: refusing another slot's key changes nothing"
[[ -n $(opens "$system" "$recovery_key") ]] || fail "apple: the other key still opens the disk"
consistent "another slot's key refused" "$old_password"
touch "$tmp/owner-query-fail"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "apple: a boot package that cannot name the owner's slot stops the change"; fi
said "Could not read which key slot holds the system disk password: The LUKS header has no key in the recorded owner slot 0."
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "apple: an unanswered owner query changes nothing"
consistent "owner query failed" "$old_password"
rm "$tmp/owner-query-fail"
touch "$tmp/owner-query-garbage"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "apple: an owner slot that is not a number stops the change"; fi
said "named 'slot zero', which is not a key slot"
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "apple: a garbled owner slot changes nothing"
rm "$tmp/owner-query-garbage"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "apple: the owner's password changes the disk" "$(cat "$tmp/output")"
consistent "owner's password after refusals" "$new_password"
pass "apple: only the owner's slot changes the system disk; another slot's key and an unanswered query change nothing"

# A Mac set up before its boot package recorded slots has no owner slot (4).
# Its disk's only key is the owner's: the change goes through and records the
# new slot. With another key beside it the owner's can't be told, so the change
# is refused, saying how to settle it: record both, or remove the extra key.
use fake apple
fixture ""
touch "$tmp/owner-unrecorded"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "apple: an unrecorded single-key disk changes its password" "$(cat "$tmp/output")"
[[ $(cat "$tmp/slot-record") == "owner=$(opens "$system" "$new_password")" ]] || fail "apple: the owner's new slot is recorded" "$(cat "$tmp/slot-record")"
consistent "no owner slot recorded, one key" "$new_password"
step=$(grep -n 'chpasswd owner' "$tmp/trace" | head -1 | cut -d: -f1)
fixture ""
touch "$tmp/owner-unrecorded"
if attempt "$step" "$old_password" "$new_password" "$new_password"; then fail "apple: the unrecorded change is killed before the accounts"; fi
[[ -e $journal && ! -e $tmp/slot-record ]] || fail "apple: a change killed before the accounts keeps its journal" "$(cat "$tmp/trace")"
attempt 0 "$new_password" || fail "apple: the rerun finishes an unrecorded change" "$(cat "$tmp/output")"
[[ $(cat "$tmp/slot-record") == "owner=$(opens "$system" "$new_password")" ]] || fail "apple: the rerun records the owner's new slot" "$(cat "$tmp/slot-record")"
consistent "no owner slot recorded, interrupted" "$new_password"
pass "apple: with no owner slot recorded, the disk's only key changes and its new slot is recorded, after an interruption too"

fixture
touch "$tmp/owner-unrecorded"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "apple: an unrecorded disk with two keys refuses the change"; fi
said "has keys in slots 0,1, so which one is yours can't be told"
said "record both: sudo omarchy-lifecycle-dispatch luks-slots owner=0 recovery=1"
said "sudo cryptsetup luksKillSlot $system <slot>"
said "The system disk password did not change."
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal && ! -e $tmp/slot-record ]] || fail "apple: an unrecorded two-key disk changes nothing"
"$ROOT/bin/omarchy-lifecycle-dispatch" luks-slots owner=0 recovery=1
: >"$tmp/slot-record"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "apple: once both slots are recorded the change goes through" "$(cat "$tmp/output")"
consistent "slots recorded as the refusal said" "$new_password"
pass "apple: with no owner slot recorded, a disk with another key refuses the change and says how to record or remove it"

fixture ""
touch "$tmp/owner-unrecorded"
export TEST_ENROLL_AT_PROMPT="Confirm new encryption password" TEST_ENROLL_DEVICE=$system
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "apple: a key enrolled during the prompts stops an unrecorded change"; fi
said "changed while you entered the new password"
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal && ! -e $tmp/slot-record ]] || fail "apple: a key enrolled during the prompts changes nothing"
pass "apple: an unrecorded disk that gains a key while the owner types is left alone"

# A slot the boot package could not record keeps the journal: the rerun records it.
use fake apple
fixture
touch "$tmp/record-fail"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "a failed record fails the command"; fi
said "Could not record the new key slot for the boot checks."
[[ -e $journal && $(account owner) == "$new_password" && ! -e $tmp/slot-record ]] || fail "a failed record keeps the journal"
rm "$tmp/record-fail"
attempt 0 "$new_password" || fail "the rerun records the slot" "$(cat "$tmp/output")"
[[ -s $tmp/slot-record ]] || fail "the rerun records the moved key's slot"
consistent "rerun after a failed record" "$new_password"
pass "apple: the change finishes only once the boot package recorded the owner's new slot"

# An installed boot package older than luks-slots could not record the slot, so
# the system disk does not change; a data drive still does.
fixture
mv "$tmp/lifecycle/usr/lib/omarchy/mac-boot/luks-slots" "$tmp/luks-slots.off"
mkdir -p "$tmp/lifecycle/var/lib/pacman/local/omarchy-mac-boot-20260925-2"
if attempt 0 "$old_password" "$new_password" "$new_password"; then fail "an Apple boot package without luks-slots fails the command"; fi
said "which omarchy-mac-boot 20260925-2 does not provide; update omarchy-mac-boot"
said "The system disk password did not change."
! grep -q 'luksChangeKey\|chpasswd' "$tmp/sudo-calls" && [[ ! -e $journal ]] || fail "a boot package without luks-slots changes nothing"
consistent "boot package without luks-slots" "$old_password"
echo "$data" >"$tmp/select"
attempt 0 "$data_password" "$new_password" "$new_password" || fail "a data drive changes without luks-slots" "$(cat "$tmp/output")"
pass "apple: a boot package without luks-slots stops a system disk change before it starts, naming the package"

# A Mac without its boot package at all predates it: nothing checks its slots,
# so the change goes through and records nothing.
fixture
rm -r "$tmp/lifecycle/var/lib/pacman"
attempt 0 "$old_password" "$new_password" "$new_password" || fail "a Mac without the boot package changes its disk password" "$(cat "$tmp/output")"
# Checked as on x86: no slot recorded and no dispatch under sudo.
platform=x86
consistent "no boot package" "$new_password"
platform=apple
! grep -q 'Error:' "$tmp/output" || fail "without the boot package nothing is reported" "$(cat "$tmp/output")"
mv "$tmp/luks-slots.off" "$tmp/lifecycle/usr/lib/omarchy/mac-boot/luks-slots"
pass "apple: a Mac without its boot package changes its disk password and records no slot"

fixture
echo "$data" >"$tmp/select"
attempt 0 "$data_password" "$new_password" "$new_password" || fail "apple: a data drive changes" "$(cat "$tmp/output")"
[[ ! -e $tmp/slot-record && -n $(opens "$data" "$new_password") ]] || fail "apple: a data drive records no slot"
pass "apple: only the system disk's slot is recorded"
