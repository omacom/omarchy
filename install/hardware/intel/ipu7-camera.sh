# Install MIPI camera support for Intel IPU7 hardware

if grep -q "OVTI08F4" /sys/bus/acpi/devices/*/hid 2>/dev/null; then
  if omarchy-pkg-present linux-omarchy; then
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add linux-omarchy-ipu7 linux-omarchy-v4l2loopback intel-ipu7-camera
  else
    OMARCHY_PKG_DEFER=1 omarchy-pkg-add intel-ipu7-drivers-dkms v4l2loopback-dkms intel-ipu7-camera
  fi

  if [[ -z ${OMARCHY_INSTALL_USER:-} ]]; then
    mkdir -p /var/lib/omarchy/provisioning
    grep -qxF video /var/lib/omarchy/provisioning/groups 2>/dev/null || echo video >>/var/lib/omarchy/provisioning/groups
  fi
fi
