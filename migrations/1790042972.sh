echo "Install Elsewhen, the world clock plugin"

omarchy-pkg-add elsewhen

packaged_plugin="/usr/share/omarchy/shell/plugins/omacom.elsewhen"
user_plugin="$HOME/.config/omarchy/plugins/omacom.elsewhen"

# The package moved from plugins/ to shell/plugins/ once, stranding the link an
# earlier run made to the old path. A link the user made is left alone.
if [[ -L $user_plugin && ! -e $user_plugin && $(readlink "$user_plugin") == /usr/share/omarchy/* && -d $packaged_plugin ]]; then
  ln -sfn "$packaged_plugin" "$user_plugin"
fi

# Dev checkouts do not contain plugins installed by system packages.
if [[ ! $OMARCHY_PATH -ef /usr/share/omarchy && -d $packaged_plugin && ! -e $user_plugin && ! -L $user_plugin ]]; then
  mkdir -p "${user_plugin%/*}"
  ln -s "$packaged_plugin" "$user_plugin"
fi

# Best-effort, like the put below: an update whose shell cannot be asked still
# finishes, and restarts the shell once the migrations are through.
omarchy-shell -q shell rescanPlugins
omarchy-bar put omacom.elsewhen --before omarchy.clock
