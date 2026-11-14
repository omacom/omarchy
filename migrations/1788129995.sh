echo "Replace Satty and Tensaku with Omasnap"

omarchy-pkg-add omasnap

# The old source installer left a NoDisplay entry that overrides the packaged launcher.
rm -f "$HOME/.local/share/applications/omasnap.desktop"

imv_config="$HOME/.config/imv/config"
if [[ -f $imv_config ]]; then
  sed -i --follow-symlinks \
    -e 's/^# Edit the current image in Tensaku and quit the viewer$/# Edit the current image in Omasnap and quit the viewer/' \
    -e 's/^# Edit the current image in Satty and quit the viewer$/# Edit the current image in Omasnap and quit the viewer/' \
    -e 's|^<Ctrl+e> = exec tensaku-edit "$imv_current_file" & ; quit$|<Ctrl+e> = exec omasnap "$imv_current_file" \& ; quit|' \
    -e 's|^<Ctrl+e> = exec satty --filename "$imv_current_file" & ; quit$|<Ctrl+e> = exec omasnap "$imv_current_file" \& ; quit|' \
    "$imv_config"
fi

omarchy-pkg-drop satty tensaku
