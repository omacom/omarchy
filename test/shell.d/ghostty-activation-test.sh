#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command desktop-file-edit
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home"
mkdir -p "$HOME/.local/share/applications"
system_desktop="$scratch/system.desktop"
cat >"$system_desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Ghostty
Exec=ghostty
DBusActivatable=true
EOF
sed "s|/usr/share/applications/com.mitchellh.ghostty.desktop|$system_desktop|g" "$ROOT/migrations/1792279674.sh" >"$scratch/migration"
omarchy-cmd-present() { return 0; }
update-desktop-database() { :; }
override="$HOME/.local/share/applications/com.mitchellh.ghostty.desktop"
source "$scratch/migration"
grep -q '^DBusActivatable=false$' "$override"
cat >"$override" <<'EOF'
[Desktop Entry]
Type=Application
Name=My Ghostty
Exec=ghostty --working-directory=/tmp
Actions=New;
[Desktop Action New]
Name=New
Exec=ghostty
EOF
source "$scratch/migration"
grep -q '^Exec=ghostty --working-directory=/tmp$' "$override"
awk '/^\[Desktop Entry\]/{main=1;next} /^\[/{main=0} main && /^DBusActivatable=false$/{found=1} END{exit !found}' "$override"
cp "$override" "$scratch/before"
source "$scratch/migration"
cmp "$scratch/before" "$override"
pass "migration repairs activation in the main group, preserves custom keys and is idempotent"

# Exercise the actual Ghostty install branch with the same local override.
sed -n '/  elif \[\[ \$package == "ghostty" \]\]; then/,/^  fi/p' "$ROOT/bin/omarchy-install-terminal" | sed '1d;$d' | sed "s|/usr/share/applications/com.mitchellh.ghostty.desktop|$system_desktop|g" >"$scratch/install"
desktop-file-edit --set-key=DBusActivatable --set-value=true "$override"
source "$scratch/install"
grep -q '^DBusActivatable=false$' "$override"
grep -q '^Name=My Ghostty$' "$override"
pass "terminal installation repairs an existing override without replacing custom settings"
