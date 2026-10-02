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
  exit 0
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/module-hardening.sh"

PROTOCOLS_CONF="$TMPDIR/etc/modprobe.d/omarchy-disable-protocols.conf"
FIREWIRE_CONF="$TMPDIR/etc/modprobe.d/omarchy-disable-firewire.conf"
FS_CONF="$TMPDIR/etc/modprobe.d/omarchy-disable-legacy-fs.conf"

[[ -f $PROTOCOLS_CONF ]] || fail "protocols blacklist exists"
pass "protocols blacklist exists"
assert_file_contains "dccp disabled" "$PROTOCOLS_CONF" "install dccp /bin/true"
assert_file_contains "sctp disabled" "$PROTOCOLS_CONF" "install sctp /bin/true"
assert_file_contains "rds disabled" "$PROTOCOLS_CONF" "install rds /bin/true"
assert_file_contains "tipc disabled" "$PROTOCOLS_CONF" "install tipc /bin/true"

[[ -f $FIREWIRE_CONF ]] || fail "firewire blacklist exists"
pass "firewire blacklist exists"
assert_file_contains "firewire-core blacklisted" "$FIREWIRE_CONF" "blacklist firewire-core"

[[ -f $FS_CONF ]] || fail "legacy fs blacklist exists"
pass "legacy fs blacklist exists"
assert_file_contains "cramfs blacklisted" "$FS_CONF" "blacklist cramfs"
assert_file_contains "hfs blacklisted" "$FS_CONF" "blacklist hfs"
assert_file_contains "hfsplus blacklisted" "$FS_CONF" "blacklist hfsplus"

if [[ -f "$TMPDIR/etc/modprobe.d/omarchy-disable-usb-storage.conf" ]]; then
  fail "usb-storage must NOT be disabled"
fi
pass "usb-storage is not disabled"

# Verify migration matches install output and is idempotent
cp "$PROTOCOLS_CONF" "$TMPDIR/install-protocols.conf"
cp "$FIREWIRE_CONF" "$TMPDIR/install-firewire.conf"
cp "$FS_CONF" "$TMPDIR/install-fs.conf"
rm -rf "$TMPDIR/etc"

PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963225.sh"
[[ -f $PROTOCOLS_CONF ]] || fail "migration created protocols dropin"
[[ -f $FIREWIRE_CONF ]] || fail "migration created firewire dropin"
[[ -f $FS_CONF ]] || fail "migration created fs dropin"
cmp -s "$TMPDIR/install-protocols.conf" "$PROTOCOLS_CONF" || fail "protocols dropin matches"
cmp -s "$TMPDIR/install-firewire.conf" "$FIREWIRE_CONF" || fail "firewire dropin matches"
cmp -s "$TMPDIR/install-fs.conf" "$FS_CONF" || fail "fs dropin matches"
pass "migration matches install dropins"

# Second run is idempotent
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963225.sh"
pass "migration is idempotent"


