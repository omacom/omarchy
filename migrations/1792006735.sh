echo "Paste voxtype dictation instead of typing it one character at a time"

# Typing each character through wtype is slow on long dictations, lets text
# land in another window when focus moves mid-stream, and drops or reorders
# characters in some CJK transcriptions. A config that is exactly one Omarchy
# shipped, never edited, gets the new default. Any edit, even a comment, means
# someone chose their settings, so the config is left alone.

voxtype_config="${XDG_CONFIG_HOME:-$HOME/.config}/voxtype/config.toml"

[[ -f $voxtype_config ]] || exit 0

# sha256 of default/voxtype/config.toml as shipped by #4088, #5364 and #14552,
# plus the #4088 config after the #5364 pause_media migration edited it.
shipped_hashes=(
  8d3891aa3657a20452896244a15982301b841aa98a2ec188e9c5a6e19f9df354
  6d36aeaf5b1623957dd0c8842ea1ef2a0fb84af9d5a21798da4ab0fb641dd584
  0026bc1a85b92439e79a39f8a12a47f4148e91824c0c3ed893f77ba15a6902c3
  2cf51ad1519304a36dda4517c6f8b3dc4b12a1ebd795c46388a40f3e7ca9150f
)

config_hash=$(sha256sum <"$voxtype_config" | cut -d' ' -f1)
[[ " ${shipped_hashes[*]} " == *" $config_hash "* ]] || exit 0

cp "$OMARCHY_PATH/default/voxtype/config.toml" "$voxtype_config"

# Voxtype reads its config at startup. Restart an idle daemon so the change
# applies now. A busy one picks it up at its next restart instead of losing
# the dictation in progress.
if systemctl --user is-active --quiet voxtype.service && [[ $(voxtype status 2>/dev/null) == "idle" ]]; then
  systemctl --user restart voxtype.service
fi
