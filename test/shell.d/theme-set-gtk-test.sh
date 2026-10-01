#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export PATH="$ROOT/bin:$PATH"
# A scratch HOME does not isolate an inherited desktop session bus.
unset DBUS_SESSION_BUS_ADDRESS OMARCHY_THEME_HEADLESS OMARCHY_THEME_OFFLINE

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next_theme="$home/.local/state/omarchy/current/next-theme"
current_theme="$home/.local/state/omarchy/current/theme"
mkdir -p "$next_theme" "$current_theme"

cat >"$next_theme/colors.toml" <<'TOML'
mode = "dark"
accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"
background = "#1a1b26"
dark_background = "#13141c"
darker_background = "#0e0e14"
lighter_background = "#24283b"
foreground = "#a9b1d6"
dark_foreground = "#565f89"
red = "#330000"
yellow = "#e0af68"
green = "#9ece6a"
cyan = "#449dab"
TOML

HOME="$home" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-theme-set-templates"
css="$next_theme/gtk.css"
[[ -f $css ]] || fail "GTK template is generated"
grep -Fq -- '--accent-bg-color: #7aa2f7;' "$css" || fail "GTK accent follows the theme"
grep -Fq -- '--accent-fg-color: #1a1b26;' "$css" || fail "GTK accent uses the theme background for contrast"
grep -Fq -- '--destructive-fg-color: #ffffff;' "$css" || fail "GTK dark destructive backgrounds get readable text"
grep -Fq -- '@define-color destructive_fg_color #ffffff;' "$css" || fail "GTK compatibility foreground matches its CSS variable"
grep -Fq -- '--success-fg-color: #1a1b26;' "$css" || fail "GTK success actions use the theme background"
grep -Fq -- '--warning-fg-color: #1a1b26;' "$css" || fail "GTK warnings use the theme background"
grep -Fq -- '--overview-bg-color: #13141c;' "$css" || fail "GTK overview surface is themed"
grep -Fq -- '--active-toggle-bg-color: #7aa2f7;' "$css" || fail "GTK active toggle is themed"
grep -Fq -- '@media (prefers-color-scheme: dark)' "$css" || fail "GTK palette follows the theme mode"
grep -Fq -- '@define-color window_bg_color #1a1b26;' "$css" || fail "GTK compatibility colors follow the theme"
grep -q '{{' "$css" && fail "GTK template has no unresolved values"

for name in \
  accent-bg accent-fg destructive-bg destructive-fg success-bg success-fg \
  warning-bg warning-fg error-bg error-fg window-bg window-fg view-bg view-fg \
  headerbar-bg headerbar-fg headerbar-backdrop sidebar-bg sidebar-fg \
  sidebar-backdrop secondary-sidebar-bg secondary-sidebar-fg \
  secondary-sidebar-backdrop card-bg card-fg dialog-bg dialog-fg popover-bg \
  popover-fg overview-bg overview-fg thumbnail-bg thumbnail-fg \
  active-toggle-bg active-toggle-fg; do
  grep -Fq -- "--${name}-color:" "$css" || fail "GTK template defines --${name}-color"
done

/usr/bin/python - "$css" <<'PY'
import sys

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

errors = []
provider = Gtk.CssProvider()
provider.connect(
    "parsing-error", lambda _provider, _section, error: errors.append(error.message)
)
provider.load_from_path(sys.argv[1])
if errors:
    raise SystemExit("\n".join(errors))
PY
pass "GTK template renders the complete libadwaita palette"

# Exercise actual generated CSS for every stock palette, not just placeholder text.
ROOT="$ROOT" HOME="$home" /usr/bin/python <<'PY'
import os
from pathlib import Path
import re
import shutil
import subprocess

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

root = Path(os.environ["ROOT"])
staging = Path.home() / ".local/state/omarchy/current/next-theme"
fixture = (staging / "colors.toml").read_text()

def luminance(color):
    channels = [int(color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4 for value in channels]
    return sum(value * weight for value, weight in zip(linear, (0.2126, 0.7152, 0.0722)))

def render():
    (staging / "gtk.css").unlink(missing_ok=True)
    subprocess.run([root / "bin/omarchy-theme-set-templates"], check=True, env=dict(os.environ, OMARCHY_PATH=str(root)))
    return (staging / "gtk.css").read_text()

for palette in sorted((root / "themes").glob("*/colors.toml")):
    shutil.copyfile(palette, staging / "colors.toml")
    text = render()
    assert "{{" not in text, palette.parent.name
    for role in ("accent", "destructive", "success", "warning", "error"):
        colors = [re.search(rf"--{role}-{part}-color:\s*(#[0-9a-fA-F]{{6}});", text).group(1) for part in ("bg", "fg")]
        low, high = sorted(map(luminance, colors))
        contrast = (high + 0.05) / (low + 0.05)
        assert contrast >= 4.5, (palette.parent.name, role, colors, contrast)
    provider = Gtk.CssProvider()
    errors = []
    provider.connect("parsing-error", lambda _provider, _section, error: errors.append(error.message))
    provider.load_from_path(str(staging / "gtk.css"))
    assert not errors, (palette.parent.name, errors)

(staging / "colors.toml").write_text(fixture + '\nred_foreground = "#eeeeee"\n')
assert "--destructive-fg-color: #eeeeee;" in render()
(staging / "colors.toml").write_text(fixture)
render()
PY
pass "all stock GTK palettes parse and provide readable accent/status text"
pass "theme authors can override derived foregrounds"

cp "$css" "$current_theme/gtk.css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-theme-set-gtk"

gtk_css="$home/.config/gtk-4.0/gtk.css"
omarchy_css="$home/.config/gtk-4.0/omarchy.css"
[[ $(<"$gtk_css") == '@import url("omarchy.css");' ]] || fail "GTK entrypoint imports the Omarchy theme"
[[ -L $omarchy_css ]] || fail "Omarchy GTK stylesheet is linked"
[[ $(readlink "$omarchy_css") == $current_theme/gtk.css ]] || fail "GTK stylesheet links to the current theme"
pass "GTK theme is installed for new GTK processes"

printf 'button { border-radius: 0; }\n' >>"$gtk_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-theme-set-gtk"
[[ $(grep -Fxc '@import url("omarchy.css");' "$gtk_css") == 1 ]] || fail "GTK import is not duplicated"
grep -Fq 'button { border-radius: 0; }' "$gtk_css" || fail "GTK user CSS is preserved"
pass "GTK installation preserves user CSS"

rm "$current_theme/gtk.css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-theme-set-gtk"
grep -Fxq '/* Omarchy GTK theme unavailable. */' "$omarchy_css" || fail "missing theme CSS clears the managed stylesheet"
grep -Fq 'button { border-radius: 0; }' "$gtk_css" || fail "missing theme CSS keeps user CSS"
pass "GTK installation clears only Omarchy-owned state"

printf '/* user-owned omarchy.css */\n' >"$omarchy_css"
printf '/* replacement theme */\n' >"$current_theme/gtk.css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-theme-set-gtk"
grep -Fxq '/* user-owned omarchy.css */' "$omarchy_css" || fail "user-owned omarchy.css is preserved"
pass "GTK installation does not overwrite an unrelated omarchy.css"

rm "$omarchy_css"
user_css="$home/user-style.css"
printf '/* user-owned stylesheet */\n' >"$user_css"
ln -s "$user_css" "$omarchy_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" "$ROOT/bin/omarchy-theme-set-gtk"
[[ $(readlink "$omarchy_css") == "$user_css" ]] || fail "user-owned stylesheet symlink is preserved"
grep -Fxq '/* user-owned stylesheet */' "$user_css" || fail "user-owned stylesheet is not modified"
rm "$omarchy_css"
ln -s "$home/missing-user-style.css" "$omarchy_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" "$ROOT/bin/omarchy-theme-set-gtk"
[[ $(readlink "$omarchy_css") == "$home/missing-user-style.css" ]] || fail "dangling user stylesheet symlink is preserved"
rm "$omarchy_css"
pass "GTK installation preserves unrelated and dangling stylesheet symlinks"

# Dotfile-managed entrypoints keep their symlink and acquire a working import.
dotfiles="$home/dotfiles/gtk"
mkdir -p "$dotfiles"
dotfile_css="$dotfiles/custom.css"
printf 'button { border-radius: 7px; }\n' >"$dotfile_css"
chmod 640 "$dotfile_css"
rm "$gtk_css"
ln -s "$dotfile_css" "$gtk_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" "$ROOT/bin/omarchy-theme-set-gtk"
HOME="$home" XDG_CONFIG_HOME="$home/.config" "$ROOT/bin/omarchy-theme-set-gtk"
[[ -L $gtk_css && $(readlink "$gtk_css") == "$dotfile_css" ]] || fail "GTK entrypoint symlink is preserved"
[[ $(grep -Fxc "@import url(\"$omarchy_css\");" "$dotfile_css") == 1 ]] || fail "symlink target gets one absolute import"
grep -Fq 'button { border-radius: 7px; }' "$dotfile_css" || fail "symlinked user CSS is preserved"
[[ $(stat -c %a "$dotfile_css") == "640" ]] || fail "symlinked stylesheet permissions are preserved"
pass "GTK installation themes dotfile-managed entrypoints"

rm "$gtk_css"
ln -s "$home/missing-gtk.css" "$gtk_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" "$ROOT/bin/omarchy-theme-set-gtk"
[[ $(readlink "$gtk_css") == "$home/missing-gtk.css" && ! -e $home/missing-gtk.css ]] || fail "dangling GTK entrypoint is left alone"
pass "GTK installation does not invent targets for dangling user entrypoints"

PYTHONPYCACHEPREFIX="$test_tmp/pycache" python -m py_compile "$ROOT/default/nautilus-python/extensions/omarchy_theme.py"
pass "Nautilus extension is syntactically valid"

signal_bin="$test_tmp/signal-bin"
signal_log="$test_tmp/signal.log"
mkdir -p "$signal_bin"
cat >"$signal_bin/gdbus" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$SIGNAL_LOG"
SH
chmod +x "$signal_bin/gdbus"
rm "$omarchy_css"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/test" SIGNAL_LOG="$signal_log" \
  PATH="$signal_bin:$PATH" "$ROOT/bin/omarchy-theme-set-gtk"
grep -Fq -- '--signal org.omarchy.Theme.Changed' "$signal_log" || fail "GTK theme changes notify Nautilus over D-Bus"
pass "GTK theme changes directly notify Nautilus"

rm "$signal_log"
HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
  OMARCHY_THEME_OFFLINE=1 DBUS_SESSION_BUS_ADDRESS="unix:path=/test" \
  SIGNAL_LOG="$signal_log" PATH="$signal_bin:$PATH" "$ROOT/bin/omarchy-theme-set-gtk"
[[ ! -e $signal_log ]] || fail "offline GTK setup does not notify Nautilus"
pass "offline GTK setup only writes persistent config"

migration_home="$test_tmp/migration-home"
stub_bin="$test_tmp/bin"
migration_log="$test_tmp/migration.log"
mkdir -p "$migration_home" "$stub_bin"
cat >"$stub_bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
printf '%s\n' refresh >>"$MIGRATION_LOG"
SH
chmod +x "$stub_bin/omarchy-theme-refresh"

HOME="$migration_home" OMARCHY_PATH="$ROOT" MIGRATION_LOG="$migration_log" \
  PATH="$stub_bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787756628.sh" >/dev/null
HOME="$migration_home" OMARCHY_PATH="$ROOT" MIGRATION_LOG="$migration_log" \
  PATH="$stub_bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787756628.sh" >/dev/null
cmp -s \
  "$ROOT/default/nautilus-python/extensions/omarchy_theme.py" \
  "$migration_home/.local/share/nautilus-python/extensions/omarchy_theme.py" || \
  fail "GTK migration installs the Nautilus extension"
[[ $(grep -Fxc refresh "$migration_log") == 1 ]] || fail "GTK migration refreshes the active theme once"
pass "GTK migration installs live reload and refreshes the theme"

failed_refresh_home="$test_tmp/failed-refresh-home"
mkdir -p "$failed_refresh_home"
cat >"$stub_bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/omarchy-theme-refresh"
HOME="$failed_refresh_home" OMARCHY_PATH="$ROOT" \
  PATH="$stub_bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787756628.sh" >/dev/null
cmp -s \
  "$ROOT/default/nautilus-python/extensions/omarchy_theme.py" \
  "$failed_refresh_home/.local/share/nautilus-python/extensions/omarchy_theme.py" || \
  fail "GTK migration keeps the Nautilus extension when theme refresh fails"
pass "GTK migration does not lose live reload to an unrelated retint failure"

dangling_home="$test_tmp/dangling-home"
dangling_extension="$dangling_home/.local/share/nautilus-python/extensions/omarchy_theme.py"
mkdir -p "$(dirname "$dangling_extension")"
ln -s "$dangling_home/missing-extension.py" "$dangling_extension"
HOME="$dangling_home" OMARCHY_PATH="$ROOT" \
  PATH="$stub_bin:$PATH" bash -euo pipefail "$ROOT/migrations/1787756628.sh" >/dev/null
[[ -L $dangling_extension ]] || fail "GTK migration preserves a dangling user extension symlink"
[[ $(readlink "$dangling_extension") == $dangling_home/missing-extension.py ]] || fail "GTK migration does not follow a dangling user extension symlink"
pass "GTK migration preserves user-managed extension symlinks"

echo "ok - omarchy GTK theming"
