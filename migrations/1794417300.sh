echo "Give the Wi-Fi card of the HP OmniBook X 14 (WCN6855) its card family's board data"

# See install/hardware/fix-ath12k-board-data.sh, which now also covers ath11k's
# WCN6855. ath11k reads board data when it probes the card, so a copy the
# package installs takes effect after a reboot. A second user finds the
# package installed and has nothing to do.
if omarchy-pkg-missing ath12k-board-fallback; then
  bash -euo pipefail -c 'source "$OMARCHY_PATH/install/hardware/fix-ath12k-board-data.sh"'
  if omarchy-pkg-present ath12k-board-fallback && [[ -s /var/lib/ath12k-board-fallback/installed ]]; then
    omarchy-state set reboot-required
  fi
fi
