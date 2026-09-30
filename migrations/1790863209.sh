echo "Install Grok through mise's first-party package"

# The npm package launches whatever is already in ~/.grok/bin, and mise does not
# run its postinstall, so a newer package keeps running the old binary. mise's
# grok tool is the binary. Drop the npm tool or its shim stays ahead of the stub.

npm_grok="npm:@xai-official/grok"
wrapper="$HOME/.local/bin/grok"
npm_stub=false

# Anchored to the package the old installer wrote. A script the user wrote that
# calls mise use -g for something else is left alone.
if [[ -f $wrapper && ! -L $wrapper ]] && grep -Fq "$npm_grok" "$wrapper"; then
  npm_stub=true
fi

drop_npm_grok() {
  omarchy-cmd-present mise || return 0
  if [[ -n $(mise ls -g "$npm_grok") ]]; then
    mise unuse -g "$npm_grok"
  fi
  if [[ -n $(mise ls -i "$npm_grok") ]]; then
    mise uninstall -y --all "$npm_grok"
  fi
}

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  # The shim is ahead of ~/.local/bin, so drop the npm tool before looking for
  # grok. A removed wrapper still looks installed until the tool is gone.
  drop_npm_grok
  if [[ $npm_stub == true ]] || omarchy-cmd-missing grok; then
    omarchy-mise-install grok
  fi
elif [[ $npm_stub == true ]]; then
  # After an opt-out, only a wrapper Omarchy wrote proves the tool is ours.
  rm -f "$wrapper"
  drop_npm_grok
fi

# The x.ai installer links ~/.local/bin/agent at its copy under ~/.grok.
# realpath -m resolves a relative or dangling target without requiring it to exist.
if [[ -L $HOME/.local/bin/agent ]]; then
  agent_target=$(readlink "$HOME/.local/bin/agent" || true)
  agent_resolved=""
  if [[ $agent_target == /* ]]; then
    agent_resolved=$(realpath -m "$agent_target")
  elif [[ -n $agent_target ]]; then
    agent_resolved=$(realpath -m "$HOME/.local/bin/$agent_target")
  fi
  if [[ $agent_resolved == "$HOME/.grok" || $agent_resolved == "$HOME/.grok/"* ]]; then
    rm -f "$HOME/.local/bin/agent"
  fi
fi
