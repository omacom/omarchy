echo "Repair a Qt5 SDDM theme selection whose greeter libraries are missing"

sddm_conf="${OMARCHY_SDDM_CONF:-/etc/sddm.conf}"
sddm_conf_dir="${OMARCHY_SDDM_CONF_DIR:-/etc/sddm.conf.d}"
greeter="${OMARCHY_SDDM_GREETER:-/usr/bin/sddm-greeter}"

[[ -x $greeter ]] || exit 0
ldd_output=$(ldd "$greeter" 2>/dev/null) || exit 0
[[ $ldd_output == *"not found"* ]] || exit 0

export LC_ALL=C
config_files=()
for file in "$sddm_conf_dir"/*; do
  [[ -f $file ]] || continue
  config_files+=("$file")
done
if [[ -f $sddm_conf ]]; then
  config_files+=("$sddm_conf")
fi
(( ${#config_files[@]} > 0 )) || exit 0

effective=$(LC_ALL=C awk '
  function trim(value) {
    sub(/^[[:space:]]+/, "", value)
    sub(/[[:space:]]+$/, "", value)
    return value
  }
  FNR == 1 {
    section = 0
  }
  {
    line = $0
    sub(/[;#].*$/, "", line)
    if (line ~ /^[[:space:]]*\[Theme\][[:space:]]*$/) {
      section = 1
      next
    }
    if (line ~ /^[[:space:]]*\[/) {
      section = 0
    }
    if (section && line ~ /^[[:space:]]*Current[[:space:]]*=/) {
      assignments++
      value = line
      sub(/^[[:space:]]*Current[[:space:]]*=[[:space:]]*/, "", value)
      value = trim(value)
      effective_file = FILENAME
      effective_value = value
      effective_line = FNR
    }
  }
  END {
    if (effective_file != "") {
      printf "%s\t%s\t%d\n", effective_file, effective_value, effective_line
    }
  }
' "${config_files[@]}" 2>/dev/null) || exit 0
[[ -n $effective ]] || exit 0
IFS=$'\t' read -r target_file theme target_line <<<"$effective"

case $theme in
  elarun|maldives|maya) ;;
  *) exit 0 ;;
esac

sudo sed -i "${target_line}s|.*|Current=omarchy|" "$target_file"

echo "Changed SDDM theme from $theme to omarchy because the Qt5 greeter has missing libraries."
