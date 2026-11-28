#!/bin/bash

# The commands behind a recording's More menu: omarchy file reveal and trash.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command gio

# Each in a subshell, so its stubs on PATH and its temporary directory stay its own.
(
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
export REVEAL_LOG="$tmp/args" REVEAL_OPEN="$tmp/open"
cat > "$tmp/bin/busctl" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" > "$REVEAL_LOG"
exit "${REVEAL_FAIL:-0}"
STUB
cat > "$tmp/bin/xdg-open" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" > "$REVEAL_OPEN"
STUB
chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$PATH"
file="$tmp/-quote' space # % ü.mp4"$'\n'
touch "$file"
ln -s "$file" "$tmp/link.mp4"
"$ROOT/bin/omarchy-file-reveal" "$file"
python3 - "$file" <<'PY'
import os, pathlib, sys
args = pathlib.Path(os.environ['REVEAL_LOG']).read_bytes().split(b'\0')[:-1]
assert args[-4:] == [b'ass', b'1', pathlib.Path(sys.argv[1]).as_uri().encode(), b'']
assert b'ShowItems' in args and b'--timeout=5' in args
assert not pathlib.Path(os.environ['REVEAL_OPEN']).exists()
PY
"$ROOT/bin/omarchy-file-reveal" "$tmp/link.mp4"
python3 - "$tmp/link.mp4" <<'PY'
import os, pathlib, sys
args = pathlib.Path(os.environ['REVEAL_LOG']).read_bytes().split(b'\0')[:-1]
assert args[-2] == pathlib.Path(sys.argv[1]).as_uri().encode()
PY
# A directory symlink before "..": the parent is resolved, not cut lexically.
mkdir -p "$tmp/other/sub"
touch "$tmp/other/clip.mp4"
ln -s "$tmp/other/sub" "$tmp/dirlink"
(cd "$tmp" && "$ROOT/bin/omarchy-file-reveal" "dirlink/../clip.mp4")
python3 - "$tmp/other/clip.mp4" <<'PY'
import os, pathlib, sys
args = pathlib.Path(os.environ['REVEAL_LOG']).read_bytes().split(b'\0')[:-1]
assert args[-2] == pathlib.Path(sys.argv[1]).as_uri().encode(), args[-2]
PY
REVEAL_FAIL=1 "$ROOT/bin/omarchy-file-reveal" "$file"
read -r -d '' opened < "$REVEAL_OPEN" || true
[[ $opened == "file://$tmp/" ]] || fail "unsupported file managers open the containing directory"
pass "file reveal encodes paths, selects symlinks and falls back to the containing folder"
)

(
# GIO refuses internal mounts such as /tmp tmpfs; use the home filesystem.
tmp=$(mktemp -d "$HOME/.cache/omarchy-trash-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/data" "$tmp/bin"
export XDG_DATA_HOME="$tmp/data"
printf 'restorable recording\n' > "$tmp/-recording clip.mp4"
"$ROOT/bin/omarchy-file-trash" "$tmp/-recording clip.mp4"
[[ ! -e "$tmp/-recording clip.mp4" ]] || fail "trashed recording leaves its source location"
[[ $(cat "$tmp/data/Trash/files/-recording clip.mp4") == 'restorable recording' ]] || fail "trash preserves the recording"
[[ -f "$tmp/data/Trash/info/-recording clip.mp4.trashinfo" ]] || fail "trash preserves restoration metadata"
python3 - "$tmp" <<'PYTEST'
import configparser, pathlib, sys, urllib.parse
root = pathlib.Path(sys.argv[1])
info = configparser.ConfigParser(interpolation=None)
info.read(root / 'data/Trash/info/-recording clip.mp4.trashinfo')
original = pathlib.Path(urllib.parse.unquote(info['Trash Info']['Path']))
assert original == root / '-recording clip.mp4'
(root / 'data/Trash/files/-recording clip.mp4').rename(original)
PYTEST
[[ $(cat "$tmp/-recording clip.mp4") == 'restorable recording' ]] || fail "trashed recording can be restored"
pass "recording moves to Trash and can be restored"

# A directory symlink before "..": GIO cuts "dirlink/.." lexically, which would
# trash a same-named file beside the link instead of the one meant.
mkdir -p "$tmp/other/sub"
printf 'meant\n' > "$tmp/other/clip.mp4"
printf 'decoy\n' > "$tmp/clip.mp4"
ln -s "$tmp/other/sub" "$tmp/dirlink"
(cd "$tmp" && "$ROOT/bin/omarchy-file-trash" "dirlink/../clip.mp4")
[[ ! -e "$tmp/other/clip.mp4" ]] || fail "trash follows a directory symlink before .."
[[ $(cat "$tmp/clip.mp4") == 'decoy' ]] || fail "trash leaves the lexical decoy alone"
pass "trash resolves the file's directory before trashing"

# Trailing newlines are part of a name: dropping them, as command substitution
# does, would trash the same name without them.
printf 'meant\n' > "$tmp/clip.mp4"$'\n'
mkdir -p "$tmp/folder"$'\n' "$tmp/folder"
printf 'meant\n' > "$tmp/folder"$'\n'"/other"
printf 'decoy\n' > "$tmp/folder/other"
"$ROOT/bin/omarchy-file-trash" "$tmp/clip.mp4"$'\n'
"$ROOT/bin/omarchy-file-trash" "$tmp/folder"$'\n'"/other"
[[ ! -e "$tmp/clip.mp4"$'\n' && ! -e "$tmp/folder"$'\n'"/other" ]] || fail "trash keeps trailing newlines in names"
[[ $(cat "$tmp/clip.mp4") == 'decoy' && $(cat "$tmp/folder/other") == 'decoy' ]] || fail "trash leaves names without the newline alone"
pass "trash keeps trailing newlines in file and directory names"

# A directory that cannot be resolved stops the trash: handing GIO the path
# would let it cut "dirlink/.." lexically and pick the decoy. A directory
# named "-" is a directory, never cd's previous one.
printf 'meant\n' > "$tmp/other/clip.mp4"
chmod 0600 "$tmp/other/sub"
if (cd "$tmp" && "$ROOT/bin/omarchy-file-trash" "dirlink/../clip.mp4" 2>/dev/null); then
  [[ ! -e "$tmp/other/clip.mp4" ]] || fail "trash through an unsearchable link reports or trashes the meant file"
fi
chmod 0700 "$tmp/other/sub"
[[ $(cat "$tmp/clip.mp4") == 'decoy' ]] || fail "trash never falls back to the lexical decoy"
mkdir -p "$tmp/-"
printf 'previous\n' > "$tmp/other/clip.mp4"
printf 'meant\n' > "$tmp/-/clip.mp4"
(cd "$tmp" && OLDPWD="$tmp/other" "$ROOT/bin/omarchy-file-trash" "-/clip.mp4")
[[ ! -e "$tmp/-/clip.mp4" ]] || fail "trash takes a directory named - literally"
[[ -e "$tmp/other/clip.mp4" ]] || fail "trash leaves the previous directory alone"
pass "trash stops when the directory cannot be resolved and takes - literally"

if (cd "$tmp" && "$ROOT/bin/omarchy-file-trash" "" 2>/dev/null); then
  fail "trash refuses an empty path"
fi
[[ -d $tmp/other ]] || fail "an empty path leaves the current directory alone"
pass "trash refuses an empty path"

cat > "$tmp/bin/gio" <<'STUB'
#!/bin/bash
printf 'Trash is unavailable\n' >&2
exit 1
STUB
cat > "$tmp/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" > "$TRASH_ERROR_LOG"
STUB
cat > "$tmp/bin/omarchy-i18n" <<'STUB'
#!/bin/bash
printf 'Could not move file to Trash\n'
STUB
chmod +x "$tmp/bin/"*
export PATH="$tmp/bin:$PATH" TRASH_ERROR_LOG="$tmp/error"
if "$ROOT/bin/omarchy-file-trash" "$tmp/-recording clip.mp4" 2>/dev/null; then
  fail "trash failure must return an error"
fi
[[ -f "$tmp/-recording clip.mp4" ]] || fail "trash failure must preserve the recording"
[[ $(cat "$tmp/error") == *'Trash is unavailable'* ]] || fail "trash failure must notify the user"
pass "trash failure reports an error and never deletes the recording"
)
