#!/bin/bash

# Remove-one path for omarchy-remove-security-fido2 (--one / bare INDEX).
# Keeps PAM; drops exactly one device from the invoking user's authfile line.
# Full wipe (--all) is covered lightly (cancel only) so packages are never touched.
#
# Run from an omarchy checkout (or this overlay's harness):
#   bash test/shell.d/security-fido2-remove-key-test.sh

set -euo pipefail

_here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ -f $_here/base-test.sh ]]; then
  source "$_here/base-test.sh"
else
  # Standalone run from the overlay repo (no omarchy test harness).
  ROOT=$(cd -- "$_here/.." && pwd)
  pass() { printf 'ok - %s\n' "$1"; }
  fail() {
    local description=$1 detail=${2:-}
    [[ -n $detail ]] && printf '%s\n' "$detail" >&2
    printf 'not ok - %s\n' "$description" >&2
    exit 1
  }
fi

remove="$ROOT/bin/omarchy-remove-security-fido2"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
stages="$test_tmp/stages.log"
calls="$test_tmp/calls.log"
authdir="$test_tmp/etc-fido2"
authfile="$authdir/fido2"
remove_copy="$test_tmp/remove.sh"
mkdir -p "$stub_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

[[ -x $remove ]] || fail "remove script is executable" "missing: $remove"
grep -Fq 'remove_one_key' "$remove" || fail "remove script has remove-one"
grep -Fq 'remove_all_fido2' "$remove" || fail "remove script has remove-all"
pass "remove script is present with one+all branches"

occurrences=$(grep -Fxc 'authdir=/etc/fido2' "$remove") || occurrences=0
(( occurrences == 1 )) ||
  fail "the remove script names its FIDO2 directory exactly once" "found $occurrences"
occurrences=$(grep -Fxc 'authfile=/etc/fido2/fido2' "$remove") || occurrences=0
(( occurrences == 1 )) ||
  fail "the remove script names its authfile exactly once" "found $occurrences"
occurrences=$(grep -Fc '/usr/bin/sudo' "$remove") || occurrences=0
(( occurrences >= 1 )) ||
  fail "the remove script invokes sudo by absolute path" "found $occurrences"
grep -Fq 'remove_all_fido2' "$remove" || fail "merged script still has full wipe"
grep -Fq 'remove_one_key' "$remove" || fail "merged script has remove-one"
pass "remove names its paths once, uses absolute sudo, and has one+all branches"

sed -e "s|^authdir=/etc/fido2$|authdir=$authdir|" \
  -e "s|^authfile=/etc/fido2/fido2$|authfile=$authfile|" \
  -e "s|/usr/bin/sudo|$stub_bin/sudo|g" "$remove" >"$remove_copy"
chmod +x "$remove_copy"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

if [[ ${TEST_TMP:-} != /* || ${TEST_AUTHFILE:-} != "$TEST_TMP/etc-fido2/fido2" ]]; then
  reject "$@"
fi

{
  flock 9
  printf 'sudo' >>"$TEST_LOG"
  printf '\t%s' "$@" >>"$TEST_LOG"
  printf '\n' >>"$TEST_LOG"
} 9>"$TEST_TMP/sudo.log.lock"

safe_stage_path() {
  local candidate=$1 prefix="$TEST_AUTHFILE.new." suffix
  [[ $candidate == "$prefix"* ]] || return 1
  suffix=${candidate#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
}

recorded_stage() {
  local candidate=$1
  safe_stage_path "$candidate" || return 1
  [[ -f $candidate && ! -L $candidate ]] || return 1
  /usr/bin/grep -Fxq -- "$candidate" "$TEST_STAGES"
}

cmd=${1:-}
cmd=${cmd#/usr/bin/}

case "$cmd" in
  mktemp)
    (( $# == 2 )) && [[ $2 == "$TEST_AUTHFILE.new.XXXXXX" ]] || reject "$@"
    stage=$(/usr/bin/mktemp -- "$2")
    safe_stage_path "$stage" && [[ -f $stage && ! -L $stage ]] || reject "$@"
    printf '%s\n' "$stage" >>"$TEST_STAGES"
    printf '%s\n' "$stage"
    ;;
  awk)
    (( $# >= 4 )) && [[ $2 == -* ]] || reject "$@"
    last=${*: -1}
    if [[ $last == "$TEST_AUTHFILE" ]] || recorded_stage "$last"; then
      exec /usr/bin/awk "${@:2}"
    fi
    reject "$@"
    ;;
  tee)
    (( $# == 2 )) && recorded_stage "$2" || reject "$@"
    exec /usr/bin/tee "$2"
    ;;
  chmod)
    (( $# == 3 )) && [[ $2 == 644 ]] && recorded_stage "$3" || reject "$@"
    exec /usr/bin/chmod 644 "$3"
    ;;
  mv)
    (( $# == 4 )) && [[ $2 == -Tf && $4 == "$TEST_AUTHFILE" ]] && recorded_stage "$3" || reject "$@"
    exec /usr/bin/mv -Tf -- "$3" "$TEST_AUTHFILE"
    ;;
  rm)
    (( $# == 4 )) && [[ $2 == -f && $3 == -- ]] && recorded_stage "$4" || reject "$@"
    exec /usr/bin/rm -f -- "$4"
    ;;
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/fido2-token" <<'SH'
#!/bin/bash
echo '/dev/hidraw2: vendor=0x096e, product=0x085a (FS ePass FIDO)'
echo '/dev/hidraw3: vendor=0x096e, product=0x085a (FS ePass FIDO)'
SH

# USB port labels for identical product names.
cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash
set -euo pipefail
if [[ ${1:-} == info && ${2:-} == -q && ${3:-} == path && ${4:-} == -- ]]; then
  case ${5:-} in
    /dev/hidraw2)
      echo '/devices/pci0000:00/0000:00:14.0/usb3/3-2/3-2:1.0/hidraw/hidraw2'
      ;;
    /dev/hidraw3)
      echo '/devices/pci0000:00/0000:00:14.0/usb3/3-3/3-3:1.0/hidraw/hidraw3'
      ;;
  esac
  exit 0
fi
if [[ ${1:-} == info && ${2:-} == -q && ${3:-} == property && ${4:-} == -- ]]; then
  case ${5:-} in
    /dev/hidraw2 | /dev/hidraw3)
      echo 'ID_FIDO_TOKEN=1'
      ;;
  esac
  exit 0
fi
exit 0
SH

# Cred 1 on hidraw2, cred 2 on hidraw3 (by keyhandle prefix in the assert stub).
cat >"$stub_bin/fido2-assert" <<'SH'
#!/bin/bash
set -euo pipefail
path=${*: -1}
# stdin: cdh, rp, keyhandle
mapfile -t lines
kh=${lines[2]:-}
case "$path:$kh" in
  /dev/hidraw2:cred1-handle*)
    exit 0
    ;;
  /dev/hidraw3:cred2-handle*)
    printf 'fido2-assert: fido_dev_get_assert: FIDO_ERR_USER_PRESENCE_REQUIRED\n' >&2
    exit 1
    ;;
  *)
    printf 'fido2-assert: fido_dev_get_assert: FIDO_ERR_NO_CREDENTIALS\n' >&2
    exit 1
    ;;
esac
SH

chmod +x "$stub_bin/sudo" "$stub_bin/fido2-token" "$stub_bin/fido2-assert" "$stub_bin/udevadm"

user=$(/usr/bin/id -un)

reset_run() {
  : >"$calls"
  : >"$stages"
  rm -rf "$authdir"
  mkdir -p "$authdir"
}

two_key_authfile() {
  printf '%s\n' \
    "$user:cred1-handle,pubkey1,es256,+presence:cred2-handle,pubkey2,es256,+presence" \
    >"$authfile"
}

invoke_remove_one() {
  local index=$1
  TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
    PATH="$stub_bin:$PATH" \
    bash "$remove_copy" --one "$index" <<<"yes" >/dev/null
}

# Top-level cancel leaves everything alone.
# OMARCHY_FIDO_REMOVE_MENU forces the chooser without a real TTY (here-strings).
reset_run
two_key_authfile
before=$(<"$authfile")
TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
  OMARCHY_FIDO_REMOVE_MENU=1 PATH="$stub_bin:$PATH" \
  bash "$remove_copy" <<<"q" >/dev/null
[[ $(<"$authfile") == "$before" ]] || fail "top-level cancel must not change the authfile"
pass "top-level menu cancel leaves registration untouched"

# Choose '1' then cancel the key pick; listing must show plugged USB ports.
reset_run
two_key_authfile
before=$(<"$authfile")
list_out=$(TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
  OMARCHY_FIDO_REMOVE_MENU=1 PATH="$stub_bin:$PATH" \
  bash "$remove_copy" <<<"$({
    echo 1
    echo q
  })" 2>&1) || true
[[ $(<"$authfile") == "$before" ]] || fail "key-pick cancel must not change the authfile"
[[ ! -s $stages ]] || fail "key-pick cancel stages nothing"
[[ $list_out == *"plugged in — FS ePass FIDO, USB 3-2"* ]] ||
  fail "key 1 should show plugged USB 3-2" "$list_out"
[[ $list_out == *"plugged in — FS ePass FIDO, USB 3-3"* ]] ||
  fail "key 2 should show plugged USB 3-3" "$list_out"
[[ $list_out != *'credential cred1'* ]] ||
  fail "plugged keys should not fall back to opaque credential labels" "$list_out"
pass "menu → remove one lists plugged keys by USB port, cancel leaves file untouched"

# Choose 'a' then decline wipe confirmation (must not call pkg drop).
reset_run
two_key_authfile
before=$(<"$authfile")
out=$(TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
  OMARCHY_FIDO_REMOVE_MENU=1 PATH="$stub_bin:$PATH" \
  bash "$remove_copy" <<<"$({
    echo a
    echo no
  })" 2>&1) || true
[[ $(<"$authfile") == "$before" ]] || fail "declined wipe must not change the authfile"
[[ $out == *Cancelled* ]] || fail "declined wipe should say Cancelled" "$out"
pass "menu → remove all → decline cancels without wiping"

# Refuses when only one key remains.
reset_run
printf '%s\n' "$user:cred1-handle,pubkey1,es256,+presence" >"$authfile"
if TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
  PATH="$stub_bin:$PATH" \
  bash "$remove_copy" --one 1 <<<"yes" >/dev/null 2>&1; then
  fail "removing the last key must fail"
fi
[[ $(<"$authfile") == "$user:cred1-handle,pubkey1,es256,+presence" ]] ||
  fail "last-key refusal must not change the authfile"
pass "refuses to remove the last remaining key"

# Drop key 1; key 2 remains; other users untouched.
reset_run
two_key_authfile
printf '%s\n' "otheruser:other-handle,other-key,es256" >>"$authfile"
invoke_remove_one 1
[[ $(head -n 1 "$authfile") == "$user:cred2-handle,pubkey2,es256,+presence" ]] ||
  fail "removing key 1 leaves only key 2" "got: $(head -n 1 "$authfile")"
[[ $(tail -n 1 "$authfile") == "otheruser:other-handle,other-key,es256" ]] ||
  fail "other users' lines stay intact" "got: $(tail -n 1 "$authfile")"
grep -Fq $'sudo\t/usr/bin/mv\t-Tf\t' "$calls" ||
  fail "successful remove publishes atomically" "$(cat "$calls")"
pass "removes one credential and publishes the rewritten authfile atomically"

# Drop key 2 instead (bare index path, same as legacy remove-key).
reset_run
two_key_authfile
TEST_TMP="$test_tmp" TEST_AUTHFILE="$authfile" TEST_LOG="$calls" TEST_STAGES="$stages" \
  PATH="$stub_bin:$PATH" \
  bash "$remove_copy" 2 <<<"yes" >/dev/null
[[ $(<"$authfile") == "$user:cred1-handle,pubkey1,es256,+presence" ]] ||
  fail "removing key 2 leaves only key 1" "got: $(<"$authfile")"
pass "bare index removes the second credential as well"
