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
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/ssh-hardening.sh"

SSHD_CONF="$TMPDIR/etc/ssh/sshd_config.d/99-omarchy-hardening.conf"
SSH_CONF="$TMPDIR/etc/ssh/ssh_config.d/99-omarchy-hardening.conf"

[[ -f $SSHD_CONF ]] || fail "sshd hardening dropin exists"
pass "sshd hardening dropin exists"
assert_file_contains "root login disabled" "$SSHD_CONF" "PermitRootLogin no"
assert_file_contains "pubkey auth enabled" "$SSHD_CONF" "PubkeyAuthentication yes"
assert_file_contains "chacha20 cipher configured in sshd" "$SSHD_CONF" "chacha20-poly1305@openssh.com"
assert_file_contains "curve25519 kex configured in sshd" "$SSHD_CONF" "curve25519-sha256"

[[ -f $SSH_CONF ]] || fail "ssh client hardening dropin exists"
pass "ssh client hardening dropin exists"
assert_file_contains "chacha20 cipher configured in client" "$SSH_CONF" "chacha20-poly1305@openssh.com"
assert_file_contains "ed25519 host key algorithm configured" "$SSH_CONF" "HostKeyAlgorithms ssh-ed25519"
