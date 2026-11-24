echo "Install coding agents and CLI tools as packages instead of mise tools"

# The settings package drops every mise declaration. Until it has, stay
# pending: the declarations would only install the tools through mise again.
if omarchy-mise-default-tools list | grep -q .; then
  echo "Waiting for the omarchy-settings package that drops the default mise tools" >&2
  exit 75
fi

omarchy-pkg-add ghui github-cli hunk nodejs uv || exit 1

# A copy mise installed for Omarchy's declaration goes. One a mise config of
# the user's own asks for is theirs and stays.
from_omarchy() {
  mise ls "$1" --json 2>/dev/null | jq -e 'length > 0 and all(.[]; .source == null)' >/dev/null
}

for tool in gh ghui hunk playwright uv; do
  if from_omarchy "$tool"; then
    mise uninstall --all "$tool"
  fi
done

# Basecamp, HEY and Cloudflare are installed from Install > CLI now. One that
# was in use becomes its package.
while read -r tool package; do
  if from_omarchy "$tool"; then
    omarchy-pkg-add "$package" || exit 1
    mise uninstall --all "$tool"
  fi
done <<'EOF'
basecamp basecamp-cli
hey-cli hey-cli
npm:cf cloudflare-cli
EOF

# Node is a runtime projects build on, so one in use stays, at the version it
# was, in the user's own config, as Install > Development > Node.js sets it up.
if from_omarchy node; then
  version=$(mise ls node --json | jq -r 'map(.version) | last')
  mise use -g --quiet "node@$version"
fi

# Each coding agent mise installed becomes its package, so an agent in use
# keeps working. One never run stays uninstalled until it's picked.
while read -r tool agent; do
  if from_omarchy "$tool"; then
    omarchy-install-ai-cli "$agent" || exit 1
    mise uninstall --all "$tool"
  fi
done <<'EOF'
amp amp
antigravity-cli agy
claude claude
codex codex
copilot copilot
crush crush
cursor-agent cursor-agent
grok grok
http:devin devin
muse muse
npm:@deepseek-ai/dsh dsh
npm:@kilocode/cli kilo
npm:@minimax-ai/code mcode
npm:@moonshot-ai/kimi-code kimi
npm:freebuff freebuff
oh-my-pi omp
opencode opencode
ori ori
qwen qwen
EOF

# Wrappers older releases wrote in ~/.local/bin run `mise use -g`, and would
# count as the user's own install of the agent. Only an exact copy goes.
wrapper() {
  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$2" "$2" "$1"
}
while read -r command package; do
  file=$HOME/.local/bin/$command
  if [[ -f $file && ! -L $file ]] && cmp -s "$file" <(wrapper "$command" "$package"); then
    rm -f "$file"
  fi
done <<'EOF'
kimi npm:@moonshot-ai/kimi-code
cursor-agent cursor-agent
muse http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]
EOF

# Command Code's and Kiro CLI's terms don't allow Omarchy to ship them, so they
# are no longer Omarchy's agents. A copy in use moves to the user's own mise
# config, and a launcher or default pointing at one goes.
while read -r tool agent spec name; do
  if from_omarchy "$tool"; then
    mise use -g --quiet "$spec"
    echo "$name is no longer one of Omarchy's agents; it stays installed through your own mise config"
  fi
  rm -f "$HOME/.local/share/applications/omarchy-agent-$agent.desktop"
  if [[ -f $HOME/.config/omarchy/defaults/agent ]] && grep -qx "$agent" "$HOME/.config/omarchy/defaults/agent"; then
    rm -f "$HOME/.config/omarchy/defaults/agent"
  fi
done <<'EOF'
npm:command-code commandcode npm:command-code@latest Command Code
http:kiro-cli kiro-cli http:kiro-cli[platforms_linux_x64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-x86_64-linux.tar.gz,platforms_linux_arm64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-aarch64-linux.tar.gz,version_list_url=https://prod.download.cli.kiro.dev/stable/latest/manifest.json,version_json_path=.version]@latest Kiro CLI
EOF

mise reshim
