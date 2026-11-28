echo "Enable speaker tuning for the ASUS Zenbook 14 (UX3480QA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3480QA"; then
  exit 0
fi

if [[ ! -r $OMARCHY_PATH/default/audio/tunings/asus-zenbook-14-ux3480qa/tuning.conf ]]; then
  echo "Waiting for omarchy-settings to ship the asus-zenbook-14-ux3480qa speaker tuning"
  exit 75
fi

if ! pacman -Q asus-zenbook-14-ux3480qa-audio >/dev/null 2>&1; then
  if ! pacman -Si asus-zenbook-14-ux3480qa-audio >/dev/null 2>&1; then
    echo "Waiting for asus-zenbook-14-ux3480qa-audio to ship before enabling speaker tuning"
    exit 75
  fi
  omarchy-pkg-add asus-zenbook-14-ux3480qa-audio
  omarchy-state set reboot-required
fi

if [[ ! -r /usr/share/wireplumber/wireplumber.conf.d/60-asus-zenbook-14-ux3480qa-soft-volume.conf ]]; then
  echo "Waiting for updated asus-zenbook-14-ux3480qa-audio soft-volume config before enabling speaker tuning"
  exit 75
fi

omarchy-pkg-add lsp-plugins-lv2

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

matched_tuning=$(omarchy-audio-tuning match 2>/dev/null || true)
if [[ -z $matched_tuning || $(basename "$matched_tuning") != "asus-zenbook-14-ux3480qa" ]]; then
  echo "Waiting for asus-zenbook-14-ux3480qa speaker tuning to match before applying"
  exit 75
fi

if ! omarchy-audio-tuning on; then
  if ! pactl list sinks short 2>/dev/null | awk '{print $2}' | grep -Eq '^alsa_output.*platform-sound.*HiFi__Speaker__sink$'; then
    omarchy-state set reboot-required
    echo "Waiting for a reboot to bring up the Zenbook 14 speaker sink before applying speaker tuning"
    exit 75
  fi
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
