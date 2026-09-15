# Make the MIPI webcam behind an Intel Visual Sensing Controller work.
#
# Tiger/Alder/Raptor/Meteor Lake laptops route the webcam through an IVSC
# that the kernel reaches over the MEI bus. Since Linux 7.2 the IPU6 bridge no
# longer waits for that MEI client: when intel_ipu6 probes before the IVSC
# firmware handshake finishes, it attaches the camera graph to the ACPI
# placeholder device instead. ivsc_csi then fails with "probed without device
# fwnode", ivsc_ace never clears the sensor's ACPI dependency, the sensor's I2C
# device is never created and the camera exposes only empty capture nodes.
# Keeping intel_ipu6 off the PCI autoload and letting udev load it when the
# CSI client appears restores the intended order.
#
# Even then the kernel only exposes raw Bayer nodes. libcamera's software ISP
# turns them into a picture, and v4l2-relayd re-exposes that as a regular v4l2
# camera so browsers, the webcam overlay and everything else that only speaks
# v4l2 can use it, without per-app PipeWire camera support. The raw nodes are
# hidden from users so they stop showing up as dozens of black "ipu6" cameras.

if omarchy-hw-intel-ivsc; then
  mapfile -t kernel_headers < <(pacman -Qqs '^linux(-zen|-lts|-hardened|-t2|-ptl|-omarchy-bore)?$' | sed 's/$/-headers/')
  omarchy-pkg-add "${kernel_headers[@]}" v4l2loopback-dkms v4l2loopback-utils v4l2-relayd libcamera gst-plugin-libcamera frei0r-plugins

  sudo install -Dm644 "$OMARCHY_PATH/default/modprobe/intel-ipu6-ivsc.conf" /etc/modprobe.d/intel-ipu6-ivsc.conf
  sudo install -Dm644 "$OMARCHY_PATH/default/udev/intel-ipu6-ivsc.rules" /etc/udev/rules.d/90-intel-ipu6-ivsc.rules

  sudo install -Dm644 "$OMARCHY_PATH/default/udev/intel-ipu6-isys.rules" /etc/udev/rules.d/71-intel-ipu6-isys.rules
  sudo install -Dm644 "$OMARCHY_PATH/default/v4l2-relayd/ipu6.conf" /etc/v4l2-relayd.d/ipu6.conf
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/ipu6-loopback.service" /etc/systemd/system/ipu6-loopback.service
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/v4l2-relayd@ipu6.service.d/ipu6.conf" /etc/systemd/system/v4l2-relayd@ipu6.service.d/ipu6.conf

  # libcamera ships no tuning for the OV01A10 and falls back to a generic one
  # that leaves the picture washed out. These colour matrices were calibrated
  # from the Intel tuning binary of the XPS 13 9320 (libcamera-devel, May
  # 2026, not merged yet). Harmless on laptops with another sensor.
  sudo install -Dm644 "$OMARCHY_PATH/default/libcamera/ov01a10.yaml" /usr/share/libcamera/ipa/simple/ov01a10.yaml

  # The module's own default device would otherwise show up in browsers as
  # "Dummy video device". Same file and content as the Cam Link 4K relay.
  sudo install -Dm644 "$OMARCHY_PATH/default/modprobe/v4l2loopback-exclusive-caps.conf" /etc/modprobe.d/v4l2loopback-exclusive-caps.conf
fi
