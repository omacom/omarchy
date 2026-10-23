echo "Apply ASUS X415MA/A416MA headset microphone quirk"

# install/hardware/all.sh only runs on fresh installs, so existing X415MA/A416MA
# machines would never get the modprobe quirk. Re-run the same install script
# here; it is guarded by omarchy-hw-match and idempotent. A reboot (or
# re-running omarchy-update) is required since snd-hda-intel only reads
# modprobe options at module load.
if omarchy-hw-match "X415MA" || omarchy-hw-match "A416MA"; then
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-x415ma-headset-mic.sh"
  omarchy-state set reboot-required
fi
