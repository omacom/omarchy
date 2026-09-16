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
else
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/service-sandboxing.sh"

SSHD_DROPIN="$TMPDIR/etc/systemd/system/sshd.service.d/99-omarchy-hardening.conf"
NM_DROPIN="$TMPDIR/etc/systemd/system/NetworkManager.service.d/99-omarchy-hardening.conf"
RESOLVED_DROPIN="$TMPDIR/etc/systemd/resolved.conf.d/99-omarchy-hardening.conf"

[[ -f $SSHD_DROPIN ]] || fail "sshd dropin exists"
pass "sshd dropin exists"
assert_file_contains "sshd ProtectSystem strict" "$SSHD_DROPIN" "ProtectSystem=strict"
assert_file_contains "sshd ProtectHome yes" "$SSHD_DROPIN" "ProtectHome=yes"
assert_file_contains "sshd PrivateTmp yes" "$SSHD_DROPIN" "PrivateTmp=yes"
assert_file_contains "sshd NoNewPrivileges yes" "$SSHD_DROPIN" "NoNewPrivileges=yes"

[[ -f $NM_DROPIN ]] || fail "NetworkManager dropin exists"
pass "NetworkManager dropin exists"
assert_file_contains "NetworkManager ProtectSystem strict" "$NM_DROPIN" "ProtectSystem=strict"
assert_file_contains "NetworkManager ProtectHome yes" "$NM_DROPIN" "ProtectHome=yes"

[[ -f $RESOLVED_DROPIN ]] || fail "resolved dropin exists"
pass "resolved dropin exists"
assert_file_contains "LLMNR disabled in resolved" "$RESOLVED_DROPIN" "LLMNR=no"
assert_file_contains "MulticastDNS disabled in resolved" "$RESOLVED_DROPIN" "MulticastDNS=no"
