echo "Separate printer discovery from root and print-filter access"

machine_marker=/var/lib/omarchy/migrations/1787815267
installed_packages=""

load_installed_packages() {
  installed_packages=$(/usr/bin/pacman -Qq) || {
    echo "Could not inspect installed packages; leaving CUPS hardening pending." >&2
    return 1
  }
}

package_installed() { [[ $'\n'$installed_packages$'\n' == *$'\n'"$1"$'\n'* ]]; }

nss_record() {
  local database=$1 name=$2 output status
  output=$(/usr/bin/getent "$database" "$name") && status=0 || status=$?
  if (( status == 0 )); then
    printf '%s' "$output"
  elif (( status == 2 )); then
    return 1
  else
    echo "Could not inspect the $name $database record; leaving CUPS hardening pending." >&2
    return 2
  fi
}

unit_active() {
  local status
  /usr/bin/systemctl is-active --quiet "$1" 2>/dev/null && return 0
  status=$?
  (( status == 3 )) && return 1
  echo "Could not inspect whether $1 is active; leaving CUPS hardening pending." >&2
  return 2
}

unit_enabled() {
  local state status
  state=$(/usr/bin/systemctl is-enabled "$1" 2>/dev/null) && status=0 || status=$?
  if (( status == 0 )); then return 0; fi
  case $state in disabled|masked|masked-runtime|static|indirect|generated|transient|alias|linked|linked-runtime) return 1 ;; esac
  echo "Could not inspect whether $1 is enabled; leaving CUPS hardening pending." >&2
  return 2
}

repair_machine() {
  local account="" group="" uid="" gid="" description="" home="" shell="" group_gid="" members="" other_primary_user="" passwd_records=""
  local status
  [[ ! -e $machine_marker ]] || return 0
  load_installed_packages || return 1

  if package_installed cups; then
    account=$(nss_record passwd cups-browsed) || { status=$?; (( status == 1 )) || return 1; account=""; }
    group=$(nss_record group cups-browsed) || { status=$?; (( status == 1 )) || return 1; group=""; }
    if [[ -n $account || -n $group ]]; then
      IFS=: read -r _ _ uid gid description home shell <<<"$account"
      IFS=: read -r _ _ group_gid members <<<"$group"
      if ! passwd_records=$(/usr/bin/getent passwd); then
        echo "Could not enumerate passwd records; leaving CUPS hardening pending." >&2
        return 1
      fi
      other_primary_user=$(/usr/bin/awk -F: -v gid="$gid" '$1 != "cups-browsed" && $4 == gid { print $1; exit }' <<<"$passwd_records") || return 1
      if [[ ! $uid =~ ^[0-9]+$ || ! $group_gid =~ ^[0-9]+$ ]] ||
        (( uid <= 0 || uid >= 1000 )) || [[ $gid != "$group_gid" ]] ||
        [[ $description != "CUPS printer discovery" || $home != "/" || $shell != "/usr/bin/nologin" ]] ||
        [[ -n $members || -n $other_primary_user ]]; then
        echo "Cannot harden printer discovery: the existing cups-browsed user or group is not a dedicated system account." >&2
        return 1
      fi
    fi
  fi

  if package_installed cups-pdf; then
    /usr/bin/env OMARCHY_UPDATE_PACMAN=1 /usr/bin/pacman -Rns --noconfirm -- cups-pdf || return 1
  fi
  if package_installed cups && ! package_installed cups-pk-helper; then
    /usr/bin/env OMARCHY_UPDATE_PACMAN=1 /usr/bin/pacman -S --needed --noconfirm -- cups-pk-helper || return 1
  fi
  if unit_active cups-browsed.service; then
    /usr/bin/systemctl stop cups-browsed.service || return 1
  else
    status=$?
    (( status == 1 )) || return 1
  fi
  if package_installed cups; then
    /usr/bin/systemctl daemon-reload || return 1
    /usr/bin/systemctl try-reload-or-restart cups.service || return 1
  fi
  if unit_enabled cups-browsed.service; then
    /usr/bin/systemctl restart cups-browsed.service || return 1
  else
    status=$?
    (( status == 1 )) || return 1
  fi
  /usr/bin/install -Dm644 /dev/null "$machine_marker" || return 1
}

if (( $# == 0 )); then
  [[ ! -e $machine_marker ]] || exit 0
  /usr/bin/sudo -N -- /usr/bin/flock --exclusive --no-fork /run/omarchy-cups-hardening-migration.lock \
    /usr/bin/env -i PATH=/usr/bin:/bin \
    /usr/bin/bash -p -euo pipefail /usr/share/omarchy/migrations/1787815267.sh --machine
elif (( $# == 1 && EUID == 0 )) && [[ $1 == "--machine" ]]; then
  repair_machine
else
  echo "This migration accepts no arguments; its machine phase requires root." >&2
  exit 1
fi
