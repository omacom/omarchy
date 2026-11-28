# Install MIPI camera support for Intel IPU7 hardware

if grep -q "OVTI08F4" /sys/bus/acpi/devices/*/hid 2>/dev/null; then
  _ipu7_sole_linux_omarchy() {
    local found=0 pkgbase
    omarchy-hw-x86 && omarchy-pkg-present linux-omarchy || return 1
    for pkgbase in /usr/lib/modules/*/pkgbase; do
      [[ -f $pkgbase ]] || continue
      [[ $(<"$pkgbase") == "linux-omarchy" ]] || return 1
      found=1
    done
    (( found ))
  }

  if _ipu7_sole_linux_omarchy; then
    ipu7_pkg=linux-omarchy-ipu7
    v4l2_pkg=linux-omarchy-v4l2loopback
    omarchy-pkg-present intel-ipu7-drivers-dkms && ipu7_pkg=intel-ipu7-drivers-dkms
    omarchy-pkg-present v4l2loopback-dkms && v4l2_pkg=v4l2loopback-dkms
  else
    ipu7_pkg=intel-ipu7-drivers-dkms
    v4l2_pkg=v4l2loopback-dkms
  fi

  OMARCHY_PKG_DEFER=1 omarchy-pkg-add "$ipu7_pkg" "$v4l2_pkg" intel-ipu7-camera

  if [[ -z ${OMARCHY_INSTALL_USER:-} ]]; then
    mkdir -p /var/lib/omarchy/provisioning
    grep -qxF video /var/lib/omarchy/provisioning/groups 2>/dev/null || echo video >>/var/lib/omarchy/provisioning/groups
  fi
fi
