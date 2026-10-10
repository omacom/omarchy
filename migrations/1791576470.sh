#!/bin/bash
echo "Accept Super-held copy/paste chords in foot"

# Universal copy/paste (Super+C / Super+V) injects Ctrl+Shift+C/V while Super
# is still held, so foot sees Mod4+Control+Shift and skips the exact-match
# Control+Shift binding. Rewrite only the shipped lines.

foot_config="$HOME/.config/foot/foot.ini"

[[ -f $foot_config ]] || exit 0

old_copy='clipboard-copy=Control+Insert Control+Shift+c XF86Copy'
new_copy='clipboard-copy=Control+Insert Control+Shift+c Mod4+Control+Shift+c XF86Copy'
old_paste='clipboard-paste=Shift+Insert Control+Shift+v XF86Paste'
new_paste='clipboard-paste=Shift+Insert Control+Shift+v Mod4+Control+Shift+v XF86Paste'

if ! grep -qxF "$old_copy" "$foot_config" && ! grep -qxF "$old_paste" "$foot_config"; then
  exit 0
fi

tmp=$(mktemp)
awk \
  -v old_copy="$old_copy" -v new_copy="$new_copy" \
  -v old_paste="$old_paste" -v new_paste="$new_paste" '
  $0 == old_copy { print new_copy; next }
  $0 == old_paste { print new_paste; next }
  { print }
' "$foot_config" >"$tmp"
# Unique recovery name so we never overwrite a user's foot.ini.bak.
# Delete only this copy, and only after the in-place write finishes.
# cat onto the existing file preserves its mode.
recovery=$(mktemp "${foot_config}.omarchy-1791576470.XXXXXX")
cp -p "$foot_config" "$recovery"
cat "$tmp" >"$foot_config"
rm -f "$tmp" "$recovery"