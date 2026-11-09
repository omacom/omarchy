# Embed Qualcomm device trees so systemd-stub can select one from SMBIOS data.
# DeviceTreeAuto requires literal paths, so the list is written here and
# refreshed before every boot image build, when a kernel update can bring new
# or renamed trees.

if omarchy-hw-aarch64-qualcomm; then
  omarchy-pkg-add systemd-ukify

  (
    export OMARCHY_QUALCOMM_DTB_ROOT OMARCHY_QUALCOMM_DTB_DIR OMARCHY_QUALCOMM_UKI_CONFIG OMARCHY_IMAGE_BOOT_REBUILD
    omarchy-update-qualcomm-device-trees --install
  )

  # limine runs pre.d's executables before it builds any boot image, the
  # kernel update's included. Root runs them, so the hook points at the
  # packaged command rather than a path under OMARCHY_PATH a user may own.
  boot_hooks_dir=${OMARCHY_QUALCOMM_BOOT_HOOKS_DIR:-/etc/boot/hooks/pre.d}
  mkdir -p "$boot_hooks_dir"
  ln -sfn /usr/bin/omarchy-update-qualcomm-device-trees "$boot_hooks_dir/20-omarchy-qualcomm-device-trees"
fi
