echo "Seed OpenCode AGENTS.md and omarchy skills path for existing users"

OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
setup="$OMARCHY_PATH/bin/omarchy-setup-opencode"
agent_file="$HOME/.config/omarchy/defaults/agent"
opencode_dir="$HOME/.config/opencode"

[[ -f $setup ]] || exit 0

# Only touch users who already selected OpenCode or have an OpenCode config dir.
if [[ -d $opencode_dir ]]; then
  :
elif [[ -f $agent_file ]] && [[ $(<"$agent_file") == opencode ]]; then
  :
else
  exit 0
fi

bash "$setup"
