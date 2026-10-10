echo "Close the image viewer with Escape"

imv_config="$HOME/.config/imv/config"
if [[ -f $imv_config ]] && ! grep -q '^<Escape>' "$imv_config"; then
  printf '\n# Close the viewer with Escape\n<Escape> = quit\n' >>"$imv_config"
fi
