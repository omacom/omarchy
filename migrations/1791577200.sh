echo "Use atomic rotate for imv Ctrl+R"

imv_config="$HOME/.config/imv/config"
if [[ -f $imv_config ]]; then
  sed -i --follow-symlinks \
    -e 's|^<Ctrl+r> = exec mogrify -rotate 90 "$imv_current_file"$|<Ctrl+r> = exec omarchy-imv-rotate "$imv_current_file"|' \
    "$imv_config"
fi
