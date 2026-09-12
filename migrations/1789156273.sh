echo "Upgrade GPU Screen Recorder to v6.1.2 or newer"

package="gpu-screen-recorder"
minimum_version="6.1.2"

if installed_package=$(LC_ALL=C pacman -Q "$package" 2>/dev/null); then
  installed_version=${installed_package#"$package "}
  if (( $(vercmp "$installed_version" "$minimum_version") < 0 )); then
    # omarchy-pkg-add skips packages that are already installed, so ask pacman
    # for the required minimum explicitly and stay pending if it is unavailable.
    sudo pacman -S --noconfirm --needed "$package>=$minimum_version"

    if installed_package=$(LC_ALL=C pacman -Q "$package" 2>/dev/null); then
      installed_version=${installed_package#"$package "}
      if (( $(vercmp "$installed_version" "$minimum_version") < 0 )); then
        echo "GPU Screen Recorder v${minimum_version} or newer is required; v${installed_version} is still installed." >&2
        exit 1
      fi
    else
      echo "Could not verify GPU Screen Recorder after its required upgrade." >&2
      if [[ -n $installed_package ]]; then
        echo "$installed_package" >&2
      fi
      exit 1
    fi
  fi
else
  if installed_packages=$(LC_ALL=C pacman -Qq 2>/dev/null); then
    if grep -Fxq "$package" <<<"$installed_packages"; then
      echo "Could not determine the installed GPU Screen Recorder version; the migration will retry." >&2
      exit 1
    fi
  else
    echo "Could not determine the installed GPU Screen Recorder version; the migration will retry." >&2
    exit 1
  fi
fi
