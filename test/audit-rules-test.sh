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

  if ! grep -Fq -e "$expected" "$file"; then
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
elif [[ \$1 == "systemctl" || \$1 == "augenrules" || \$1 == "auditctl" ]]; then
  exit 0
else
  echo "unexpected sudo command: \$*" >&2
  exit 1
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/audit-rules.sh"

RULES_CONF="$TMPDIR/etc/audit/rules.d/99-omarchy-hardening.rules"

[[ -f $RULES_CONF ]] || fail "audit rules conf exists"
pass "audit rules conf exists"

assert_file_contains "passwd write watch configured" "$RULES_CONF" "-w /etc/passwd -p wa -k omarchy-identity"
assert_file_contains "shadow write watch configured" "$RULES_CONF" "-w /etc/shadow -p wa -k omarchy-identity"
assert_file_contains "sudoers write watch configured" "$RULES_CONF" "-w /etc/sudoers -p wa -k omarchy-sudoers"
assert_file_contains "sudoers.d write watch configured" "$RULES_CONF" "-w /etc/sudoers.d/ -p wa -k omarchy-sudoers"
assert_file_contains "pam.d write watch configured" "$RULES_CONF" "-w /etc/pam.d/ -p wa -k omarchy-pam"
assert_file_contains "privilege escalation execve monitored" "$RULES_CONF" "uid!=euid -F euid=0 -k omarchy-priv-esc"

# Verify migration matches install output and is idempotent
cp "$RULES_CONF" "$TMPDIR/install-audit.rules"
rm -rf "$TMPDIR/etc"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963210.sh"
[[ -f $RULES_CONF ]] || fail "migration created audit rules"
cmp -s "$TMPDIR/install-audit.rules" "$RULES_CONF" || fail "migration matches install rules"
pass "migration matches install rules"

# Second run is idempotent
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963210.sh"
pass "migration is idempotent"


