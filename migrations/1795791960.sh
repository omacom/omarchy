echo "Remove agent launchers left for agents that are not installed"

# 1794931275 gave a launcher to every agent found on PATH. Coming from 4.5 it
# ran while Omarchy's lazy mise shims still put every declared agent there, and
# 1795441383 then installed only the agents in use. The rest kept a launcher
# that installs the agent with no prompt when clicked, so those go.
applications="$HOME/.local/share/applications"
removed=false

for launcher in "$applications"/omarchy-agent-*.desktop; do
  [[ -f $launcher ]] || continue
  agent=${launcher##*/omarchy-agent-}
  agent=${agent%.desktop}
  [[ -f $OMARCHY_PATH/default/applications/omarchy-agent-$agent.desktop ]] || continue
  omarchy-default-agent --installed "$agent" 2>/dev/null && continue
  rm -f "$launcher"
  removed=true
done

if $removed; then
  update-desktop-database "$applications" 2>/dev/null || true
fi
