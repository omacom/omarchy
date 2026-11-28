echo "Install OpenRazer on Razer laptops so the keyboard lighting follows the theme"

omarchy-hw-razer || exit 0

# linux-omarchy-openrazer ships the modules built and signed with each kernel.
# It only covers linux-omarchy, so a machine with another kernel installed
# keeps (or gets) the DKMS build from install/hardware/razer.sh.
if omarchy-pkg-present linux-omarchy &&
  [[ $(cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u) == "linux-omarchy" ]]; then
  installed=$(pacman -Q linux-omarchy | cut -d' ' -f2)
  offered=$(LC_ALL=C pacman -Si linux-omarchy-openrazer 2>/dev/null | awk '/^Version/ { print $3 }' || true)

  # The modules only install next to the kernel they were built with.
  if [[ $offered != "$installed" ]] || ! pacman -Si openrazer-driver &>/dev/null; then
    echo "Waiting for linux-omarchy-openrazer $installed to reach this machine's packages"
    exit 75
  fi

  # One transaction with --ask 4 so pacman accepts replacing the conflicting
  # openrazer-driver-dkms in place.
  if omarchy-pkg-present openrazer-driver-dkms; then
    sudo pacman -S --noconfirm --ask 4 linux-omarchy-openrazer openrazer-driver
  fi
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" OMARCHY_INSTALL_USER="${USER:-$(id -un)}" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/razer.sh"
'

# Takes effect once the modules are loaded and this session holds the
# openrazer group, so on most machines from the next boot.
omarchy-theme-set-keyboard-razer
