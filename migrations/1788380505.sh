echo "Guard the SDDM login theme against a Qt5 greeter that cannot run it"

# Fresh Omarchy 4.x has no Qt5 packages. SDDM falls back to the Qt5 greeter
# (/usr/bin/sddm-greeter) for any theme whose metadata.desktop does not declare
# QtVersion=6. On a 4.x install that leaves the login screen permanently black.
# If the configured theme is not Qt6 and the Qt5 greeter cannot run, reset it
# to the packaged omarchy theme, which does declare QtVersion=6.

sddm_conf="${OMARCHY_SDDM_CONF:-/etc/sddm.conf}"
sddm_conf_dir="${OMARCHY_SDDM_CONF_DIR:-/etc/sddm.conf.d}"
theme_dir="${OMARCHY_SDDM_THEME_DIR:-/usr/share/sddm/themes}"
qt5_greeter="${OMARCHY_SDDM_QT5_GREETER:-/usr/bin/sddm-greeter}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# sddm.conf is loaded first, then sddm.conf.d/*.conf in lexicographic order.
# The last Current= wins.
configs=()
[[ -f $sddm_conf ]] && configs+=("$sddm_conf")
for conf in "$sddm_conf_dir"/*.conf; do
  [[ -f $conf ]] || continue
  configs+=("$conf")
done

active_theme=""
active_file=""
if (( ${#configs[@]} > 0 )); then
  for conf in "${configs[@]}"; do
    while IFS= read -r line; do
      [[ $line == Current=* ]] || continue
      active_theme=${line#Current=}
      active_file=$conf
    done < "$conf"
  done
fi

[[ -n $active_theme ]] || exit 0

metadata="$theme_dir/$active_theme/metadata.desktop"
if [[ -f $metadata ]]; then
  qt_version=$(awk -F= 'BEGIN{IGNORECASE=1} /^[[:space:]]*QtVersion[[:space:]]*=/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$metadata" 2>/dev/null | tail -1)
  [[ ${qt_version:-} == "6" ]] && exit 0
fi

# If the Qt5 greeter is present and its libraries are all satisfied, a
# non-Qt6 theme is still runnable, so leave the user's choice alone.
if [[ -x $qt5_greeter ]] && ! ldd "$qt5_greeter" 2>/dev/null | grep -q 'not found'; then
  exit 0
fi

# The configured theme is not Qt6 and the Qt5 fallback cannot run. Reset the
# active Current= line to omarchy so login does not stay black.
as_root sed -i.bak 's/^Current=.*/Current=omarchy/' "$active_file"
as_root rm -f "$active_file.bak"
echo "Reset SDDM theme from '$active_theme' to 'omarchy' because the Qt5 greeter cannot run it."
