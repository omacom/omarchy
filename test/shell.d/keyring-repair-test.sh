#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

repair="$ROOT/bin/omarchy-keyring-repair"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export OMARCHY_KEYRING_DIR="$tmpdir/keyrings"

has_backup() {
  local prefix=$1
  local matches=("$OMARCHY_KEYRING_DIR"/"$prefix".broken-*)
  [[ -e ${matches[0]} ]]
}

# Healthy cleartext stub must be left alone.
mkdir -p "$OMARCHY_KEYRING_DIR"
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
[keyring]
display-name=Default keyring
ctime=1
mtime=0
lock-on-idle=false
lock-after=false
EOF
printf 'Default_keyring\n' >"$OMARCHY_KEYRING_DIR/default"
cp -a "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" "$tmpdir/before.keyring"

"$repair"

cmp -s "$tmpdir/before.keyring" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid cleartext keyring was rewritten"
pass "valid cleartext keyring is left alone"

# Multi-line secret (the #12563 failure mode) must be backed up and replaced.
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
[keyring]
display-name=Default keyring
ctime=1
mtime=0
lock-on-idle=false
lock-after=false

[1]
item-type=0
display-name=io.ente.auth/FlutterSecureStorage
secret={
  "auth_secret_key": "REDACTED",
  "key": "REDACTED"
}
mtime=1
ctime=1
EOF

"$repair"

has_backup Default_keyring.keyring ||
  fail "corrupt cleartext keyring was not backed up"
grep -Fq '[keyring]' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "repaired keyring is missing the cleartext header"
if grep -Fq 'auth_secret_key' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring"; then
  fail "corrupt multi-line secret survived repair"
fi
pass "corrupt multi-line cleartext keyring is replaced"

# Password-protected default pointer (autologin dead-end) must be reset.
# Use a distinct name so this fixture stays valid on case-insensitive volumes
# (macOS) as well as on Arch.
printf 'login\n' >"$OMARCHY_KEYRING_DIR/default"
printf 'GNUPG\x01encrypted-not-really' >"$OMARCHY_KEYRING_DIR/login.keyring"

"$repair"

[[ $(tr -d '[:space:]' <"$OMARCHY_KEYRING_DIR/default") == Default_keyring ]] ||
  fail "default pointer was not reset to the cleartext keyring"
has_backup login.keyring ||
  fail "password-protected keyring was not backed up"
grep -Fq '[keyring]' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "cleartext default keyring missing after encrypted reset"
pass "password-protected default is reset to cleartext"

service="$ROOT/default/systemd/user/omarchy-keyring-repair.service"
grep -Fx 'ExecStart=/usr/bin/omarchy-keyring-repair' "$service" >/dev/null ||
  fail "keyring repair service must call omarchy-keyring-repair"
grep -Fx 'WantedBy=graphical-session-pre.target' "$service" >/dev/null ||
  fail "keyring repair must run before graphical-session-pre"
grep -F 'omarchy-keyring-repair.service' \
  "$ROOT/install/user/first-run/enable-user-units.sh" >/dev/null ||
  fail "first-run must enable the keyring repair service"
pass "keyring repair service is wired into early session startup"
