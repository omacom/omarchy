echo "Move each monitor's workspace blocks and scaling log into ~/.local/state/omarchy/monitors"

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
mkdir -p "$state_dir/monitors"

# The blocks give every monitor back its own workspaces when it's plugged in,
# and the merged list sends an unplugged monitor's workspaces home when it
# returns, which an update in the middle of a session must not forget. A config
# reload after the update may already have carried either over, reading the old
# file and writing the new one; then the old one only needs to go.
for name in workspaces workspaces-merged; do
  if [[ -f $state_dir/monitor-$name ]]; then
    if [[ -f $state_dir/monitors/$name ]]; then
      rm -f "$state_dir/monitor-$name"
    else
      mv "$state_dir/monitor-$name" "$state_dir/monitors/$name"
    fi
  fi
done

# The scaling log is history, kept ahead of any entries written since.
if [[ -f $state_dir/monitor-scaling.log ]]; then
  cat "$state_dir/monitor-scaling.log" "$state_dir/monitors/scaling" 2>/dev/null >"$state_dir/monitors/scaling.tmp" || true
  mv "$state_dir/monitors/scaling.tmp" "$state_dir/monitors/scaling"
  rm -f "$state_dir/monitor-scaling.log"
fi
