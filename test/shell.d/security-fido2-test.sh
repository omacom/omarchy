#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fido2"
security_functions="$ROOT/bin/omarchy-security-functions"
router="$ROOT/bin/omarchy"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
poison_bin="$test_tmp/poison-bin"
stages="$test_tmp/stages.log"
calls="$test_tmp/calls.log"
pamu_targets="$test_tmp/pamu-targets.log"
bare_mktemp="$test_tmp/bare-mktemp.log"
poison_calls="$test_tmp/poison-calls.log"
startup_poison="$test_tmp/bash-env"
sudo_ticket="$test_tmp/sudo-ticket"
credential="tester:credential-handle,public-key,es256,+presence"
authdir="$test_tmp/etc-fido2"
authfile="$authdir/fido2"
setup_copy="$stub_bin/omarchy-setup-security-fido2"
mkdir -p "$stub_bin" "$poison_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

[[ $(head -n 1 "$router") == '#!/bin/bash -p' ]] ||
  fail "the public Omarchy router requests privileged Bash at the kernel boundary"
router_poison="$test_tmp/router-bash-env"
router_poison_calls="$test_tmp/router-poison-calls"
cat >"$router_poison" <<'SH'
printf '%s\n' router-bash-env >>"$TEST_ROUTER_POISON_CALLS"
SH
cat >"$poison_bin/dirname" <<'SH'
#!/bin/bash
printf '%s\n' router-path-dirname >>"$TEST_ROUTER_POISON_CALLS"
exec /usr/bin/dirname "$@"
SH
chmod +x "$poison_bin/dirname"
BASH_ENV="$router_poison" TEST_ROUTER_POISON_CALLS="$router_poison_calls" \
  OMARCHY_PATH="$ROOT" PATH="$poison_bin:/usr/bin:/bin" \
  "$router" setup security fido2 --help >/dev/null
[[ ! -e $router_poison_calls ]] ||
  fail "the public Omarchy router executes a pre-dispatch user callback" "$(<"$router_poison_calls")"
unsafe_router_status=0
/usr/bin/bash "$router" -p >/dev/null 2>&1 || unsafe_router_status=$?
(( unsafe_router_status == 126 )) ||
  fail "the public Omarchy router rejects an ordinary Bash launch with a decoy -p argument" "got status $unsafe_router_status"
sourced_router_status=0
/usr/bin/bash -p -c 'source "$1"' omarchy-source-test "$router" >/dev/null 2>&1 || sourced_router_status=$?
(( sourced_router_status == 126 )) ||
  fail "the public Omarchy router rejects being sourced by a privileged parent shell" "got status $sourced_router_status"
pass "the public Omarchy router resolves the FIDO2 route without inherited Bash startup hooks or PATH utilities"

# The setup installs to an absolute path no unprivileged suite can write, and an
# environment override in the shipped command would hand its privileged install
# and mv an operand the caller chooses. Retarget a scratch copy instead, and
# fail if either path is not named exactly once, so this seam cannot quietly
# stop standing for the command it copies. Keying the suite on the host's own
# /etc/fido2 instead is what let the staging checks below pass without asserting
# anything on the machines that actually use FIDO2.
occurrences=$(grep -Fxc 'authdir=/etc/fido2' "$setup") || occurrences=0
(( occurrences == 1 )) ||
  fail "the setup names its FIDO2 directory exactly once" "found $occurrences occurrences"
occurrences=$(grep -Fxc 'authfile=/etc/fido2/fido2' "$setup") || occurrences=0
(( occurrences == 1 )) ||
  fail "the setup names its authfile exactly once" "found $occurrences occurrences"
pass "setup names its FIDO2 paths once each, and the test drives a retargeted copy"

occurrences=$(grep -Fxc 'PATH="$OMARCHY_PATH/bin:/usr/local/bin:/usr/bin:/bin"' "$setup") || occurrences=0
(( occurrences == 1 )) ||
  fail "FIDO2 setup defines one trusted command path" "found $occurrences occurrences"
grep -Fq 'omarchy_security_sanitize_bash_environment "$security_entrypoint" "$@"' "$setup" ||
  fail "FIDO2 setup re-executes through its canonical entrypoint"

sed -e "s|^authdir=/etc/fido2$|authdir=$authdir|" \
  -e "s|^authfile=/etc/fido2/fido2$|authfile=$authfile|" \
  -e "s|^PATH=\"\$OMARCHY_PATH/bin:/usr/local/bin:/usr/bin:/bin\"$|PATH=\"$stub_bin:$ROOT/bin:/usr/bin:/bin\"|" \
  -e "s|/usr/bin/sudo|$stub_bin/sudo|g" \
  -e "s|/usr/bin/fido2-token|$stub_bin/fido2-token|g" \
  -e "s|/usr/bin/pamu2fcfg|$stub_bin/pamu2fcfg|g" \
  -e "s|/usr/bin/grep|$stub_bin/grep|g" \
  -e "s|\"\$OMARCHY_PATH/bin/omarchy-pkg-add\"|\"$stub_bin/omarchy-pkg-add\"|" \
  "$setup" >"$setup_copy"
cp "$security_functions" "$stub_bin/omarchy-security-functions"

[[ $(head -n 1 "$setup") == '#!/bin/bash -p' ]] ||
  fail "FIDO2 setup requests privileged Bash at the kernel boundary"
unsafe_startup_status=0
/usr/bin/bash "$setup_copy" -p </dev/null >/dev/null 2>&1 || unsafe_startup_status=$?
(( unsafe_startup_status == 126 )) ||
  fail "FIDO2 setup rejects an ordinary Bash launch with a decoy -p argument" "got status $unsafe_startup_status"
sourced_startup_status=0
/usr/bin/bash -p -c 'source "$1"' omarchy-source-test "$setup_copy" >/dev/null 2>&1 || sourced_startup_status=$?
(( sourced_startup_status == 126 )) ||
  fail "FIDO2 setup rejects being sourced by a privileged parent shell" "got status $sourced_startup_status"
pass "FIDO2 setup requires a verified privileged Bash startup"

mismatched_root_status=0
OMARCHY_PATH="$test_tmp/mismatched-root" /usr/bin/bash -p "$setup_copy" </dev/null >/dev/null 2>&1 || mismatched_root_status=$?
(( mismatched_root_status == 126 )) ||
  fail "FIDO2 setup rejects a mismatched Omarchy source root" "got status $mismatched_root_status"
pass "FIDO2 setup binds runtime helpers to its own source root"

grep -Fxq "PATH=\"$stub_bin:$ROOT/bin:/usr/bin:/bin\"" "$setup_copy" ||
  fail "the test redirects the trusted FIDO2 command path"
grep -Fq "$stub_bin/sudo -k" "$setup_copy" ||
  fail "the test redirects fixed sudo invocations"
grep -Fq "$stub_bin/fido2-token -L" "$setup_copy" ||
  fail "the test redirects the fixed hardware probe"
grep -Fq "$stub_bin/pamu2fcfg" "$setup_copy" ||
  fail "the test redirects the fixed credential generator"
pass "FIDO2 setup limits command lookup and fixes its security-sensitive executables"

cat >"$startup_poison" <<'SH'
if [[ -e $TEST_SUDO_TICKET ]]; then
  printf '%s\n' bash-env-with-live-sudo >>"$TEST_POISON_CALLS"
fi
SH

# The setup must not create a caller-owned named file for pamu2fcfg. A bare
# mktemp is therefore a test failure; only the sudo stub below may invoke the
# real command, and it does so with an absolute scratch template.
cat >"$stub_bin/mktemp" <<'SH'
#!/bin/bash

printf 'mktemp' >>"$TEST_BARE_MKTEMP"
printf '\t%s' "$@" >>"$TEST_BARE_MKTEMP"
printf '\n' >>"$TEST_BARE_MKTEMP"
exit 98
SH

# Execute only the setup's expected bare-sudo protocol. The production mktemp
# template is logged exactly, but its root-created sibling is represented by a
# unique regular file inside the scratch directory. The whitelisted operations
# map every write into that directory; arbitrary direct commands are outside
# this harness.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

if [[ ${TEST_TMP:-} != /* || ${TEST_AUTHDIR:-} != "$TEST_TMP/etc-fido2" || ${TEST_AUTHFILE:-} != "$TEST_AUTHDIR/fido2" || ${TEST_STAGES:-} != "$TEST_TMP/stages.log" || ${TEST_LOG:-} != "$TEST_TMP/calls.log" || ${TEST_SUDO_TICKET:-} != "$TEST_TMP/sudo-ticket" || ${TEST_POISON_CALLS:-} != "$TEST_TMP/poison-calls.log" || ! ${TEST_FAIL_CHMOD:-} =~ ^[01]$ || ! ${TEST_FAIL_MV:-} =~ ^[01]$ ]]; then
  reject "$@"
fi

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

if [[ ${1:-} == "-k" ]]; then
  (( $# == 1 )) || reject "$@"
  /usr/bin/rm -f -- "$TEST_SUDO_TICKET"
  exit 0
fi

: >"$TEST_SUDO_TICKET"

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

case "${1:-}" in
  package-authorize)
    (( $# == 1 )) || reject "$@"
    ;;
  install)
    if (( $# != 9 )) || [[ $2 != "-d" || $3 != "-m" || $4 != "755" || $5 != "-o" || $6 != "root" || $7 != "-g" || $8 != "root" || $9 != "$TEST_AUTHDIR" ]]; then
      reject "$@"
    fi

    if (( EUID == 0 )); then
      exec /usr/bin/install -d -m 755 -o root -g root "$TEST_AUTHDIR"
    else
      exec /usr/bin/install -d -m 755 "$TEST_AUTHDIR"
    fi
    ;;
  mktemp)
    if (( $# != 2 )) || [[ $2 != "$TEST_AUTHFILE.new.XXXXXX" ]]; then
      reject "$@"
    fi

    case ${TEST_MKTEMP_MODE:-normal} in
      normal)
        stage=$(/usr/bin/mktemp -- "$2")
        if ! safe_stage_path "$stage" || [[ ! -f $stage || -L $stage ]]; then
          reject "$@"
        fi

        printf '%s\n' "$stage" >>"$TEST_STAGES"
        printf '%s\n' "$stage"
        ;;
      malformed)
        stage="$TEST_AUTHFILE.new.A/BCDE"
        /usr/bin/mkdir -- "${stage%/*}"
        : >"$stage"
        printf '%s\n' "$stage"
        ;;
      nonregular)
        stage="$TEST_AUTHFILE.new.BAD123"
        /usr/bin/mkdir -- "$stage"
        printf '%s\n' "$stage"
        ;;
      *)
        reject "$@"
        ;;
    esac
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
  test)
    if (( $# != 3 )) || [[ $2 != "-s" ]] || ! recorded_stage "$3"; then
      reject "$@"
    fi
    /usr/bin/test -s "$3"
    ;;
  chmod)
    if (( $# != 3 )) || [[ $2 != "644" ]] || ! recorded_stage "$3"; then
      reject "$@"
    fi
    if [[ $TEST_FAIL_CHMOD == "1" ]]; then
      exit 73
    fi
    exec /usr/bin/chmod 644 "$3"
    ;;
  mv)
    if (( $# != 4 )) || [[ $2 != "-Tf" || $4 != "$TEST_AUTHFILE" ]] || ! recorded_stage "$3"; then
      reject "$@"
    fi
    if [[ $TEST_FAIL_MV == "1" ]]; then
      exit 74
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
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/fido2-token" <<'SH'
#!/bin/bash

if [[ -e $TEST_SUDO_TICKET ]]; then
  printf '%s\n' fido2-token-with-live-sudo >>"$TEST_POISON_CALLS"
  exit 94
fi

echo '/dev/hidraw0: vendor=0x1050, product=0x0407 (Yubico YubiKey)'
SH

cat >"$stub_bin/grep" <<'SH'
#!/bin/bash

if [[ -e $TEST_SUDO_TICKET ]]; then
  printf '%s\n' grep-with-live-sudo >>"$TEST_POISON_CALLS"
  exit 94
fi

exec /usr/bin/grep "$@"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

if (( $# != 3 )) || [[ $1 != "--revoke-sudo" || $2 != "libfido2" || $3 != "pam-u2f" ]]; then
  exit 92
fi

"$TEST_SUDO_STUB" package-authorize
"$TEST_SUDO_STUB" -k
SH

# Record what pamu2fcfg's stdout actually targets. The fixed implementation
# captures it through a pipe while sudo is cold; refusing a regular-file
# descriptor keeps a regression from writing credential bytes into a
# caller-owned named file.
cat >"$stub_bin/pamu2fcfg" <<'SH'
#!/bin/bash

set -euo pipefail

if [[ -e $TEST_SUDO_TICKET ]]; then
  printf '%s\n' pamu2fcfg-with-live-sudo >>"$TEST_POISON_CALLS"
  exit 94
fi

target=$(readlink /proc/self/fd/1)
printf '%s\n' "$target" >>"$TEST_PAMU_TARGETS"
[[ $target == pipe:* ]] || exit 96

case "$TEST_PAMU_MODE" in
  success)
    printf '%s\n' "$TEST_CREDENTIAL"
    ;;
  fail)
    printf '%s\n' "$TEST_CREDENTIAL"
    exit 23
    ;;
  empty)
    exit 0
    ;;
  *)
    exit 95
    ;;
esac
SH

for command in omarchy-pkg-add fido2-token pamu2fcfg; do
  cat >"$poison_bin/$command" <<'SH'
#!/bin/bash

printf '%s\n' "${0##*/}" >>"$TEST_POISON_CALLS"
exit 93
SH
done

chmod +x "$stub_bin/mktemp" "$stub_bin/sudo" "$stub_bin/fido2-token" "$stub_bin/grep" \
  "$stub_bin/omarchy-pkg-add" "$stub_bin/pamu2fcfg" "$poison_bin"/*

reset_run() {
  : >"$calls"
  : >"$stages"
  : >"$pamu_targets"
  : >"$bare_mktemp"
  : >"$poison_calls"
  rm -f "$sudo_ticket"
  rm -rf "$authdir"
}

invoke_setup() {
  local pamu_mode="${1:-success}"
  local fail_chmod="${2:-0}"
  local fail_mv="${3:-0}"
  local mktemp_mode="${4:-normal}"
  local status

  if /usr/bin/env \
    TEST_AUTHDIR="$authdir" TEST_AUTHFILE="$authfile" TEST_BARE_MKTEMP="$bare_mktemp" \
    TEST_CREDENTIAL="$credential" TEST_FAIL_CHMOD="$fail_chmod" TEST_FAIL_MV="$fail_mv" \
    TEST_LOG="$calls" TEST_MKTEMP_MODE="$mktemp_mode" TEST_PAMU_MODE="$pamu_mode" \
    TEST_PAMU_TARGETS="$pamu_targets" TEST_POISON_CALLS="$poison_calls" \
    TEST_STAGES="$stages" TEST_SUDO_STUB="$stub_bin/sudo" TEST_SUDO_TICKET="$sudo_ticket" \
    TEST_TMP="$test_tmp" OMARCHY_PATH="$test_tmp" PATH="$poison_bin:$stub_bin:$ROOT/bin:$PATH" \
    BASH_ENV="$startup_poison" ENV="$startup_poison" \
    SHELLOPTS=braceexpand:hashall:interactive-comments:xtrace \
    'PS4=$(if [[ -e $TEST_SUDO_TICKET ]]; then builtin printf "%s\n" xtrace-with-live-sudo >>"$TEST_POISON_CALLS"; fi)' \
    'BASH_FUNC_echo%%=() { if [[ -e $TEST_SUDO_TICKET ]]; then builtin printf "%s\n" exported-echo-with-live-sudo >>"$TEST_POISON_CALLS"; fi; builtin echo "$@"; }' \
    'BASH_FUNC_printf%%=() { if [[ -e $TEST_SUDO_TICKET ]]; then builtin echo exported-printf-with-live-sudo >>"$TEST_POISON_CALLS"; fi; builtin printf "$@"; }' \
    /usr/bin/bash -p "$setup_copy" </dev/null >/dev/null; then
    status=0
  else
    status=$?
  fi

  [[ $(head -n 1 "$calls") == $'sudo\t-k' ]] ||
    fail "FIDO2 setup begins with cold sudo credentials" "$(cat "$calls")"
  [[ $(tail -n 1 "$calls") == $'sudo\t-k' ]] ||
    fail "FIDO2 setup invalidates sudo credentials before returning" "$(cat "$calls")"
  [[ ! -e $sudo_ticket ]] || fail "FIDO2 setup leaves no reusable sudo credentials"
  [[ ! -s $poison_calls ]] ||
    fail "FIDO2 setup executes an inherited or user-PATH callback" "$(cat "$poison_calls")"

  return "$status"
}

run_setup() {
  invoke_setup "${1:-success}" ||
    fail "FIDO2 setup registers a device that answers fido2-token" "sudo calls:
$(cat "$calls")"
}

safe_fixture_stage_path() {
  local candidate=$1
  local prefix="$authfile.new."
  local suffix

  [[ $candidate == "$prefix"* ]] || return 1
  suffix=${candidate#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
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

assert_failed_stage_cleanup() {
  local stage_path

  stage_path=$(single_stage)
  safe_fixture_stage_path "$stage_path" ||
    fail "the failed setup stage is a unique scratch sibling" "got: $stage_path"
  grep -Fxq $'sudo\trm\t-f\t--\t'"$stage_path" "$calls" ||
    fail "failed setup removes its exact privileged stage" "$(cat "$calls")"
  [[ ! -e $stage_path && ! -L $stage_path ]] ||
    fail "the failed setup stage is gone" "left behind: $stage_path"
  [[ ! -e $authfile ]] || fail "failed setup never publishes a credential"
}

# Each branch below is a fixture rather than whatever the host happens to have
# at /etc/fido2, so all of them run on every machine and the staging assertions
# that follow are reached even on one that already uses FIDO2.
reset_run
mkdir -p "$authdir"
printf '%s\n' "$credential" >"$authfile"
run_setup
[[ ! -s $stages && ! -s $pamu_targets ]] ||
  fail "FIDO2 setup stages nothing when a registration already exists"
! grep -Fq $'sudo\tmktemp\t' "$calls" ||
  fail "FIDO2 setup creates no stage over an existing registration" "$(cat "$calls")"
pass "FIDO2 setup leaves an existing registration alone"

reset_run
mkdir -p "$authdir"
ln -s /dev/null "$authfile"
invoke_setup >/dev/null 2>&1 &&
  fail "FIDO2 setup refuses a symlinked authfile"
[[ ! -s $stages && ! -s $pamu_targets ]] ||
  fail "FIDO2 setup stages nothing against a symlinked authfile"
[[ -L $authfile ]] || fail "FIDO2 setup leaves the symlinked authfile in place"
pass "FIDO2 setup refuses a symlinked authfile"

reset_run
mkdir -p "$authfile"
invoke_setup >/dev/null 2>&1 &&
  fail "FIDO2 setup refuses a directory where the authfile belongs"
[[ ! -s $stages && ! -s $pamu_targets ]] ||
  fail "FIDO2 setup stages nothing against a directory authfile"
pass "FIDO2 setup refuses a non-regular authfile"

# install -d follows a symlink at the directory and applies its mode and
# ownership to whatever it points at, so the credential would be staged and
# published inside the target and that directory reopened to root:root 755.
reset_run
mkdir -p "$test_tmp/elsewhere"
chmod 700 "$test_tmp/elsewhere"
ln -s "$test_tmp/elsewhere" "$authdir"
invoke_setup >/dev/null 2>&1 &&
  fail "FIDO2 setup refuses a symlinked FIDO2 directory"
[[ ! -s $stages && ! -s $pamu_targets ]] ||
  fail "FIDO2 setup stages nothing through a symlinked FIDO2 directory"
! grep -Fq $'sudo\tinstall\t' "$calls" ||
  fail "FIDO2 setup never runs install -d through a symlink" "$(cat "$calls")"
[[ $(stat -c %a "$test_tmp/elsewhere") == "700" ]] ||
  fail "FIDO2 setup leaves the symlink target's mode alone" "got: $(stat -c %a "$test_tmp/elsewhere")"
[[ ! -e $test_tmp/elsewhere/fido2 ]] ||
  fail "FIDO2 setup publishes nothing inside the symlink target"
pass "FIDO2 setup refuses a symlinked FIDO2 directory and leaves its target alone"

reset_run
run_setup
stage_path=$(single_stage)
safe_fixture_stage_path "$stage_path" ||
  fail "FIDO2 setup uses a unique sibling stage" "got: $stage_path"
assert_pipe_target

[[ ! -s $bare_mktemp ]] ||
  fail "FIDO2 setup never creates a caller-owned temporary file" "$(cat "$bare_mktemp")"
grep -Fxq $'sudo\tmktemp\t'"$authfile.new.XXXXXX" "$calls" ||
  fail "FIDO2 setup asks root to create a unique sibling stage" "$(cat "$calls")"
grep -Fxq $'sudo\ttee\t'"$stage_path" "$calls" ||
  fail "the captured credential is written into the exact privileged stage" "$(cat "$calls")"
grep -Fxq $'sudo\tchmod\t644\t'"$stage_path" "$calls" ||
  fail "FIDO2 setup makes the completed authfile PAM-readable" "$(cat "$calls")"
grep -Fxq $'sudo\tmv\t-Tf\t'"$stage_path"$'\t'"$authfile" "$calls" ||
  fail "FIDO2 setup atomically publishes the exact privileged stage" "$(cat "$calls")"
! grep -Fq $'sudo\trm\t' "$calls" ||
  fail "successful setup leaves its cleanup trap inert" "$(cat "$calls")"

[[ ! -e $stage_path && ! -L $stage_path ]] ||
  fail "the privileged stage path is gone after publication" "left behind: $stage_path"
[[ -f $authfile && $(<"$authfile") == "$credential" ]] ||
  fail "the published authfile contains the generated credential"
[[ $(stat -c %a "$authfile") == "644" ]] ||
  fail "the published authfile is mode 644" "got: $(stat -c %a "$authfile")"
pass "FIDO2 setup pipes the credential into a unique root-created stage and publishes it atomically"
pass "FIDO2 utilities run with sanitized Bash state and setup revokes sudo before returning"

# A chmod failure happens after a complete credential has been written but
# before publication. It must abort the setup and leave the EXIT trap armed.
reset_run
if invoke_setup success 1 >/dev/null 2>&1; then
  fail "a failed chmod propagates out of FIDO2 setup"
fi
failed_stage=$(single_stage)
assert_pipe_target
grep -Fxq $'sudo\tchmod\t644\t'"$failed_stage" "$calls" ||
  fail "the injected chmod failure targets the exact privileged stage" "$(cat "$calls")"
! grep -Fq $'sudo\tmv\t' "$calls" ||
  fail "a stage whose chmod failed is never published" "$(cat "$calls")"
assert_failed_stage_cleanup
pass "FIDO2 setup propagates chmod failure and cleans its privileged stage"

# A failed atomic rename has the same cleanup obligation. The completed stage
# must not survive beside the live authfile when publication fails.
reset_run
if invoke_setup success 0 1 >/dev/null 2>&1; then
  fail "a failed mv propagates out of FIDO2 setup"
fi
failed_stage=$(single_stage)
assert_pipe_target
grep -Fxq $'sudo\tchmod\t644\t'"$failed_stage" "$calls" ||
  fail "the mv-failure fixture reaches a completed mode-644 stage" "$(cat "$calls")"
grep -Fxq $'sudo\tmv\t-Tf\t'"$failed_stage"$'\t'"$authfile" "$calls" ||
  fail "the injected mv failure targets the exact privileged stage" "$(cat "$calls")"
assert_failed_stage_cleanup
pass "FIDO2 setup propagates mv failure and cleans its privileged stage"

# Emit a valid credential and then fail. The command substitution must preserve
# pamu2fcfg's failure and prevent its output from reaching privileged staging.
reset_run
if invoke_setup fail >/dev/null 2>&1; then
  fail "a failing pamu2fcfg pipeline fails setup"
fi
assert_pipe_target
[[ ! -s $stages ]] || fail "a failing pamu2fcfg creates no privileged stage"
! grep -Fq $'sudo\tinstall\t' "$calls" ||
  fail "a failing pamu2fcfg reaches no privileged write" "$(cat "$calls")"
! grep -Fq $'sudo\tchmod\t' "$calls" ||
  fail "a failed pamu2fcfg result is never prepared for publication" "$(cat "$calls")"
! grep -Fq $'sudo\tmv\t' "$calls" ||
  fail "a failed pamu2fcfg result is never published" "$(cat "$calls")"
pass "FIDO2 setup rejects a failed credential before privileged staging"

# A successful pamu2fcfg invocation can still produce no credential. Reject
# that result before creating a privileged stage.
reset_run
if invoke_setup empty >/dev/null 2>&1; then
  fail "an empty pamu2fcfg result fails setup"
fi
assert_pipe_target
[[ ! -s $stages ]] || fail "an empty pamu2fcfg result creates no privileged stage"
! grep -Fq $'sudo\tinstall\t' "$calls" ||
  fail "an empty pamu2fcfg result reaches no privileged write" "$(cat "$calls")"
! grep -Fq $'sudo\tchmod\t' "$calls" ||
  fail "an empty pamu2fcfg result is never prepared for publication" "$(cat "$calls")"
! grep -Fq $'sudo\tmv\t' "$calls" ||
  fail "an empty pamu2fcfg result is never published" "$(cat "$calls")"
pass "FIDO2 setup rejects an empty credential before privileged staging"

# mktemp's output is an operand for a privileged tee, chmod, mv and rm. Take
# only the name this script asked for: a stage path outside that shape must stop
# the setup before any of them runs, exactly as the migration does.
reset_run
invoke_setup success 0 0 malformed >/dev/null 2>&1 &&
  fail "a malformed mktemp result fails setup"
! grep -Fq $'sudo\ttee\t' "$calls" ||
  fail "no credential is written to a malformed stage path" "$(cat "$calls")"
! grep -Fq $'sudo\tchmod\t' "$calls" ||
  fail "a malformed stage path never reaches a privileged chmod" "$(cat "$calls")"
! grep -Fq $'sudo\tmv\t' "$calls" ||
  fail "a malformed stage path is never published" "$(cat "$calls")"
! grep -Fq $'sudo\trm\t' "$calls" ||
  fail "a malformed stage path never reaches a privileged rm" "$(cat "$calls")"
[[ ! -e $authfile ]] || fail "a malformed stage publishes no authfile"
pass "FIDO2 setup rejects malformed mktemp output before any privileged write"

reset_run
invoke_setup success 0 0 nonregular >/dev/null 2>&1 &&
  fail "a nonregular mktemp result fails setup"
! grep -Fq $'sudo\ttee\t' "$calls" ||
  fail "no credential is written into a nonregular stage" "$(cat "$calls")"
! grep -Fq $'sudo\tchmod\t' "$calls" ||
  fail "a nonregular stage never reaches a privileged chmod" "$(cat "$calls")"
! grep -Fq $'sudo\tmv\t' "$calls" ||
  fail "a nonregular stage is never published" "$(cat "$calls")"
[[ ! -e $authfile ]] || fail "a nonregular stage publishes no authfile"
pass "FIDO2 setup rejects nonregular mktemp output before any privileged write"
