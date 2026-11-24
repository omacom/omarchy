# The 83S1 internal mic is on the SN6140 codec; UCM selects an inactive ACP input.
# Use the codec's ALSA profiles, which expose its internal microphone port.
if omarchy-hw-match '^83S1$'; then
  sudo mkdir -p /etc/wireplumber/wireplumber.conf.d
  sudo tee /etc/wireplumber/wireplumber.conf.d/51-ideapad-slim5-internal-mic.conf >/dev/null <<'CONF'
monitor.alsa.rules = [
  {
    matches = [ { device.name = "alsa_card.pci-0000_04_00.6" } ]
    actions = {
      update-props = { api.alsa.use-ucm = false }
    }
  }
]
CONF
fi
