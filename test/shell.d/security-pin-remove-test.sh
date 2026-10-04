#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

remove="$ROOT/bin/omarchy-remove-security-pin"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
policy_file="$test_tmp/policy"
system_auth="$test_tmp/pam-system-auth"
sudo_pam="$test_tmp/pam-sudo"
polkit_pam="$test_tmp/pam-polkit-1"
dropin_file="$test_tmp/polkit-agent-helper-dropin/pinpam.conf"
remove_copy="$test_tmp/remove.sh"
mkdir -p "$stub_bin"

cleanup() {
  rm -rf "$test_tmp"
  return 0
}
trap cleanup EXIT

assert_named_once() {
  local pattern="$1" description="$2" occurrences

  occurrences=$(grep -Fxc "$pattern" "$remove") || occurrences=0
  (( occurrences == 1 )) || fail "$description" "found $occurrences occurrences of: $pattern"
}

assert_named_once 'policy_file=/etc/pinpam/policy' "the removal names its policy file exactly once"
assert_named_once 'polkit_dropin_file=/etc/systemd/system/polkit-agent-helper@.service.d/pinpam.conf' \
  "the removal names its polkit drop-in file exactly once"
pass "removal names its privileged target paths once each, and the test drives a retargeted copy"

sed \
  -e "s|/etc/pinpam/policy|$policy_file|g" \
  -e "s|/etc/pam\\.d/system-auth|$system_auth|g" \
  -e "s|/etc/pam\\.d/sudo|$sudo_pam|g" \
  -e "s|/etc/pam\\.d/polkit-1|$polkit_pam|g" \
  -e "s|/etc/systemd/system/polkit-agent-helper@\\.service\\.d/pinpam\\.conf|$dropin_file|g" \
  "$remove" >"$remove_copy"
chmod +x "$remove_copy"

if grep -Fq 'policy_file=/etc/pinpam/policy' "$remove_copy" ||
  grep -Fq '/etc/systemd/system/polkit-agent-helper@.service.d/pinpam.conf' "$remove_copy" ||
  grep -Fq '/etc/pam.d/system-auth' "$remove_copy" ||
  grep -Fq '/etc/pam.d/sudo' "$remove_copy" ||
  grep -Fq '/etc/pam.d/polkit-1' "$remove_copy"; then
  fail "the isolated fixture redirects every live-system removal target"
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

case "${1:-}" in
  sed)
    (( $# == 4 )) && [[ $2 == "-i" ]] || reject "$@"
    exec /usr/bin/sed -i "$3" "$4"
    ;;
  rm)
    (( $# == 3 )) && [[ $2 == "-f" ]] || reject "$@"
    exec /usr/bin/rm -f "$3"
    ;;
  systemctl)
    (( $# == 2 )) && [[ $2 == "daemon-reload" ]] || reject "$@"
    exit 0
    ;;
  pinutil)
    (( $# == 3 )) && [[ $2 == "delete" ]] || reject "$@"
    printf 'sudo-pinutil-delete\t%s\n' "$3" >>"$TEST_CALLS"
    [[ ${TEST_PINUTIL_DELETE_MODE:-success} == fail ]] && exit 1
    exit 0
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
  *)
    exit 90
    ;;
esac
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash

for cmd in "$@"; do
  command -v "$cmd" >/dev/null || exit 1
done
exit 0
SH

cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-drop\t%s\n' "$*" >>"$TEST_CALLS"
SH

cat >"$stub_bin/omarchy-apply-lock" <<'SH'
#!/bin/bash

printf 'omarchy-apply-lock\n' >>"$TEST_CALLS"
exit 0
SH

chmod +x "$stub_bin/sudo" "$stub_bin/pinutil" "$stub_bin/omarchy-cmd-present" \
  "$stub_bin/omarchy-pkg-drop" "$stub_bin/omarchy-apply-lock"

reset_fixtures() {
  : >"$calls"
  rm -f "$policy_file" "$system_auth" "$sudo_pam" "$polkit_pam"
  rm -rf "$(dirname "$dropin_file")"
}

invoke_remove() {
  TEST_CALLS="$calls" TEST_PIN_STATUS="${1:-enrolled}" TEST_PINUTIL_DELETE_MODE="${2:-success}" \
    PATH="$stub_bin:$PATH" \
    bash "$remove_copy" </dev/null >"$test_tmp/stdout.log" 2>"$test_tmp/stderr.log"
}

# The fully-configured case: everything the setup could have left behind.
reset_fixtures
printf 'auth       [success=2 default=ignore]  libpinpam.so\nauth       [success=1 default=bad]     pam_unix.so\naccount    required                    pam_unix.so\n' >"$system_auth"
printf '#%%PAM-1.0\nauth      sufficient libpinpam.so\nauth\t\tinclude\t\tsystem-auth\n' >"$sudo_pam"
printf 'auth      sufficient pam_u2f.so cue authfile=/etc/fido2/fido2\nauth      sufficient libpinpam.so\nauth      required pam_unix.so\n' >"$polkit_pam"
printf 'pin_min_length=4\npin_max_length=6\npin_lockout_max_attempts=5\npinutil_path=/usr/bin/pinutil\ntcti=device:/dev/tpmrm0\n' >"$policy_file"
mkdir -p "$(dirname "$dropin_file")"
printf '[Service]\nDeviceAllow=/dev/tpmrm0 rw\nPrivateDevices=no\n' >"$dropin_file"

invoke_remove enrolled success ||
  fail "removal completes on a fully-configured machine" "$(cat "$test_tmp/stderr.log")"

grep -Fq $'sudo-pinutil-delete\toliver' "$calls" ||
  fail "removal deletes the enrolled PIN as root" "$(cat "$calls")"
! grep -Fq $'sudo\tsed\t-i\t1i' "$calls" || fail "removal never inserts a PAM line"
grep -Fxq $'sudo\tsed\t-i\t/libpinpam\\.so/d\t'"$system_auth" "$calls" ||
  fail "removal strips PIN from login" "$(cat "$calls")"
grep -Fxq $'sudo\tsed\t-i\t/libpinpam\\.so/d\t'"$sudo_pam" "$calls" ||
  fail "removal strips PIN from sudo" "$(cat "$calls")"
grep -Fxq $'sudo\tsed\t-i\t/libpinpam\\.so/d\t'"$polkit_pam" "$calls" ||
  fail "removal strips PIN from polkit-1" "$(cat "$calls")"
! grep -q libpinpam.so "$system_auth" || fail "libpinpam.so is gone from system-auth" "$(cat "$system_auth")"
! grep -q libpinpam.so "$sudo_pam" || fail "libpinpam.so is gone from sudo" "$(cat "$sudo_pam")"
! grep -q libpinpam.so "$polkit_pam" || fail "libpinpam.so is gone from polkit-1" "$(cat "$polkit_pam")"
grep -Fq 'pam_unix.so' "$system_auth" || fail "removal leaves system-auth's pam_unix.so lines alone" "$(cat "$system_auth")"
grep -Fq 'pam_u2f.so' "$polkit_pam" || fail "removal leaves an unrelated FIDO2 line in polkit-1 alone" "$(cat "$polkit_pam")"
pass "removal deletes the enrolled PIN and strips PIN authentication from login, sudo, and polkit"

grep -Fxq $'sudo\trm\t-f\t'"$dropin_file" "$calls" ||
  fail "removal deletes the polkit sandbox drop-in" "$(cat "$calls")"
[[ ! -e $dropin_file ]] || fail "the polkit sandbox drop-in is gone"
grep -Fq $'sudo\tsystemctl\tdaemon-reload' "$calls" ||
  fail "removal reloads systemd after removing the drop-in" "$(cat "$calls")"
pass "removal deletes the polkit sandbox drop-in and reloads systemd"

grep -Fq $'omarchy-pkg-drop\tpinpam-git' "$calls" || fail "removal drops the pinpam-git package" "$(cat "$calls")"
grep -Fxq $'sudo\trm\t-f\t'"$policy_file" "$calls" || fail "removal deletes the policy file" "$(cat "$calls")"
[[ ! -e $policy_file ]] || fail "the policy file is gone"
grep -Fq 'omarchy-apply-lock' "$calls" || fail "removal resyncs the lock screen PAM stack" "$(cat "$calls")"
pass "removal drops the package, deletes the policy file, and resyncs the lock screen"

# Nothing configured at all: removal must not escalate anything beyond the
# package drop and lock resync, and it costs no extra prompts.
reset_fixtures
printf '#%%PAM-1.0\nauth       required pam_unix.so\n' >"$system_auth"
printf '#%%PAM-1.0\nauth\t\tinclude\t\tsystem-auth\n' >"$sudo_pam"
invoke_remove not-enrolled success ||
  fail "removal completes when nothing was ever configured" "$(cat "$test_tmp/stderr.log")"
if grep -Fq $'sudo\tsed' "$calls" || grep -Fq $'sudo\trm' "$calls" ||
  grep -Fq $'sudo\tsystemctl' "$calls" || grep -Fq 'sudo-pinutil-delete' "$calls"; then
  fail "removal escalates nothing beyond the package drop on an unconfigured machine" "$(cat "$calls")"
fi
pass "removal escalates nothing extra on a machine that was never configured"

# pinutil missing entirely (package already gone): removal must not try to
# invoke it at all.
reset_fixtures
printf '#%%PAM-1.0\nauth       required pam_unix.so\n' >"$system_auth"
printf '#%%PAM-1.0\nauth\t\tinclude\t\tsystem-auth\n' >"$sudo_pam"
no_pinutil_bin="$test_tmp/no-pinutil-bin"
mkdir -p "$no_pinutil_bin"
for helper in sudo omarchy-pkg-drop omarchy-apply-lock; do
  ln -s "$stub_bin/$helper" "$no_pinutil_bin/$helper"
done
# remove_pam_config() reads /etc/pam.d/* with a bare (non-sudo) grep, so this
# scenario needs a real grep on PATH -- but PATH can't just fall back to the
# real system's, or it resolves a genuinely-installed pinutil binary too (as
# it does on this dogfood machine right now), defeating the "pinutil already
# gone" premise. Link only grep, and fake omarchy-cmd-present to always
# report pinutil absent, rather than relying on a PATH that happens to hide
# it, which would only work by accident of whatever host runs the suite.
ln -s "$(command -v grep)" "$no_pinutil_bin/grep"
# PATH is overridden for the whole invocation below, including the lookup of
# "bash" itself -- needs to be reachable too, not just available to the
# script's own internal command lookups.
ln -s "$(command -v bash)" "$no_pinutil_bin/bash"
cat >"$no_pinutil_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == pinutil ]] && exit 1
command -v "$1" >/dev/null
SH
chmod +x "$no_pinutil_bin/omarchy-cmd-present"
: >"$calls"
TEST_CALLS="$calls" PATH="$no_pinutil_bin" \
  bash "$remove_copy" </dev/null >"$test_tmp/stdout.log" 2>"$test_tmp/stderr.log" ||
  fail "removal completes when pinutil is already gone" "$(cat "$test_tmp/stderr.log")"
if grep -Fq 'pinutil' "$calls"; then
  fail "removal never invokes a nonexistent pinutil" "$(cat "$calls")"
fi
pass "removal never invokes pinutil once the package is already gone"

# A failed pinutil delete must not abort the rest of the removal.
reset_fixtures
printf 'auth       [success=2 default=ignore]  libpinpam.so\nauth       [success=1 default=bad]     pam_unix.so\n' >"$system_auth"
printf '#%%PAM-1.0\nauth      sufficient libpinpam.so\nauth\t\tinclude\t\tsystem-auth\n' >"$sudo_pam"
invoke_remove enrolled fail ||
  fail "removal continues past a failed pinutil delete" "$(cat "$test_tmp/stderr.log")"
grep -Fxq $'sudo\tsed\t-i\t/libpinpam\\.so/d\t'"$system_auth" "$calls" ||
  fail "removal still strips PIN from login after a failed pinutil delete" "$(cat "$calls")"
grep -Fxq $'sudo\tsed\t-i\t/libpinpam\\.so/d\t'"$sudo_pam" "$calls" ||
  fail "removal still strips PAM lines after a failed pinutil delete" "$(cat "$calls")"
grep -Fq $'omarchy-pkg-drop\tpinpam-git' "$calls" ||
  fail "removal still drops the package after a failed pinutil delete" "$(cat "$calls")"
pass "removal tolerates a failed pinutil delete and still finishes"
