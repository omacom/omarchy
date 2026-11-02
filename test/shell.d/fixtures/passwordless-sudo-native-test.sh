#!/bin/bash

# The host only launches Docker. The checkout is read-only and every command
# under test, including real sudo, runs inside the disposable container.
run_native_passwordless_sudo_test() {
  local image=${OMARCHY_NATIVE_SUDO_IMAGE:-} name output status=0
  [[ -n $image ]] || {
    skip "set OMARCHY_NATIVE_SUDO_IMAGE to a local image containing sudo"
    return
  }
  command -v docker >/dev/null || fail "Docker is required for native passwordless sudo coverage"
  command -v timeout >/dev/null || fail "timeout is required for native passwordless sudo coverage"

  name="omarchy-native-sudo-$$"
  trap 'docker rm -f "$name" >/dev/null 2>&1 || true' RETURN
  output=$(timeout 30 docker run --rm --name "$name" --pull never -i --network none --read-only \
    --hostname localhost \
    --cap-drop ALL --cap-add SETUID --cap-add SETGID --cap-add AUDIT_WRITE \
    --pids-limit 64 --memory 256m --cpus 1 --ulimit fsize=1048576 \
    --tmpfs /tmp:rw,nosuid,nodev,noexec,size=8m \
    --tmpfs /run:rw,nosuid,nodev,size=8m \
    --tmpfs /var:rw,nosuid,nodev,size=8m \
    --tmpfs /home:rw,nosuid,nodev,size=1m \
    --tmpfs /etc/sudoers.d:rw,nosuid,nodev,size=1m \
    --mount "type=bind,src=$ROOT,dst=/source,readonly" \
    --entrypoint /usr/bin/env "$image" -i \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin HOME=/home/nobody TMPDIR=/tmp XDG_CACHE_HOME=/tmp/cache LC_ALL=C TERM=dumb \
    /bin/bash -p -s 2>&1 <<'CONTAINER'
set -euo pipefail

mkdir -p /run/lock /tmp/cache
chmod 0755 /run /run/lock /etc/sudoers.d
# The image's root-owned /etc/sudoers must include this tmpfs directory. The
# policy is created only after Docker starts, so no host policy is mounted.
grep -Eq '^[[:space:]]*#includedir[[:space:]]+/etc/sudoers\.d$' /etc/sudoers
cat >/etc/sudoers.d/00-native-password-required <<'SUDOERS'
Defaults timestamp_timeout=10
Defaults timestamp_type=global
nobody ALL=(ALL:ALL) ALL
daemon ALL=(ALL:ALL) ALL
SUDOERS
chmod 0440 /etc/sudoers.d/00-native-password-required
visudo -cf /etc/sudoers >/dev/null

as_user() {
  local uid=$1 gid=$2
  shift 2
  /usr/bin/setpriv --reuid="$uid" --regid="$gid" --clear-groups -- "$@"
}
expect_success() {
  local description=$1 stdout stderr status=0
  shift
  stdout=$(mktemp)
  stderr=$(mktemp)
  "$@" >"$stdout" 2>"$stderr" || status=$?
  [[ $status == 0 && ! -s $stdout && ! -s $stderr ]] || {
    printf '%s: status=%s stdout=%s stderr=%s\n' "$description" "$status" "$(<"$stdout")" "$(<"$stderr")" >&2
    exit 1
  }
}
expect_password() {
  local description=$1 stdout stderr status=0
  shift
  stdout=$(mktemp)
  stderr=$(mktemp)
  "$@" >"$stdout" 2>"$stderr" || status=$?
  [[ $status == 1 && ! -s $stdout && $(<"$stderr") == 'sudo: a password is required' ]] || {
    printf '%s: status=%s stdout=%s stderr=%s\n' "$description" "$status" "$(<"$stdout")" "$(<"$stderr")" >&2
    exit 1
  }
}
verify_and_run() {
  expect_success "$1 validates" as_user "$2" "$3" /usr/bin/sudo -n -v
  expect_success "$1 runs" as_user "$2" "$3" /usr/bin/sudo -n /usr/bin/true
}
refuse_verify_and_run() {
  expect_password "$1 validation" as_user "$2" "$3" /usr/bin/sudo -n -v
  expect_password "$1 command" as_user "$2" "$3" /usr/bin/sudo -n /usr/bin/true
}

# The generated permanent grant is published by the real command. SUDO_UID is
# what sudo supplies after the interactive public enable action succeeds.
as_user 65534 65534 /usr/bin/sudo -K
as_user 1 1 /usr/bin/sudo -K
refuse_verify_and_run 'nobody baseline' 65534 65534
refuse_verify_and_run 'daemon baseline' 1 1
SUDO_UID=65534 /source/bin/omarchy-sudo-passwordless __enable 65534 permanent
verify_and_run 'generated grant' 65534 65534
refuse_verify_and_run 'daemon during grant' 1 1

# Do not invalidate sudo's cache here: the refusal proves publication removal
# itself left no usable timestamp from the active checks.
SUDO_UID=65534 /source/bin/omarchy-sudo-passwordless __disable 65534
refuse_verify_and_run 'revoked grant' 65534 65534
refuse_verify_and_run 'daemon after revoke' 1 1

# Preserve the publisher's generated account-scoped default and replace only
# the timed rule's deadline. systemd is deliberately not started in this test.
SUDO_UID=65534 /source/bin/omarchy-sudo-passwordless __enable 65534 permanent
deadline=$(/usr/bin/date -u -d 'now + 3 seconds' +%Y%m%d%H%M%SZ)
permanent=/etc/sudoers.d/99-omarchy-permanent-nopasswd-65534
timed=/etc/sudoers.d/99-omarchy-nopasswd-65534
pending=$(mktemp /etc/sudoers.d/.native-expiry.XXXXXX)
{ head -1 "$permanent"; printf 'nobody ALL=(ALL) NOTAFTER=%s NOPASSWD: ALL\n' "$deadline"; } >"$pending"
chmod 0440 "$pending"
visudo -cf "$pending" >/dev/null
mv -fT "$pending" "$timed"
rm "$permanent"
visudo -cf /etc/sudoers >/dev/null
verify_and_run 'expiry fixture' 65534 65534
/usr/bin/sleep 4
# Sudo 1.8.31 lets -v inspect this expired rule, but it cannot execute a
# command. The actual expiry callback removes the policy before checking both.
expect_password 'expired grant command' as_user 65534 65534 /usr/bin/sudo -n /usr/bin/true
/source/bin/omarchy-sudo-passwordless __expire 65534
[[ ! -e $timed ]]
refuse_verify_and_run 'expired grant cleanup' 65534 65534
refuse_verify_and_run 'daemon after expiry' 1 1
CONTAINER
) || status=$?

  if (( status != 0 )); then
    fail "native sudo grants validate, revoke, expire, and isolate accounts" "$output"
  fi
  pass "native sudo grants validate, revoke, expire, and isolate accounts"
}
