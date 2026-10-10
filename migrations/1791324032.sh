echo "Cap MacBook10,1 package power at 4.5W/7W and CPU turbo at 3GHz"

source "$OMARCHY_PATH/install/hardware/apple/fix-macbook10-power-envelope.sh"

if omarchy-hw-macbook10; then
  sudo /usr/bin/omarchy-hw-macbook10-power-envelope
fi
