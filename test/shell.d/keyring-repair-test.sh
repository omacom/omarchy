#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

repair="$ROOT/bin/omarchy-keyring-repair"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export OMARCHY_KEYRING_DIR="$tmpdir/keyrings"
mkdir -p "$OMARCHY_KEYRING_DIR"

# 1. Preserves valid cleartext keyrings without byte alteration,
# including when secret= is the last property followed by blank lines and comments
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
# Standard Omarchy cleartext keyring
[keyring]
display-name=Default keyring
ctime=1700000000
mtime=1700000000

[1]
item-type=0
display-name=Valid Secret
secret=singleline_secret_value

# Separator comment before section 2
[2]
item-type=0
display-name=Second Valid Secret
secret=another_token

EOF

cp -a "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" "$tmpdir/before.keyring"
python3 "$repair"
cmp -s "$tmpdir/before.keyring" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid cleartext keyring was altered"
pass "valid cleartext keyring is unmodified"

# 2. Repairs unescaped multiline secret in-place with leading comments,
# interior blank lines, base64 padding, comments, and backslashes
cat >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring" <<'EOF'
# Standard Omarchy cleartext keyring
# Auto-generated during provisioning
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
display-name=Complex Multiline Secret
secret=line1_val
line2_with_equals=abc==
line3_with_backslash\slash	with	tab

# interior comment in secret
line4_end

# Separator comment before section 3
[3]
item-type=0
display-name=Claude Safe Storage
secret=N6r6grCAlNU4IRv3ZhcX8Q==
mtime=1700000000
ctime=1700000000

[2:attribute0]
name=service
type=string
value=roundtrip_test
EOF

python3 "$repair"

# Assert valid secrets preserved
grep -Fq 'secret=C8aLYMkXBDnNoGLPjj/opg==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 1 was destroyed during repair"
grep -Fq 'secret=N6r6grCAlNU4IRv3ZhcX8Q==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 3 was destroyed during repair"

# Assert multiline folded onto single escaped line
grep -Fq 'secret=line1_val\nline2_with_equals=abc==\nline3_with_backslash\\slash\twith\ttab\n\n# interior comment in secret\nline4_end' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "multiline secret was cut short or incorrectly escaped"

# Assert separator comment between sections was preserved outside secret
grep -Fq '# Separator comment before section 3' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "separator comment between sections was lost"

# Assert no stray continuation lines remain
! grep -Fxq 'line2_with_equals=abc==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"
! grep -Fxq 'line4_end' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"

pass "multiline secrets folded with zero data loss under leading comments"

# 3. Round-trip verification through the real reader (gnome-keyring-daemon & GLib)
export EXPECTED_RAW=$'line1_val\nline2_with_equals=abc==\nline3_with_backslash\\slash\twith\ttab\n\n# interior comment in secret\nline4_end'

# A) GLib GKeyFile direct C-binding verification
python3 - << 'PY'
import os
import gi
gi.require_version('GLib', '2.0')
from gi.repository import GLib

kf = GLib.KeyFile()
keyring_dir = os.environ["OMARCHY_KEYRING_DIR"]
kf.load_from_file(f"{keyring_dir}/Default_keyring.keyring", GLib.KeyFileFlags.KEEP_COMMENTS)
val = kf.get_string("2", "secret")
expected = os.environ["EXPECTED_RAW"]
assert val == expected, f"GLib recovered string mismatch: {repr(val)} != {repr(expected)}"
PY
pass "recovered secret bytes match via GLib GKeyFile parser"

# B) Live daemon round-trip verification via secret-tool (if tools are available)
if command -v dbus-run-session >/dev/null 2>&1 && command -v gnome-keyring-daemon >/dev/null 2>&1 && command -v secret-tool >/dev/null 2>&1; then
  cat >"$OMARCHY_KEYRING_DIR/default" <<'EOF'
Default_keyring
EOF
  runtime_tmp="$tmpdir/runtime"
  mkdir -p -m 0700 "$runtime_tmp"

  daemon_script='
    export XDG_DATA_HOME="$1"
    export XDG_RUNTIME_DIR="$2"
    unset GNOME_KEYRING_CONTROL
    gnome-keyring-daemon --daemonize --components=secrets
    recovered=$(secret-tool lookup service roundtrip_test)
    if [ "$recovered" = "$3" ]; then
      exit 0
    else
      echo "Mismatch: $recovered" >&2
      exit 1
    fi
  '
  dbus-run-session bash -c "$daemon_script" -- "$tmpdir" "$runtime_tmp" "$EXPECTED_RAW" ||
    fail "daemon round-trip through secret-tool failed"
  pass "recovered secret bytes match via live gnome-keyring-daemon and secret-tool"
fi

# 4. Encrypted binary keyrings are left untouched (#14913 compatibility)
printf 'GnomeKeyring\n\r\0\0encrypted_binary_payload' >"$OMARCHY_KEYRING_DIR/login.keyring"
cp -a "$OMARCHY_KEYRING_DIR/login.keyring" "$tmpdir/login.before"
python3 "$repair"
cmp -s "$tmpdir/login.before" "$OMARCHY_KEYRING_DIR/login.keyring" ||
  fail "encrypted binary keyring was altered by repair script"
pass "encrypted keyrings remain untouched"

# 5. Missing directory or empty directory exits 0 cleanly
export OMARCHY_KEYRING_DIR="$tmpdir/nonexistent"
python3 "$repair" || fail "repair script failed on missing directory"
pass "missing keyring directory handled cleanly"
