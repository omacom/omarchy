echo "Give the Acer Aspire 16 AI (A16-11M) working speakers and microphones"

# See install/hardware/acer/fix-acer-aspire-16-ai-speakers.sh. The sound card
# comes with linux-omarchy-dtbs' Aspire 16 AI tree, so it comes up from the
# next boot. Migrations run once per user, so a later user finds the package
# installed and leaves the machine as it is.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "Aspire A16-11M" || omarchy-pkg-present acer-aspire-16-ai-audio; then
  exit 0
fi

omarchy-pkg-add acer-aspire-16-ai-audio
omarchy-state set reboot-required
