echo "Seed the Herdr profile for the Omarchy qconsole agent"

# Only seed. A user who already has this profile keeps their customization.
[[ -f "$HOME/.config/herdr/qconsole.toml" ]] ||
  omarchy-refresh-config herdr/qconsole.toml
