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
if [[ \$1 == "tee" ]]; then
  shift
  target="$TMPDIR\$1"
  mkdir -p "\$(dirname "\$target")"
  cat > "\$target"
elif [[ \$1 == "chmod" ]]; then
  exit 0
elif [[ \$1 == "visudo" ]]; then
  exit 0
else
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/sudo-hardening.sh"

SUDO_CONF="$TMPDIR/etc/sudoers.d/99-omarchy-hardening"

[[ -f $SUDO_CONF ]] || fail "sudo hardening dropin exists"
pass "sudo hardening dropin exists"
assert_file_contains "env_reset enabled" "$SUDO_CONF" "Defaults env_reset"
assert_file_contains "mail_badpass enabled" "$SUDO_CONF" "Defaults mail_badpass"
assert_file_contains "use_pty enabled" "$SUDO_CONF" "Defaults use_pty"
