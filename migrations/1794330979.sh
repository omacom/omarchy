echo "Replace Nautilus with Files as the file manager"

# Nautilus goes, with its extensions and its previewer. nautilus-dropbox
# depends on it, so it goes too. Only these: removing their dependencies as
# well (pacman -s) would take whatever arrived with them first, which on some
# installs is Papers and xdg-user-dirs, both Omarchy defaults.
nautilus_packages=()
for package_name in nautilus nautilus-python nautilus-dropbox sushi; do
  pacman -Qq "$package_name" &>/dev/null && nautilus_packages+=("$package_name")
done
if (( ${#nautilus_packages[@]} )); then
  # Both packages own org.freedesktop.FileManager1.service. Cache the incoming
  # package and its dependencies before removing the current file manager.
  if omarchy-pkg-missing folio; then
    sudo pacman -Sw --noconfirm -- folio
  fi
  sudo pacman -Rn --noconfirm "${nautilus_packages[@]}"
fi

omarchy-pkg-add folio

# The packaged mimeapps.list now names Files, but a personal one in ~/.config
# still wins, so point any Nautilus association there at Files too.
user_mimeapps="$HOME/.config/mimeapps.list"
if [[ -f $user_mimeapps ]] && grep -q "org.gnome.Nautilus.desktop" "$user_mimeapps"; then
  sed --follow-symlinks -i 's/org\.gnome\.Nautilus\.desktop/folio.desktop/g' "$user_mimeapps"
fi

# A dock that still pins Nautilus pins Files instead.
shell_json="$HOME/.config/omarchy/shell.json"
if [[ -f $shell_json ]] && grep -q '"org.gnome.Nautilus"' "$shell_json"; then
  sed --follow-symlinks -i 's/"org\.gnome\.Nautilus"/"folio"/' "$shell_json"
fi
