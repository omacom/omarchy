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
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/file-permissions.sh"

[[ -f $LOG_FILE ]] || fail "chmod operations executed"
pass "chmod operations executed"

grep -Fq "700 /root" "$LOG_FILE" || fail "root directory secured"
pass "root directory secured"

grep -Fq "600 /etc/shadow" "$LOG_FILE" || fail "shadow file secured"
pass "shadow file secured"

grep -Fq "600 /etc/gshadow" "$LOG_FILE" || fail "gshadow file secured"
pass "gshadow file secured"

grep -Fq "644 /etc/passwd" "$LOG_FILE" || fail "passwd file mode set"
pass "passwd file mode set"

grep -Fq "644 /etc/group" "$LOG_FILE" || fail "group file mode set"
pass "group file mode set"

grep -Fq "600 /etc/ssh/sshd_config" "$LOG_FILE" || fail "sshd_config secured"
pass "sshd_config secured"
