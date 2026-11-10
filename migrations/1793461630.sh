echo "Move each monitor's workspace blocks and scaling log into ~/.local/state/omarchy/monitors"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
mkdir -p "$state_dir/monitors"

# The blocks give every monitor back its own workspaces when it's plugged in,
# and the merged list sends an unplugged monitor's workspaces home when it
# returns, which an update in the middle of a session must not forget. The old
# files win: anything a config reload wrote under monitors/ before this ran
# started from nothing.
for name in workspaces workspaces-merged; do
  if [[ -f $state_dir/monitor-$name ]]; then
    mv -f "$state_dir/monitor-$name" "$state_dir/monitors/$name"
  fi
done

# The scaling log is history, kept ahead of any entries written since. A copy
# that fails stops the migration before anything is replaced or deleted.
if [[ -f $state_dir/monitor-scaling.log ]]; then
  if [[ -f $state_dir/monitors/scaling ]]; then
    cat "$state_dir/monitor-scaling.log" "$state_dir/monitors/scaling" >"$state_dir/monitors/scaling.tmp"
    mv "$state_dir/monitors/scaling.tmp" "$state_dir/monitors/scaling"
    rm -f "$state_dir/monitor-scaling.log"
  else
    mv "$state_dir/monitor-scaling.log" "$state_dir/monitors/scaling"
  fi
fi
