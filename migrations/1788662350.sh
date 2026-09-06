echo "Add picture printing from Files and imv"

omarchy-pkg-add python-cairo

mkdir -p "$HOME/.local/share/nautilus-python/extensions"
cp "$OMARCHY_PATH/default/nautilus-python/extensions/print_picture.py" "$HOME/.local/share/nautilus-python/extensions/"

# Replace only the shipped binding, preserving custom shortcuts and other settings.
imv_config="$HOME/.config/imv/config"
if [[ -f $imv_config ]] && grep -Fxq '<Ctrl+p> = exec lp "$imv_current_file"' "$imv_config"; then
  cp -p "$imv_config" "$imv_config.bak.$(date +%s)"
  sed -i 's|^<Ctrl+p> = exec lp "$imv_current_file"$|<Ctrl+p> = exec nohup omarchy-launch-image-print "$imv_current_file" </dev/null >/dev/null 2>\&1 \&|' "$imv_config"
fi

echo "Reopen Files and image viewer windows to use the new print action."
