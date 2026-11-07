echo "Install herdr's session-restore integration for Hermes"

# Hermes comes from its app rather than mise, so mise's postinstall hook never integrated it.
if omarchy-pkg-present hermes-desktop; then
  omarchy-agent-integrate-herdr hermes
fi
