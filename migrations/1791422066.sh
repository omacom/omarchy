echo "Make tmux copies reach the local clipboard over mosh"

tmux_config="$HOME/.config/tmux/tmux.conf"
override=',*:Ms=\E]52;%?%p1%l%{0}%=%tc%e%p1%s%;;%p2%s\007'
# A user who already overrides Ms, or turned it off with Ms@, keeps their choice
own_ms_override="^[[:space:]]*[^#[:space:]].*terminal-overrides(\[[0-9]+\])?[[:space:]]+['\"]?[^'\"[:space:]]*:Ms[=@]"

if [[ -f $tmux_config ]] && ! grep -Eq "$own_ms_override" "$tmux_config"; then
  if tmux show -s terminal-overrides >/dev/null 2>&1; then
    tmux set -as terminal-overrides "$override"
  fi

  printf "\n# tmux copies with an empty OSC 52 target, which mosh drops: fill in c, keep explicit targets\nset -as terminal-overrides '%s'\n" "$override" >>"$tmux_config"
fi
