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

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/coredump-hardening.sh"

LIMITS_CONF="$TMPDIR/etc/security/limits.d/99-no-core.conf"
SYSTEMD_CONF="$TMPDIR/etc/systemd/system.conf.d/99-no-core.conf"
COREDUMP_CONF="$TMPDIR/etc/systemd/coredump.conf.d/99-no-core.conf"

[[ -f $LIMITS_CONF ]] || fail "limits conf exists"
pass "limits conf exists"
assert_file_contains "hard core limit is 0" "$LIMITS_CONF" "* hard core 0"
assert_file_contains "soft core limit is 0" "$LIMITS_CONF" "* soft core 0"

[[ -f $SYSTEMD_CONF ]] || fail "systemd system conf exists"
pass "systemd system conf exists"
assert_file_contains "systemd core limit is 0" "$SYSTEMD_CONF" "DefaultLimitCORE=0"

[[ -f $COREDUMP_CONF ]] || fail "systemd coredump conf exists"
pass "systemd coredump conf exists"
assert_file_contains "coredump storage is none" "$COREDUMP_CONF" "Storage=none"
assert_file_contains "process size max is 0" "$COREDUMP_CONF" "ProcessSizeMax=0"
