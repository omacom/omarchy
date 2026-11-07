# Speaker amplifier tuning for the ASUS ProArt P16 H7607BA (NVIDIA N1x).
#
# The Cirrus CS35L56 amplifiers name their DSP firmware and speaker tuning after
# the laptop's subsystem ID, 1043:1484 on this one, and linux-firmware has none
# for it, so they run their ROM defaults: quiet and unvoiced. The package
# carries ASUS's tuning for it. It runs before speaker-tuning.sh, like the
# P14's, so a voicing that assumes the amplifiers have it can match.

if omarchy-hw-match "H7607BA"; then
  omarchy-pkg-add asus-proart-p16-speaker-firmware
fi
