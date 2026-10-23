echo "Install Grok through mise's first-party package"

# The npm package launches whatever is already in ~/.grok/bin, and mise does not
# run its postinstall, so a newer package keeps running the old binary. mise's
# grok tool is the binary. Drop the npm tool or its shim stays ahead of the stub.

npm_grok="npm:@xai-official/grok"
wrapper="$HOME/.local/bin/grok"
npm_stub=false

# Only remove a wrapper Omarchy actually wrote. A user script may also name the
# npm package, and removing that tool would break it.
generated_npm_stub() {
  [[ -f $wrapper && ! -L $wrapper ]] || return 1
  (( $(stat -c%s "$wrapper") <= 1024 )) || return 1

  local current legacy
  current=$(printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "grok" "$@"\n' "$npm_grok" "$npm_grok")
  cmp -s -- "$wrapper" <(printf '%s\n' "$current") && return 0
  legacy=${current/ --quiet/}
  cmp -s -- "$wrapper" <(printf '%s\n' "$legacy") && return 0
  legacy=${legacy/$'export MISE_MINIMUM_RELEASE_AGE=0\n'/}
  cmp -s -- "$wrapper" <(printf '%s\n' "$legacy") && return 0
  legacy=${legacy/ || exit 1/}
  legacy=${legacy/exec mise x/exec mise exec}
  cmp -s -- "$wrapper" <(printf '%s\n' "$legacy") && return 0
  legacy=$(printf '#!/bin/bash\nmise use -g "%s"\nexec "grok" "$@"' "$npm_grok")
  cmp -s -- "$wrapper" <(printf '%s\n' "$legacy")
}

if generated_npm_stub; then
  npm_stub=true
fi

drop_npm_grok() {
  omarchy-cmd-present mise || return 0
  if [[ -n $(mise ls -g "$npm_grok") ]]; then
    mise unuse -y -g "$npm_grok"
  fi
  if [[ -n $(mise ls -i "$npm_grok") ]]; then
    mise uninstall -y --all "$npm_grok"
  fi
}

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  if [[ $npm_stub == true ]]; then
    backup=$(mktemp "$HOME/.local/bin/.grok-wrapper.XXXXXX")
    mv -fT "$wrapper" "$backup"
    if omarchy-mise-install grok; then
      rm -f "$backup"
    else
      if [[ -e $wrapper || -L $wrapper ]]; then
        echo "Grok install failed; previous launcher saved at $backup" >&2
      else
        mv -T "$backup" "$wrapper"
      fi
      exit 1
    fi
    drop_npm_grok
  elif [[ ! -f $wrapper ]] || ! grep -Fq "$npm_grok" "$wrapper"; then
    # The shim is ahead of ~/.local/bin, so remove it before checking PATH.
    drop_npm_grok
    if omarchy-cmd-missing grok; then
      omarchy-mise-install grok
    fi
  fi
elif [[ $npm_stub == true ]]; then
  # After an opt-out, only a wrapper Omarchy wrote proves the tool is ours.
  drop_npm_grok
  rm -f "$wrapper"
fi

# The npm launcher unpacked its binary into ~/.grok/bin, where x.ai's installer
# also puts its copy and a PATH entry ahead of mise. With Omarchy's wrapper
# gone, nothing of ours runs from there, and a copy left behind would keep
# shadowing the mise tool.
if [[ $npm_stub == true ]]; then
  rm -f "$HOME/.grok/bin/grok" "$HOME"/.grok/bin/grok-[0-9]*
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
