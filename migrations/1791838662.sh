echo "Link the Omarchy problem investigation skill for existing users"

skill="$OMARCHY_PATH/default/agents/skills/diagnose-omarchy"

link_skill() {
  local skills_dir="$1"
  mkdir -p "$skills_dir"
  # Leave a user's own skill directory or file alone. Replace stale symlinks
  # without following them into the old target.
  if [[ ! -e $skills_dir/diagnose-omarchy || -L $skills_dir/diagnose-omarchy ]]; then
    ln -sfnT "$skill" "$skills_dir/diagnose-omarchy"
  fi
}

for skills_dir in ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills ~/.gemini/config/skills ~/.hermes/skills; do
  link_skill "$skills_dir"
done

for profile in ~/.hermes/profiles/*/; do
  [[ -d $profile ]] || continue
  link_skill "$profile/skills"
done
