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

# 2. Repairs unescaped multiline secret in-place while keeping valid items byte-for-byte
# untouched, preserving interior/trailing notes, CRLF, and payload containing fake keys
cat >"$tmpdir/valid_item_1.snippet" <<'EOF'
[1]
item-type=0
display-name=Chromium Safe Storage
secret=C8aLYMkXBDnNoGLPjj/opg==
mtime=1700000000
ctime=1700000000

# Separator comment before corrupted section 2
EOF

cat >"$tmpdir/valid_item_3.snippet" <<'EOF'
[3]
item-type=0
display-name=Claude Safe Storage
secret=N6r6grCAlNU4IRv3ZhcX8Q==
mtime=1700000000
ctime=1700000000
EOF

printf '# Standard Omarchy cleartext keyring\n# Auto-generated during provisioning\n[keyring]\ndisplay-name=Default keyring\nctime=1700000000\nmtime=1700000000\n\n' >"$OMARCHY_KEYRING_DIR/Default_keyring.keyring"
cat "$tmpdir/valid_item_1.snippet" >>"$OMARCHY_KEYRING_DIR/Default_keyring.keyring"
printf '\n[2]\nitem-type=0\ndisplay-name=Complex Multiline Secret\nsecret=line1_val\r\nline2_with_equals=abc==\r\nline3_with_backslash\\slash\twith\ttab\nmtime=fake_metadata_payload\n\n# interior comment in secret\nline4_end\n#note at end of secret\n\nctime=1700000000\nmtime=1700000000\n\n[2:attribute0]\nname=service\ntype=string\nvalue=roundtrip_test\n\n' >>"$OMARCHY_KEYRING_DIR/Default_keyring.keyring"
cat "$tmpdir/valid_item_3.snippet" >>"$OMARCHY_KEYRING_DIR/Default_keyring.keyring"

python3 "$repair"

# Assert valid items and their surrounding comments were preserved byte-for-byte
grep -Fqz "$(cat "$tmpdir/valid_item_1.snippet")" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 1 or its separator comment was mutated during repair"
grep -Fqz "$(cat "$tmpdir/valid_item_3.snippet")" "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "valid item 3 was mutated during repair"

# Assert multiline folded onto single escaped line with carriage returns and trailing notes preserved
grep -Fq 'secret=line1_val\r\nline2_with_equals=abc==\r\nline3_with_backslash\\slash\twith\ttab\nmtime=fake_metadata_payload\n\n# interior comment in secret\nline4_end\n#note at end of secret\n' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "multiline secret was cut short or incorrectly escaped"

# Assert no stray continuation lines remain
! grep -Fxq 'line2_with_equals=abc==' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"
! grep -Fxq 'line4_end' "$OMARCHY_KEYRING_DIR/Default_keyring.keyring" ||
  fail "bare continuation line remained in keyfile"

pass "multiline secrets folded with zero data loss while preserving valid items"

# 3. Round-trip verification through the real reader (gnome-keyring-daemon & GLib)
export EXPECTED_RAW=$'line1_val\r\nline2_with_equals=abc==\r\nline3_with_backslash\\slash\twith\ttab\nmtime=fake_metadata_payload\n\n# interior comment in secret\nline4_end\n#note at end of secret\n'

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
  printf '%s' "$EXPECTED_RAW" >"$runtime_tmp/expected.txt"

  daemon_script='
    export XDG_DATA_HOME="$1"
    export XDG_RUNTIME_DIR="$2"
    unset GNOME_KEYRING_CONTROL
    gnome-keyring-daemon --daemonize --components=secrets
    secret-tool lookup service roundtrip_test >"$2/recovered.txt"
    cmp -s "$2/recovered.txt" "$2/expected.txt"
  '
  dbus-run-session bash -c "$daemon_script" -- "$tmpdir" "$runtime_tmp" ||
    fail "daemon round-trip through secret-tool failed"
  pass "recovered secret bytes match via live gnome-keyring-daemon and secret-tool"
fi

# 4. Ambiguous corruption with trailing bare lines fails safely without replacing original file
ambig_file="$OMARCHY_KEYRING_DIR/ambiguous.keyring"
cat >"$ambig_file" <<'EOF'
[keyring]
display-name=Ambiguous Keyring

[1]
item-type=0
secret=val1
ctime=1700000000
unresolvable_dangling_bare_line
EOF
cp -a "$ambig_file" "$tmpdir/ambig_before.keyring"
! python3 "$repair" 2>/dev/null || fail "repair should return nonzero on ambiguous corruption"
cmp -s "$tmpdir/ambig_before.keyring" "$ambig_file" || fail "ambiguous file should not be modified"
rm -f "$ambig_file"
pass "ambiguous corruption halts safely without replacing file"

# 5. Ambiguous section boundaries (e.g. [payload] inside secret) are rejected before committing
ambig_section_file="$OMARCHY_KEYRING_DIR/ambig_section.keyring"
cat >"$ambig_section_file" <<'EOF'
[keyring]
display-name=Ambiguous Section Keyring

[1]
item-type=0
secret=first
second
[payload]
display-name=value
EOF
cp -a "$ambig_section_file" "$tmpdir/ambig_sec_before.keyring"
! python3 "$repair" 2>/dev/null || fail "repair should reject ambiguous section boundary"
cmp -s "$tmpdir/ambig_sec_before.keyring" "$ambig_section_file" || fail "ambiguous section file should not be modified"
rm -f "$ambig_section_file"
pass "ambiguous section boundaries rejected without shortening secrets"

# 6. Encrypted binary keyrings are left untouched (#14913 compatibility)
printf 'GnomeKeyring\n\r\0\0encrypted_binary_payload' >"$OMARCHY_KEYRING_DIR/login.keyring"
cp -a "$OMARCHY_KEYRING_DIR/login.keyring" "$tmpdir/login.before"
python3 "$repair"
cmp -s "$tmpdir/login.before" "$OMARCHY_KEYRING_DIR/login.keyring" ||
  fail "encrypted binary keyring was altered by repair script"
pass "encrypted keyrings remain untouched"

# 7. Missing directory or empty directory exits 0 cleanly
export OMARCHY_KEYRING_DIR="$tmpdir/nonexistent"
python3 "$repair" || fail "repair script failed on missing directory"
pass "missing keyring directory handled cleanly"

# 8. Read-only directory causes failed repair to return exit code 1 (skipped for root)
if (( EUID != 0 )); then
  ro_dir="$tmpdir/ro_keyrings"
  mkdir -p "$ro_dir"
  cat >"$ro_dir/corrupt.keyring" <<'EOF'
[keyring]
display-name=Corrupt
[1]
item-type=0
secret=val1
val2
EOF
  chmod 0555 "$ro_dir"
  export OMARCHY_KEYRING_DIR="$ro_dir"
  ! python3 "$repair" 2>/dev/null || fail "repair script should exit nonzero when commit fails"
  chmod 0755 "$ro_dir"
  pass "failed repair returns nonzero exit code"
else
  pass "permission-based write failure test skipped for root"
fi

# 9. CRLF line ending preservation and GLib verification
export OMARCHY_KEYRING_DIR="$tmpdir/keyrings"
mkdir -p "$OMARCHY_KEYRING_DIR"
rm -f "$OMARCHY_KEYRING_DIR"/*.keyring

crlf_file="$OMARCHY_KEYRING_DIR/crlf.keyring"
printf '[keyring]\r\ndisplay-name=CRLF Keyring\r\n\r\n[1]\r\nitem-type=0\r\ndisplay-name=CRLF Secret\r\nsecret=crlf_line1\r\ncrlf_line2\r\ncrlf_line3\r\nctime=1700000000\r\nmtime=1700000000\r\n' >"$crlf_file"

python3 "$repair"

grep -Fq $'\r\n' "$crlf_file" || fail "CRLF keyring line endings were not preserved"
grep -Fq 'secret=crlf_line1\ncrlf_line2\ncrlf_line3' "$crlf_file" || fail "secret line contains extraneous carriage returns"

python3 - << 'PY'
import os
import gi
gi.require_version('GLib', '2.0')
from gi.repository import GLib

kf = GLib.KeyFile()
keyring_dir = os.environ["OMARCHY_KEYRING_DIR"]
kf.load_from_file(f"{keyring_dir}/crlf.keyring", GLib.KeyFileFlags.KEEP_COMMENTS)
val = kf.get_string("1", "secret")
expected = "crlf_line1\ncrlf_line2\ncrlf_line3"
assert val == expected, f"GLib CRLF mismatch: {repr(val)} != {repr(expected)}"
PY
rm -f "$crlf_file"
pass "CRLF line endings and payload fidelity verified via GLib"

# 10. Embedded metadata patterns (ctime=\d+, mtime=\d+ in payload) without false truncation
embed_file="$OMARCHY_KEYRING_DIR/embed_meta.keyring"
cat >"$embed_file" <<'EOF'
[keyring]
display-name=Default keyring

[1]
item-type=0
display-name=Payload With Metadata Strings
secret={"service": "auth",
ctime=1234567890
mtime=9876543210
"token": "tok_xyz"}
ctime=1700000000
mtime=1700000000
EOF

python3 "$repair"

(( $(grep -c '^ctime=1700000000$' "$embed_file") == 1 )) || fail "missing or duplicate section ctime"
(( $(grep -c '^mtime=1700000000$' "$embed_file") == 1 )) || fail "missing or duplicate section mtime"

python3 - << 'PY'
import os
import gi
gi.require_version('GLib', '2.0')
from gi.repository import GLib

kf = GLib.KeyFile()
keyring_dir = os.environ["OMARCHY_KEYRING_DIR"]
kf.load_from_file(f"{keyring_dir}/embed_meta.keyring", GLib.KeyFileFlags.KEEP_COMMENTS)
val = kf.get_string("1", "secret")
expected = '{"service": "auth",\nctime=1234567890\nmtime=9876543210\n"token": "tok_xyz"}'
assert val == expected, f"GLib embedded metadata mismatch: {repr(val)} != {repr(expected)}"
PY
rm -f "$embed_file"
pass "embedded metadata patterns in secret payload preserved without false truncation"

# 11. Ambiguous bracket boundary ([1] inside secret) safe halt without modifying file
ambig_bracket_file="$OMARCHY_KEYRING_DIR/ambig_bracket.keyring"
cat >"$ambig_bracket_file" <<'EOF'
[keyring]
display-name=Ambiguous Header Keyring

[1]
item-type=0
display-name=Ambiguous Item
secret=First payload line
[1]
Second payload line
ctime=1700000000
mtime=1700000000
EOF

cp -a "$ambig_bracket_file" "$tmpdir/ambig_bracket_before.keyring"
! python3 "$repair" 2>/dev/null || fail "repair should return nonzero on ambiguous bracket header"
cmp -s "$tmpdir/ambig_bracket_before.keyring" "$ambig_bracket_file" || fail "ambiguous bracket file was modified"
rm -f "$ambig_bracket_file" "$tmpdir/ambig_bracket_before.keyring"
pass "ambiguous bracket boundary halts safely without modifying file"

# 12. Valid provisioned keyring format (lock-on-idle, lock-after) unmodified and exits 0
valid_prov_file="$OMARCHY_KEYRING_DIR/valid_provisioned.keyring"
cat >"$valid_prov_file" <<'EOF'
[keyring]
display-name=Default keyring
ctime=1786094050
mtime=1792937000
lock-on-idle=false
lock-after=false

[1]
item-type=0
display-name=Chromium Safe Storage
secret=oHBQUMfFSYdW3Fj+zECDog==
mtime=1792937000
ctime=1786094050

[1:attribute0]
name=application
type=string
value=Code
EOF

cp -a "$valid_prov_file" "$tmpdir/valid_prov_before.keyring"
python3 "$repair"
cmp -s "$tmpdir/valid_prov_before.keyring" "$valid_prov_file" || fail "valid provisioned keyring was modified"
rm -f "$valid_prov_file" "$tmpdir/valid_prov_before.keyring"
pass "valid provisioned keyring with lock-on-idle is untouched"

# 13. Unicode line separators (U+2028) survive repair without gaining extraneous newlines
unicode_sep_file="$OMARCHY_KEYRING_DIR/unicode_sep.keyring"
cat >"$unicode_sep_file" <<'EOF'
[keyring]
display-name=Default keyring

[1]
item-type=0
display-name=Unicode Separator Item
secret=first second
third
ctime=1700000000
mtime=1700000000
EOF

python3 "$repair"

python3 - << 'PY'
import os
import gi
gi.require_version('GLib', '2.0')
from gi.repository import GLib

kf = GLib.KeyFile()
keyring_dir = os.environ["OMARCHY_KEYRING_DIR"]
kf.load_from_file(f"{keyring_dir}/unicode_sep.keyring", GLib.KeyFileFlags.KEEP_COMMENTS)
val = kf.get_string("1", "secret")
expected = "first\u2028second\nthird"
assert val == expected, f"GLib unicode separator mismatch: {repr(val)} != {repr(expected)}"
PY
rm -f "$unicode_sep_file"
pass "unicode line separators survive repair without gaining extra newlines"

# 14. Leading secret spaces survive repair and round-trip via GLib GKeyFile
leading_space_file="$OMARCHY_KEYRING_DIR/leading_space.keyring"
cat >"$leading_space_file" <<'EOF'
[keyring]
display-name=Default keyring

[1]
item-type=0
display-name=Leading Space Item
secret=   first line with leading spaces
second line
ctime=1700000000
mtime=1700000000
EOF

python3 "$repair"

python3 - << 'PY'
import os
import gi
gi.require_version('GLib', '2.0')
from gi.repository import GLib

kf = GLib.KeyFile()
keyring_dir = os.environ["OMARCHY_KEYRING_DIR"]
kf.load_from_file(f"{keyring_dir}/leading_space.keyring", GLib.KeyFileFlags.KEEP_COMMENTS)
val = kf.get_string("1", "secret")
expected = "   first line with leading spaces\nsecond line"
assert val == expected, f"GLib leading space mismatch: {repr(val)} != {repr(expected)}"
PY
rm -f "$leading_space_file"
pass "leading secret spaces survive repair without disappearing"
