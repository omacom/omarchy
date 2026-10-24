echo "Let PipeWire follow the source's sample rate"

conf="pipewire/pipewire.conf.d/10-sample-rates.conf"

# Leave anyone who already chose their rates alone, in any PipeWire config.
# PIPEWIRE_CONFIG_DIR is PipeWire's own override for /etc/pipewire.
rates_configured() {
  local system="${PIPEWIRE_CONFIG_DIR:-/etc/pipewire}"

  grep -qsE '^[[:space:]]*default\.clock\.allowed-rates' \
    "$HOME/.config/pipewire/pipewire.conf" "$HOME"/.config/pipewire/pipewire.conf.d/*.conf \
    "$system/pipewire.conf" "$system"/pipewire.conf.d/*.conf
}

if [[ ! -f "$HOME/.config/$conf" ]] && ! rates_configured; then
  omarchy-refresh-config "$conf"
  # PipeWire only reads conf.d at startup. Apply the rates to the running graph
  # too, so the change takes effect now without interrupting playback.
  pw-metadata -n settings 0 clock.allowed-rates "[ 44100 48000 88200 96000 ]" >/dev/null 2>&1 || true
fi
