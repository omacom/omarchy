echo "Install Elsewhen, the world clock plugin"

omarchy-pkg-add elsewhen

plugin="$HOME/.config/omarchy/plugins/omacom.elsewhen"
mkdir -p "$(dirname "$plugin")"
if [[ ! -e $plugin && ! -L $plugin ]]; then
  ln -s /usr/share/omarchy/plugins/omacom.elsewhen "$plugin"
fi

omarchy-shell shell rescanPlugins
omarchy-bar put omacom.elsewhen --before omarchy.clock
