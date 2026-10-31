#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for script in omarchy-user-add omarchy-user-remove omarchy-user-groups omarchy-user-privileges omarchy-user-functions; do
  bash -n "$ROOT/bin/$script" || fail "$script parses"
done
pass "omarchy user scripts parse"

unset SUDO_USER
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
export FAKE_LOG="$test_tmp/sudo.log"
export FAKE_STATE="$test_tmp/state"
mkdir -p "$FAKE_STATE"

# Stubs read the fixture: USERS as name:uid:primary:supplementary-groups and
# FAKE_GROUPS as name:members. sudo only records what the script would have run.
cat >"$mock_bin/id" <<'STUB'
#!/bin/bash
source "$FAKE_DB"
flag=""
if [[ ${1:-} == -* ]]; then
  flag=$1
  shift
fi
name=${1:-$FAKE_CURRENT}
rec=""
for entry in "${USERS[@]}"; do
  [[ ${entry%%:*} == "$name" ]] && rec=$entry
done
[[ ! -e $FAKE_STATE/deleted-$name ]] || exit 1
[[ -n $rec ]] || { echo "id: '$name': no such user" >&2; exit 1; }
IFS=: read -r _ uid primary groups <<<"$rec"
case $flag in
  -u) echo "$uid" ;;
  -un) echo "$name" ;;
  -gn) echo "$primary" ;;
  -nG) echo "$primary $groups" ;;
  "") echo "uid=$uid($name)" ;;
esac
STUB

cat >"$mock_bin/getent" <<'STUB'
#!/bin/bash
source "$FAKE_DB"
case ${1:-} in
  passwd)
    found=0
    for entry in "${USERS[@]}"; do
      IFS=: read -r name uid _ _ <<<"$entry"
      if [[ -z ${2:-} || $2 == "$name" || $2 == "$uid" ]]; then
        echo "$name:x:$uid:$uid::/home/$name:/bin/bash"
        found=1
      fi
    done
    ((found)) || exit 2
    exit 0
    ;;
  group)
    for entry in "${FAKE_GROUPS[@]}"; do
      IFS=: read -r name members <<<"$entry"
      [[ $name == "${2:-}" ]] && { echo "$name:x:1:$members"; exit 0; }
    done
    exit 2
    ;;
esac
exit 2
STUB

cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
source "$FAKE_DB"
case $1 in
  test)
    # All sudoers reads stay inside the fixture, including dangling symlinks.
    /usr/bin/test "$2" "$FAKE_STATE/${3##*/}"
    ;;
  -l)
    if [[ ${FAKE_SUDO_ERROR:-0} == 1 ]]; then
      echo 'sudo: unable to read policy' >&2
      exit 1
    elif [[ ${FAKE_FULL_SUDO:-} == "$3" ]]; then
      printf 'User %s may run the following commands on host:\n    (ALL : ALL) ALL\n' "$3"
    elif [[ ${FAKE_RESTRICTED_SUDO:-} == "$3" ]]; then
      printf 'User %s may run the following commands on host:\n    (root) /usr/bin/true\n' "$3"
    else
      echo "User $3 is not allowed to run sudo on host."
      exit 1
    fi
    ;;
  userdel)
    echo "$*" >>"$FAKE_LOG"
    touch "$FAKE_STATE/deleted-${*: -1}"
    ;;
  *) echo "$*" >>"$FAKE_LOG" ;;
esac
STUB
chmod +x "$mock_bin"/*

fixture_admins="$test_tmp/admins.sh"
cat >"$fixture_admins" <<'FIXTURE'
USERS=("alice:1000:alice:wheel video" "bob:1001:bob:wheel" "carol:1002:carol:wheel-helper")
FAKE_GROUPS=("wheel:alice,bob" "video:alice" "audio:" "input:" "wheel-helper:carol")
FAKE_CURRENT=alice
FIXTURE

fixture_one_admin="$test_tmp/one-admin.sh"
cat >"$fixture_one_admin" <<'FIXTURE'
USERS=("alice:1000:alice:video" "bob:1001:bob:wheel")
FAKE_GROUPS=("wheel:bob" "video:alice" "audio:")
FAKE_CURRENT=alice
FIXTURE

# Runs a user script as the given caller fixture, stdin closed so it never
# goes interactive. Prints combined output and returns the script's status.
run_as() {
  local fixture=$1
  shift
  : >"$FAKE_LOG"
  rm -f -- "$FAKE_STATE"/deleted-*
  PATH="$mock_bin:$PATH" FAKE_DB="$fixture" bash "$ROOT/bin/$1" "${@:2}" </dev/null 2>&1
}

expect_refused() {
  local description=$1 fixture=$2 expected=$3 out status=0
  shift 3
  out=$(run_as "$fixture" "$@") || status=$?
  [[ $status -ne 0 && $out == *"$expected"* && ! -s $FAKE_LOG ]] ||
    fail "$description" "status=$status output: $out sudo: $(cat "$FAKE_LOG")"
  pass "$description"
}

expect_applied() {
  local description=$1 fixture=$2 expected=$3 out status=0
  shift 3
  out=$(run_as "$fixture" "$@") || status=$?
  [[ $status -eq 0 ]] && grep -qF -- "$expected" "$FAKE_LOG" ||
    fail "$description" "status=$status output: $out sudo: $(cat "$FAKE_LOG")"
  pass "$description"
}

expect_refused "groups refuses to drop wheel from the caller" "$fixture_admins" \
  "refusing to remove wheel from your own account" omarchy-user-groups alice --remove wheel --yes

expect_applied "groups drops wheel from another admin when another login admin remains" "$fixture_admins" \
  "usermod -G video -- bob" omarchy-user-groups bob --add video --remove wheel --yes

expect_refused "groups refuses to drop wheel from the last login admin" "$fixture_one_admin" \
  "refusing to remove the last administrator" omarchy-user-groups bob --remove wheel --yes

expect_applied "groups leaves similarly named groups alone" "$fixture_admins" \
  "usermod -G video,wheel-helper -- carol" omarchy-user-groups carol --set video,wheel-helper --yes

expect_applied "groups allows unrelated edits to the caller's own account" "$fixture_one_admin" \
  "usermod -G video,audio -- alice" omarchy-user-groups alice --set video,audio --yes

expect_refused "privileges refuses to remove the caller's own sudo" "$fixture_admins" \
  "refusing to remove wheel from your own account" omarchy-user-privileges alice --level none --yes

expect_refused "privileges refuses to remove the last login admin's sudo" "$fixture_one_admin" \
  "refusing to remove the last administrator" omarchy-user-privileges bob --level none --yes

expect_applied "privileges removes sudo from another admin" "$fixture_admins" \
  "gpasswd -d bob wheel" omarchy-user-privileges bob --level none --yes

expect_applied "privileges grants password sudo" "$fixture_one_admin" \
  "gpasswd -a alice wheel" omarchy-user-privileges alice --level password --yes

expect_applied "user add creates an account with no groups by default" "$fixture_admins" \
  "useradd -m -s" omarchy-user-add dave --skip-password --yes

if [[ $(cat "$FAKE_LOG") == *usermod* ]]; then
  fail "user add skips usermod when no groups are given" "$(cat "$FAKE_LOG")"
fi
pass "user add skips usermod when no groups are given"

expect_applied "user add puts the new account in the requested groups" "$fixture_admins" \
  "usermod -aG video dave" omarchy-user-add dave --groups video --skip-password --yes

expect_refused "user remove refuses the caller's own account" "$fixture_admins" \
  "refusing to remove your own account" omarchy-user-remove alice --keep-home --yes

expect_refused "user remove refuses to continue without confirmation" "$fixture_admins" \
  "refusing to continue without confirmation" omarchy-user-remove bob --keep-home

# Safety-check coverage: system accounts and self-removal by numeric UID are
# refused before any privileged command runs.
fixture_remove_safety="$test_tmp/remove-safety.sh"
cat >"$fixture_remove_safety" <<'FIXTURE'
USERS=("alice:1000:alice:wheel video" "sysacct:500:sysacct:")
FAKE_GROUPS=("wheel:alice" "video:alice" "audio:")
FAKE_CURRENT=alice
FIXTURE

expect_refused "user remove refuses system accounts" "$fixture_remove_safety" \
  "system account" omarchy-user-remove sysacct --keep-home --yes

expect_refused "user remove blocks removing yourself by numeric UID" "$fixture_remove_safety" \
  "your own account" omarchy-user-remove 1000 --keep-home --yes


fixture_primary="$test_tmp/primary-wheel.sh"
cat >"$fixture_primary" <<'FIXTURE'
USERS=("alice:1000:alice:video" "bob:1001:bob:wheel" "carol:1002:wheel:video")
FAKE_GROUPS=("wheel:bob" "video:alice,carol" "audio:")
FAKE_CURRENT=alice
FIXTURE

expect_applied "primary wheel member counts as another administrator" "$fixture_primary" \
  "gpasswd -d bob wheel" omarchy-user-privileges bob --level none --yes

expect_applied "unrelated supplementary edit leaves primary wheel untouched" "$fixture_primary" \
  "usermod -G video,audio -- carol" omarchy-user-groups carol --set video,audio --yes

expect_refused "privileges cannot remove primary wheel with gpasswd" "$fixture_primary" \
  "wheel is the primary group" omarchy-user-privileges carol --level none --yes

expect_refused "removing the last administrator is blocked before session termination" "$fixture_one_admin" \
  "refusing to remove the last administrator" omarchy-user-remove bob --keep-home --yes

expect_applied "removing an administrator succeeds when primary wheel admin remains" "$fixture_primary" \
  "userdel -- bob" omarchy-user-remove bob --keep-home --yes

expect_refused "groups rejects numeric UIDs" "$fixture_admins" \
  "use the login name, not a UID" omarchy-user-groups 1001 --add video --yes

expect_refused "privileges rejects numeric UIDs" "$fixture_admins" \
  "use the login name, not a UID" omarchy-user-privileges 1001 --level password --yes

expect_refused "remove rejects another account's numeric UID before terminating it" "$fixture_admins" \
  "use the login name, not a UID" omarchy-user-remove 1001 --keep-home --yes

expect_refused "groups refuses system accounts" "$fixture_remove_safety" \
  "system account" omarchy-user-groups sysacct --add video --yes

expect_refused "privileges refuses system accounts when granting sudo" "$fixture_remove_safety" \
  "system account" omarchy-user-privileges sysacct --level password --yes

expect_refused "privileges refuses system accounts when removing sudo" "$fixture_remove_safety" \
  "system account" omarchy-user-privileges sysacct --level none --yes

expect_applied "explicit empty groups creates a plain user" "$fixture_admins" \
  "useradd -m -s" omarchy-user-add dave --groups '' --skip-password --yes
[[ $(cat "$FAKE_LOG") != *usermod* ]] || fail "empty groups do not add supplementary membership"
pass "empty groups do not add supplementary membership"

expect_applied "explicit empty set clears supplementary groups" "$fixture_one_admin" \
  "usermod -G  -- alice" omarchy-user-groups alice --set '' --yes

expect_refused "empty set cannot be combined with add" "$fixture_one_admin" \
  "combine --add/--remove" omarchy-user-groups alice --set '' --add audio --yes

expect_refused "empty set still protects the caller's wheel membership" "$fixture_admins" \
  "refusing to remove wheel from your own account" omarchy-user-groups alice --set '' --yes

printf 'dave ALL=(ALL) ALL\n' >"$FAKE_STATE/dave"
expect_refused "stale sudoers file blocks plain account creation" "$fixture_admins" \
  "/etc/sudoers.d/dave already exists" omarchy-user-add dave --skip-password --yes
rm -- "$FAKE_STATE/dave"
ln -s "$FAKE_STATE/missing" "$FAKE_STATE/dave"
expect_refused "dangling sudoers symlink blocks account creation" "$fixture_admins" \
  "/etc/sudoers.d/dave already exists" omarchy-user-add dave --skip-password --yes
rm -- "$FAKE_STATE/dave"

fixture_sudo_admin="$test_tmp/sudo-admin.sh"
cat >"$fixture_sudo_admin" <<'FIXTURE'
USERS=("alice:1000:alice:" "bob:1001:bob:wheel")
FAKE_GROUPS=("wheel:bob")
FAKE_CURRENT=alice
FAKE_FULL_SUDO=alice
FIXTURE
expect_applied "unrestricted sudo counts as an alternative administrator" "$fixture_sudo_admin" \
  "gpasswd -d bob wheel" omarchy-user-privileges bob --level none --yes
expect_applied "account removal accepts an alternative unrestricted sudo admin" "$fixture_sudo_admin" \
  "userdel -- bob" omarchy-user-remove bob --keep-home --yes

fixture_only_sudo="$test_tmp/only-sudo.sh"
cat >"$fixture_only_sudo" <<'FIXTURE'
USERS=("alice:1000:alice:" "bob:1001:bob:")
FAKE_GROUPS=("wheel:")
FAKE_CURRENT=alice
FAKE_FULL_SUDO=bob
FIXTURE
expect_refused "account removal protects the last administrator with only sudo" "$fixture_only_sudo" \
  "refusing to remove the last administrator" omarchy-user-remove bob --keep-home --yes

fixture_restricted="$test_tmp/restricted-sudo.sh"
cat >"$fixture_restricted" <<'FIXTURE'
USERS=("alice:1000:alice:" "bob:1001:bob:wheel")
FAKE_GROUPS=("wheel:bob")
FAKE_CURRENT=alice
FAKE_RESTRICTED_SUDO=alice
FIXTURE
expect_refused "command-limited sudo does not count as another administrator" "$fixture_restricted" \
  "refusing to remove the last administrator" omarchy-user-privileges bob --level none --yes

check_report() {
  local description=$1 fixture=$2 expected=$3 out
  out=$(run_as "$fixture" omarchy-user-privileges bob --level none --yes) || fail "$description" "$out"
  [[ $out == *"$expected"* ]] || fail "$description" "$out"
  if [[ $expected != "No sudo access remains" && $out == *"No sudo access remains"* ]]; then
    fail "$description must not confirm revocation" "$out"
  fi
  pass "$description"
}

fixture_external="$test_tmp/external-sudo.sh"
cat >"$fixture_external" <<'FIXTURE'
USERS=("alice:1000:alice:wheel" "bob:1001:bob:wheel")
FAKE_GROUPS=("wheel:alice,bob")
FAKE_CURRENT=alice
FAKE_FULL_SUDO=bob
FIXTURE
check_report "removing wheel warns about an independent sudo grant" "$fixture_external" "still has effective sudo privileges"
check_report "none also checks sudo when the account is already outside wheel" "$fixture_only_sudo" "still has effective sudo privileges"
check_report "an explicit policy denial confirms no sudo remains" "$fixture_admins" "No sudo access remains"

fixture_error="$test_tmp/sudo-error.sh"
cat >"$fixture_error" <<'FIXTURE'
USERS=("alice:1000:alice:wheel" "bob:1001:bob:wheel")
FAKE_GROUPS=("wheel:alice,bob")
FAKE_CURRENT=alice
FAKE_SUDO_ERROR=1
FIXTURE
check_report "a failed sudo query reports uncertainty" "$fixture_error" "Could not verify remaining sudo access"
