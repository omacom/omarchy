#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

repair="$ROOT/bin/omarchy-keyring-repair"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export OMARCHY_KEYRING_DIR="$tmpdir/keyrings"
mkdir -p "$OMARCHY_KEYRING_DIR"

# 1. Preserves valid cleartext keyrings without byte alteration
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
[keyring]
display-name=Default keyring
ctime=1700000000
mtime=1700000000
lock-on-idle=false
lock-after=false

[1]
item-type=0
display-name=Valid Secret
secret=singleline_secret_value
mtime=1700000000
ctime=1700000000
EOF

cp -a "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" "$tmpdir/before.keyring"
python3 "$repair"
cmp -s "$tmpdir/before.keyring" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid cleartext keyring was altered"
pass "valid cleartext keyring is unmodified"

# 2. Repairs unescaped multiline secret in-place without data loss
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
[keyring]
display-name=Default keyring
ctime=1700000000
mtime=1700000000

[1]
item-type=0
display-name=Chromium Safe Storage
secret=C8aLYMkXBDnNoGLPjj/opg==
mtime=1700000000
ctime=1700000000

[2]
item-type=0
display-name=Proton VPN OpenVPN Credentials
secret=line1
line2
line3
mtime=1700000000
ctime=1700000000

[3]
item-type=0
display-name=Claude Safe Storage
secret=N6r6grCAlNU4IRv3ZhcX8Q==
mtime=1700000000
ctime=1700000000
EOF

python3 "$repair"

# Assert valid secrets preserved
grep -Fq 'secret=C8aLYMkXBDnNoGLPjj/opg==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 1 was destroyed during repair"
grep -Fq 'secret=N6r6grCAlNU4IRv3ZhcX8Q==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 3 was destroyed during repair"

# Assert multiline folded onto single escaped line
grep -Fq 'secret=line1\nline2\nline3' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "multiline secret was not properly folded and escaped"

# Assert no stray continuation lines remain
! grep -Fxq 'line2' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"
! grep -Fxq 'line3' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"

pass "multiline secrets folded with zero data loss"

# 3. Encrypted binary keyrings are left untouched (#14913 compatibility)
printf 'GnomeKeyring\n\r\0\0encrypted_binary_payload' >"$OMARCHY_KEYRING_DIR/login.keyring"
cp -a "$OMARCHY_KEYRING_DIR/login.keyring" "$tmpdir/login.before"
python3 "$repair"
cmp -s "$tmpdir/login.before" "$OMARCHY_KEYRING_DIR/login.keyring" ||
  fail "encrypted binary keyring was altered by repair script"
pass "encrypted keyrings remain untouched"

# 4. Comments and blank lines are preserved
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
# Standard Omarchy cleartext keyring
[keyring]
display-name=Default keyring
ctime=1700000000
mtime=1700000000

# First secret item
[1]
item-type=0
display-name=Secret With Comment
secret=test\nvalue
mtime=1700000000
ctime=1700000000
EOF

cp -a "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" "$tmpdir/comments.before"
python3 "$repair"
cmp -s "$tmpdir/comments.before" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "keyring with comments was altered"
pass "keyring with comments and blank lines is preserved"

# 5. Missing directory or empty directory exits 0 cleanly
export OMARCHY_KEYRING_DIR="$tmpdir/nonexistent"
python3 "$repair" || fail "repair script failed on missing directory"
pass "missing keyring directory handled cleanly"
