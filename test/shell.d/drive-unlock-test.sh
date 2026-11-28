#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-drive-unlock against a fake LUKS partition: lsblk names it, udisksctl
# accepts or refuses a keyfile, and omarchy-shell records being asked.

unlock="$ROOT/bin/omarchy-drive-unlock"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin" "$test_tmp/home"

cat >"$fake_bin/lsblk" <<'STUB'
#!/bin/bash
case $2 in
  UUID) echo "${TEST_UUID:-5d1e-0f00}" ;;
  LABEL) echo Backup ;;
  SIZE) echo " 1.8T" ;;
esac
STUB

cat >"$fake_bin/udisksctl" <<'STUB'
#!/bin/bash
printf 'udisksctl %s\n' "$*" >>"$TEST_LOG"
[[ -z ${TEST_REFUSE_KEY:-} ]]
STUB

cat >"$fake_bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf 'omarchy-shell %s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$fake_bin"/*

run_unlock() {
  : >"$test_tmp/calls.log"
  TEST_LOG="$test_tmp/calls.log" HOME="$test_tmp/home" PATH="$fake_bin:$PATH" bash "$unlock" /dev/sdz1
}

run_unlock
! grep -q '^udisksctl' "$test_tmp/calls.log" || fail "a drive with no keyfile is not unlocked behind the user's back"
grep -qFx 'omarchy-shell -q omarchy.polkit unlockDrive /dev/sdz1 Backup · 1.8T' "$test_tmp/calls.log" ||
  fail "a drive with no keyfile asks for its password" "$(cat "$test_tmp/calls.log")"
pass "a drive with no keyfile asks for its password"

keyfile="$test_tmp/home/.config/omarchy/drive-keys/5d1e-0f00"
mkdir -p "${keyfile%/*}"
echo secret >"$test_tmp/backup.keyfile"
ln -s "$test_tmp/backup.keyfile" "$keyfile"

run_unlock
grep -qFx "udisksctl unlock --no-user-interaction --block-device /dev/sdz1 --key-file $keyfile" "$test_tmp/calls.log" ||
  fail "a drive with a keyfile is unlocked with it" "$(cat "$test_tmp/calls.log")"
! grep -q '^omarchy-shell' "$test_tmp/calls.log" || fail "a drive its keyfile unlocks does not ask for a password"
pass "a drive with a keyfile unlocks without asking"

TEST_REFUSE_KEY=1 run_unlock
grep -q '^omarchy-shell .* unlockDrive /dev/sdz1 ' "$test_tmp/calls.log" ||
  fail "a refused keyfile falls back to asking for the password" "$(cat "$test_tmp/calls.log")"
pass "a refused keyfile falls back to asking for the password"

# A LUKS1 UUID is free text in the drive's header, so a stranger's stick can
# name any file the user can read.
mkdir -p "$test_tmp/home/.ssh"
echo private >"$test_tmp/home/.ssh/id_ed25519"
TEST_UUID=../../../.ssh/id_ed25519 run_unlock
! grep -q '^udisksctl' "$test_tmp/calls.log" || fail "a drive's UUID cannot name a keyfile outside drive-keys" "$(cat "$test_tmp/calls.log")"
pass "a drive's UUID cannot name a keyfile outside drive-keys"
