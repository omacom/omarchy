echo "Give the ASUS Zenbook A16 (UX3607OA) working speakers, microphones and ASUS's speaker voicing"

# See install/hardware/asus/fix-asus-zenbook-a16-speakers.sh and the
# asus-zenbook-a16-ux3607oa speaker tuning. The sound card registers at the next
# boot, once the package has given it its topology and UCM profile.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

omarchy-pkg-add asus-zenbook-a16-audio

if omarchy-audio-tuning match >/dev/null 2>&1; then
  omarchy-pkg-add lsp-plugins-lv2
  omarchy-audio-tuning on
fi
