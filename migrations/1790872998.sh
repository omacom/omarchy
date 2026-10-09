echo "Deploy the shutdown-only battery guard from trusted packages"

# Per-user migration markers must not cause a second privilege prompt once
# another user has deployed the exact current payload and started the service.
if sha256sum --check --status /etc/systemd/system/omarchy-battery-guard.service.sha256 2>/dev/null &&
  cmp -s /usr/share/omarchy/default/systemd/system/omarchy-battery-guard.service /etc/systemd/system/omarchy-battery-guard.service &&
  systemctl is-enabled --quiet omarchy-battery-guard.service &&
  systemctl is-active --quiet omarchy-battery-guard.service; then
  exit 0
fi

# Validate the fixed packaged installer before executing any of its code as
# root. A user checkout (including a /usr/bin symlink into it) is not trusted.
# A package that does not ship the guard yet stays pending until it does. The
# guard is optional protection, so package files that are not root-owned (a
# hand-installed or modified tree) skip it instead: that does not fix itself,
# and a failed migration blocks every later one. A declined prompt or a service
# that fails to start stays pending so the next run retries it.
untrusted=78
status=0
sudo /bin/bash -c '
  set -euo pipefail
  export PATH=/usr/bin:/bin
  untrusted=$1
  source_path=/usr/share/omarchy/install/helpers/battery-guard.sh
  if [[ ! -e $source_path && ! -L $source_path ]]; then
    echo "The installed Omarchy package does not include battery protection yet. Run omarchy-migrate again once it does." >&2
    exit 1
  fi
  path=$source_path
  while [[ $path != "/" ]]; do
    [[ ! -L $path ]] || { echo "Battery guard requires package files, not symlinks: $path" >&2; exit "$untrusted"; }
    read -r owner mode < <(stat -c "%u %a" -- "$path") || { echo "Battery guard cannot inspect $path." >&2; exit "$untrusted"; }
    if [[ $owner != "0" ]] || (( (8#$mode & 0022) != 0 )); then
      echo "Battery guard requires root-owned Omarchy package files: $path" >&2
      exit "$untrusted"
    fi
    path=${path%/*}
    [[ -n $path ]] || path=/
  done
  /bin/bash "$source_path" --restart
' _ "$untrusted" || status=$?

if (( status == untrusted )); then
  echo "Skipping battery protection until the files named above are root-owned. Then run: bash /usr/share/omarchy/migrations/1790872998.sh" >&2
elif (( status != 0 )); then
  exit "$status"
fi
