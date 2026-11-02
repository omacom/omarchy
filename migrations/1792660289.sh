echo "Use output-relative coordinates for screenshare region selection"

config="$HOME/.config/hyprland-preview-share-picker/config.yaml"

[[ -f $config ]] || exit 0

sed -i "s|^  command: slurp -f '%o@%x,%y,%w,%h'$|  command: slurp -f '%o@%X,%Y,%W,%H'|" "$config"
