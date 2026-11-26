echo "Bring up the HP ZBook Ultra G3a speakers and microphones with its own UCM profile"

# The generic AMD SoundWire profile can't load on this laptop (alsa-ucm-conf
# has no TAS2783 speaker config yet), so PipeWire offered only a dummy output.
# The machine profile now ships in omarchy-settings, and PipeWire only probes a
# card's UCM profiles when WirePlumber opens it.
if omarchy-hw-match "ZBook Ultra G3a"; then
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
