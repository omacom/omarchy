echo "Replace Nautilus with Files as the file manager"

# Nautilus goes, with its extensions and its previewer. nautilus-dropbox
# depends on it, so it goes too. Only these: removing their dependencies as
# well (pacman -s) would take whatever arrived with them first, which on some
# installs is Papers and xdg-user-dirs, both Omarchy defaults. pacman -Qq names
# the installed package, which is a replacement like nautilus-typeahead where
# one provides nautilus.
nautilus_packages=()
for package_name in nautilus nautilus-python nautilus-dropbox sushi; do
  installed=$(pacman -Qq "$package_name" 2>/dev/null) && nautilus_packages+=("$installed")
done

# Extensions installed on top, like nautilus-open-any-terminal and
# ghostty-nautilus, need these too, so they go with them. Anything else that
# needs Nautilus, like GNOME's xdg-desktop-portal-gnome, keeps it, and Files
# stays out: both own org.freedesktop.FileManager1.service.
removing=()
needed_by=""
if (( ${#nautilus_packages[@]} )); then
  removal=$(pacman -Rc --print --print-format %n "${nautilus_packages[@]}")
  mapfile -t removing <<<"$removal"
  needed_by=$(printf '%s\n' "${removing[@]}" | grep -v -e nautilus -e '^sushi$' || true)
fi

if [[ -n $needed_by ]]; then
  echo "Keeping Nautilus as the file manager: ${needed_by//$'\n'/, } still need it."
  echo "To switch to Files, remove those, then run: rm ~/.local/state/omarchy/migrations/1794330979.sh && omarchy-migrate"

  # The packaged mimeapps.list names Files, which can't be installed here, so
  # folders would open in whatever else claims them. Nautilus opens them,
  # unless a personal list already says what does: the desktop's own, the
  # one in ~/.config, or the older one in ~/.local/share.
  personal_lists=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/hyprland-mimeapps.list"
    "${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
    "${XDG_DATA_HOME:-$HOME/.local/share}/applications/mimeapps.list"
  )
  if ! grep -qs '^inode/directory=' "${personal_lists[@]}"; then
    xdg-mime default org.gnome.Nautilus.desktop inode/directory
  fi
else
  if (( ${#removing[@]} )); then
    # Cache the incoming package and its dependencies before removing the
    # current file manager. Remove exactly what was checked above, so a
    # package installed since then stops the removal instead of going with it.
    if omarchy-pkg-missing folio; then
      sudo pacman -Sw --noconfirm -- folio
    fi
    sudo pacman -Rn --noconfirm "${removing[@]}"
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
fi
