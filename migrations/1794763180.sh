echo "Add launchers for the coding agents already signed in"

# Signing in to Claude, Codex or Grok from the agents panel now adds a launcher
# of its own (Claude Code, Codex, Grok Build) beside Agent. Agents signed in
# before that get theirs here.
for provider in claude codex grok; do
  entry="omarchy-agent-$provider.desktop"
  [[ -f $HOME/.local/share/applications/$entry ]] && continue
  if omarchy-agent-account-state list "$provider" 2>/dev/null | jq -e '.[0].accounts | any(.signedIn)' >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/share/applications"
    install -m 644 "$OMARCHY_PATH/default/applications/$entry" "$HOME/.local/share/applications/$entry"
  fi
done
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# Drawing the icon set links the launchers' new icons in right away, where they
# would otherwise wait for the next theme switch.
omarchy-theme-set-icons || true
