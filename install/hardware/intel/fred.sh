# Enable Flexible Return and Event Delivery on Intel Panther Lake.

# Left alone once set, so a rerun is not a boot image change to rebuild for.
if omarchy-hw-intel-ptl && [[ $(omarchy-boot-cmdline get intel-panther-lake-fred) != *fred=on* ]]; then
  omarchy-boot-cmdline set intel-panther-lake-fred fred=on
fi
