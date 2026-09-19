echo "Install Elsewhen, the world clock plugin"

# elsewhen Depends: omarchy. On WSL/dev checkouts there is no omarchy pacman
# package (/usr/share/omarchy is a symlink into the checkout). Installing
# elsewhen then resolves the whole desktop package set and conflicts with that
# symlink (https://github.com/omacom/omarchy/issues/12531).
if ! pacman -Q omarchy &>/dev/null; then
  echo "Skipping Elsewhen on unpackaged Omarchy (e.g. WSL checkout)"
  exit 0
fi

omarchy-pkg-add elsewhen

plugin="$HOME/.config/omarchy/plugins/omacom.elsewhen"
mkdir -p "$(dirname "$plugin")"
if [[ ! -e $plugin && ! -L $plugin ]]; then
  ln -s /usr/share/omarchy/plugins/omacom.elsewhen "$plugin"
fi

omarchy-shell shell rescanPlugins
omarchy-bar put omacom.elsewhen --before omarchy.clock
