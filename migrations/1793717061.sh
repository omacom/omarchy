echo "Drive the internal panel from the Intel iGPU on MacBookPro11,3"

# The install-time quirk only reaches machines set up after it shipped. See
# install/hardware/apple/fix-dual-gpu-intel-panel.sh for why the GT 750M can't
# drive this desktop and what the quirk changes. It writes machine-wide state
# only, so a user after the first finds the service enabled and stops here.
omarchy-hw-match "MacBookPro11,3" || exit 0
[[ -d /sys/firmware/efi/efivars ]] || exit 0
systemctl is-enabled --quiet omarchy-apple-dgpu-off.service && exit 0

sudo bash "$OMARCHY_PATH/install/hardware/apple/fix-dual-gpu-intel-panel.sh"

# The firmware reads gpu-power-prefs only at power-on.
omarchy-state set reboot-required
