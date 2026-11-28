echo "Bring up the HP OmniBook X Flip 16 speakers and microphones"

# See install/hardware/hp/fix-hp-omnibook-x-flip-audio.sh. Adds missing 3-field
# TAS2783 firmware symlinks and restarts WirePlumber so PipeWire probes the
# card-specific UCM profile shipped in omarchy-settings.
if omarchy-hw-x86 && omarchy-hw-match "OmniBook X Flip Laptop 16-cc0"; then
  source "$OMARCHY_PATH/install/hardware/hp/fix-hp-omnibook-x-flip-audio.sh"
  systemctl --user try-restart wireplumber.service 2>/dev/null || true
fi
