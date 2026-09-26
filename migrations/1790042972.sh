echo "Install Elsewhen, the world clock plugin"

omarchy-pkg-add elsewhen
omarchy-shell -q shell rescanPlugins
omarchy-bar put omacom.elsewhen --before omarchy.clock
