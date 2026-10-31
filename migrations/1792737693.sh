echo "Create /dev/nvidia-modeset at boot, so containerized games can present on hybrid NVIDIA laptops"

rule=/etc/udev/rules.d/61-nvidia-modeset.rules
node="${OMARCHY_NVIDIA_MODESET_NODE:-/dev/nvidia-modeset}"

if omarchy-hw-nvidia && ! omarchy-hw-aarch64-n1x && omarchy-cmd-present nvidia-modprobe; then
  if ! cmp -s "$OMARCHY_PATH/default/udev/nvidia-modeset.rules" "$rule"; then
    sudo install -Dm644 "$OMARCHY_PATH/default/udev/nvidia-modeset.rules" "$rule"
  fi

  # Replayed until the node exists, so a retry after a failed udevadm still creates it and another user's run is a no-op
  if [[ ! -e $node ]]; then
    sudo udevadm control --reload
    sudo udevadm trigger --action=bind --subsystem-match=pci --attr-match=vendor=0x10de --attr-match='class=0x03*'
    sudo udevadm settle
  fi
fi
