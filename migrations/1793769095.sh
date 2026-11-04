echo "Let PipeWire follow the source's sample rate"

conf="pipewire/pipewire.conf.d/10-sample-rates.conf"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"

# Leave anyone who already chose their rates alone, in any PipeWire config.
# PIPEWIRE_CONFIG_DIR is PipeWire's own override for /etc/pipewire.
rates_configured() {
  local system="${PIPEWIRE_CONFIG_DIR:-/etc/pipewire}"

  grep -qsE '^[[:space:]]*default\.clock\.allowed-rates' \
    "$config_root/pipewire/pipewire.conf" "$config_root"/pipewire/pipewire.conf.d/*.conf \
    "$system/pipewire.conf" "$system"/pipewire.conf.d/*.conf
}

if [[ ! -f $config_root/$conf ]] && ! rates_configured; then
  install -Dm644 "$OMARCHY_PATH/config/$conf" "$config_root/$conf"
  # PipeWire only reads conf.d at startup. Apply the rates to the running graph
  # too, so the change takes effect now without interrupting playback.
  pw-metadata -n settings 0 clock.allowed-rates "[ 44100 48000 88200 96000 ]" >/dev/null 2>&1 || true
fi
