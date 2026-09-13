# Shared by the standalone availability commands and the menu's Bash batch.
# Check all explicit targets, not the solvability of a complete installation.
# Caches live only for this process; a new menu evaluation reads fresh databases.
declare -A __omarchy_sync_targets=() __omarchy_target_results=()
declare -A __omarchy_optional_sync=() __omarchy_optional_aur=()
__omarchy_sync_loaded=false
__omarchy_optional_loaded=false
__omarchy_optional_valid=false
__omarchy_arch_loaded=false

omarchy-pkg-available() {
  local target
  (( $# > 0 )) || return 0
  if ! $__omarchy_sync_loaded; then
    local -a names=()
    mapfile -t names < <(pacman -Slq 2>/dev/null)
    for target in "${names[@]}"; do
      [[ -z $target ]] || __omarchy_sync_targets[$target]=1
    done
    __omarchy_sync_loaded=true
  fi
  for target in "$@"; do
    [[ -n $target ]] || return 1
    if [[ -n ${__omarchy_sync_targets[$target]-} ]]; then
      continue
    fi
    if [[ -z ${__omarchy_target_results[$target]-} ]]; then
      if pacman -Sp --noconfirm -- "$target" >/dev/null 2>&1; then
        __omarchy_target_results[$target]=yes
      else
        __omarchy_target_results[$target]=no
      fi
    fi
    [[ ${__omarchy_target_results[$target]} == "yes" ]] || return 1
  done
}

__omarchy_optional_load() {
  if $__omarchy_optional_loaded; then
    $__omarchy_optional_valid
    return
  fi
  __omarchy_optional_loaded=true
  local id packages arches extra arch
  while IFS='|' read -r id packages extra || [[ -n $id ]]; do
    [[ -z $id || $id == \#* ]] && continue
    [[ $id =~ ^install\.[a-z0-9.-]+$ && $packages =~ [^[:space:]] && -z $extra ]] || return 1
    [[ -z ${__omarchy_optional_sync[$id]-} ]] || return 1
    __omarchy_optional_sync[$id]=$packages
  done <"$OMARCHY_PATH/install/optional-packages.tsv" || return 1
  while IFS='|' read -r id packages arches extra || [[ -n $id ]]; do
    [[ -z $id || $id == \#* ]] && continue
    [[ $id =~ ^install\.[a-z0-9.-]+$ && $packages =~ [^[:space:]] && $arches =~ [^[:space:]] && -z $extra ]] || return 1
    [[ -z ${__omarchy_optional_sync[$id]-} && -z ${__omarchy_optional_aur[$id]-} ]] || return 1
    for arch in $arches; do
      [[ $arch == "x86_64" || $arch == "aarch64" ]] || return 1
    done
    __omarchy_optional_aur[$id]=$arches
  done <"$OMARCHY_PATH/install/optional-aur-packages.tsv" || return 1
  __omarchy_optional_valid=true
}

# Return the complete selected sync targets in an array without a subprocess.
# Xbox's mandatory headers follow the installer's hardware predicate, not uname.
__omarchy_optional_targets() {
  local id=${1:-} headers=linux-headers
  __omarchy_optional_load || return 1
  [[ -n $id && -n ${__omarchy_optional_sync[$id]-} ]] || return 1
  read -ra __omarchy_requested_packages <<<"${__omarchy_optional_sync[$id]}"
  if [[ $id == "install.gaming.xbox-controllers" ]]; then
    if omarchy-hw-apple-silicon; then
      headers=linux-asahi-headers
    fi
    __omarchy_requested_packages=("$headers" "${__omarchy_requested_packages[@]}")
  fi
}

omarchy-install-available() {
  local id=${1:-}
  [[ -n $id ]] || return 1
  __omarchy_optional_load || return 1
  if [[ -n ${__omarchy_optional_aur[$id]-} ]]; then
    if ! $__omarchy_arch_loaded; then
      __omarchy_optional_arch=$(uname -m) || return 1
      __omarchy_arch_loaded=true
    fi
    [[ " ${__omarchy_optional_aur[$id]} " == *" $__omarchy_optional_arch "* ]]
  else
    __omarchy_optional_targets "$id" || return 1
    omarchy-pkg-available "${__omarchy_requested_packages[@]}"
  fi
}
