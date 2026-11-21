#!/bin/bash

set -euo pipefail

# Exercises migrations/1791324018.sh: links the recovery skill for existing
# agents without replacing user skills, writes no launcher, and leaves
# machines without hermes-desktop alone. Launcher fixes live in omarchy-pkgs.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791324018.sh"
[[ -f $migration ]] || fail "Hermes desktop launcher recovery migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery"
printf '# recovery skill\n' >"$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery/SKILL.md"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH
chmod +x "$mock_bin/omarchy-pkg-present"

run_migration() {
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-1}" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_tmp/home" \
    OMARCHY_PATH="$test_tmp/omarchy" \
    bash -euo pipefail "$migration" >/dev/null
}

skill_src="$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery"
home="$test_tmp/home"
agent_dirs=(.agents/skills .claude/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills .hermes/profiles/work/skills)

# Skill linking does not depend on Hermes Desktop being installed.
for d in "${agent_dirs[@]}"; do mkdir -p "$home/$d"; done
OMARCHY_TEST_DESKTOP_INSTALLED=0 run_migration || fail "migration exits clean without Hermes Desktop"
for d in "${agent_dirs[@]}"; do
  [[ -L $home/$d/hermes-desktop-recovery && $(readlink "$home/$d/hermes-desktop-recovery") == "$skill_src" ]] ||
    fail "skill linked into ~/$d"
done
[[ ! -e $home/.config/omarchy/bin/hermes-desktop ]] || fail "migration writes no user launcher"
run_migration || fail "migration is idempotent"
pass "migration links the recovery skill into every existing agent skill folder"

rm -rf "$home"; mkdir -p "$home/.claude/skills"
run_migration || fail "migration exits clean with few agent folders"
[[ ! -e $home/.codex && ! -e $home/.hermes && ! -e $home/.agents ]] || fail "missing agent folders are not created"
[[ -L $home/.claude/skills/hermes-desktop-recovery ]] || fail "existing agent folder gets the skill"
pass "migration only links where an agent skill folder exists"

ln -sfn /somewhere/custom "$home/.claude/skills/hermes-desktop-recovery"
mkdir -p "$home/.codex/skills/hermes-desktop-recovery"
echo mine >"$home/.codex/skills/hermes-desktop-recovery/SKILL.md"
run_migration || fail "migration exits clean with user skills present"
[[ $(readlink "$home/.claude/skills/hermes-desktop-recovery") == /somewhere/custom ]] || fail "custom skill link is preserved"
[[ ! -L $home/.codex/skills/hermes-desktop-recovery && $(cat "$home/.codex/skills/hermes-desktop-recovery/SKILL.md") == mine ]] ||
  fail "user's own skill directory is preserved"
pass "migration never replaces a user's existing skill"

! grep -q 'config/omarchy/bin' "$ROOT/bin/omarchy-install-ai-hermes" ||
  fail "omarchy-install-ai-hermes does not depend on ~/.config/omarchy/bin"
pass "install-ai-hermes launches the packaged launcher"

skill_dir="$ROOT/default/agents/skills/hermes-desktop-recovery"
for ref in fast-fix.md desktop-recovery-checklist.md; do
  [[ -f $skill_dir/references/$ref ]] || fail "skill reference $ref exists"
done
pass "hermes-desktop-recovery skill ships all referenced docs"
