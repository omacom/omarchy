echo "Move each monitor's workspace blocks and scaling log into ~/.local/state/omarchy/monitors"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
mkdir -p "$state_dir/monitors"

# The blocks give every monitor back its own workspaces when it's plugged in.
# A config reload after the update may already have carried them over, reading
# the old file and writing the new one; then the old one only needs to go.
if [[ -f $state_dir/monitor-workspaces ]]; then
  if [[ -f $state_dir/monitors/workspaces ]]; then
    rm -f "$state_dir/monitor-workspaces"
  else
    mv "$state_dir/monitor-workspaces" "$state_dir/monitors/workspaces"
  fi
fi

# Where unplugged monitors' workspaces came from is forgotten every session, so
# the old file is simply dropped.
rm -f "$state_dir/monitor-workspaces-merged"

# The scaling log is history, kept ahead of any entries written since.
if [[ -f $state_dir/monitor-scaling.log ]]; then
  cat "$state_dir/monitor-scaling.log" "$state_dir/monitors/scaling" 2>/dev/null >"$state_dir/monitors/scaling.tmp" || true
  mv "$state_dir/monitors/scaling.tmp" "$state_dir/monitors/scaling"
  rm -f "$state_dir/monitor-scaling.log"
fi
