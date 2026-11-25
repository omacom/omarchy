echo "Install coding agents and CLI tools as packages instead of mise tools"

# The settings package drops every mise declaration. Until it has, stay
# pending: the declarations would only install the tools through mise again.
if [[ -n $(omarchy-mise-default-tools list) ]]; then
  echo "Waiting for the omarchy-settings package that drops the default mise tools" >&2
  exit 75
fi

# Wrappers older releases wrote in ~/.local/bin run `mise use -g`, and would
# count as the user's own install of the agent. Only an exact copy goes.
omarchy-mise-install npm:@moonshot-ai/kimi-code kimi
omarchy-mise-install cursor-agent
omarchy-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse

# A copy mise installed for Omarchy's declaration goes. One a mise config of
# the user's own asks for is theirs and stays.
from_omarchy() {
  mise ls "$1" --json 2>/dev/null | jq -e 'length > 0 and all(.[]; .source == null)' >/dev/null
}
installed_version() {
  mise ls "$1" --json | jq -r 'map(.version) | last'
}

# Everyone gets these. gh comes with Setup > Git, ghui, Hunk, Basecamp, HEY and
# Cloudflare from Install > CLI, and each coding agent from Install > AI > CLI,
# so one of them becomes its package only if it was in use. The lists are read
# first and installed in one go, with the terminal still on stdin for sudo.
packages=(nodejs playwright-cli uv)
retired=(playwright uv)
while read -r tool package; do
  if from_omarchy "$tool"; then
    packages+=("$package")
    retired+=("$tool")
  fi
done <<'EOF'
gh github-cli
ghui ghui
hunk hunk
basecamp basecamp-cli
hey-cli hey-cli
npm:cf cloudflare-cli
EOF
while read -r tool agent; do
  if from_omarchy "$tool"; then
    packages+=("$(omarchy-install-ai-cli --package "$agent")")
    retired+=("$tool")
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

omarchy-pkg-add "${packages[@]}" || exit 1
for tool in "${retired[@]}"; do
  if from_omarchy "$tool"; then
    mise uninstall --all "$tool"
  fi
done

# Node is a runtime projects build on, so one in use stays, at the version it
# was, in the user's own config, as Install > Development > Node.js sets it up.
if from_omarchy node; then
  MISE_OFFLINE=1 mise use -g --quiet "node@$(installed_version node)"
fi

# Command Code's and Kiro CLI's terms don't allow Omarchy to ship them, so they
# are no longer Omarchy's agents. A copy in use moves to the user's own mise
# config at the version it was, and a launcher or default pointing at one goes.
while read -r tool agent spec name <&3; do
  if from_omarchy "$tool"; then
    MISE_OFFLINE=1 mise use -g --quiet "$spec@$(installed_version "$tool")" 3<&-
    echo "$name is no longer one of Omarchy's agents; it stays installed through your own mise config"
  fi
  rm -f "$HOME/.local/share/applications/omarchy-agent-$agent.desktop"
  if [[ -f $HOME/.config/omarchy/defaults/agent ]] && grep -qx "$agent" "$HOME/.config/omarchy/defaults/agent"; then
    rm -f "$HOME/.config/omarchy/defaults/agent"
  fi
done 3<<'EOF'
npm:command-code commandcode npm:command-code Command Code
http:kiro-cli kiro-cli http:kiro-cli[platforms_linux_x64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-x86_64-linux.tar.gz,platforms_linux_arm64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-aarch64-linux.tar.gz,version_list_url=https://prod.download.cli.kiro.dev/stable/latest/manifest.json,version_json_path=.version] Kiro CLI
EOF

# Account switching for claude, codex and grok is Omarchy's own dispatchers
# now, not mise's command wrappers, so the wrappers mise built for it go.
wrappers="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/command-wrappers/bin"
for command in claude codex grok; do
  if [[ -L $wrappers/$command && $(readlink -f "$wrappers/$command") == "$(readlink -f "$(command -v mise)")" ]]; then
    rm -f "$wrappers/$command"
  fi
done
rmdir "$wrappers" "${wrappers%/bin}" 2>/dev/null || true

# SSH commands that run no shell take PATH from PAM, so the dispatchers lead
# Omarchy's line there too. Only the exact line Omarchy wrote is changed.
pam_env=/etc/security/pam_env.conf
old_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
new_path='PATH DEFAULT=@{HOME}/.local/share/omarchy/agent-accounts/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
if grep -qxF "$old_path" "$pam_env"; then
  sudo sed -i "s|^${old_path//./\\.}\$|${new_path}|" "$pam_env"
fi

# The shims of what mise no longer has go first, so only a CLI really there
# gets an account dispatcher.
mise reshim
omarchy-agent-account-dispatch
