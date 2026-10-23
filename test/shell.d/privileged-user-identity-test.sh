#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

! grep -Fq '${USER}' "$ROOT/bin/omarchy-sudo-passwordless" ||
  fail "passwordless sudo does not interpolate USER into sudoers"

# A bare id -nG reports this session's groups, fixed at login, so --configured
# must name the euid's account to see a change made since.
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT
cat >"$stub_dir/id" <<'STUB'
#!/bin/bash
case "$*" in
  -un) echo alice ;;
  "-nG alice") echo "alice wheel docker" ;;
  *) echo "alice wheel" ;;
esac
STUB
chmod +x "$stub_dir/id"
status=0
USER=nobody PATH="$stub_dir:$PATH" "$ROOT/bin/omarchy-sudo-docker" --configured || status=$?
(( status == 1 )) ||
  fail "sudoless Docker --configured reads the euid account's configured groups"

for cmd in \
  "$ROOT/bin/omarchy-setup-security-sudoless-docker" \
  "$ROOT/bin/omarchy-remove-security-sudoless-docker" \
  "$ROOT/bin/omarchy-dev-install-ydoo" \
  "$ROOT/bin/omarchy-install-service-tailscale" \
  "$ROOT/bin/omarchy-install-gaming-xbox-controllers" \
  "$ROOT/bin/omarchy-install-service-nordvpn"
do
  grep -Fq 'user=$(id -un)' "$cmd" ||
    fail "$(basename "$cmd") takes the username from id -un"
  ! grep -Fq '"$USER"' "$cmd" ||
    fail "$(basename "$cmd") does not pass USER to a privileged command"
done

fingerprint="$ROOT/bin/omarchy-setup-security-fingerprint"
grep -Fq 'user=$(id -un)' "$fingerprint" && grep -Fq 'fprintd-enroll "$user"' "$fingerprint" ||
  fail "fingerprint enroll uses id -un"
grep -Fq 'OMARCHY_INSTALL_USER="$user" "$OMARCHY_PATH/bin/omarchy-apply-lock"' "$fingerprint" ||
  fail "fingerprint setup configures the lock screen for the enrolled account"

pass "privileged commands take the username from the euid, not USER"
