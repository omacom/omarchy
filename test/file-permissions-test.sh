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

cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

BINDIR="$TMPDIR/bin"
mkdir -p "$BINDIR"

LOG_FILE="$TMPDIR/chmod.log"

cat > "$BINDIR/sudo" <<EOF
#!/bin/bash
if [[ \$1 == "chmod" ]]; then
  shift
  echo "\$@" >> "$LOG_FILE"
  exit 0
else
  exit 0
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/file-permissions.sh"

[[ -f $LOG_FILE ]] || fail "chmod operations executed"
pass "chmod operations executed"

grep -Fq "700 /root" "$LOG_FILE" || fail "root directory secured"
pass "root directory secured"

[[ -f /etc/shadow ]] && { grep -Fq "600 /etc/shadow" "$LOG_FILE" || fail "shadow file secured"; }
[[ -f /etc/gshadow ]] && { grep -Fq "600 /etc/gshadow" "$LOG_FILE" || fail "gshadow file handled"; }
[[ -f /etc/passwd ]] && { grep -Fq "644 /etc/passwd" "$LOG_FILE" || fail "passwd file mode set"; }
[[ -f /etc/group ]] && { grep -Fq "644 /etc/group" "$LOG_FILE" || fail "group file mode set"; }

if [[ -f /etc/ssh/sshd_config ]]; then
  grep -Fq "600 /etc/ssh/sshd_config" "$LOG_FILE" || fail "sshd_config secured"
fi
pass "install operations verified"

# Verify migration script matches install operations
cp "$LOG_FILE" "$TMPDIR/install-chmod.log"
rm -f "$LOG_FILE"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963195.sh"
cmp -s "$TMPDIR/install-chmod.log" "$LOG_FILE" || fail "migration matches install operations"
pass "migration matches install operations"


