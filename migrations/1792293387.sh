echo "Clear the tmux status line under prompts on tmux 3.8"

tmux_config="$HOME/.config/tmux/tmux.conf"

if [[ -f $tmux_config ]] && grep -qxE 'set -g message(-command)?-style "bg=default,fg=blue"' "$tmux_config"; then
  sed -i --follow-symlinks -E 's/^(set -g message(-command)?-style "bg=default,fg=blue)"$/\1,fill=terminal"/' "$tmux_config"
  omarchy-restart-tmux
fi
