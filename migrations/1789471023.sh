echo "Upgrade Sunshine to fix privileged GUI module loading"

# GHSA-fp6g-27w5-489j; originally reported by Sean Huber.
if omarchy-pkg-present sunshine; then
  minimum_version="2026.914.233613"
  installed_version=$(pacman -Q sunshine)
  installed_version=${installed_version#sunshine }

  if (( $(vercmp "$installed_version" "$minimum_version") < 0 )); then
    sudo pacman -S --noconfirm --needed "sunshine>=$minimum_version"

    # Keep the migration pending if the installed package is still vulnerable.
    pacman -T "sunshine>=$minimum_version"
  fi
fi
