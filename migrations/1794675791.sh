echo "Give the HP OmniBook 3 working speakers and microphones"

# See install/hardware/hp/fix-hp-omnibook-3-speakers.sh. The sound card comes
# with linux-omarchy-dtbs' OmniBook 3 tree, so it comes up from the next boot.
# Migrations run once per user, so a later user finds the package installed
# and leaves the machine as it is.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "OmniBook 3 Laptop" || omarchy-pkg-present hp-omnibook-3-audio; then
  exit 0
fi

omarchy-pkg-add hp-omnibook-3-audio
omarchy-state set reboot-required
