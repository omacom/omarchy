echo "Give the ASUS ProArt PZ13 (HT5306QA) working speakers and microphones"

# See install/hardware/asus/fix-asus-proart-pz13-speakers.sh. The sound card
# needs the kernel's ProArt PZ13 device tree as well, so it comes up from the
# next boot. Migrations run once per user, so a later user finds the package
# installed and leaves the machine as it is.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "HT5306QA" || omarchy-pkg-present asus-proart-pz13-audio; then
  exit 0
fi

omarchy-pkg-add asus-proart-pz13-audio
omarchy-state set reboot-required
