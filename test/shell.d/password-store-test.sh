#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

default_flags="$ROOT/config/electron-flags.conf"
[[ $(<"$default_flags") == "--password-store=gnome-libsecret" ]] ||
  fail "fresh installs pin Electron's password store"
pass "fresh installs pin Electron's password store"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_CURSOR_PKG:-0} == 1 && $1 == cursor-bin ]]
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_CURSOR_CMD:-0} == 1 && $1 == cursor ]]
SH

chmod +x "$stub_bin"/*

# omarchy-migrate calls these two commands. The tests call them directly.
pin_stores() {
  local home=$1

  env -u XDG_CONFIG_HOME \
    HOME="$home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_CURSOR_PKG="${OMARCHY_TEST_CURSOR_PKG:-0}" \
    OMARCHY_TEST_CURSOR_CMD="${OMARCHY_TEST_CURSOR_CMD:-0}" \
    "$ROOT/bin/omarchy-cmd-electron-password-store"
  env -u XDG_CONFIG_HOME \
    HOME="$home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_CURSOR_PKG="${OMARCHY_TEST_CURSOR_PKG:-0}" \
    OMARCHY_TEST_CURSOR_CMD="${OMARCHY_TEST_CURSOR_CMD:-0}" \
    "$ROOT/bin/omarchy-cmd-cursor-password-store" --if-installed
}

# Comments are not settings. A string that mentions the key is not the key.
# This strips both without touching text inside strings, then parses the rest.
assert_argv() {
  local file=$1
  local expected=$2

  python3 - "$file" "$expected" <<'PY'
import json
import pathlib
import sys

file, expected = sys.argv[1:]
text = pathlib.Path(file).read_text()
out = []
i = 0
n = len(text)
while i < n:
    if text[i] == '"':
        out.append(text[i])
        i += 1
        while i < n:
            out.append(text[i])
            if text[i] == "\\":
                i += 1
                if i < n:
                    out.append(text[i])
                i += 1
                continue
            if text[i] == '"':
                i += 1
                break
            i += 1
        continue
    if text.startswith("//", i):
        while i < n and text[i] != "\n":
            i += 1
        continue
    if text.startswith("/*", i):
        i += 2
        while i + 1 < n and not text.startswith("*/", i):
            i += 1
        i = min(n, i + 2)
        continue
    out.append(text[i])
    i += 1
data = json.loads("".join(out))
if data.get("password-store") != expected:
    raise SystemExit(f"password-store is {data.get('password-store')!r}")
PY
}

home="$test_dir/commented-option"
mkdir -p "$home/.config"
printf '%s\n' '# --password-store=basic' >"$home/.config/electron-flags.conf"

pin_stores "$home"

[[ $(<"$home/.config/electron-flags.conf") == $'# --password-store=basic\n--password-store=gnome-libsecret' ]] ||
  fail "pin ignores a commented password-store option"
pass "pin ignores a commented password-store option"

home="$test_dir/existing-user"
mkdir -p "$home"

pin_stores "$home" || fail "pin prepares existing users for a future Electron app"

grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron-flags.conf" ||
  fail "pin prepares existing users for a future Electron app"
[[ ! -e $home/.cursor ]] || fail "pin leaves Cursor alone when it is not installed"
pass "pin prepares existing users for a future Electron app"

home="$test_dir/custom-option"
mkdir -p "$home/.config"
printf '%s\n' '--password-store=basic' >"$home/.config/electron-flags.conf"

pin_stores "$home"

[[ $(<"$home/.config/electron-flags.conf") == "--password-store=basic" ]] ||
  fail "pin preserves an active password-store choice"
pass "pin preserves an active password-store choice"

home="$test_dir/missing-newline"
mkdir -p "$home/.config"
printf %s '--enable-features=WaylandLinuxDrmSyncobj' >"$home/.config/electron-flags.conf"

pin_stores "$home"

[[ $(<"$home/.config/electron-flags.conf") == $'--enable-features=WaylandLinuxDrmSyncobj\n--password-store=gnome-libsecret' ]] ||
  fail "pin appends the pin on its own line"
pass "pin appends the pin on its own line"

before=$(sha256sum "$home/.config/electron-flags.conf")
pin_stores "$home"
after=$(sha256sum "$home/.config/electron-flags.conf")

[[ $before == "$after" ]] || fail "Electron password-store pin is idempotent"
pass "Electron password-store pin is idempotent"

home="$test_dir/versioned-flags"
mkdir -p "$home/.config"
printf '%s\n' '--enable-features=WaylandLinuxDrmSyncobj' >"$home/.config/electron43-flags.conf"

pin_stores "$home"

grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron-flags.conf" ||
  fail "pin still seeds the fallback flags file"
grep -qxF -- '--password-store=gnome-libsecret' "$home/.config/electron43-flags.conf" ||
  fail "pin pins a versioned Electron flags file"
pass "pin pins versioned Electron flags files that shadow the fallback"

home="$test_dir/versioned-custom"
mkdir -p "$home/.config"
printf '%s\n' '--password-store=basic_text' >"$home/.config/electron43-flags.conf"

pin_stores "$home"

[[ $(<"$home/.config/electron43-flags.conf") == "--password-store=basic_text" ]] ||
  fail "pin preserves a versioned password-store choice"
pass "pin preserves a versioned password-store choice"

home="$test_dir/xdg-home"
config_home="$test_dir/xdg config"
mkdir -p "$home" "$config_home"
printf '%s\n' '--enable-features=WaylandLinuxDrmSyncobj' >"$config_home/electron43-flags.conf"

HOME="$home" XDG_CONFIG_HOME="$config_home" PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_CURSOR_PKG=0 OMARCHY_TEST_CURSOR_CMD=0 \
  "$ROOT/bin/omarchy-cmd-electron-password-store"
HOME="$home" XDG_CONFIG_HOME="$config_home" PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_CURSOR_PKG=0 OMARCHY_TEST_CURSOR_CMD=0 \
  "$ROOT/bin/omarchy-cmd-cursor-password-store" --if-installed

grep -qxF -- '--password-store=gnome-libsecret' "$config_home/electron-flags.conf" ||
  fail "pin seeds the fallback flags file under XDG_CONFIG_HOME"
grep -qxF -- '--password-store=gnome-libsecret' "$config_home/electron43-flags.conf" ||
  fail "pin pins versioned flags files under XDG_CONFIG_HOME"
[[ ! -e $home/.config ]] || fail "pin writes nothing under ~/.config when XDG_CONFIG_HOME is set"
[[ ! -e $home/.cursor ]] || fail "pin does not create Cursor config when Cursor is not installed"
pass "pin follows XDG_CONFIG_HOME"

home="$test_dir/cursor-package"
mkdir -p "$home"
OMARCHY_TEST_CURSOR_PKG=1 pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin writes argv.json when the Cursor package is installed"
pass "pin writes argv.json when the Cursor package is installed"

home="$test_dir/cursor-command"
mkdir -p "$home"
OMARCHY_TEST_CURSOR_CMD=1 pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin writes argv.json when the cursor command is installed"
pass "pin writes argv.json when the cursor command is installed"

home="$test_dir/cursor-existing"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
// NOTE: Changing this file requires a restart of VS Code.
{
	"enable-crash-reporter": true,
	"crash-reporter-id": "keep-me"
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin inserts gnome-libsecret into an existing argv.json"
grep -Fq '"crash-reporter-id": "keep-me"' "$home/.cursor/argv.json" ||
  fail "pin preserves existing argv.json keys"
grep -Fq 'restart of VS Code' "$home/.cursor/argv.json" ||
  fail "pin preserves argv.json comments"
grep -Fq $'\t"enable-crash-reporter"' "$home/.cursor/argv.json" ||
  fail "pin keeps the file's indentation"
pass "pin inserts gnome-libsecret into an existing argv.json"

before=$(sha256sum "$home/.cursor/argv.json")
pin_stores "$home"
after=$(sha256sum "$home/.cursor/argv.json")
[[ $before == "$after" ]] || fail "Cursor password-store pin is idempotent"
pass "Cursor password-store pin is idempotent"

home="$test_dir/cursor-commented-key"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  // "password-store": "basic"
  "crash-reporter-id": "keep-me"
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin does not treat a commented-out password-store as set"
grep -Fq '// "password-store": "basic"' "$home/.cursor/argv.json" ||
  fail "pin keeps the commented-out password-store line"
pass "pin does not treat a commented-out password-store as set"

home="$test_dir/cursor-trailing-comment"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "crash-reporter-id": "keep-me"
  // the closing brace is }
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin does not insert the key inside a trailing comment"
grep -Fq '// the closing brace is }' "$home/.cursor/argv.json" ||
  fail "pin keeps a trailing comment that mentions a brace"
pass "pin does not insert the key inside a trailing comment"

home="$test_dir/cursor-block-comment"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "crash-reporter-id": "keep-me"
  /* password-store } */
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin does not insert the key inside a block comment"
grep -Fq '/* password-store } */' "$home/.cursor/argv.json" ||
  fail "pin keeps a block comment that mentions the key"
pass "pin does not insert the key inside a block comment"

home="$test_dir/cursor-string-mention"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "note": "password-store stays basic, see https://example.com/a",
  "crash-reporter-id": "keep \"me\""
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin does not treat a password-store mention in a string as set"
grep -Fq 'https://example.com/a' "$home/.cursor/argv.json" ||
  fail "pin preserves a string that contains comment-like text"
pass "pin does not treat a password-store mention in a string as set"

home="$test_dir/cursor-nested"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "nested": { "password-store": "basic" },
  "crash-reporter-id": "keep-me"
}
EOF

pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin adds a top-level password-store when only a nested one exists"
grep -Fq '"password-store": "basic"' "$home/.cursor/argv.json" ||
  fail "pin leaves a nested password-store alone"
pass "pin adds a top-level password-store when only a nested one exists"

home="$test_dir/cursor-chosen"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "password-store": "basic",
  "crash-reporter-id": "keep-me"
}
EOF
before=$(sha256sum "$home/.cursor/argv.json")
pin_stores "$home"
after=$(sha256sum "$home/.cursor/argv.json")
[[ $before == "$after" ]] || fail "pin leaves an explicit password-store alone"
pass "pin leaves an explicit password-store alone"

home="$test_dir/cursor-compact"
mkdir -p "$home/.cursor"
printf '%s\n' '{ "password-store":"gnome-libsecret" }' >"$home/.cursor/argv.json"
before=$(sha256sum "$home/.cursor/argv.json")
pin_stores "$home"
after=$(sha256sum "$home/.cursor/argv.json")
[[ $before == "$after" ]] || fail "pin leaves an already-pinned argv.json untouched"
pass "pin leaves an already-pinned argv.json untouched"

home="$test_dir/cursor-invalid"
mkdir -p "$home/.cursor"
printf '%s\n' '{' >"$home/.cursor/argv.json"
before=$(sha256sum "$home/.cursor/argv.json")
pin_stores "$home"
after=$(sha256sum "$home/.cursor/argv.json")
[[ $before == "$after" ]] || fail "pin leaves an unparseable argv.json unchanged"
pass "pin leaves an unparseable argv.json unchanged"

home="$test_dir/cursor-file-without-package"
mkdir -p "$home/.cursor"
printf '%s\n' '{ "enable-crash-reporter": true }' >"$home/.cursor/argv.json"
pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin pins argv.json that already exists when Cursor is not installed"
pass "pin pins argv.json that already exists when Cursor is not installed"

home="$test_dir/cursor-trailing-comma"
mkdir -p "$home/.cursor"
cat >"$home/.cursor/argv.json" <<'EOF'
{
  "crash-reporter-id": "keep-me",
}
EOF
pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin pins an argv.json that already has a trailing comma"
pass "pin pins an argv.json that already has a trailing comma"

home="$test_dir/cursor-comments-only"
mkdir -p "$home/.cursor"
printf '%s\n' '// user note' >"$home/.cursor/argv.json"
pin_stores "$home"
assert_argv "$home/.cursor/argv.json" gnome-libsecret ||
  fail "pin pins an argv.json that is only a comment"
grep -Fq '// user note' "$home/.cursor/argv.json" ||
  fail "pin keeps a leading comment when the file has no object"
pass "pin pins an argv.json that is only a comment"

home="$test_dir/cursor-symlink"
mkdir -p "$home/.cursor" "$home/dotfiles"
cat >"$home/dotfiles/argv.json" <<'EOF'
{
  "crash-reporter-id": "keep-me"
}
EOF
ln -s ../dotfiles/argv.json "$home/.cursor/argv.json"

pin_stores "$home"

[[ -L $home/.cursor/argv.json ]] || fail "pin keeps a symlinked argv.json as a symlink"
[[ $(readlink "$home/.cursor/argv.json") == ../dotfiles/argv.json ]] ||
  fail "pin keeps the symlink target"
assert_argv "$home/dotfiles/argv.json" gnome-libsecret ||
  fail "pin writes the password store through a symlinked argv.json"
grep -Fq '"crash-reporter-id": "keep-me"' "$home/dotfiles/argv.json" ||
  fail "pin keeps the managed file's other keys"
pass "pin writes the password store through a symlinked argv.json"

before=$(sha256sum "$home/dotfiles/argv.json")
pin_stores "$home"
after=$(sha256sum "$home/dotfiles/argv.json")
[[ -L $home/.cursor/argv.json && $before == "$after" ]] ||
  fail "pin leaves a symlinked argv.json that is already set"
pass "pin leaves a symlinked argv.json that is already set"
