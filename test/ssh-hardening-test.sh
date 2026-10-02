#!/bin/bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TMPDIR=$(mktemp -d)

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local description="$1"
  local file="$2"
  local expected="$3"

  if ! grep -Fq "$expected" "$file"; then
    printf 'Expected file %s to contain: %s\n' "$file" "$expected" >&2
    fail "$description"
  fi

  pass "$description"
}

cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

BINDIR="$TMPDIR/bin"
mkdir -p "$BINDIR"

cat > "$BINDIR/systemctl" <<EOF
#!/bin/bash
exit 0
EOF
chmod +x "$BINDIR/systemctl"

cat > "$BINDIR/sudo" <<EOF
#!/bin/bash
if [[ \$1 == "mkdir" ]]; then
  shift
  target="$TMPDIR\${@: -1}"
  mkdir -p "\$target"
elif [[ \$1 == "tee" ]]; then
  shift
  target="$TMPDIR\$1"
  mkdir -p "\$(dirname "\$target")"
  cat > "\$target"
elif [[ \$1 == "chmod" ]]; then
  exit 0
elif [[ \$1 == "sshd" ]]; then
  exit 0
elif [[ \$1 == "systemctl" ]]; then
  exit 0
else
  echo "unexpected sudo command: \$*" >&2
  exit 1
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/ssh-hardening.sh"

SSHD_CONF="$TMPDIR/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"
SSH_CONF="$TMPDIR/etc/ssh/ssh_config.d/10-omarchy-hardening.conf"

[[ -f $SSHD_CONF ]] || fail "sshd hardening dropin exists"
pass "sshd hardening dropin exists"
assert_file_contains "root login disabled" "$SSHD_CONF" "PermitRootLogin no"
assert_file_contains "pubkey auth enabled" "$SSHD_CONF" "PubkeyAuthentication yes"
assert_file_contains "chacha20 cipher configured in sshd" "$SSHD_CONF" "chacha20-poly1305@openssh.com"

[[ -f $SSH_CONF ]] || fail "ssh client hardening dropin exists"
pass "ssh client hardening dropin exists"
assert_file_contains "chacha20 cipher configured in client" "$SSH_CONF" "chacha20-poly1305@openssh.com"

# Verify migration matches install output and is idempotent
cp "$SSHD_CONF" "$TMPDIR/install-sshd.conf"
rm -rf "$TMPDIR/etc"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963220.sh"
[[ -f $SSHD_CONF ]] || fail "migration created dropin"
cmp -s "$TMPDIR/install-sshd.conf" "$SSHD_CONF" || fail "migration matches install dropin"
pass "migration matches install dropin"

# Second run is idempotent
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963220.sh"
pass "migration is idempotent"


