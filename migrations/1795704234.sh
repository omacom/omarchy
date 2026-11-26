echo "Update speaker tuning for the ASUS Zenbook A16 (UX3607OA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

# Only refresh Omarchy's prior shipped Zenbook A16 tuning so users who disabled
# speaker tuning or installed a custom graph are left untouched.
fragment="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf"
if [[ ! -f $fragment || -L $fragment ]] ||
  ! grep -qx '# ASUS Zenbook A16 UX3607OA (Snapdragon X2 Elite) speaker tuning.' "$fragment" ||
  ! grep -q 'eq12_l' "$fragment"; then
  exit 0
fi

if [[ ! -r $OMARCHY_PATH/default/audio/tunings/asus-zenbook-a16-ux3607oa/filter-chain.conf ]] ||
  ! grep -q 'weq0_l' "$OMARCHY_PATH/default/audio/tunings/asus-zenbook-a16-ux3607oa/filter-chain.conf"; then
  echo "Waiting for omarchy-settings to ship the updated asus-zenbook-a16-ux3607oa speaker tuning"
  exit 75
fi

# An update from a TTY or SSH has no audio session yet, so keep this migration
# pending for the next graphical login without failing the update.
if ! pactl info >/dev/null 2>&1; then
  echo "Waiting for an audio session to apply speaker tuning"
  exit 75
fi

# Preserve an existing EasyEffects setup rather than failing updates when
# omarchy-audio-tuning refuses to coexist with it.
if pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -qx easyeffects_sink ||
  pgrep -u "$(id -u)" -x easyeffects >/dev/null 2>&1 ||
  systemctl --user is-active --quiet easyeffects.service 2>/dev/null; then
  echo "Skipping automatic speaker tuning while EasyEffects is active. To switch later, stop EasyEffects and run: omarchy audio tuning on"
  exit 0
fi

omarchy-pkg-add lsp-plugins-lv2

if ! omarchy-audio-tuning on; then
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
