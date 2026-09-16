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
elif [[ \$1 == "auditctl" ]]; then
  exit 0
else
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/audit-rules.sh"

RULES_CONF="$TMPDIR/etc/audit/rules.d/99-omarchy-hardening.rules"

[[ -f $RULES_CONF ]] || fail "audit rules conf exists"
pass "audit rules conf exists"

assert_file_contains "passwd write watch configured" "$RULES_CONF" "-w /etc/passwd -p wa -k identity"
assert_file_contains "shadow write watch configured" "$RULES_CONF" "-w /etc/shadow -p wa -k identity"
assert_file_contains "sudoers write watch configured" "$RULES_CONF" "-w /etc/sudoers -p wa -k sudoers"
assert_file_contains "sshd_config write watch configured" "$RULES_CONF" "-w /etc/ssh/sshd_config -p wa -k sshd"
assert_file_contains "privilege escalation execve monitored" "$RULES_CONF" "uid!=euid -F euid=0 -k privilege_escalation"
