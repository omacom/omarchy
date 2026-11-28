echo "Teach the agents about omarchy vm"

# Fresh installs get every skill linked by omarchy-provision-user, which only
# runs once, so existing installs need the new one linked here.

skill="$OMARCHY_PATH/default/agents/skills/omarchy-vm"

if [[ -d $skill ]]; then
  for skills_dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills ~/.gemini/config/skills ~/.hermes/skills; do
    mkdir -p "$skills_dir"
    ln -sfn "$skill" "$skills_dir/omarchy-vm"
  done

  # Hermes discovers skills through the active profile, so an existing profile
  # needs its own link the way omarchy-provision-user gives a fresh install one.
  if [[ -d ~/.hermes/profiles ]]; then
    for profile in ~/.hermes/profiles/*/; do
      [[ -d $profile ]] || continue
      mkdir -p "$profile/skills"
      ln -sfn "$skill" "$profile/skills/omarchy-vm"
    done
  fi
fi
