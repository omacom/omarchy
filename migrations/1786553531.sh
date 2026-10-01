echo "Keep tmux clipboard copies working over mosh"

tmux_config="$HOME/.config/tmux/tmux.conf"

if [[ -f $tmux_config ]]; then
  mosh_override='set -ag terminal-overrides ",xterm*:Ms=\\E]52;c%p1%.0s;%p2%s\\007"'
  if ! grep -qFx "$mosh_override" "$tmux_config"; then
    if grep -Eq "^[[:space:]]*set(-option)?[[:space:]].*terminal-overrides.*[,\"'[:space:]](\\*|xterm[^,:\"']*)(:[^,:\"']*)*:Ms[=@]" "$tmux_config"; then
      echo "Keeping your custom tmux Ms override; check its OSC 52 clipboard selector when using mosh."
      exit 0
    fi
    printf '\n%s\n' \
      '# Make OSC 52 clipboard writes compatible with mosh 1.4.' \
      "$mosh_override" >>"$tmux_config"
  fi

  if omarchy-cmd-present tmux && tmux list-sessions >/dev/null 2>&1; then
    if ! tmux source-file "$tmux_config"; then
      echo "Could not reload tmux; fix the config error and run tmux source-file $tmux_config." >&2
    fi
    echo "Reattach existing tmux clients to refresh their clipboard capabilities."
  fi
fi
