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
elif [[ \$1 == "install" ]]; then
  shift
  mode="0440"
  if [[ \$1 == "-m" ]]; then
    mode="\$2"
    shift 2
  fi
  src="\$1"
  dest="$TMPDIR\$2"
  mkdir -p "\$(dirname "\$dest")"
  cp -f "\$src" "\$dest"
  chmod "\$mode" "\$dest"
elif [[ \$1 == "visudo" ]]; then
  exit 0
else
  exit 0
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/sudo-hardening.sh"

SUDO_CONF="$TMPDIR/etc/sudoers.d/99-omarchy-hardening"

[[ -f $SUDO_CONF ]] || fail "sudo hardening dropin exists"
pass "sudo hardening dropin exists"
assert_file_contains "env_reset enabled" "$SUDO_CONF" "Defaults env_reset"
assert_file_contains "use_pty enabled" "$SUDO_CONF" "Defaults use_pty"

# Verify migration matches install output and is idempotent
cp "$SUDO_CONF" "$TMPDIR/install-sudo.conf"
rm -rf "$TMPDIR/etc"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963215.sh"
[[ -f $SUDO_CONF ]] || fail "migration created dropin"
cmp -s "$TMPDIR/install-sudo.conf" "$SUDO_CONF" || fail "migration matches install dropin"
pass "migration matches install dropin"

# Second run is idempotent
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963215.sh"
pass "migration is idempotent"


