# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)

PACKAGES=()

if omarchy-hw-pci --class 03 8086:*; then
  PACKAGES+=(vulkan-intel)
fi
if omarchy-hw-pci --class 03 1002:*; then
  PACKAGES+=(vulkan-radeon)
fi
if omarchy-hw-pci --class 03 106b:*; then
  PACKAGES+=(vulkan-asahi)
fi

# Adreno GPUs are platform devices, so lspci never sees them.
if omarchy-hw-aarch64-qualcomm; then
  PACKAGES+=(vulkan-freedreno)
fi

# Mali GPUs (panthor/panfrost) are platform or ACPI devices, not PCI devices.
if omarchy-hw-aarch64; then
  has_mali=false
  for drm_driver in "${OMARCHY_DRM_DEVICES:-/sys/class/drm}"/*/device/driver; do
    [[ -L $drm_driver ]] || continue
    case $(readlink "$drm_driver") in
      */panthor | */panfrost)
        has_mali=true
        break
        ;;
    esac
  done
  if [[ $has_mali == "false" ]]; then
    for acpi_gpu in "${OMARCHY_ACPI_DEVICES:-/sys/bus/acpi/devices}"/CIXH5000:*; do
      [[ -e $acpi_gpu ]] || continue
      acpi_status=15
      [[ -r $acpi_gpu/status ]] && acpi_status=$(<"$acpi_gpu/status")
      if [[ $acpi_status =~ ^[0-9]+$ ]] && (( (acpi_status & 3) == 3 )); then
        has_mali=true
        break
      fi
    done
  fi
  if [[ $has_mali == "true" ]]; then
    PACKAGES+=(vulkan-panfrost)
  fi
fi

if (( ${#PACKAGES[@]} > 0 )); then
  OMARCHY_PKG_DEFER=1 omarchy-pkg-add "${PACKAGES[@]}"
fi
