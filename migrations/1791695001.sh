echo "Put the Shelf on the bar"

# Best-effort, like the put below: an update whose shell cannot be asked still
# finishes, and restarts the shell once the migrations are through. The widget
# stays hidden until something floats or a window is set aside, and a bar that
# already carries it keeps it where the user put it.
omarchy-shell -q shell rescanPlugins
omarchy-bar put omarchy.shelf --section left --after omarchy.workspaces
