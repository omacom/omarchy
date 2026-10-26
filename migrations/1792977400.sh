echo "Voice the ASUS ProArt P16 (NVIDIA N1x) woofers like ASUS's Windows tuning"

# See default/audio/tunings/asus-proart-p16-n1x. It matches only once ASUS's
# amplifier tuning for this laptop (asus-proart-p16-speaker-firmware) is
# installed, so on a P16 without it this does nothing; the migration that
# installs the package switches the tuning on then.
if ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

if omarchy-audio-tuning match >/dev/null 2>&1; then
  omarchy-pkg-add lsp-plugins-lv2
  omarchy-audio-tuning on
fi
