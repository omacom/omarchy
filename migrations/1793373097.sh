echo "Install HP EliteBook X G2i speaker and camera support"

# See install/hardware/hp/elitebook-x-g2i.sh and the hp-elitebook-x-g2i
# speaker tuning.
if ! omarchy-hw-hp-elitebook-x-g2i; then
  exit 0
fi

source "$OMARCHY_PATH/install/hardware/hp/elitebook-x-g2i.sh"

# The four amps only split left from right with the kernel patches in
# linux-omarchy, so the speaker sink appears from the next boot.
omarchy-state set reboot-required

if omarchy-audio-tuning match >/dev/null 2>&1; then
  omarchy-pkg-add lsp-plugins-lv2
  # The tuning needs the speaker sink. If the speakers are not up yet, a
  # missing tuning must not stop the remaining migrations; it can be applied
  # after the reboot.
  omarchy-audio-tuning on ||
    echo "Speaker tuning not applied yet. After rebooting, run: omarchy audio tuning on"
fi
