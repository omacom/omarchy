echo "Remove macbook12-spi-driver-dkms, which no longer builds and isn't needed"

# applespi has been in the mainline kernel since 5.3 and drives the keyboard and
# trackpad on these MacBooks. The out-of-tree package fails to build on 7.x, so
# every kernel update prints a DKMS error for it. The mkinitcpio MODULES drop-in
# stays: it only names in-tree modules.
omarchy-pkg-drop macbook12-spi-driver-dkms
