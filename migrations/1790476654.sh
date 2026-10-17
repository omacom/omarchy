echo "Add Ctrl+Shift+C/V to existing Foot clipboard bindings"

# SUPER+C/V now send Ctrl+Shift+C/V to terminals. Foot configs seeded before
# the packaged defaults gained those chords bind copy/paste to Insert only, so
# SUPER+C reaches the shell as an interrupt. Extend only the untouched legacy
# lines, and leave a config that already binds a chord elsewhere alone, since
# Foot refuses a key combination mapped twice.

foot_config="$HOME/.config/foot/foot.ini"

[[ -f $foot_config ]] || exit 0

if ! grep -qiE '(^|[[:space:]=])(Control\+Shift\+c|XF86Copy)([[:space:]]|$)' "$foot_config"; then
  sed -i 's/^clipboard-copy=Control+Insert[[:space:]]*$/clipboard-copy=Control+Insert Control+Shift+c XF86Copy/' "$foot_config"
fi

if ! grep -qiE '(^|[[:space:]=])(Control\+Shift\+v|XF86Paste)([[:space:]]|$)' "$foot_config"; then
  sed -i 's/^clipboard-paste=Shift+Insert[[:space:]]*$/clipboard-paste=Shift+Insert Control+Shift+v XF86Paste/' "$foot_config"
fi
