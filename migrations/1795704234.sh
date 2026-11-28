echo "Update speaker tuning for the ASUS Zenbook A16 (UX3607OA)"

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

# Only refresh an unmodified copy of Omarchy's prior shipped Zenbook A16 tuning
# (allowing only the substituted target.object sink name to differ) so users who
# disabled speaker tuning or customized their graph are left untouched.
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
host_config="$config_home/pipewire/omarchy-speaker-tuning.conf"
fragment="$config_home/pipewire/omarchy-speaker-tuning.conf.d/90-tuning.conf"
unit_name=omarchy-speaker-tuning.service
unit="$config_home/systemd/user/$unit_name"
unit_source="$OMARCHY_PATH/default/systemd/user/$unit_name"
prior_sha256="d53b4108730b129ffafae3a410b95751e75777788aa059d8ed6c35e787fa626d"

if [[ ! -f $fragment || -L $fragment ]]; then
  exit 0
fi

installed_sha256="$(
  sed -E 's|^([[:space:]]*target\.object[[:space:]]*=[[:space:]]*).*|\1"@SPEAKER_SINK@"|' "$fragment" |
    sha256sum | awk '{print $1}'
)"
if [[ $installed_sha256 != "$prior_sha256" ]]; then
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

# omarchy-audio-tuning on removes the installed files if verification fails.
# Back them up first so a transient failure restores the prior tuning and a
# subsequent migration retry can still detect and refresh it.
backup_dir="$(mktemp -d)"
trap 'rm -rf "$backup_dir"' EXIT
was_enabled=0
was_active=0
systemctl --user is-enabled --quiet "$unit_name" 2>/dev/null && was_enabled=1
systemctl --user is-active --quiet "$unit_name" 2>/dev/null && was_active=1
cp -p "$fragment" "$backup_dir/90-tuning.conf"
[[ -f $host_config ]] && cp -p "$host_config" "$backup_dir/omarchy-speaker-tuning.conf"
[[ -f $unit ]] && cp -p "$unit" "$backup_dir/$unit_name"

if ! omarchy-audio-tuning on; then
  install -Dm644 "$backup_dir/90-tuning.conf" "$fragment"
  [[ -f $backup_dir/omarchy-speaker-tuning.conf ]] &&
    install -Dm644 "$backup_dir/omarchy-speaker-tuning.conf" "$host_config"
  if [[ -f $backup_dir/$unit_name ]]; then
    install -Dm644 "$backup_dir/$unit_name" "$unit"
  elif [[ -f $unit_source ]]; then
    install -Dm644 "$unit_source" "$unit"
  fi
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  ((was_enabled)) && systemctl --user enable "$unit_name" >/dev/null 2>&1 || true
  ((was_active)) && systemctl --user restart "$unit_name" >/dev/null 2>&1 || true
  echo "Speaker tuning not applied yet. After logging in or rebooting, run: omarchy audio tuning on" >&2
  exit 1
fi
