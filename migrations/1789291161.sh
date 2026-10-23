echo "Make the Intel IPU6 webcam behind an IVSC work"

if omarchy-hw-intel-ivsc; then
  source "$OMARCHY_PATH/install/hardware/intel/ipu6-ivsc-camera.sh"

  sudo systemctl daemon-reload
  sudo udevadm control --reload

  # Hide the raw nodes and start the relay right away. The user ACL from the
  # nodes' first appearance survives a re-trigger, so drop it here.
  sudo udevadm trigger --action=add --subsystem-match=video4linux
  sudo udevadm settle
  for node in /sys/class/video4linux/video*; do
    grep -qs '^Intel IPU6 ISYS Capture' "$node/name" && sudo setfacl -b "/dev/${node##*/}"
  done

  # The intel_ipu6 load order only takes effect on the next boot, and an
  # already loaded intel_ipu6 cannot be reloaded safely.
  omarchy-state set reboot-required
fi
