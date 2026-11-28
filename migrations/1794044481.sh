echo "Bring up the Anduril BlueChip's speakers and microphones with its own UCM profile"

# alsa-ucm-conf has no profile for the BlueChip, so PipeWire offered only a
# dummy output. The machine profile now ships in omarchy-settings, and PipeWire
# only probes a card's UCM profiles when WirePlumber opens it. The speakers also
# need linux-omarchy-aarch64 7.3-27's tree, which links only the left pair.
if omarchy-hw-match-device-tree anduril,bluechip; then
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
