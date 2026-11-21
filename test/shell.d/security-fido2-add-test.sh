#!/bin/bash

# Additional-device offer for omarchy-setup-security-fido2 (else branch).
#
# First-registration staging stays in security-fido2-test.sh. That suite still
# treats an existing authfile as leave-alone: it closes stdin, the prompt's
# default is No, and the setup exits 0 without staging.
#
# The add branch calls sudo by absolute path (/usr/bin/sudo …), so PATH
# stubbing cannot intercept it. This suite rewrites that operand in a scratch
# copy — the same seam as the absolute-path hardening tests — and fails if the
# absolute path is not named in the setup at least once.
#
# Run from an omarchy checkout:
#   bash test/shell.d/security-fido2-add-test.sh

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fido2"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
stages="$test_tmp/stages.log"
calls="$test_tmp/calls.log"
pamu_targets="$test_tmp/pamu-targets.log"
revoked="$test_tmp/revoked.log"
second_credential="second-handle,second-key,es256"
authdir="$test_tmp/etc-fido2"
authfile="$authdir/fido2"
setup_copy="$test_tmp/setup.sh"
mkdir -p "$stub_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

occurrences=$(grep -Fxc 'authdir=/etc/fido2' "$setup") || occurrences=0
(( occurrences == 1 )) ||
  fail "the setup names its FIDO2 directory exactly once" "found $occurrences occurrences"
occurrences=$(grep -Fxc 'authfile=/etc/fido2/fido2' "$setup") || occurrences=0
(( occurrences == 1 )) ||
  fail "the setup names its authfile exactly once" "found $occurrences occurrences"
occurrences=$(grep -Fc '/usr/bin/sudo' "$setup") || occurrences=0
(( occurrences >= 1 )) ||
  fail "the add branch invokes sudo by absolute path" "found $occurrences occurrences"
pass "setup names its FIDO2 paths once each, and the add branch uses absolute sudo"

# Retarget auth paths and stand the absolute sudo operand on the whitelist stub.
sed -e "s|^authdir=/etc/fido2$|authdir=$authdir|" \
  -e "s|^authfile=/etc/fido2/fido2$|authfile=$authfile|" \
  -e "s|/usr/bin/sudo|$stub_bin/sudo|g" "$setup" >"$setup_copy"

# Whitelist only the add branch's privileged protocol, plus the bare-sudo PAM
# and verification calls that run after a successful publish. Log lines are
# serialized with flock so the concurrent awk|tee pipeline cannot interleave.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

if [[ ${TEST_TMP:-} != /* || ${TEST_AUTHDIR:-} != "$TEST_TMP/etc-fido2" || ${TEST_AUTHFILE:-} != "$TEST_AUTHDIR/fido2" || ${TEST_STAGES:-} != "$TEST_TMP/stages.log" || ${TEST_LOG:-} != "$TEST_TMP/calls.log" ]]; then
  reject "$@"
fi

{
  flock 9
  printf 'sudo' >>"$TEST_LOG"
  printf '\t%s' "$@" >>"$TEST_LOG"
  printf '\n' >>"$TEST_LOG"
} 9>"$TEST_TMP/sudo.log.lock"

safe_stage_path() {
  local candidate=$1
  local prefix="$TEST_AUTHFILE.new."
  local suffix

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

# Production add uses /usr/bin/<cmd>; PAM/verify still use bare names via PATH.
cmd=${1:-}
cmd=${cmd#/usr/bin/}

case "$cmd" in
  mktemp)
    if (( $# != 2 )) || [[ $2 != "$TEST_AUTHFILE.new.XXXXXX" ]]; then
      reject "$@"
    fi

    stage=$(/usr/bin/mktemp -- "$2")
    if ! safe_stage_path "$stage" || [[ ! -f $stage || -L $stage ]]; then
      reject "$@"
    fi

    printf '%s\n' "$stage" >>"$TEST_STAGES"
    printf '%s\n' "$stage"
    ;;
  awk)
    # Rewrite: … -v user=… -v cred=… '<program>' "$authfile"
    # Validate: … -F: -v user=… '<program>' "$stage"
    if (( $# < 4 )) || [[ $2 != -* ]]; then
      reject "$@"
    fi

    last=${*: -1}
    if [[ $last == "$TEST_AUTHFILE" ]] || recorded_stage "$last"; then
      exec /usr/bin/awk "${@:2}"
    fi
    reject "$@"
    ;;
  tee)
    if (( $# == 2 )) && recorded_stage "$2"; then
      exec /usr/bin/tee "$2"
    elif (( $# == 2 )) && [[ $2 == "/etc/pam.d/polkit-1" ]]; then
      /usr/bin/cat >/dev/null
    else
      reject "$@"
    fi
    ;;
  chmod)
    if (( $# != 3 )) || [[ $2 != "644" ]] || ! recorded_stage "$3"; then
      reject "$@"
    fi
    exec /usr/bin/chmod 644 "$3"
    ;;
  mv)
    if (( $# != 4 )) || [[ $2 != "-Tf" || $4 != "$TEST_AUTHFILE" ]] || ! recorded_stage "$3"; then
      reject "$@"
    fi
    exec /usr/bin/mv -Tf -- "$3" "$TEST_AUTHFILE"
    ;;
  rm)
    if (( $# != 4 )) || [[ $2 != "-f" || $3 != "--" ]] || ! recorded_stage "$4"; then
      reject "$@"
    fi
    exec /usr/bin/rm -f -- "$4"
    ;;
  sed)
    # Same no-op PAM whitelist as security-fido2-test.sh: never touch the host.
    if (( $# != 4 )) || [[ $2 != "-i" ]]; then
      reject "$@"
    fi

    if [[ $3 == "1i auth    sufficient pam_u2f.so cue authfile=/etc/fido2/fido2" && $4 == "/etc/pam.d/sudo" ]]; then
      exit 0
    elif [[ $3 == "1i auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2" && $4 == "/etc/pam.d/polkit-1" ]]; then
      exit 0
    else
      reject "$@"
    fi
    ;;
  echo)
    if (( $# != 2 )) || [[ $2 != "FIDO2 authentication test successful" ]]; then
      reject "$@"
    fi
    ;;
  setfacl)
    # Multi-device isolation: drop/restore the invoking user's ACL on sibling
    # hidraw nodes so pamu2fcfg can only open the target key.
    if (( $# == 5 )) && [[ $2 == "-x" && $3 == u:* && $4 == "--" && $5 =~ ^/dev/hidraw[0-9]+$ ]]; then
      printf '%s\n' "$5" >>"$TEST_REVOKED"
      exit 0
    fi
    if (( $# == 5 )) && [[ $2 == "-m" && $3 == u:*:rw- && $4 == "--" && $5 =~ ^/dev/hidraw[0-9]+$ ]]; then
      if [[ -f $TEST_REVOKED ]]; then
        /usr/bin/grep -Fxv -- "$5" "$TEST_REVOKED" >"$TEST_REVOKED.tmp" || true
        /usr/bin/mv -f -- "$TEST_REVOKED.tmp" "$TEST_REVOKED"
      fi
      exit 0
    fi
    reject "$@"
    ;;
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/fido2-token" <<'SH'
#!/bin/bash

# Default: one key. TEST_FIDO_COUNT=2 lists an older (already registered) then
# a newer (unregistered) hidraw path.
case ${TEST_FIDO_COUNT:-1} in
  2)
    echo '/dev/hidraw8: vendor=0x096e, product=0x085a (FS ePass FIDO)'
    echo '/dev/hidraw9: vendor=0x096e, product=0x085a (FS ePass FIDO)'
    ;;
  *)
    echo '/dev/hidraw0: vendor=0x1050, product=0x0407 (Yubico YubiKey)'
    ;;
esac
SH

# Check-only asserts: hidraw8 already holds authfile creds; hidraw9 (and the
# single-device hidraw0) do not — so add skips registered sticks.
cat >"$stub_bin/fido2-assert" <<'SH'
#!/bin/bash

set -euo pipefail

path=${*: -1}

case "$path" in
  /dev/hidraw8)
    printf 'fido2-assert: fido_dev_get_assert: FIDO_ERR_USER_PRESENCE_REQUIRED\n' >&2
    exit 1
    ;;
  *)
    printf 'fido2-assert: fido_dev_get_assert: FIDO_ERR_NO_CREDENTIALS\n' >&2
    exit 1
    ;;
esac
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
SH

# Add captures with pamu2fcfg --nouser into a command substitution (a pipe),
# never a caller-owned named file.
cat >"$stub_bin/pamu2fcfg" <<'SH'
#!/bin/bash

set -euo pipefail

target=$(readlink /proc/self/fd/1)
printf '%s\n' "$target" >>"$TEST_PAMU_TARGETS"
[[ $target == pipe:* ]] || exit 96

if [[ ${1:-} != "--nouser" ]]; then
  exit 95
fi

# Two keys: succeed only when the older path is revoked and the newer is not —
# i.e. pamu2fcfg is isolated onto /dev/hidraw9 (newest-first).
if [[ ${TEST_FIDO_COUNT:-1} == 2 ]]; then
  if [[ -f ${TEST_REVOKED:-} ]] &&
    /usr/bin/grep -Fxq /dev/hidraw8 "$TEST_REVOKED" &&
    ! /usr/bin/grep -Fxq /dev/hidraw9 "$TEST_REVOKED"; then
    printf ':%s\n' "$TEST_SECOND_CREDENTIAL"
    exit 0
  fi
  printf 'error: fido_dev_make_cred (58) FIDO_ERR_ACTION_TIMEOUT\n' >&2
  exit 58
fi

case "$TEST_PAMU_MODE" in
  # Real pamu2fcfg --nouser always prefixes the credential with ':'.
  success)
    printf ':%s\n' "$TEST_SECOND_CREDENTIAL"
    ;;
  fail)
    printf ':%s\n' "$TEST_SECOND_CREDENTIAL"
    exit 23
    ;;
  empty)
    exit 0
    ;;
  multiline)
    printf ':%s\n' "$TEST_SECOND_CREDENTIAL"
    printf ':extra-handle,extra-key,es256\n'
    ;;
  colon)
    # Leading ':' is normal; an internal ':' must still be rejected.
    printf ':bad:handle,second-key,es256\n'
    ;;
  *)
    exit 95
    ;;
esac
SH

chmod +x "$stub_bin/sudo" "$stub_bin/fido2-token" "$stub_bin/fido2-assert" \
  "$stub_bin/omarchy-pkg-add" "$stub_bin/pamu2fcfg"

reset_run() {
  : >"$calls"
  : >"$stages"
  : >"$pamu_targets"
  : >"$revoked"
  rm -rf "$authdir"
}

# Every case passes an explicit prompt answer so nothing depends on a TTY.
invoke_setup() {
  local answer="$1"
  local pamu_mode="${2:-success}"
  local fido_count="${3:-1}"

  TEST_AUTHDIR="$authdir" TEST_AUTHFILE="$authfile" \
    TEST_SECOND_CREDENTIAL="$second_credential" \
    TEST_LOG="$calls" TEST_PAMU_MODE="$pamu_mode" \
    TEST_PAMU_TARGETS="$pamu_targets" TEST_STAGES="$stages" TEST_TMP="$test_tmp" \
    TEST_REVOKED="$revoked" TEST_FIDO_COUNT="$fido_count" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$setup_copy" <<<"$answer" >/dev/null
}

run_setup() {
  invoke_setup "$1" "${2:-success}" "${3:-1}" ||
    fail "FIDO2 setup adds a device that answers pamu2fcfg --nouser" "sudo calls:
$(cat "$calls")"
}

single_stage() {
  local count

  count=$(wc -l <"$stages")
  (( count == 1 )) || fail "setup creates exactly one privileged stage" "got $count stages"
  head -n 1 "$stages"
}

assert_pipe_target() {
  local count target

  count=$(wc -l <"$pamu_targets")
  (( count == 1 )) || fail "setup invokes pamu2fcfg exactly once" "got $count invocations"
  target=$(head -n 1 "$pamu_targets")
  [[ $target == pipe:* ]] ||
    fail "pamu2fcfg writes only to a pipe, never a caller-owned named file" "got: $target"
}

# Fixtures use the invoking user: the add branch appends only that mapping.
existing_authfile() {
  local user
  user=$(/usr/bin/id -un)
  printf '%s\n' "$user:credential-handle,public-key,es256,+presence" >"$authfile"
}

assert_unchanged_single_device() {
  local user
  user=$(/usr/bin/id -un)
  [[ $(<"$authfile") == "$user:credential-handle,public-key,es256,+presence" ]] ||
    fail "$1" "got: $(<"$authfile")"
}

# --- decline / default No: no privileged work, authfile byte-identical -------

reset_run
mkdir -p "$authdir"
existing_authfile
invoke_setup n
assert_unchanged_single_device "a declined offer leaves the authfile alone"
[[ ! -s $stages && ! -s $pamu_targets && ! -s $calls ]] ||
  fail "a declined offer runs no privileged protocol" "calls:
$(cat "$calls")"
pass "a declined offer leaves the existing registration untouched"

reset_run
mkdir -p "$authdir"
existing_authfile
invoke_setup ""
assert_unchanged_single_device "an empty answer defaults to No"
[[ ! -s $stages && ! -s $pamu_targets && ! -s $calls ]] ||
  fail "an empty answer runs no privileged protocol" "calls:
$(cat "$calls")"
pass "an empty answer defaults to No and registers nothing"

# --- happy path: append to this user only, publish through the stage protocol

reset_run
mkdir -p "$authdir"
existing_authfile
printf '%s\n' "otheruser:other-handle,other-key,es256" >>"$authfile"
run_setup y
stage_path=$(single_stage)
assert_pipe_target

grep -Fq $'sudo\t/usr/bin/mktemp\t'"$authfile.new.XXXXXX" "$calls" ||
  fail "the add asks root to create a unique sibling stage" "$(cat "$calls")"
grep -Fq $'sudo\t/usr/bin/awk\t' "$calls" ||
  fail "the add rewrites the authfile through privileged awk" "$(cat "$calls")"
grep -Fxq $'sudo\t/usr/bin/tee\t'"$stage_path" "$calls" ||
  fail "the rewritten mapping is written into the exact privileged stage" "$(cat "$calls")"
grep -Fxq $'sudo\t/usr/bin/chmod\t644\t'"$stage_path" "$calls" ||
  fail "the completed stage is made PAM-readable" "$(cat "$calls")"
grep -Fxq $'sudo\t/usr/bin/mv\t-Tf\t'"$stage_path"$'\t'"$authfile" "$calls" ||
  fail "the stage is published atomically" "$(cat "$calls")"
grep -Fq $'sudo\techo\tFIDO2 authentication test successful' "$calls" ||
  fail "a successful add still runs the sudo verification" "$(cat "$calls")"

user=$(/usr/bin/id -un)
expected="$user:credential-handle,public-key,es256,+presence:$second_credential"
[[ $(head -n 1 "$authfile") == "$expected" ]] ||
  fail "the published authfile appends the new device to the user's line" "got: $(head -n 1 "$authfile")"
[[ $(tail -n 1 "$authfile") == "otheruser:other-handle,other-key,es256" ]] ||
  fail "the published authfile leaves other users' lines alone" "got: $(tail -n 1 "$authfile")"
[[ $(stat -c %a "$authfile") == "644" ]] ||
  fail "the published authfile is mode 644" "got: $(stat -c %a "$authfile")"
[[ ! -e $stage_path ]] || fail "the stage is gone after publication" "left behind: $stage_path"
pass "an accepted offer appends the device to the user's line and publishes atomically"

# Accept Y the same as y (the prompt documents [y/N]).
reset_run
mkdir -p "$authdir"
existing_authfile
run_setup Y
user=$(/usr/bin/id -un)
[[ $(<"$authfile") == "$user:credential-handle,public-key,es256,+presence:$second_credential" ]] ||
  fail "answering Y appends the new device" "got: $(<"$authfile")"
pass "answering Y accepts the add offer"

# --- refuse to invent a mapping; refuse ambiguous duplicates ------------------

reset_run
mkdir -p "$authdir"
printf '%s\n' "otheruser:other-handle,other-key,es256" >"$authfile"
if invoke_setup y >/dev/null 2>&1; then
  fail "an add for a user with no mapping fails"
fi
[[ $(<"$authfile") == "otheruser:other-handle,other-key,es256" ]] ||
  fail "a failed add leaves the authfile alone" "got: $(<"$authfile")"
[[ ! -s $stages ]] || fail "a failed add stages nothing" "$(cat "$calls")"
pass "an add for a user with no existing mapping fails without staging"

reset_run
mkdir -p "$authdir"
user=$(/usr/bin/id -un)
printf '%s\n' "$user:credential-handle,public-key,es256,+presence" >"$authfile"
printf '%s\n' "$user:duplicate-handle,duplicate-key,es256" >>"$authfile"
if invoke_setup y >/dev/null 2>&1; then
  fail "an add against duplicate mappings fails"
fi
[[ $(<"$authfile") == "$user:credential-handle,public-key,es256,+presence
$user:duplicate-handle,duplicate-key,es256" ]] ||
  fail "a failed add leaves duplicate mappings alone" "got: $(<"$authfile")"
[[ ! -s $stages ]] || fail "a failed add stages nothing" "$(cat "$calls")"
pass "an add against duplicate mappings fails without publishing"

# --- credential capture failures abort before any stage ----------------------

reset_run
mkdir -p "$authdir"
existing_authfile
if invoke_setup y fail >/dev/null 2>&1; then
  fail "a failing pamu2fcfg fails the add"
fi
assert_unchanged_single_device "a failed capture leaves the authfile alone"
[[ ! -s $stages ]] || fail "a failed capture stages nothing" "$(cat "$calls")"
pass "a failing pamu2fcfg aborts the add before any staging"

reset_run
mkdir -p "$authdir"
existing_authfile
if invoke_setup y empty >/dev/null 2>&1; then
  fail "an empty pamu2fcfg result fails the add"
fi
assert_unchanged_single_device "an empty capture leaves the authfile alone"
[[ ! -s $stages ]] || fail "an empty capture stages nothing" "$(cat "$calls")"
pass "an empty pamu2fcfg result aborts the add before any staging"

reset_run
mkdir -p "$authdir"
existing_authfile
if invoke_setup y colon >/dev/null 2>&1; then
  fail "a colon-bearing credential fails the add"
fi
assert_unchanged_single_device "a rejected credential leaves the authfile alone"
[[ ! -s $stages ]] || fail "a rejected credential stages nothing" "$(cat "$calls")"
pass "a colon-bearing credential is rejected before any staging"

# Extra lines from pamu2fcfg must not reach the authfile: only the first line
# is kept (same trimming the setup applies before the colon check).
reset_run
mkdir -p "$authdir"
existing_authfile
run_setup y multiline
user=$(/usr/bin/id -un)
expected="$user:credential-handle,public-key,es256,+presence:$second_credential"
[[ $(<"$authfile") == "$expected" ]] ||
  fail "a multiline credential adds only its first line" "got: $(<"$authfile")"
! grep -Fq "extra-handle" "$authfile" ||
  fail "a multiline credential never publishes its extra lines" "got: $(<"$authfile")"
pass "a multiline credential contributes only its first line"

# Two plugged-in keys: the older already matches the authfile (assert stub),
# the newer does not. The setup must skip the registered stick, isolate the
# unregistered one, and never enroll a duplicate on the known key.
reset_run
mkdir -p "$authdir"
existing_authfile
run_setup y success 2
user=$(/usr/bin/id -un)
expected="$user:credential-handle,public-key,es256,+presence:$second_credential"
[[ $(<"$authfile") == "$expected" ]] ||
  fail "a multi-device add publishes only the unregistered key's credential" "got: $(<"$authfile")"
grep -Fq $'sudo\t/usr/bin/setfacl\t-x\tu:'"$user"$'\t--\t/dev/hidraw8' "$calls" ||
  fail "a multi-device add revokes the registered key while enrolling the new one" "$(cat "$calls")"
grep -Fq $'sudo\t/usr/bin/setfacl\t-m\tu:'"$user"':rw-'$'\t--\t/dev/hidraw8' "$calls" ||
  fail "a multi-device add restores the registered key's ACL afterwards" "$(cat "$calls")"
[[ ! -s $revoked ]] ||
  fail "revoked ACLs are restored after registration" "still revoked: $(cat "$revoked")"
pass "with a registered and a new key plugged in, the add skips the known key"

# If every plugged key already matches the authfile, refuse rather than
# writing a second credential onto one of them.
reset_run
mkdir -p "$authdir"
existing_authfile
# Both enumerated paths report as registered.
cat >"$stub_bin/fido2-assert" <<'SH'
#!/bin/bash
printf 'fido2-assert: fido_dev_get_assert: FIDO_ERR_USER_PRESENCE_REQUIRED\n' >&2
exit 1
SH
chmod +x "$stub_bin/fido2-assert"
if invoke_setup y success 2 >/dev/null 2>&1; then
  fail "an add with only registered keys plugged in fails"
fi
assert_unchanged_single_device "an add with only registered keys leaves the authfile alone"
[[ ! -s $stages ]] || fail "an add with only registered keys stages nothing" "$(cat "$calls")"
pass "an add with only already-registered keys plugged in refuses to enroll"
