echo "Point an already-installed Claude Code at the Omarchy theme"

# Only a machine that already chose Claude Code as its agent has it installed
# and a settings.json to update.
[[ -f "$HOME/.config/omarchy/defaults/agent" ]] || exit 0
read -r current_agent <"$HOME/.config/omarchy/defaults/agent"
[[ $current_agent == "claude" ]] || exit 0

omarchy-theme-set-claude --activate
