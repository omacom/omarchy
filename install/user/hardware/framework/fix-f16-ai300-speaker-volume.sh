# The Framework ALC285 exposes separate stereo "Speaker" and "Bass Speaker"
# mixers. Use software volume to preserve their relative levels, and initialize
# hardware levels after WirePlumber discovers the card on audio-session startup.
# https://github.com/NixOS/nixos-hardware/issues/1743

if omarchy-hw-framework16 && omarchy-hw-match '^Laptop 16 (AMD Ryzen AI 300 Series)$'; then
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
  mixer_source="$OMARCHY_PATH/default/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
  mixer_target="$config_dir/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
  unit_name="omarchy-framework16-speaker-levels.service"
  wants_dir="$config_dir/systemd/user/wireplumber.service.wants"

  if [[ -e $mixer_target || -L $mixer_target ]] && ! cmp -s "$mixer_source" "$mixer_target"; then
    echo "Keeping custom Framework speaker configuration"
  else
    (
      set -e
      mkdir -p "$(dirname "$mixer_target")" "$wants_dir"
      if [[ ! -e $mixer_target && ! -L $mixer_target ]]; then
        mixer_staged=$(mktemp "$(dirname "$mixer_target")/.framework16-mixer.XXXXXX")
        trap 'rm -f "$mixer_staged"' EXIT
        cp --preserve=mode "$mixer_source" "$mixer_staged"
        mv -T "$mixer_staged" "$mixer_target"
      fi
      # Enable offline too. Keep the unit package-owned so updates reach users.
      ln -sfn "/usr/lib/systemd/user/$unit_name" "$wants_dir/$unit_name"
    )
    echo "Framework speaker volume fix enabled; reboot to apply"
  fi
fi
