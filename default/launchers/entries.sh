# Shared XDG desktop-ID lookup for launcher entry management.
launcher_user_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
launcher_dirs=("$launcher_user_dir")
IFS=: read -ra launcher_data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for launcher_dir in "${launcher_data_dirs[@]}"; do
  [[ -n $launcher_dir ]] && launcher_dirs+=("$launcher_dir/applications")
done

launcher_find_entry() (
  local id=$1 skip_managed=${2:-false} dir file relative name
  [[ -n $id && $id != "." && $id != ".." && $id != */* && $id != *\\* && ! $id =~ [[:cntrl:]] ]] || return 1
  shopt -s globstar nullglob
  # The application library passes a bare ID. Prefer appending the suffix even
  # when that ID itself ends in .desktop (org.telegram.desktop, for example).
  for name in "$id.desktop" "$id"; do
    [[ $name == *.desktop ]] || continue
    for dir in "${launcher_dirs[@]}"; do
      for file in "$dir/$name" "$dir"/**/*.desktop; do
        [[ -f $file ]] || continue
        relative=${file#"$dir/"}
        [[ ${relative//\//-} == $name ]] || continue
        if [[ $skip_managed == true && $dir == $launcher_user_dir ]] && grep -Fxq 'X-Omarchy-Renamed=true' "$file"; then
          continue
        fi
        printf '%s\n' "$file"
        return 0
      done
    done
  done
  return 1
)
