echo "Upgrade Sunshine to fix privileged GUI module loading"

# GHSA-fp6g-27w5-489j; originally reported by Sean Huber.
if omarchy-pkg-present sunshine; then
  minimum_version="2026.914.233613"
  read -r installed_package installed_version < <(pacman -Q sunshine)

  # AUR variants provide sunshine under their own name and conflict with the repo package.
  if [[ $installed_package != "sunshine" ]]; then
    echo "Sunshine comes from $installed_package; update it from its own source if it is older than $minimum_version"
  elif (( $(vercmp "$installed_version" "$minimum_version") < 0 )); then
    sudo pacman -S --noconfirm --needed "sunshine>=$minimum_version"

    # Keep the migration pending if the installed package is still vulnerable.
    pacman -T "sunshine>=$minimum_version"
  fi
fi
