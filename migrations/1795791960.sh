echo "Remove agent launchers left for agents that are not installed"

# 1794931275 gave a launcher to every agent found on PATH. Coming from 4.5 it
# ran while Omarchy's lazy mise shims still put every declared agent there, and
# 1795441383 then installed only the agents in use. The rest kept a launcher
# that installs the agent with no prompt when clicked, so those go.
applications="$HOME/.local/share/applications"
removed=false

# The upgrade from Omarchy 3 runs migrations without mise's shims on PATH, and
# an agent the user's own mise config installs is found only there.
PATH="$PATH:${MISE_SHIMS_DIR:-${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims}"

for launcher in "$applications"/omarchy-agent-*.desktop; do
  [[ -f $launcher && ! -L $launcher ]] || continue
  agent=${launcher##*/omarchy-agent-}
  agent=${agent%.desktop}
  # Only an unchanged copy of Omarchy's launcher goes. One the user edited, to
  # run the agent in a container say, is theirs.
  cmp -s "$launcher" "$OMARCHY_PATH/default/applications/omarchy-agent-$agent.desktop" || continue
  omarchy-default-agent --installed "$agent" 2>/dev/null && continue
  rm -f "$launcher"
  removed=true
done

if $removed; then
  update-desktop-database "$applications" 2>/dev/null || true
fi
