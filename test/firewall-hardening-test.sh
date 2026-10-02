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
elif [[ \$1 == "ufw-docker" ]]; then
  exit 0
elif [[ \$1 == "systemctl" ]]; then
  shift
  echo "systemctl \$*" >> "$LOG_FILE"
  exit 0
elif [[ \$1 == "sed" ]]; then
  exit 0
else
  echo "unexpected sudo command: \$*" >&2
  exit 1
fi
EOF
chmod +x "$BINDIR/sudo"

cat > "$BINDIR/ufw" <<EOF
#!/bin/bash
exit 0
EOF
chmod +x "$BINDIR/ufw"

PATH="$BINDIR:$PATH" bash "$ROOT/install/config/firewall-hardening.sh"

[[ -f $LOG_FILE ]] || fail "ufw commands executed"
pass "ufw commands executed"

grep -Fq "ufw default deny incoming" "$LOG_FILE" || fail "default deny incoming set"
pass "default deny incoming set"

grep -Fq "ufw default allow outgoing" "$LOG_FILE" || fail "default allow outgoing set"
pass "default allow outgoing set"

grep -Fq "ufw allow 53317/udp comment localsend" "$LOG_FILE" || fail "localsend udp allowed"
pass "localsend udp allowed"

grep -Fq "ufw allow 53317/tcp comment localsend" "$LOG_FILE" || fail "localsend tcp allowed"
pass "localsend tcp allowed"

grep -Fq "ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment allow-docker-dns" "$LOG_FILE" || fail "docker dns 172.16 allowed"
pass "docker dns 172.16 allowed"

grep -Fq "ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment allow-docker-dns" "$LOG_FILE" || fail "docker dns 192.168 allowed"
pass "docker dns 192.168 allowed"

grep -Fq "systemctl enable ufw.service" "$LOG_FILE" || fail "ufw service enabled"
pass "ufw service enabled"

# Verify migration matches install operations
cp "$LOG_FILE" "$TMPDIR/install-ufw.log"
rm -f "$LOG_FILE"
PATH="$BINDIR:$PATH" bash "$ROOT/migrations/1790963205.sh"
cmp -s "$TMPDIR/install-ufw.log" "$LOG_FILE" || fail "migration matches install operations"
pass "migration matches install operations"


