echo "Keep Neovim as the editor on existing installs now that new ones start with Plain"

# New installs edit in Plain. An existing install keeps the editor it has
# until its owner picks another under Setup > Default > Editor. Without a saved
# choice it has been Neovim, so save that.
editor_file="$HOME/.local/state/omarchy/defaults/editor"
if [[ ! -s $editor_file ]]; then
  mkdir -p "$(dirname "$editor_file")"
  printf 'nvim\n' >"$editor_file"
fi

# The packaged mimeapps.list now opens text files in Plain. A personal list in
# ~/.config wins, so keep Neovim there for each type the user hasn't set.
user_mimeapps="$HOME/.config/mimeapps.list"
types=(
  text/plain text/english text/x-makefile text/x-c++hdr text/x-c++src text/x-chdr text/x-csrc text/x-java
  text/x-moc text/x-pascal text/x-tcl text/x-tex application/x-shellscript text/x-c text/x-c++
  application/xml text/xml
)

# Only [Default Applications] picks what opens a type; [Added Associations]
# just offers more choices. A choice saved in the older ~/.local/share list
# counts too, since a Neovim line in ~/.config would hide it.
chosen=""
for list in "$user_mimeapps" "$HOME/.local/share/applications/mimeapps.list"; do
  if [[ -f $list ]]; then
    chosen+=$(awk '/^\[/ { defaults = ($0 == "[Default Applications]") } defaults && /=/ { sub(/=.*/, ""); print }' "$list")$'\n'
  fi
done

missing=()
for type in "${types[@]}"; do
  grep -qxF "$type" <<<"$chosen" && continue
  missing+=("$type=nvim.desktop")
done
((${#missing[@]})) || exit 0

mkdir -p "$(dirname "$user_mimeapps")"
lines=$(printf '%s\n' "${missing[@]}")
if [[ -f $user_mimeapps ]] && grep -qxF "[Default Applications]" "$user_mimeapps"; then
  updated=$(awk -v lines="$lines" '{ print } $0 == "[Default Applications]" { print lines }' "$user_mimeapps")
else
  updated=$( ([[ -f $user_mimeapps ]] && cat "$user_mimeapps" && echo); printf '[Default Applications]\n%s' "$lines")
fi
# Written through, so a symlinked list (a dotfiles repo) stays a symlink.
printf '%s\n' "$updated" >"$user_mimeapps"
