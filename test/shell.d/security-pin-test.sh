#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-pin"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
tpm_marker="$test_tmp/tpm-present"
policy_file="$test_tmp/policy"
system_auth="$test_tmp/pam-system-auth"
sudo_pam="$test_tmp/pam-sudo"
polkit_pam="$test_tmp/pam-polkit-1"
dropin_dir="$test_tmp/polkit-agent-helper-dropin"
setup_copy="$test_tmp/setup.sh"
mkdir -p "$stub_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

# The setup reaches several absolute, root-owned paths no unprivileged suite
# can write, and an environment override in the shipped command would hand a
# privileged tee/sed/install an operand the caller chooses. Retarget scratch
# copies instead, and fail if a path is not named exactly once, so this seam
# cannot quietly stop standing for the paths it copies.
assert_named_once() {
  local pattern="$1" description="$2" occurrences

  occurrences=$(grep -Fxc "$pattern" "$setup") || occurrences=0
  (( occurrences == 1 )) || fail "$description" "found $occurrences occurrences of: $pattern"
}

assert_named_once 'policy_file=/etc/pinpam/policy' "the setup names its policy file exactly once"
assert_named_once 'polkit_dropin_dir=/etc/systemd/system/polkit-agent-helper@.service.d' \
  "the setup names its polkit drop-in directory exactly once"
pass "setup names its privileged target paths once each, and the test drives a retargeted copy"

# pinutil reads a PIN straight from the terminal; scripting or piping input to
# it would defeat that and risk logging a PIN. Statically confirm the call
# that enrolls a PIN carries no redirection or pipe at all.
if grep 'pinutil setup' "$setup" | grep -E '[<|]' >/dev/null; then
  fail "the setup never pipes or redirects input into pinutil setup"
fi
pass "the setup invokes pinutil without scripting its input"

awk -v tpm_marker="$tpm_marker" '
  {
    line = $0
    if (line == "  if [[ ! -e /dev/tpmrm0 && ! -e /dev/tpm0 ]]; then") {
      print "  if [[ ! -e \"" tpm_marker "\" ]]; then"
      next
    }
    print line
  }
' "$setup" | sed \
  -e "s|/etc/pinpam/policy|$policy_file|g" \
  -e "s|/etc/pam\\.d/system-auth|$system_auth|g" \
  -e "s|/etc/pam\\.d/sudo|$sudo_pam|g" \
  -e "s|/etc/pam\\.d/polkit-1|$polkit_pam|g" \
  -e "s|/etc/systemd/system/polkit-agent-helper@\\.service\\.d|$dropin_dir|g" \
  >"$setup_copy"
chmod +x "$setup_copy"

if grep -Fq 'policy_file=/etc/pinpam/policy' "$setup_copy" ||
  grep -Fq 'polkit_dropin_dir=/etc/systemd/system/polkit-agent-helper@.service.d' "$setup_copy" ||
  grep -Fq '/etc/pam.d/system-auth' "$setup_copy" ||
  grep -Fq '/etc/pam.d/sudo' "$setup_copy" ||
  grep -Fq '/etc/pam.d/polkit-1' "$setup_copy" ||
  grep -Fq 'if [[ ! -e /dev/tpmrm0 && ! -e /dev/tpm0 ]]; then' "$setup_copy"; then
  fail "the isolated fixture redirects every live-system setup target"
fi

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

reject() {
  printf 'refusing unexpected sudo invocation:' >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  exit 97
}

printf 'sudo' >>"$TEST_CALLS"
printf '\t%s' "$@" >>"$TEST_CALLS"
printf '\n' >>"$TEST_CALLS"

# /etc/polkit-1/rules.d ships 0750 root:polkitd on a real system, so this
# fixture can make its scratch stand-in genuinely inaccessible to the test
# process (chmod 000) to prove a privileged check sees through it, the same
# way apply-lock-test.sh's stat stub proves it for an unreadable directory.
# Real root would just see the file; this stub isn't root, so it opens the
# directory only for the instant it takes to answer, then closes it again.
with_dir_open() {
  local target="$1" dir saved_mode="" status
  shift
  dir=$(dirname "$target")
  if [[ -d $dir ]]; then
    saved_mode=$(/usr/bin/stat -c %a "$dir" 2>/dev/null) || saved_mode=""
    [[ -n $saved_mode ]] && /usr/bin/chmod 755 "$dir"
  fi
  status=0
  "$@" || status=$?
  [[ -n $saved_mode ]] && /usr/bin/chmod "$saved_mode" "$dir"
  return "$status"
}

case "${1:-}" in
  tee)
    (( $# == 2 )) || reject "$@"
    exec /usr/bin/tee "$2"
    ;;
  sed)
    (( $# == 4 )) && [[ $2 == "-i" ]] || reject "$@"
    exec /usr/bin/sed -i "$3" "$4"
    ;;
  install)
    if (( $# == 9 )) && [[ $2 == "-d" && $3 == "-m" && $4 == "755" && $5 == "-o" && $6 == "root" && $7 == "-g" && $8 == "root" ]]; then
      exec /usr/bin/install -d -m 755 "$9"
    fi
    reject "$@"
    ;;
  mkdir)
    (( $# == 3 )) && [[ $2 == "-p" ]] || reject "$@"
    exec /usr/bin/mkdir -p "$3"
    ;;
  test)
    (( $# == 3 )) && [[ $2 == "-e" ]] || reject "$@"
    with_dir_open "$3" /usr/bin/test -e "$3"
    exit $?
    ;;
  chown)
    (( $# == 3 )) && [[ $2 == "root:root" ]] || reject "$@"
    exit 0
    ;;
  chmod)
    (( $# == 3 )) || reject "$@"
    exec /usr/bin/chmod "$2" "$3"
    ;;
  systemctl)
    (( $# == 2 )) && [[ $2 == "daemon-reload" ]] || reject "$@"
    exit 0
    ;;
  echo)
    (( $# == 2 )) && [[ $2 == "PIN authentication test successful" ]] || reject "$@"
    echo "$2"
    ;;
  *)
    reject "$@"
    ;;
esac
SH

cat >"$stub_bin/pinutil" <<'SH'
#!/bin/bash

set -euo pipefail

printf 'pinutil' >>"$TEST_CALLS"
printf '\t%s' "$@" >>"$TEST_CALLS"
printf '\n' >>"$TEST_CALLS"

# --machine/-m is a global option and comes before the subcommand
# (`pinutil --machine status <user>`, not `pinutil status <user> --machine`).
# The "if" form (not a bare "[[ ]] && shift") matters here: this stub runs
# under set -e, and a standalone "&&" list exits the script on a false test.
if [[ ${1:-} == --machine || ${1:-} == -m ]]; then
  shift
fi

case "${1:-}" in
  status)
    case "${TEST_PIN_STATUS:-not-enrolled}" in
      enrolled) printf '{"Ok":{"used":1,"limit":5,"locked":false}}\n' ;;
      not-enrolled) printf '{"Ok":null}\n' ;;
      error) exit 1 ;;
      *) exit 91 ;;
    esac
    ;;
  setup)
    [[ ${TEST_PINUTIL_SETUP_MODE:-success} == fail ]] && exit 1
    exit 0
    ;;
  *)
    exit 90
    ;;
esac
SH

cat >"$stub_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-aur-add' >>"$TEST_CALLS"
printf '\t%s' "$@" >>"$TEST_CALLS"
printf '\n' >>"$TEST_CALLS"

[[ ${TEST_PKG_MODE:-success} == fail ]] && exit 1
exit 0
SH

cat >"$stub_bin/omarchy-apply-lock" <<'SH'
#!/bin/bash

printf 'omarchy-apply-lock\n' >>"$TEST_CALLS"
exit 0
SH

chmod +x "$stub_bin/sudo" "$stub_bin/pinutil" "$stub_bin/omarchy-pkg-aur-add" "$stub_bin/omarchy-apply-lock"

reset_fixtures() {
  : >"$calls"
  rm -f "$tpm_marker" "$policy_file" "$system_auth" "$sudo_pam" "$polkit_pam"
  rm -rf "$dropin_dir"
  touch "$tpm_marker"
  # /etc/pam.d/sudo and /etc/pam.d/system-auth always exist on a real system
  # (shipped by the sudo and pambase packages); the setup only ever edits
  # them in place, never creates them. system-auth's shape mirrors the real
  # file: three other sections each call pam_unix.so too, with a plain
  # "required" rather than the auth section's "[success=1 default=bad]", so
  # the fixture can prove the insertion touches only the auth line.
  printf '#%%PAM-1.0\nauth\t\tinclude\t\tsystem-auth\naccount\t\tinclude\t\tsystem-auth\n' >"$sudo_pam"
  printf '#%%PAM-1.0\n\nauth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120\n-auth      [success=2 default=ignore]  pam_systemd_home.so\nauth       [success=1 default=bad]     pam_unix.so          try_first_pass nullok\nauth       [default=die]               pam_faillock.so authfail deny=10 unlock_time=120\nauth       optional                    pam_permit.so\nauth       required                    pam_env.so\nauth       required                    pam_faillock.so      authsucc\n\naccount    required                    pam_unix.so\naccount    optional                    pam_permit.so\n\npassword   required                    pam_unix.so          try_first_pass nullok shadow\npassword   optional                    pam_permit.so\n\nsession    required                    pam_limits.so\nsession    required                    pam_unix.so\nsession    optional                    pam_permit.so\n' >"$system_auth"
}

invoke_setup() {
  TEST_CALLS="$calls" TEST_PIN_STATUS="${1:-not-enrolled}" TEST_PINUTIL_SETUP_MODE="${2:-success}" \
    TEST_PKG_MODE="${3:-success}" PATH="$stub_bin:$PATH" \
    bash "$setup_copy" </dev/null >"$test_tmp/stdout.log" 2>"$test_tmp/stderr.log"
}

# No TPM: the setup must bail before installing anything.
reset_fixtures
rm -f "$tpm_marker"
if invoke_setup; then
  fail "setup fails without a TPM device"
fi
[[ ! -s $calls ]] || fail "setup escalates nothing without a TPM device" "$(cat "$calls")"
pass "setup refuses to proceed without a TPM device"

# A fresh machine: TPM present, no prior PIN, nothing configured yet. An
# existing polkit-1 (as most real systems have, e.g. from FIDO2) already
# authenticates another way; PIN must be added alongside it, not replace it.
reset_fixtures
printf 'auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2\nauth      required pam_unix.so\n' >"$polkit_pam"
invoke_setup not-enrolled success success ||
  fail "setup completes on a fresh machine" "$(cat "$test_tmp/stderr.log")"

grep -Fq $'omarchy-pkg-aur-add\tpinpam-git' "$calls" ||
  fail "setup installs the pinpam-git package" "$(cat "$calls")"

[[ -f $policy_file ]] || fail "setup writes the policy file"
[[ $(stat -c %a "$policy_file") == "644" ]] || fail "the policy file is mode 644" "got: $(stat -c %a "$policy_file")"
if grep -q '^#' "$policy_file" || grep -q '"' "$policy_file"; then
  fail "the policy file has no comment lines or quoted values" "$(cat "$policy_file")"
fi
grep -Fxq 'pinutil_path=/usr/bin/pinutil' "$policy_file" ||
  fail "the policy file sets an unquoted, absolute pinutil_path" "$(cat "$policy_file")"
pass "setup writes a clean, parseable policy file"

grep -Fq $'pinutil\tsetup' "$calls" ||
  fail "setup enrolls a PIN when none is configured" "$(cat "$calls")"
pass "setup enrolls a PIN on a fresh machine"

grep -Fq $'sudo\tsed\t-i\t/\\[success=1 default=bad\\][[:space:]]*pam_unix\\.so/i auth       [success=2 default=ignore]  libpinpam.so\t'"$system_auth" "$calls" ||
  fail "setup wires login for PIN authentication" "$(cat "$calls")"
[[ $(grep -c libpinpam.so "$system_auth") == 1 ]] ||
  fail "libpinpam.so appears exactly once in system-auth" "$(cat "$system_auth")"
grep -A1 'libpinpam.so' "$system_auth" | grep -q 'pam_unix.so' ||
  fail "libpinpam.so sits immediately before the auth section's pam_unix.so line" "$(cat "$system_auth")"
account_line=$(grep '^account.*pam_unix' "$system_auth")
password_line=$(grep '^password.*pam_unix' "$system_auth")
session_line=$(grep '^session.*pam_unix' "$system_auth")
[[ $account_line == "account    required                    pam_unix.so" ]] ||
  fail "setup leaves the account section's pam_unix.so line alone" "$account_line"
[[ $password_line == "password   required                    pam_unix.so          try_first_pass nullok shadow" ]] ||
  fail "setup leaves the password section's pam_unix.so line alone" "$password_line"
[[ $session_line == "session    required                    pam_unix.so" ]] ||
  fail "setup leaves the session section's pam_unix.so line alone" "$session_line"
pass "setup wires login for PIN authentication without disturbing account, password, or session"

grep -Fq $'sudo\tsed\t-i\t1i auth      sufficient libpinpam.so\t'"$sudo_pam" "$calls" ||
  fail "setup wires sudo for PIN authentication" "$(cat "$calls")"
grep -Fq $'sudo\tsed\t-i\t1i auth      sufficient libpinpam.so\t'"$polkit_pam" "$calls" ||
  fail "setup wires an existing polkit-1 for PIN authentication" "$(cat "$calls")"
grep -Fq 'pam_u2f.so' "$polkit_pam" ||
  fail "setup leaves an existing FIDO2 line in polkit-1 alone" "$(cat "$polkit_pam")"
pass "setup wires sudo and polkit for PIN authentication"

grep -Fq $'sudo\tinstall\t-d\t-m\t755\t-o\troot\t-g\troot\t'"$dropin_dir" "$calls" ||
  fail "setup creates the polkit-agent-helper drop-in directory" "$(cat "$calls")"
[[ -f $dropin_dir/pinpam.conf ]] || fail "setup writes the polkit sandbox drop-in"
grep -Fq 'DeviceAllow=/dev/tpmrm0 rw' "$dropin_dir/pinpam.conf" ||
  fail "the drop-in allows /dev/tpmrm0" "$(cat "$dropin_dir/pinpam.conf")"
grep -Fq 'PrivateDevices=no' "$dropin_dir/pinpam.conf" ||
  fail "the drop-in disables PrivateDevices" "$(cat "$dropin_dir/pinpam.conf")"
grep -Fq $'sudo\tsystemctl\tdaemon-reload' "$calls" ||
  fail "setup reloads systemd after writing the drop-in" "$(cat "$calls")"
pass "setup allows polkit's PIN prompt to reach the TPM"

grep -Fq 'omarchy-apply-lock' "$calls" || fail "setup resyncs the lock screen PAM stack" "$(cat "$calls")"
grep -Fq $'sudo\techo\tPIN authentication test successful' "$calls" ||
  fail "setup verifies PIN authentication with sudo" "$(cat "$calls")"
pass "setup resyncs the lock screen and verifies sudo authentication"

# Already enrolled: pinutil setup must not run again.
reset_fixtures
invoke_setup enrolled success success ||
  fail "setup completes when a PIN is already enrolled" "$(cat "$test_tmp/stderr.log")"
if grep -Fq $'pinutil\tsetup' "$calls"; then
  fail "setup does not re-enroll an existing PIN" "$(cat "$calls")"
fi
pass "setup leaves an existing PIN enrollment alone"

# Idempotent PAM wiring: already-configured files are never touched again.
reset_fixtures
printf '#%%PAM-1.0\nauth      sufficient libpinpam.so\nauth       include       system-auth\n' >"$sudo_pam"
printf 'auth      sufficient libpinpam.so\nauth      required pam_unix.so\n' >"$polkit_pam"
printf 'auth       [success=2 default=ignore]  libpinpam.so\nauth       [success=1 default=bad]     pam_unix.so\n' >"$system_auth"
invoke_setup enrolled success success ||
  fail "setup completes with PIN already wired" "$(cat "$test_tmp/stderr.log")"
if grep -Fq $'sudo\tsed' "$calls"; then
  fail "setup never re-inserts an existing PIN auth line" "$(cat "$calls")"
fi
pass "setup wires sudo and polkit for PIN authentication exactly once"

# No polkit-1 at all: setup creates one from scratch.
reset_fixtures
rm -f "$polkit_pam"
invoke_setup enrolled success success ||
  fail "setup completes when polkit-1 does not exist" "$(cat "$test_tmp/stderr.log")"
[[ -f $polkit_pam ]] || fail "setup creates a polkit-1 configuration"
grep -Fq 'libpinpam.so' "$polkit_pam" || fail "the created polkit-1 configures PIN authentication"
grep -Fq 'pam_unix.so' "$polkit_pam" || fail "the created polkit-1 keeps a password fallback"
pass "setup creates polkit-1 with PIN authentication when it does not exist yet"

# The polkit sandbox drop-in is left alone once present, and existing content
# survives (rather than being clobbered) so a later, differently-configured
# drop-in is only detected, not replaced.
reset_fixtures
mkdir -p "$dropin_dir"
printf '[Service]\nDeviceAllow=/dev/tpmrm0 rw\nPrivateDevices=no\n' >"$dropin_dir/pinpam.conf"
invoke_setup enrolled success success ||
  fail "setup completes with the polkit drop-in already present" "$(cat "$test_tmp/stderr.log")"
if grep -Fq $'sudo\tinstall' "$calls" || grep -Fq $'sudo\tsystemctl' "$calls"; then
  fail "setup does not recreate an already-correct polkit drop-in" "$(cat "$calls")"
fi
pass "setup leaves the polkit sandbox drop-in alone once present"

# A symlinked policy destination must never be published through.
reset_fixtures
ln -s /dev/null "$policy_file"
invoke_setup >/dev/null 2>&1 && fail "setup refuses a symlinked policy file"
if grep -Fq $'sudo\ttee' "$calls" || grep -Fq $'sudo\tchown' "$calls"; then
  fail "setup writes nothing through a symlinked policy file" "$(cat "$calls")"
fi
[[ -L $policy_file ]] || fail "setup leaves the symlinked policy file in place"
pass "setup refuses a symlinked policy file"

# A failed enrollment must stop before any PAM or polkit changes.
reset_fixtures
invoke_setup not-enrolled fail success && fail "a failed pinutil setup fails the whole command"
if grep -Fq $'sudo\tsed' "$calls" || grep -Fq $'sudo\tinstall' "$calls"; then
  fail "a failed PIN enrollment configures nothing else" "$(cat "$calls")"
fi
pass "setup stops after a failed PIN enrollment"

# A failed package install must stop before touching the policy file.
reset_fixtures
invoke_setup not-enrolled success fail && fail "a failed package install fails the whole command"
[[ ! -e $policy_file ]] || fail "a failed package install never reaches the policy file"
pass "setup stops after a failed package install"
