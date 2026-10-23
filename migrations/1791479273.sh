echo "Preserve Voxtype as the default for existing dictation users"

backend_config="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/defaults/dictation"
if [[ ! -e $backend_config && ! -L $backend_config ]] && omarchy-pkg-present voxtype-bin; then
  mkdir -p "${backend_config%/*}"
  temporary=$(mktemp "$backend_config.XXXXXX")
  printf '%s\n' voxtype > "$temporary"
  mv -f "$temporary" "$backend_config"
fi
