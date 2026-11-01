echo "Qualify shell palette references in installed plugins for Qt 6.12"

# #14553 qualified the shipped shell; clones and third-party plugins still say
# bare Color. omarchy plugin add and update repair plugins from here on.
plugins_dir="$HOME/.config/omarchy/plugins"
[[ -d $plugins_dir ]] || exit 0

omarchy-plugin-fix-palette "$plugins_dir"/*/
