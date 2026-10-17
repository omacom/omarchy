#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
skill="$ROOT/default/agents/skills/diagnose-omarchy"
migration="$ROOT/migrations/1791838662.sh"
skill_dirs=(.agents/skills .claude/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills)

run_migration() {
  bash -euo pipefail "$migration" >/dev/null
}

run_migration
for dir in "${skill_dirs[@]}"; do
  [[ $(readlink "$HOME/$dir/diagnose-omarchy") == "$skill" ]] || fail "migration links $dir"
done
[[ ! -e $HOME/.hermes/profiles ]] || fail "migration does not create Hermes profiles"
pass "migration links the new skill for every provisioned agent without creating profiles"

mkdir -p "$HOME/.hermes/profiles/work/skills" "$HOME/.hermes/profiles/with spaces/skills"
ln -s /missing-old-checkout "$HOME/.hermes/profiles/work/skills/diagnose-omarchy"
ln -sfnT /missing-old-checkout "$HOME/.claude/skills/diagnose-omarchy"
run_migration
run_migration
for dir in "${skill_dirs[@]}" .hermes/profiles/work/skills '.hermes/profiles/with spaces/skills'; do
  [[ $(readlink "$HOME/$dir/diagnose-omarchy") == "$skill" ]] || fail "migration repairs and preserves links for $dir"
  [[ -f $HOME/$dir/diagnose-omarchy/SKILL.md ]] || fail "migrated skill is readable for $dir"
done
pass "migration is repeatable and repairs stale links including existing Hermes profiles"

rm "$HOME/.claude/skills/diagnose-omarchy" "$HOME/.codex/skills/diagnose-omarchy"
mkdir "$HOME/.claude/skills/diagnose-omarchy"
printf '%s\n' 'custom skill' >"$HOME/.claude/skills/diagnose-omarchy/SKILL.md"
printf '%s\n' 'custom file' >"$HOME/.codex/skills/diagnose-omarchy"
run_migration
[[ $(cat "$HOME/.claude/skills/diagnose-omarchy/SKILL.md") == "custom skill" ]] || fail "custom skill contents are preserved"
[[ $(cat "$HOME/.codex/skills/diagnose-omarchy") == "custom file" ]] || fail "custom file contents are preserved"
[[ ! -L $HOME/.claude/skills/diagnose-omarchy && ! -L $HOME/.codex/skills/diagnose-omarchy ]] || fail "custom skills are not replaced with symlinks"
[[ ! -e $skill/diagnose-omarchy ]] || fail "migration never nests a symlink in the shipped skill"
pass "migration preserves custom files and directories instead of nesting or replacing them"

[[ $(stat -c %a "$migration") == "644" ]] || fail "migration has non-executable permissions"
pass "migration follows the runner's file permission contract"
