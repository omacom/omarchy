echo "Link the Hermes Desktop recovery skill for existing agents"

# The launcher fixes (5-value launch options, weak-NVIDIA software GPU) ship in
# the hermes-desktop package from omarchy-pkgs. omarchy-provision-user links
# skills only during first setup, so agents configured before this skill
# existed never see it. Link it into the same agent skill folders, only where
# they already exist, and never replace a skill the user has under this name.

skill_src="${OMARCHY_PATH:-/usr/share/omarchy}/default/agents/skills/hermes-desktop-recovery"
[[ -d $skill_src ]] || exit 0

link_skill() {
  local dir=$1
  [[ -d $dir ]] || return 0
  [[ -e $dir/hermes-desktop-recovery || -L $dir/hermes-desktop-recovery ]] && return 0
  ln -s "$skill_src" "$dir/hermes-desktop-recovery"
}

for dir in "$HOME"/.agents/skills "$HOME"/.claude/skills "$HOME"/.codex/skills \
  "$HOME"/.pi/agent/skills "$HOME"/.gemini/config/skills "$HOME"/.hermes/skills; do
  link_skill "$dir"
done
for profile in "$HOME"/.hermes/profiles/*/; do
  link_skill "${profile%/}/skills"
done
exit 0
