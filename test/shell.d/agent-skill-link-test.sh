#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

link="$ROOT/bin/omarchy-agent-skill-link"
skill="$tmp_dir/skills/example"
mkdir -p "$skill"
printf -- '---\nname: example\n---\n' >"$skill/SKILL.md"

agent_dirs=(.agents/skills .claude/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills)

fresh_home() {
  rm -rf "$tmp_dir/home"
  mkdir -p "$tmp_dir/home"
  export HOME="$tmp_dir/home"
}

# Every agent directory gets the link, created where it is missing, and an
# existing Hermes profile is covered without a profile being invented.
fresh_home
mkdir -p "$HOME/.hermes/profiles/work"
"$link" "$skill"

for dir in "${agent_dirs[@]}" .hermes/profiles/work/skills; do
  [[ -L $HOME/$dir/example && $(realpath "$HOME/$dir/example") == "$(realpath "$skill")" ]] ||
    fail "skill link reaches every agent skills directory" "$dir"
done
pass "skill link reaches every agent skills directory"

[[ ! -e $HOME/.hermes/profiles/default ]] || fail "skill link does not invent Hermes profiles"
pass "skill link does not invent Hermes profiles"

# A real directory of the same name is the user's, not a place to drop a link.
fresh_home
mkdir -p "$HOME/.codex/skills/example"
touch "$HOME/.codex/skills/example/SKILL.md"
"$link" "$skill" 2>/dev/null

[[ ! -L $HOME/.codex/skills/example && ! -e $HOME/.codex/skills/example/example ]] ||
  fail "skill link leaves a user's directory of the same name alone"
[[ -L $HOME/.claude/skills/example ]] || fail "skill link still reaches the other agent directories"
pass "skill link leaves a user's directory of the same name alone"

# --remove takes back only links to this skill: one of the same name pointing
# somewhere else stays.
fresh_home
mkdir -p "$tmp_dir/theirs" "$HOME/.claude/skills"
ln -s "$tmp_dir/theirs" "$HOME/.claude/skills/example"
"$link" "$skill"
"$link" "$skill" --remove

for dir in .agents/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills; do
  [[ ! -e $HOME/$dir/example && ! -L $HOME/$dir/example ]] || fail "skill link --remove takes back the links it made" "$dir"
done
pass "skill link --remove takes back the links it made"

[[ -L $HOME/.claude/skills/example && $(readlink "$HOME/.claude/skills/example") == "$tmp_dir/theirs" ]] ||
  fail "skill link --remove keeps a foreign link of the same name"
pass "skill link --remove keeps a foreign link of the same name"

# A link made from another Omarchy tree is still this skill: installed while a
# dev checkout was linked, then removed or installed again from the package.
fresh_home
for tree in checkout package; do
  mkdir -p "$tmp_dir/$tree/default/agents/optional-skills/example"
  printf -- '---\nname: example\n---\n' >"$tmp_dir/$tree/default/agents/optional-skills/example/SKILL.md"
done
checkout_skill="$tmp_dir/checkout/default/agents/optional-skills/example"
package_skill="$tmp_dir/package/default/agents/optional-skills/example"

"$link" "$checkout_skill"
"$link" "$package_skill" 2>/dev/null
for dir in "${agent_dirs[@]}"; do
  [[ $(realpath "$HOME/$dir/example") == "$(realpath "$package_skill")" ]] ||
    fail "skill link repoints a link made from another Omarchy tree" "$dir"
done
pass "skill link repoints a link made from another Omarchy tree"

"$link" "$checkout_skill"
rm -rf "$tmp_dir/checkout"
mkdir -p "$tmp_dir/theirs/optional-skills/example"
ln -sfn "$tmp_dir/theirs/optional-skills/example" "$HOME/.claude/skills/example"
"$link" "$package_skill" --remove
for dir in .agents/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills; do
  [[ ! -e $HOME/$dir/example && ! -L $HOME/$dir/example ]] ||
    fail "skill link --remove takes back links made from another Omarchy tree" "$dir"
done
pass "skill link --remove takes back links made from another Omarchy tree"

[[ -L $HOME/.claude/skills/example ]] || fail "skill link --remove keeps a link to a same-named skill kept anywhere else"
pass "skill link --remove keeps a link to a same-named skill kept anywhere else"

# The tree's own path may hold a default/agents of its own.
fresh_home
nested_skill="$tmp_dir/default/agents/checkout/default/agents/optional-skills/example"
mkdir -p "$nested_skill"
cp "$package_skill/SKILL.md" "$nested_skill/"
"$link" "$package_skill"
"$link" "$nested_skill" --remove
[[ ! -L $HOME/.claude/skills/example ]] || fail "skill link finds the skill's place in a tree kept under another default/agents"
pass "skill link finds the skill's place in a tree kept under another default/agents"

# Removing what was never linked is not an error.
fresh_home
"$link" "$skill" --remove || fail "skill link --remove succeeds with nothing to remove"
pass "skill link --remove succeeds with nothing to remove"

# Linking needs a skill to point at.
fresh_home
if "$link" "$tmp_dir/nowhere" 2>/dev/null; then
  fail "skill link refuses a directory without a SKILL.md"
fi
pass "skill link refuses a directory without a SKILL.md"
