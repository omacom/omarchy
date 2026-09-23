echo "Repair gnome-keyring plaintext keyring files that gnome-keyring 50 rejects"

# gnome-keyring writes textual secrets with g_key_file_set_value(), which does
# not escape newlines. A secret containing a raw newline (JSON with embedded
# PEM blocks, multi-line tokens) produces a keyring file the daemon cannot
# parse again. On the next start it logs
#   keyring was in an invalid or unrecognized format
# and silently drops the collection, creating a fresh empty default. Browsers
# lose Safe Storage and every saved login appears wiped.
#
# The reader (GKeyFile) does unescape standard sequences, so affected files can
# be repaired in place by escaping multi-line values. Byte-exact after parse.
# Repaired files are also backed up first.

keyrings_dir="$HOME/.local/share/keyrings"

[[ -d $keyrings_dir ]] || exit 0
command -v python3 >/dev/null || exit 0

python3 - "$keyrings_dir" <<'PY'
import re
import shutil
import sys
import time
from pathlib import Path

SECTION = re.compile(rb"^\[[^\]]+\]$")
KV = re.compile(rb"^[A-Za-z0-9_-]+=")
TERM = re.compile(rb"^(mtime|ctime)=")

# Keys the writer can emit, per group type (gkm-secret-textual.c). A
# key=value line with any other key is a continuation of the previous
# (multi-line) value, not a new key.
KEYRING_KEYS = {b"display-name", b"ctime", b"mtime", b"lock-on-idle",
                b"lock-timeout", b"lock-after"}
ITEM_KEYS = {b"item-type", b"display-name", b"secret", b"binary-secret",
             b"mtime", b"ctime"}
ATTRIBUTE_KEYS = {b"name", b"type", b"value"}
ACL_KEYS = {b"display-name", b"path", b"read-access", b"write-access",
            b"remove-access"}


def group_keys(section):
    name = section.decode(errors="replace").strip("[]")
    if name == "keyring":
        return KEYRING_KEYS
    if re.fullmatch(r"\d+", name):
        return ITEM_KEYS
    if re.fullmatch(r"\d+:attribute\d+", name):
        return ATTRIBUTE_KEYS
    if re.fullmatch(r"\d+:acl\d+", name):
        return ACL_KEYS
    return None


def is_corrupt(raw):
    cur = None
    for line in raw.split(b"\n"):
        if SECTION.match(line):
            cur = line
            continue
        if cur is None or line == b"":
            continue
        if not KV.match(line):
            return True
    return False


def escape(value):
    out = value.replace(b"\\", b"\\\\")
    out = out.replace(b"\r", b"\\r")
    out = out.replace(b"\n", b"\\n")
    out = out.replace(b"\t", b"\\t")
    return out


def repair(raw):
    lines = raw.split(b"\n")
    out = []
    section = None
    keys = None
    i = 0
    changed = False
    while i < len(lines):
        line = lines[i]
        if SECTION.match(line):
            section = line
            keys = group_keys(line)
            out.append(line)
            i += 1
            continue
        if line == b"":
            out.append(line)
            i += 1
            continue
        m = KV.match(line)
        if not m:
            return None
        key = line[: line.index(b"=")]
        starts_new_value = keys is None or key in keys
        value = [line[len(key) + 1:]]
        i += 1
        if starts_new_value:
            while i < len(lines):
                nxt = lines[i]
                if SECTION.match(nxt) or TERM.match(nxt) or nxt == b"":
                    break
                if keys is not None and KV.match(nxt):
                    if nxt[: nxt.index(b"=")] in keys:
                        break
                elif keys is None and KV.match(nxt):
                    break
                value.append(nxt)
                i += 1
        if len(value) > 1:
            out.append(key + b"=" + escape(b"\n".join(value)))
            changed = True
        else:
            out.append(line)
    if not changed:
        return None
    fixed = b"\n".join(out)
    return None if is_corrupt(fixed) else fixed


keyrings = Path(sys.argv[1])
backups = keyrings / f"backup-{time.strftime('%Y%m%d-%H%M%S')}"
checked = repaired = failed = 0

for path in sorted(keyrings.glob("*.keyring")):
    raw = path.read_bytes()
    if not raw.startswith(b"[keyring]") or not is_corrupt(raw):
        continue
    checked += 1
    fixed = repair(raw)
    if fixed is None:
        print(f"  could not repair {path.name}; left untouched")
        failed += 1
        continue
    backups.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, backups / path.name)
    path.write_bytes(fixed)
    print(f"  repaired {path.name} (backup in {backups.name}/)")
    repaired += 1

if checked == 0:
    print("  no affected keyring files found")
print(f"  summary: corrupt={checked} repaired={repaired} failed={failed}")
sys.exit(0)
PY
