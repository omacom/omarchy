echo "Keep tmux clipboard copies working over mosh"

tmux_config="$HOME/.config/tmux/tmux.conf"

# Mosh gives tmux TERM=xterm or xterm-256color, so only an Ms override whose pattern matches one of those is the user's choice for mosh.
custom_ms_override() {
  local line entry pattern entries

  # Without -r, read joins a line continued with a trailing backslash, as tmux does.
  while IFS= read line || [[ -n $line ]]; do
    [[ $line =~ ^[[:space:]]*set(-option)?([[:space:]].*)?[[:space:]]terminal-overrides ]] || continue
    line=${line#*terminal-overrides}
    line=${line#\[*\]}
    line=${line%%[[:space:]]#*}
    line=${line#"${line%%[![:space:]]*}"}
    # tmux keeps a space after a comma as part of the next pattern, so entries are not trimmed.
    IFS=, read -ra entries <<<"${line//[\"\']/}"

    for entry in "${entries[@]}"; do
      pattern=${entry%%:*}
      if [[ :${entry#*:}: =~ :Ms[=@] ]] && [[ xterm == $pattern || xterm-256color == $pattern ]]; then
        return 0
      fi
    done
  done <"$tmux_config"

  return 1
}

if [[ -f $tmux_config ]]; then
  mosh_override='set -ag terminal-overrides ",xterm*:Ms=\\E]52;%?%p1%l%t%p1%s%ec%;;%p2%s\\007"'
  if ! grep -qFx "$mosh_override" "$tmux_config"; then
    if custom_ms_override; then
      echo "Keeping your custom tmux Ms override; check its OSC 52 clipboard selector when using mosh."
      exit 0
    fi
    printf '\n%s\n%s\n' \
      '# Make OSC 52 clipboard writes compatible with mosh 1.4.' \
      "$mosh_override" >>"$tmux_config"

    if omarchy-cmd-present tmux && tmux list-sessions >/dev/null 2>&1; then
      # Add only the override: re-sourcing the config would append every -a option in it a second time.
      if ! tmux set -ag terminal-overrides ',xterm*:Ms=\E]52;%?%p1%l%t%p1%s%ec%;;%p2%s\007'; then
        echo "Could not update the running tmux server; restart tmux to pick up the clipboard fix." >&2
      fi
      echo "Reattach existing tmux clients to refresh their clipboard capabilities."
    fi
  fi
fi
