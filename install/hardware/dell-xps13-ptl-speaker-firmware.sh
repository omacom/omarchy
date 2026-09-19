# The CS35L56 amplifiers in the Panther Lake Dell XPS 13 DX13260 ask for firmware
# by a subsystem ID that linux-firmware only aliased in 20260910; without the
# aliases the speakers are silent. The package carries just those aliases.

if omarchy-hw-dell-xps13-dx13260-ptl; then
  omarchy-pkg-add dell-xps13-speaker-firmware
fi
