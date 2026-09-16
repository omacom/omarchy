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

LOG_FILE="$TMPDIR/ufw.log"

cat > "$BINDIR/omarchy-pkg-missing" <<EOF
#!/bin/bash
exit 1
EOF
chmod +x "$BINDIR/omarchy-pkg-missing"

cat > "$BINDIR/omarchy-pkg-add" <<EOF
#!/bin/bash
exit 0
EOF
chmod +x "$BINDIR/omarchy-pkg-add"

cat > "$BINDIR/sudo" <<EOF
#!/bin/bash
if [[ \$1 == "ufw" ]]; then
  shift
  echo "ufw \$*" >> "$LOG_FILE"
  exit 0
elif [[ \$1 == "systemctl" ]]; then
  shift
  echo "systemctl \$*" >> "$LOG_FILE"
  exit 0
else
  "\$@"
fi
EOF
chmod +x "$BINDIR/sudo"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/firewall-hardening.sh"

[[ -f $LOG_FILE ]] || fail "ufw commands executed"
pass "ufw commands executed"

grep -Fq "ufw default deny incoming" "$LOG_FILE" || fail "default deny incoming set"
pass "default deny incoming set"

grep -Fq "ufw default allow outgoing" "$LOG_FILE" || fail "default allow outgoing set"
pass "default allow outgoing set"

grep -Fq "ufw --force enable" "$LOG_FILE" || fail "ufw enabled"
pass "ufw enabled"

grep -Fq "systemctl enable ufw.service" "$LOG_FILE" || fail "ufw service enabled"
pass "ufw service enabled"
