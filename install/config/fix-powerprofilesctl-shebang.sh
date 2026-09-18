# Ensure we use system python3 and not mise's python3 in powerprofilesctl.
# Runs at install, and again from the omarchy libalpm hook after every
# power-profiles-daemon install or upgrade, since the upgrade restores the
# packaged #!/usr/bin/env python3 shebang. The migration that repairs installs
# whose upgrade already reverted the fix sources this script too. Skipping an
# already-fixed client keeps re-runs from reaching for privileges.
target=${OMARCHY_POWERPROFILESCTL_PATH:-/usr/bin/powerprofilesctl}
if [[ -f $target && $(head -n1 "$target") == "#!/usr/bin/env python3" ]]; then
  if (( EUID == 0 )); then
    sed -i '1c\#!/bin/python3' "$target"
  else
    sudo sed -i '1c\#!/bin/python3' "$target"
  fi
fi
