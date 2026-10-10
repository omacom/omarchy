# Detect Surface devices which require additional modules for the keyboard to work.
# Module list derived from Chris McLeod's manual install instructions
# https://chrismcleod.dev/blog/installing-arch-linux-with-secure-boot-on-a-microsoft-surface-laptop-studio/
# The Intel LPSS modules below do not exist on arm64, so this is an x86_64-only fix.
mkinitcpio_dir=${OMARCHY_SURFACE_MKINITCPIO_DIR:-/etc/mkinitcpio.conf.d}

if omarchy-hw-surface && [[ $(uname -m) == "x86_64" ]]; then
  product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
  echo "Detected Surface Device"

  # Modules already exist in the rootfs for the default kernel.
  if [[ $product_name != "Surface Laptop 3" ]]; then
    echo "Untested Surface Device: $product_name, additional modules may be required for your device."
  fi

  echo "Attempting to autodetect required pinctrl module"
  pinctrl_module=$(lsmod | grep pinctrl_ | cut -f 1 -d" " || true)
  if [[ -z $pinctrl_module ]]; then
    echo "Failed to autodetect pinctrl module."
  else
    echo "Detected pinctrl module: $pinctrl_module"
    mkdir -p "$mkinitcpio_dir"
    echo "MODULES=(${pinctrl_module} surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw)" > \
      "$mkinitcpio_dir/surface_device_modules.conf"
  fi
fi
