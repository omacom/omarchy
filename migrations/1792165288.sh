echo "Check GPU Screen Recorder's security update"

package="gpu-screen-recorder"
minimum_version="6.1.2"

# Upstream 6.1.2 includes a security fix for the privileged KMS helper.
# https://git.dec05eba.com/gpu-screen-recorder/commit/?h=6.1.2
if installed_package=$(LC_ALL=C pacman -Q "$package" 2>/dev/null); then
  # A provider's build version need not match upstream's release version.
  # Let pacman compare the version in its provides metadata instead.
  if ! LC_ALL=C pacman -T "$package>=$minimum_version" >/dev/null; then
    installed_name=${installed_package% *}
    installed_version=${installed_package##* }
    echo "GPU Screen Recorder v${minimum_version} or newer is required for its KMS helper security fix." >&2
    if [[ $installed_name == "$package" ]]; then
      echo "v${installed_version} is installed. Run omarchy update; if the package is held, review IgnorePkg in /etc/pacman.conf before updating it." >&2
    else
      echo "$installed_name ($installed_version) does not provide $package>=$minimum_version. Update or rebuild it with the upstream security fix and a versioned provides entry." >&2
    fi
    # Normal package updates already upgrade repository installs. Leave holds
    # and alternate providers to their owner rather than overriding them.
    exit 1
  fi
else
  if missing_dependencies=$(LC_ALL=C pacman -T "$package" 2>/dev/null); then
    echo "Could not determine the installed GPU Screen Recorder version; the migration will retry." >&2
    exit 1
  elif ! grep -Fxq "$package" <<<"$missing_dependencies"; then
    echo "Could not determine the installed GPU Screen Recorder version; the migration will retry." >&2
    exit 1
  fi
fi
