echo "Select screenshare regions relative to their monitor"

# The portal reads the region as relative to the named output, so the global
# %x,%y shifted every region on a monitor not at 0,0. Only the stock line changes.
config="$HOME/.config/hyprland-preview-share-picker/config.yaml"

if [[ -f $config ]]; then
  sed -i --follow-symlinks \
    "s/^  command: slurp -f '%o@%x,%y,%w,%h'\$/  command: slurp -f '%o@%X,%Y,%W,%H'/" \
    "$config"
fi
