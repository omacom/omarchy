echo "Show print jobs from imv in a notification"

# Only the line as Omarchy shipped it: a binding the user changed stays theirs.
imv_config="$HOME/.config/imv/config"
if [[ -f $imv_config ]]; then
  sed -i --follow-symlinks \
    's|^<Ctrl+p> = exec lp "$imv_current_file"$|<Ctrl+p> = exec omarchy-print "$imv_current_file"|' \
    "$imv_config"
fi
