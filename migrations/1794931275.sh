echo "Add a launcher for the default agent harness"

# Installing a harness now adds a launcher of its own beside Agent, as signing
# in to a subscription does. The harness picked before that gets its own here.
agent=$(omarchy-default-agent)
if [[ -n $agent ]]; then
  omarchy-agent-launcher "$agent"
fi

# Drawing the icon set links the launchers' new icons in right away, where they
# would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
