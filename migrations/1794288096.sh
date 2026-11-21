echo "Restore web app icons the Omarchy 4 upgrade moved out from under their launchers"

# The upgrade to Omarchy 4 moved legacy icons such as ChatGPT.png and
# GitHub.png into a backup folder while their launchers stayed behind, so those
# apps showed no icon. Put back each icon a launcher still names.
apps_dir="$HOME/.local/share/applications"
icons_dir="$apps_dir/icons"

shopt -s nullglob
for desktop in "$apps_dir"/*.desktop; do
  icon=$(sed -n "s|^Icon=$icons_dir/||p" "$desktop" | head -n 1)
  [[ -n $icon && ! -e $icons_dir/$icon ]] || continue

  for backup in "$apps_dir"/icons.omarchy-upgrade-to-quattro.*.bak/"$icon"; do
    mkdir -p "$icons_dir"
    cp -p "$backup" "$icons_dir/$icon"
    break
  done
done
