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
elif [[ \$1 == "systemctl" ]]; then
  exit 0
else
  echo "unexpected sudo command: \$*" >&2
  exit 1
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/service-sandboxing.sh"

RESOLVED_DROPIN="$TMPDIR/etc/systemd/resolved.conf.d/99-omarchy-hardening.conf"

[[ -f $RESOLVED_DROPIN ]] || fail "resolved dropin exists"
pass "resolved dropin exists"
grep -qx 'LLMNR=no' "$RESOLVED_DROPIN" || fail "LLMNR disabled in resolved"
pass "LLMNR disabled in resolved"
grep -qx 'MulticastDNS=no' "$RESOLVED_DROPIN" || fail "MulticastDNS disabled in resolved"
pass "MulticastDNS disabled in resolved"

# Verify migration script matches install output and is idempotent
cp "$RESOLVED_DROPIN" "$TMPDIR/install-resolved.conf"
rm -rf "$TMPDIR/etc"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963200.sh"
[[ -f $RESOLVED_DROPIN ]] || fail "migration created dropin"
cmp -s "$TMPDIR/install-resolved.conf" "$RESOLVED_DROPIN" || fail "migration matches install dropin"
pass "migration matches install dropin"

# Second run should be no-op (idempotent)
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963200.sh"
pass "migration is idempotent"


