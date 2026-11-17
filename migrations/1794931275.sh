echo "Add launchers for the agent harnesses already installed"

# Installing a harness now adds a launcher of its own beside Agent, as signing
# in to a subscription does. Harnesses installed before that get theirs here,
# leaving any launcher already in place alone.
for entry in "$OMARCHY_PATH"/default/applications/omarchy-agent-*.desktop; do
  name=${entry##*/}
  agent=${name#omarchy-agent-}
  agent=${agent%.desktop}
  [[ -f $HOME/.local/share/applications/$name ]] && continue
  if omarchy-default-agent --installed "$agent" 2>/dev/null; then
    omarchy-agent-launcher "$agent"
  fi
done

# Drawing the icon set links the launchers' new icons in right away, where they
# would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
