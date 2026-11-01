#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
stub_bin="$test_tmp/bin"
mkdir -p "$state" "$stub_bin"

HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
  XDG_RUNTIME_DIR="$test_tmp" \
  bash "$ROOT/bin/omarchy-theme-set" "Tokyo Night"

generated_theme="$state/theme/zed.json"
[[ -f $generated_theme ]] || fail "Zed theme is generated with the current theme"
jq -e '.themes[0].name == "Omarchy" and .themes[0].appearance == "dark"' "$generated_theme" >/dev/null ||
  fail "Zed theme is valid JSON with the Omarchy identity and appearance"
! grep -q '{{' "$generated_theme" || fail "Zed theme resolves every template placeholder"
pass "Zed theme is rendered by the shared theme pipeline"

HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
  OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
  XDG_RUNTIME_DIR="$test_tmp" \
  bash "$ROOT/bin/omarchy-theme-set" "Catppuccin Latte"
jq -e '.themes[0].appearance == "light"' "$generated_theme" >/dev/null ||
  fail "Zed theme follows a light Omarchy theme"
pass "Zed theme renders both dark and light appearances"

printf '#!/bin/bash\nexit 0\n' >"$stub_bin/zeditor"
chmod +x "$stub_bin/zeditor"

run_sync() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-set-zed" "$@"
}

run_sync
settings="$home/.config/zed/settings.json"
installed_theme="$home/.config/zed/themes/omarchy.json"
cmp -s "$generated_theme" "$installed_theme" || fail "Zed receives the generated Omarchy theme"
[[ ! -e $settings ]] || fail "Zed theme sync does not take over the user's theme selection"
run_sync --select
jq -e '.theme == "Omarchy"' "$settings" >/dev/null || fail "Zed selects Omarchy when requested"
[[ $(stat -c '%a' "$settings") == "600" ]] || fail "new Zed settings are private"
pass "Zed receives the generated theme and selects it only when requested"

cat >"$settings" <<'JSONC'
{
  // Keep this user preference.
  "autosave": "on_focus_change",
  "theme": "Existing"
}
JSONC
cp "$settings" "$test_tmp/manual-settings.json"
run_sync
cmp -s "$test_tmp/manual-settings.json" "$settings" ||
  fail "Zed theme sync preserves a manually selected theme"
pass "Zed theme sync preserves a manually selected theme"
run_sync --select
grep -q '// Keep this user preference.' "$settings" || fail "Zed sync preserves JSONC comments"
grep -q '"autosave": "on_focus_change"' "$settings" || fail "Zed sync preserves unrelated settings"
grep -q '"theme": "Omarchy"' "$settings" || fail "Zed sync replaces a string theme"
pass "Zed sync updates a string theme without rewriting JSONC"

cat >"$settings" <<'JSONC'
{
  // "theme": "Omazed",
  "theme": {
    "mode": "system",
    "light": "One Light",
    "dark": "One Dark"
  },
  "autosave": "on_focus_change"
}
JSONC
run_sync --select
grep -q '// "theme": "Omazed",' "$settings" || fail "Zed sync ignores a commented-out string theme"
grep -q '"theme": "Omarchy"' "$settings" || fail "Zed sync replaces a theme object"
! grep -q 'One Light\|One Dark' "$settings" || fail "Zed sync removes the old theme object"
grep -q '"autosave": "on_focus_change"' "$settings" || fail "Zed sync preserves settings after a theme object"
sed '/^[[:space:]]*\/\//d' "$settings" | jq -e '.theme == "Omarchy" and .autosave == "on_focus_change"' >/dev/null ||
  fail "Zed sync keeps settings valid after replacing a theme object"
pass "Zed sync ignores comments while updating Zed's light/dark theme object"

cat >"$settings" <<'JSONC'
{
  "theme": {
    "mode": "system",
    // A closing brace } in a comment must not terminate the object.
    "light": "One Light",
    "dark": "One Dark"
  },
  "autosave": "on_focus_change"
}
JSONC
run_sync --select
jq -e '.theme == "Omarchy" and .autosave == "on_focus_change"' "$settings" >/dev/null ||
  fail "Zed sync safely replaces a theme object containing braces in comments"
pass "Zed sync does not corrupt JSONC containing braces in comments"

cat >"$settings" <<'JSONC'
{
  // Keep this comment too.
  "autosave": "on_focus_change",
}
JSONC
run_sync --select
grep -q '"theme": "Omarchy"' "$settings" || fail "Zed sync adds a missing theme setting"
grep -q '// Keep this comment too.' "$settings" || fail "Zed sync preserves JSONC while adding a theme"
pass "Zed sync adds its theme to existing JSONC settings"

settings_target="$home/.config/zed/settings-target.json"
mv "$settings" "$settings_target"
ln -s "$(basename "$settings_target")" "$settings"
run_sync --select
[[ -L $settings ]] || fail "Zed sync preserves a symlinked settings file"
grep -q '"theme": "Omarchy"' "$settings_target" || fail "Zed sync updates a symlink target"
rm "$settings"
mv "$settings_target" "$settings"
pass "Zed sync preserves symlinked settings"

cat >"$settings" <<'JSONC'
{
  // Keep the comment and a per-language font.
  "theme": "One Dark",
  "languages": {"Rust": {"buffer_font_family": "Rust Font"}},
  "buffer_font_family": "Old Font"
}
JSONC
font_name='Test "Mono" \ Font'
HOME="$home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" --enable "$font_name"
grep -q '// Keep the comment and a per-language font.' "$settings" ||
  fail "Zed font sync preserves JSONC comments"
sed '/^[[:space:]]*\/\//d' "$settings" | jq -e --arg font "$font_name" \
  '.buffer_font_family == $font and .theme == "One Dark" and .languages.Rust.buffer_font_family == "Rust Font"' >/dev/null ||
  fail "Zed font sync escapes the font and preserves unrelated settings"
pass "Zed font sync preserves JSONC and per-language settings"

python3 - "$ROOT" "$test_tmp" <<'PY'
import ctypes
import json
import os
from pathlib import Path
import struct
import subprocess
import sys

root = Path(sys.argv[1])
home = Path(sys.argv[2]) / "watch-home"
settings = home / ".config/zed/settings.json"
settings.parent.mkdir(parents=True)
settings.write_text('{"buffer_font_family":"Old Font"}\n')
libc = ctypes.CDLL(None, use_errno=True)
in_modify = 0x2
fd = libc.inotify_init1(os.O_NONBLOCK | os.O_CLOEXEC)
if fd < 0 or libc.inotify_add_watch(fd, os.fsencode(settings), in_modify) < 0:
    raise OSError(ctypes.get_errno(), "cannot watch Zed settings")
env = dict(os.environ, HOME=str(home), PATH=f"{root / 'bin'}:{os.environ['PATH']}")
try:
    for font in ("First Font", "Second Font"):
        subprocess.run([str(root / "bin/omarchy-theme-set-zed"), "--font", font], env=env, check=True)
        try:
            events = os.read(fd, 65536)
        except BlockingIOError:
            events = b""
        masks = []
        while events:
            _, mask, _, length = struct.unpack_from("iIII", events)
            masks.append(mask)
            events = events[16 + length:]
        if not any(mask & in_modify for mask in masks):
            raise AssertionError(f"Zed settings watcher missed the update to {font}")
        assert json.loads(settings.read_text())["buffer_font_family"] == font
finally:
    os.close(fd)
print("ok - repeated font changes notify a Zed settings file watcher")
PY

font_target="$home/.config/zed/font-settings-target.json"
mv "$settings" "$font_target"
ln -s "$(basename "$font_target")" "$settings"
run_sync --font 'Another Font'
[[ -L $settings ]] || fail "Zed font sync preserves a symlinked settings file"
grep -q '"buffer_font_family": "Another Font"' "$font_target" ||
  fail "Zed font sync updates the symlink target"
rm "$settings"
mv "$font_target" "$settings"
pass "Zed font sync preserves a symlinked settings file"

font_home="$test_tmp/font-home"
mkdir -p "$font_home/.config/zed"
HOME="$font_home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" --enable 'First Font'
jq -e '.buffer_font_family == "First Font"' "$font_home/.config/zed/settings.json" >/dev/null ||
  fail "Zed font sync creates settings without requiring a theme"
[[ $(stat -c '%a' "$font_home/.config/zed/settings.json") == "600" ]] || fail "new font settings are private"
[[ -f $font_home/.local/state/omarchy/zed/font-sync ]] || fail "Zed font sync records explicit opt-in"
HOME="$font_home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" 'Second Font'
jq -e '.buffer_font_family == "Second Font"' "$font_home/.config/zed/settings.json" >/dev/null ||
  fail "Zed font sync follows a subsequent system font change"
pass "Zed font sync creates settings without requiring a theme"

manual_font_home="$test_tmp/manual-font-home"
mkdir -p "$manual_font_home/.config/zed"
printf '{"buffer_font_family":"Personal Font"}\n' >"$manual_font_home/.config/zed/settings.json"
HOME="$manual_font_home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" 'System Font'
jq -e '.buffer_font_family == "Personal Font"' "$manual_font_home/.config/zed/settings.json" >/dev/null ||
  fail "font sync leaves users who did not opt in alone"
[[ ! -e $manual_font_home/.local/state/omarchy/zed/font-sync ]] || fail "font sync does not enable itself"
pass "Zed font sync does not take over a manual installation"

printf '{"buffer_font_family":\n' >"$manual_font_home/.config/zed/settings.json"
if HOME="$manual_font_home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" --enable 'System Font' >/dev/null 2>&1; then
  fail "font sync reports an invalid settings file"
fi
[[ ! -e $manual_font_home/.local/state/omarchy/zed/font-sync ]] ||
  fail "font sync does not opt in when settings could not be updated"
[[ $(<"$manual_font_home/.config/zed/settings.json") == '{"buffer_font_family":' ]] ||
  fail "font sync preserves malformed settings"
pass "Zed font sync does not enable itself after an update failure"

missing_zed_home="$test_tmp/missing-zed-home"
mkdir -p "$missing_zed_home" "$test_tmp/missing-zed-bin"
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/missing-zed-bin/omarchy-cmd-missing"
chmod +x "$test_tmp/missing-zed-bin/omarchy-cmd-missing"
HOME="$missing_zed_home" PATH="$test_tmp/missing-zed-bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set-zed" --enable 'Unused Font'
[[ ! -e $missing_zed_home/.config/zed ]] || fail "font sync skips a missing Zed installation"
[[ ! -e $missing_zed_home/.local/state/omarchy/zed/font-sync ]] || fail "font sync does not opt in without Zed"
pass "Zed font sync skips users without Zed"

other_home="$test_tmp/other-home"
mkdir -p "$other_home/.config/zed/themes" "$other_home/.local/state/omarchy/current/theme"
cp "$generated_theme" "$other_home/.local/state/omarchy/current/theme/zed.json"
printf '{"theme":"Omazed"}\n' >"$other_home/.config/zed/settings.json"
for _ in 1 2; do
  HOME="$other_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate
done
jq -e '.theme == "Omarchy"' "$other_home/.config/zed/settings.json" >/dev/null ||
  fail "Zed sync replaces an Omazed selection"
pass "Zed sync migrates an Omazed selection idempotently"

printf '%s\n' '{' '  // "theme": "Omazed",' '  "theme": "One Dark"' '}' >"$other_home/.config/zed/settings.json"
HOME="$other_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate

grep -q '"theme": "One Dark"' "$other_home/.config/zed/settings.json" ||
  fail "Zed migration preserves a manually selected theme"
grep -q '// "theme": "Omazed",' "$other_home/.config/zed/settings.json" ||
  fail "Zed migration ignores an Omazed reference inside a comment"
pass "Zed migration preserves another selected theme"
[[ ! -e $other_home/.local/state/omarchy/zed/font-sync ]] ||
  fail "Zed theme sync does not enable font sync"

cat >"$other_home/.config/zed/settings.json" <<'JSONC'
{
  "theme": {
    "mode": "system",
    "light": "One Light",
    "dark": "Omazed"
  }
}
JSONC
HOME="$other_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate
jq -e '.theme.mode == "system" and .theme.light == "One Light" and .theme.dark == "Omarchy"' \
  "$other_home/.config/zed/settings.json" >/dev/null ||
  fail "Zed migration replaces only Omazed in a light/dark theme object"
pass "Zed migration preserves other choices in a light/dark theme object"

missing_theme_home="$test_tmp/missing-theme-home"
mkdir -p "$missing_theme_home/.config/zed/themes"
printf '{"theme":"Omazed"}\n' >"$missing_theme_home/.config/zed/settings.json"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate >/dev/null 2>&1; then
  fail "Zed sync fails while a selected Omazed theme has no native replacement"
fi
grep -q '"theme":"Omazed"' "$missing_theme_home/.config/zed/settings.json" ||
  fail "Zed sync keeps the working selection when the native theme is unavailable"
pass "Zed sync keeps Omazed selected until the replacement is ready"

if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --select >/dev/null 2>&1; then
  fail "Zed selection reports a missing generated theme"
fi
pass "Zed selection fails rather than silently selecting a missing theme"

mkdir -p "$missing_theme_home/.local/state/omarchy/current/theme"
printf '%s\n' '{"themes": []}' >"$missing_theme_home/.local/state/omarchy/current/theme/zed.json"
cp "$generated_theme" "$missing_theme_home/.config/zed/themes/omarchy.json"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate >/dev/null 2>&1; then
  fail "Zed sync fails when the replacement does not define the Omarchy theme"
fi
grep -q '"theme":"Omazed"' "$missing_theme_home/.config/zed/settings.json" ||
  fail "Zed sync keeps the old selection when the replacement is invalid"
cmp -s "$generated_theme" "$missing_theme_home/.config/zed/themes/omarchy.json" ||
  fail "Zed sync does not overwrite a valid theme with an invalid replacement"
pass "Zed sync rejects an invalid replacement"

printf '%s\n' '{broken json' >"$missing_theme_home/.local/state/omarchy/current/theme/zed.json"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" >/dev/null 2>&1; then
  fail "Zed sync reports malformed theme JSON"
fi
cmp -s "$generated_theme" "$missing_theme_home/.config/zed/themes/omarchy.json" ||
  fail "Zed sync preserves its previous theme when generated JSON is malformed"
pass "Zed sync preserves the previous theme when generated JSON is malformed"

cat "$generated_theme" "$generated_theme" >"$missing_theme_home/.local/state/omarchy/current/theme/zed.json"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" >/dev/null 2>&1; then
  fail "Zed sync rejects multiple JSON documents"
fi
cmp -s "$generated_theme" "$missing_theme_home/.config/zed/themes/omarchy.json" ||
  fail "Zed sync preserves the previous theme when multiple documents are supplied"
pass "Zed sync rejects multiple JSON documents"

jq '.themes[0].style["border"] = "{{ accent }}"' "$generated_theme" >"$missing_theme_home/.local/state/omarchy/current/theme/zed.json"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" >/dev/null 2>&1; then
  fail "Zed sync rejects unresolved color placeholders"
fi
cmp -s "$generated_theme" "$missing_theme_home/.config/zed/themes/omarchy.json" ||
  fail "Zed sync keeps its previous theme when colors are unresolved"
if HOME="$missing_theme_home" PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-zed" --migrate >/dev/null 2>&1; then
  fail "Zed sync does not migrate to a theme with unresolved colors"
fi
grep -q '"theme":"Omazed"' "$missing_theme_home/.config/zed/settings.json" ||
  fail "Zed sync keeps Omazed selected when colors are unresolved"
pass "Zed sync preserves the previous theme when colors are unresolved"

python3 - "$settings" "$test_tmp/crlf-expected" <<'PY'
import pathlib
import sys

before = (b'\xef\xbb\xbf{\r\n  "other": [1, 2, false,], // keep }\r\n'
          b'  "buffer_font_family": /* keep */ "Old" /* }, */,\r\n}\r\n')
pathlib.Path(sys.argv[1]).write_bytes(before)
pathlib.Path(sys.argv[2]).write_bytes(before.replace(b'"Old"', b'"New Font"'))
PY
run_sync --font 'New Font'
cmp -s "$test_tmp/crlf-expected" "$settings" || fail "Zed font sync preserves BOM, CRLF, and JSONC comments"
pass "Zed font sync preserves BOM, CRLF, and JSONC comments"

printf '{"theme":"First", "theme":"Second"}\n' >"$settings"
cp "$settings" "$test_tmp/duplicate-settings.json"
if run_sync --select >/dev/null 2>&1; then
  fail "Zed sync refuses ambiguous duplicate settings"
fi
cmp -s "$test_tmp/duplicate-settings.json" "$settings" || fail "Zed sync preserves ambiguous settings"
pass "Zed sync refuses ambiguous duplicate settings"

python3 - "$ROOT" "$test_tmp" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys

root = Path(sys.argv[1])
home = Path(sys.argv[2]) / "concurrent-home"
settings = home / ".config/zed/settings.json"
settings.parent.mkdir(parents=True)
theme = home / ".local/state/omarchy/current/theme/zed.json"
theme.parent.mkdir(parents=True)
theme.write_text(json.dumps({"themes": [{"name": "Omarchy", "appearance": "dark", "style": {}}]}))
env = dict(os.environ, HOME=str(home), PATH=f"{root / 'bin'}:{os.environ['PATH']}")
command = str(root / "bin/omarchy-theme-set-zed")
for existing in (True, False):
    for _ in range(5):
        if existing:
            settings.write_text(json.dumps({"theme": "Old", "buffer_font_family": "Old", "padding": "x" * 100000}))
        else:
            settings.unlink(missing_ok=True)
        commands = [[command, "--select"] for _ in range(3)] + [[command, "--font", "New Font"] for _ in range(3)]
        children = [subprocess.Popen(args, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE) for args in commands]
        for child in children:
            _, error = child.communicate()
            if child.returncode:
                raise RuntimeError(error.decode())
        result = json.loads(settings.read_text())
        if result["theme"] != "Omarchy" or result["buffer_font_family"] != "New Font":
            raise AssertionError("concurrent theme and font updates lost a setting")
print("ok - concurrent Zed theme and font updates do not overwrite one another")
PY
