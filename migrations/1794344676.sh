echo "Share the global AGENTS.md with added Grok accounts"

# An added Grok account links its shared files back to ~/.grok when it
# becomes active, so one that already is gets the newly shared AGENTS.md here.
omarchy-agent-account-state homes grok | while IFS=$'\t' read -r _ home _; do
  if [[ $home != "$HOME/.grok" && -d $home ]]; then
    omarchy-agent-account-state link grok "$home"
  fi
done
