echo "Re-apply theme icons to replace retired Yaru-gray/Yaru-grey variants"

current="$HOME/.local/state/omarchy/current"
theme_name_path="$current/theme.name"
staged="$current/theme/icons.theme"

staged_icon=""
[[ -f $staged ]] && staged_icon=$(<"$staged")

if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  user_bus="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"
  if [[ -S $user_bus ]]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$user_bus"
  fi
fi

desktop_icon=""
if command -v gsettings >/dev/null 2>&1; then
  desktop_read=0
  if [[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
    if desktop_raw=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null); then
      desktop_icon=$(printf '%s' "$desktop_raw" | tr -d "'\"")
      desktop_read=1
    fi
  fi
  if (( ! desktop_read )) && command -v dconf >/dev/null 2>&1; then
    if desktop_raw=$(dconf read /org/gnome/desktop/interface/icon-theme 2>/dev/null) && [[ -n $desktop_raw ]]; then
      desktop_icon=$(printf '%s' "$desktop_raw" | tr -d "'\"")
      desktop_read=1
    fi
  fi

  if (( ! desktop_read )); then
    exit 1
  fi
fi

if [[ $staged_icon != "Yaru-gray" && $staged_icon != "Yaru-grey" && $desktop_icon != "Yaru-gray" && $desktop_icon != "Yaru-grey" ]]; then
  exit 0
fi

if command -v gsettings >/dev/null 2>&1 && [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  exit 1
fi

icon_dirs=()
if [[ -n ${OMARCHY_ICONS_DIR:-} ]]; then
  icon_dirs+=("$OMARCHY_ICONS_DIR")
fi
icon_dirs+=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/icons"
  "$HOME/.icons"
)
IFS=: read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for d in "${data_dirs[@]}"; do
  [[ -n $d ]] && icon_dirs+=("$d/icons")
done

icon_theme_exists() {
  local name="$1"
  [[ -n $name ]] || return 1
  local dir
  for dir in "${icon_dirs[@]}"; do
    [[ -f "$dir/$name/index.theme" ]] && return 0
  done
  return 1
}

resolve_installed_icon() {
  local preferred="$1"
  if icon_theme_exists "$preferred"; then
    printf '%s\n' "$preferred"
    return 0
  fi
  local cand
  local candidates
  if [[ $preferred == "Yaru" ]]; then
    candidates=(Yaru Yaru-dark hicolor)
  else
    candidates=(Yaru-dark Yaru hicolor)
  fi
  for cand in "${candidates[@]}"; do
    if icon_theme_exists "$cand"; then
      printf '%s\n' "$cand"
      return 0
    fi
  done
  return 1
}

theme_name=""
[[ -s $theme_name_path ]] && theme_name=$(<"$theme_name_path")

user_theme_dir="$HOME/.config/omarchy/themes/$theme_name"
system_theme_dir="${OMARCHY_PATH:-/usr/share/omarchy}/themes/$theme_name"

if [[ -n $theme_name && (-d $user_theme_dir || -d $system_theme_dir) ]]; then
  omarchy-theme-refresh || exit 1
  if command -v gsettings >/dev/null 2>&1; then
    current_raw=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null) || exit 1
    current_desktop=$(printf '%s' "$current_raw" | tr -d "'\"")
    if [[ $current_desktop == "Yaru-gray" || $current_desktop == "Yaru-grey" ]]; then
      new_staged=""
      [[ -f $staged ]] && new_staged=$(<"$staged")
      target_icon=""
      if [[ -n $new_staged && $new_staged != "Yaru-gray" && $new_staged != "Yaru-grey" ]] && icon_theme_exists "$new_staged"; then
        target_icon="$new_staged"
      else
        target_icon=$(resolve_installed_icon "Yaru-dark")
      fi
      [[ -z $target_icon ]] && exit 1
      gsettings set org.gnome.desktop.interface icon-theme "$target_icon" || exit 1
    fi
  fi
else
  target_icon=""
  if [[ -n $staged_icon && $staged_icon != "Yaru-gray" && $staged_icon != "Yaru-grey" ]] && icon_theme_exists "$staged_icon"; then
    target_icon="$staged_icon"
  else
    preferred_icon="Yaru-dark"
    if [[ $staged_icon == "Yaru-grey" || $desktop_icon == "Yaru-grey" || $theme_name == "white" ]]; then
      preferred_icon="Yaru"
    fi
    target_icon=$(resolve_installed_icon "$preferred_icon")
  fi
  [[ -z $target_icon ]] && exit 1

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$target_icon" || exit 1
  fi
  if [[ -f $staged && ($staged_icon == "Yaru-gray" || $staged_icon == "Yaru-grey") ]]; then
    printf '%s\n' "$target_icon" > "$staged"
  fi
fi

