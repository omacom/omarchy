# Speaker amplifier tuning for the ASUS ProArt P14 H7407BA (NVIDIA N1x).
#
# The Cirrus CS35L56 amplifiers name their DSP firmware and speaker tuning after
# the laptop, and linux-firmware has none for this one, so they run their ROM
# defaults: quiet and unvoiced. The package carries ASUS's tuning for it. It runs
# before speaker-tuning.sh, whose voicing for this laptop assumes the amplifiers
# have it.

if omarchy-hw-match "H7407BA"; then
  omarchy-pkg-add asus-proart-p14-speaker-firmware
fi
