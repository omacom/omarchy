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
sudo /bin/bash -c '
  set -euo pipefail
  export PATH=/usr/bin:/bin
  source_path=/usr/share/omarchy/install/helpers/battery-guard.sh
  path=$source_path
  while [[ $path != "/" ]]; do
    [[ ! -L $path ]] || { echo "Battery guard requires package files, not symlinks." >&2; exit 1; }
    read -r owner mode < <(stat -c "%u %a" -- "$path")
    if [[ $owner != "0" ]] || (( (8#$mode & 0022) != 0 )); then
      echo "Update root-owned Omarchy packages before enabling battery protection." >&2
      exit 1
    fi
    path=${path%/*}
    [[ -n $path ]] || path=/
  done
  /bin/bash "$source_path" --restart
'
