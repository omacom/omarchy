echo "Put Elsewhen, the world clock, on the bar"

# Best-effort, like the put below: an update whose shell cannot be asked still
# finishes, and restarts the shell once the migrations are through.
omarchy-shell -q shell rescanPlugins
omarchy-bar put omarchy.elsewhen --before omarchy.clock
