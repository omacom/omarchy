# Speakers and microphones on the ASUS Zenbook 14 UX3480QA (Snapdragon X
# X1-26-100). alsa-ucm-conf has no profile for its sound card, so the package
# points the card at the ThinkPad T14s profile, as alsa-ucm-conf does for the
# Zenbook A14.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  omarchy-pkg-add asus-zenbook-14-ux3480qa-audio
fi
