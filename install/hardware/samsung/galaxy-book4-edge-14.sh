# Samsung Galaxy Book4 Edge 14 (X1E-80-100) board setup.

limine_config_dir=${OMARCHY_GALAXY_BOOK4_EDGE_14_LIMINE_CONFIG_DIR:-/etc/limine-entry-tool.d}
mkinitcpio_dir=${OMARCHY_GALAXY_BOOK4_EDGE_14_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}
initcpio_install_dir=${OMARCHY_GALAXY_BOOK4_EDGE_14_INITCPIO_INSTALL_DIR:-/etc/initcpio/install}

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match-device-tree samsung,galaxy-book4-edge-14; then
  echo "Detected Samsung Galaxy Book4 Edge 14, applying board-specific support..."

  # The laptop doesn't come back from AOSS sleep: a deep suspend loses UFS on
  # resume, and an s2idle one ends in a PMIC power cycle once a full hour of
  # the AOP clock passes. linux-omarchy's qcom_aoss keeps the AOSS awake when
  # this parameter is set. A kernel without the parameter ignores it.
  # usbcore is built into linux-omarchy, so the usb-autosuspend modprobe option
  # never reaches it; hubs then autosuspend after 2 s and the USB-C hub drops
  # off the bus.
  mkdir -p "$limine_config_dir"
  cat >"$limine_config_dir/samsung-galaxy-book4-edge-14.conf" <<'CONF'
# Keep the AOSS out of sleep, which this laptop doesn't resume from.
KERNEL_CMDLINE[default]+=" qcom_aoss.prevent_aoss_sleep=1"
# Keep USB hubs from autosuspending; usbcore is built in, so modprobe.d can't.
KERNEL_CMDLINE[default]+=" usbcore.autosuspend=-1"
CONF

  # The disk unlock prompt stays black when msm is in the initramfs. It binds
  # the display, which ends the firmware framebuffer's scanout, but can't
  # finish: the USB-C DisplayPort controllers wait on the USB-C side, which
  # isn't up until the root file system is. Keeping msm out of the initramfs
  # leaves simpledrm to show the prompt; msm loads after switch root. From
  # Jonny Heggheim's board package (github.com/hegjon/omarchy-galaxy-book4-edge).
  mkdir -p "$initcpio_install_dir"
  cat >"$initcpio_install_dir/samsung-galaxy-book4-edge-14" <<'HOOK'
#!/bin/bash

build() {
  add_dir /etc/modprobe.d
  printf 'blacklist msm\n' >"$BUILDROOT/etc/modprobe.d/samsung-galaxy-book4-edge-14-initrd.conf"
}

help() {
  cat <<HELP
Keeps msm out of the Samsung Galaxy Book4 Edge 14's initramfs, so simpledrm
shows the disk unlock prompt. msm loads normally after switch root.
HELP
}
HOOK

  mkdir -p "$mkinitcpio_dir"
  cat >"$mkinitcpio_dir/samsung-galaxy-book4-edge-14.conf" <<'CONF'
HOOKS+=(samsung-galaxy-book4-edge-14)
CONF

  # Keyboard tags, Bluetooth address and the sound topology's name.
  omarchy-pkg-add samsung-galaxy-book4-edge-14-support
fi
