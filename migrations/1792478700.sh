echo "Remove unused NVIDIA userspace from machines without an NVIDIA GPU"

# A --noconfirm transaction used to resolve vulkan-driver and
# lib32-vulkan-driver to NVIDIA's userspace when no other provider was
# installed. That leaves an unusable driver on a machine with no NVIDIA GPU,
# including a setuid nvidia-modprobe and EGL vendor libraries that libglvnd
# still dispatches into. Claiming the virtuals for future installs is handled
# separately in the installers and package helpers; this only repairs machines
# that already carry the userspace.
#
# Leave a visible NVIDIA display device or an installed NVIDIA kernel driver
# alone: an unplugged eGPU has no other way to say it exists, and a driver
# installed for one is a deliberate setup. Only remove packages pacman recorded
# as dependencies, so an explicit install stays.
if omarchy-hw-nvidia; then
  exit 0
fi

for driver in nvidia nvidia-open nvidia-lts nvidia-open-lts nvidia-dkms nvidia-open-dkms nvidia-580xx-dkms; do
  if omarchy-pkg-present "$driver"; then
    exit 0
  fi
done

# Match installed names exactly. omarchy-pkg-present follows Provides, so
# nvidia-580xx-utils would also match nvidia-utils, and pacman -R does not
# resolve those aliases when it removes the packages.
if ! installed_packages=$(pacman -Qq); then
  echo "Could not query installed packages." >&2
  exit 1
fi

declare -A installed=()
while IFS= read -r package; do
  installed[$package]=1
done <<<"$installed_packages"

# Add the next legacy generation here when Omarchy packages one.
vulkan_targets=()
opencl_targets=()
for package in \
  nvidia-utils lib32-nvidia-utils \
  nvidia-580xx-utils lib32-nvidia-580xx-utils \
  opencl-nvidia lib32-opencl-nvidia \
  opencl-nvidia-580xx lib32-opencl-nvidia-580xx; do
  [[ -n ${installed[$package]:-} ]] || continue

  if ! info=$(LC_ALL=C pacman -Qi "$package" 2>/dev/null); then
    echo "Could not inspect $package." >&2
    exit 1
  fi

  grep -q '^Install Reason[[:space:]]*: Installed as a dependency' <<<"$info" || continue

  case $package in
    opencl-* | lib32-opencl-*) opencl_targets+=("$package") ;;
    *) vulkan_targets+=("$package") ;;
  esac
done

(( ${#vulkan_targets[@]} + ${#opencl_targets[@]} > 0 )) || exit 0

# A dependency block leaves the package installed. A real pacman failure stays
# pending, so a lock or a damaged database is retried rather than recorded as
# "nothing else needed it".
remove_packages() {
  local description="$1" output
  shift

  (( $# > 0 )) || return 0

  if ! output=$(LC_ALL=C pacman -Rs --print "$@" 2>&1); then
    if grep -q 'could not satisfy dependencies' <<<"$output"; then
      echo "Something still depends on the $description; leaving it installed." >&2
      return 0
    fi

    printf '%s\n' "$output" >&2
    return 1
  fi

  if ! omarchy-pkg-drop "$@"; then
    echo "Could not remove the $description; leaving it installed." >&2
    return 1
  fi
}

if (( ${#vulkan_targets[@]} > 0 )); then
  # Claim the virtual packages with the drivers for the GPU that is present
  # before removing what claims them. Read the cached sysfs IDs rather than
  # lspci, which wakes runtime-suspended GPUs.
  pci_devices_path="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"
  intel=0
  amd=0
  shopt -s nullglob
  for device in "$pci_devices_path"/*; do
    [[ $(< "$device/class") == 0x03* ]] || continue
    case $(< "$device/vendor") in
      0x8086) intel=1 ;;
      0x1002) amd=1 ;;
    esac
  done

  # The 64-bit driver mapping is architecture-independent; only the lib32 twins
  # depend on x86_64's multilib.
  hardware_packages=()
  lib32_packages=()
  if (( intel )); then
    hardware_packages+=(vulkan-intel)
    if omarchy-hw-x86; then
      lib32_packages+=(lib32-vulkan-intel)
    fi
  fi
  if (( amd )); then
    hardware_packages+=(vulkan-radeon)
    if omarchy-hw-x86; then
      lib32_packages+=(lib32-vulkan-radeon)
    fi
  fi

  # The 64-bit driver is mandatory; the 32-bit one is best effort, because a
  # missing multilib or an unreachable mirror must not take the 64-bit driver
  # down with it.
  if (( ${#hardware_packages[@]} > 0 )); then
    if ! omarchy-pkg-add "${hardware_packages[@]}"; then
      echo "Could not install the matching Vulkan drivers; leaving the NVIDIA packages installed." >&2
      exit 1
    fi
  fi

  lib32_ready=1
  if (( ${#lib32_packages[@]} > 0 )); then
    if ! omarchy-pkg-add "${lib32_packages[@]}"; then
      echo "Warning: could not install the 32-bit Vulkan drivers; 32-bit applications may resolve to NVIDIA's userspace." >&2
      lib32_ready=0
    fi
  fi

  # Without a 32-bit driver, removing the 32-bit NVIDIA userspace would let the
  # next Steam install resolve lib32-vulkan-driver to it again. Leave that half
  # until a provider exists; the dry run decides whether the 64-bit packages can
  # still go without it.
  removal_targets=("${vulkan_targets[@]}")
  if (( ! lib32_ready )); then
    removal_targets=()
    for package in "${vulkan_targets[@]}"; do
      [[ $package == lib32-* ]] || removal_targets+=("$package")
    done
  fi

  if (( ${#removal_targets[@]} > 0 )); then
    remove_packages "NVIDIA userspace" "${removal_targets[@]}" || exit 1
  else
    echo "Leaving the 32-bit NVIDIA userspace installed until a 32-bit Vulkan driver is available." >&2
  fi

  # A failed 32-bit install is transient, but it leaves the pair installed: the
  # 32-bit package keeps nvidia-utils alive through its exact-version
  # dependency, and the dry run reports that as "something still depends on
  # it". Only the excluded 32-bit packages are evidence of that failure; a
  # 64-bit package left behind without one is a real dependency block, which
  # remove_packages already handles by leaving it alone. Stay pending so the
  # next update retries, instead of recording a cleanup this run could not
  # finish.
  if (( ! lib32_ready )); then
    if ! current_packages=$(pacman -Qq); then
      echo "Could not query installed packages." >&2
      exit 1
    fi

    for package in "${vulkan_targets[@]}"; do
      [[ $package == lib32-* ]] || continue
      if grep -Fxq "$package" <<<"$current_packages"; then
        echo "The 32-bit Vulkan driver install failed and $package is still installed; leaving the cleanup pending for the next run." >&2
        exit 1
      fi
    done
  fi
fi

# OpenCL is a separate transaction so a package that still wants opencl-driver
# cannot veto the Vulkan cleanup.
if (( ${#opencl_targets[@]} > 0 )); then
  remove_packages "NVIDIA OpenCL userspace" "${opencl_targets[@]}" || exit 1
fi
