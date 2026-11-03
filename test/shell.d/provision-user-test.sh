#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"

for command in xdg-user-dirs-update xdg-settings xdg-mime; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "${0##*/}" "$*" >>"$TEST_COMMAND_LOG"\n' >"$mock_bin/$command"
done
# Antigravity and Hermes count as installed: skills are only linked into the
# folders of agents that are, and a plain script on PATH is an install.
for command in agy hermes; do
  printf '#!/bin/bash\n' >"$mock_bin/$command"
done
export TEST_COMMAND_LOG=$test_tmp/commands.log
chmod +x "$mock_bin"/*

# Provisioning prepends $OMARCHY_PATH/bin, which shadows a mock for anything
# Omarchy ships, so the install suite is stubbed out at its path instead. The
# real one rethemes the session it runs in: hyprctl reload against the live
# compositor, gsettings against the live desktop, and a global Node install.
mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes"

for skill in omarchy diagnose-crash; do
  link="$test_tmp/home/.gemini/config/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Antigravity"

  link="$test_tmp/home/.hermes/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Hermes"

  link="$test_tmp/home/.hermes/profiles/james/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for a Hermes profile"
done

pass "omarchy-provision-user provisions Antigravity and Hermes skills"

for dir in DOWNLOAD:Downloads PICTURES:Pictures VIDEOS:Videos DOCUMENTS:Documents MUSIC:Music; do
  grep -qxF "xdg-user-dirs-update --set ${dir%%:*} $test_tmp/home/${dir#*:}" "$TEST_COMMAND_LOG" ||
    fail "provisioning names the ${dir%%:*} folder in English" "$(cat "$TEST_COMMAND_LOG")"
done
for dir in Downloads Pictures Videos Documents Music; do
  [[ -d $test_tmp/home/$dir ]] || fail "provisioning creates the $dir folder it names"
done
pass "provisioning names the user folders in English before a first login in another language"

: >"$TEST_COMMAND_LOG"
mkdir -p "$test_tmp/home/.config"
printf 'XDG_DOWNLOAD_DIR="$HOME/下载"\n' >"$test_tmp/home/.config/user-dirs.dirs"
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" --force >/dev/null ||
  fail "omarchy-provision-user finishes again"
! grep -q -- '--set DOWNLOAD ' "$TEST_COMMAND_LOG" || fail "provisioning keeps a folder the user already named"
grep -q -- '--set PICTURES ' "$TEST_COMMAND_LOG" || fail "provisioning still names the folders the user has not"
pass "provisioning keeps a folder the user already named, in any language"

# Provisioning links the skills through omarchy-agent-skills-link, which also
# runs after updates and agent installs. Its own rules, on a home of its own:
# Claude Code, Hermes and Codex are installed (a plain script on PATH is how
# an install of the user's own looks), nothing else is, and the mise shims of
# the machine running the test stay off PATH.
link_home="$test_tmp/link-home"
link_bin="$test_tmp/link-bin"
mkdir -p "$link_home" "$link_bin"
for command in claude hermes codex; do
  printf '#!/bin/bash\n' >"$link_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$link_bin/mise"
chmod +x "$link_bin"/*

link() {
  HOME="$link_home" PATH="$link_bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-agent-skills-link" "$@"
}

links_to_shipped() {
  [[ -L $1 && $(readlink "$1") == "$ROOT/default/agents/skills/${1##*/}" ]]
}

skills=()
for skill in "$ROOT"/default/agents/skills/*/; do
  skill=${skill%/}
  skills+=("${skill##*/}")
done
(( ${#skills[@]} > 0 )) || fail "the checkout ships at least one skill"

# What an earlier Omarchy left behind: links in every folder it used to write,
# a user's own skill under a shipped name, and a link that is not Omarchy's.
mkdir -p "$link_home/.codex/skills/.system" "$link_home/.pi/agent/skills" "$link_home/.hermes/profiles/james" "$link_home/.claude/skills/omarchy"
printf 'mine\n' >"$link_home/.claude/skills/omarchy/SKILL.md"
ln -s "/usr/share/omarchy/default/agents/skills/omarchy" "$link_home/.codex/skills/omarchy"
ln -s "/usr/share/omarchy/default/agents/skills/omarchy" "$link_home/.pi/agent/skills/omarchy"
ln -s "$test_tmp/elsewhere" "$link_home/.codex/skills/theirs"

link || fail "omarchy-agent-skills-link finishes"

for skill in "${skills[@]}"; do
  links_to_shipped "$link_home/.agents/skills/$skill" || fail "every shipped skill is linked into ~/.agents/skills ($skill)"
  links_to_shipped "$link_home/.hermes/skills/$skill" || fail "Hermes gets its own links ($skill)"
  links_to_shipped "$link_home/.hermes/profiles/james/skills/$skill" || fail "an existing Hermes profile gets links ($skill)"
done
pass "shipped skills are linked into ~/.agents/skills and into the folders of agents that do not read it"

[[ -d $link_home/.claude/skills/omarchy && ! -L $link_home/.claude/skills/omarchy && $(<"$link_home/.claude/skills/omarchy/SKILL.md") == "mine" ]] ||
  fail "a user's own skill under a shipped name is left alone"
for skill in "${skills[@]}"; do
  [[ $skill == "omarchy" ]] && continue
  links_to_shipped "$link_home/.claude/skills/$skill" || fail "Claude Code still gets the other skills ($skill)"
done
pass "a user's own skill under a shipped name is kept and the rest are linked beside it"

[[ ! -e $link_home/.codex/skills/omarchy ]] || fail "an old Omarchy link is removed from an agent that reads ~/.agents/skills"
[[ -L $link_home/.codex/skills/theirs ]] || fail "a link that is not Omarchy's is kept"
[[ -d $link_home/.codex/skills/.system ]] || fail "a folder with other content stays"
[[ ! -e $link_home/.pi/agent/skills ]] || fail "a folder Omarchy emptied is removed"
pass "links from earlier Omarchy versions are removed only where they are no longer wanted"

[[ ! -e $link_home/.gemini && ! -e $link_home/.kiro && ! -e $link_home/.config/opencode ]] ||
  fail "an agent that is not installed gets no folder"
pass "agents that are not installed get no folders"

before=$(cd "$link_home" && find . -printf '%p %y %l\n' | sort)
link || fail "omarchy-agent-skills-link finishes a second time"
after=$(cd "$link_home" && find . -printf '%p %y %l\n' | sort)
[[ $before == "$after" ]] || fail "a second run changes nothing" "$(diff <(echo "$before") <(echo "$after") || true)"
pass "a second run of the skill links changes nothing"

# The selected default agent is linked even before mise reports it installed.
mkdir -p "$link_home/.config/omarchy/defaults"
printf 'agy\n' >"$link_home/.config/omarchy/defaults/agent"
link agy || fail "omarchy-agent-skills-link finishes for one agent"
for skill in "${skills[@]}"; do
  links_to_shipped "$link_home/.gemini/config/skills/$skill" || fail "the default agent gets its own links ($skill)"
done
[[ ! -e $link_home/.kiro ]] || fail "naming one agent leaves the others untouched"
pass "the selected default agent gets its own links, and naming an agent touches only that agent"

# A home moved by its variable is the one that gets the links.
rm -rf "$link_home/.claude"
CLAUDE_CONFIG_DIR="$test_tmp/claude-elsewhere" link claude || fail "omarchy-agent-skills-link honours CLAUDE_CONFIG_DIR"
for skill in "${skills[@]}"; do
  links_to_shipped "$test_tmp/claude-elsewhere/skills/$skill" || fail "a moved home gets the links ($skill)"
done
[[ ! -e $link_home/.claude ]] || fail "the default home is left alone when the variable moves it"
pass "a home moved by its environment variable gets the links instead of the default one"

# Some people make an agent's folder a link to ~/.agents/skills by hand. The
# cleanup of a shared-folder agent must not reach the shared links through it,
# and the link itself stays.
link_home="$test_tmp/link-home-2"
mkdir -p "$link_home/.codex" "$link_home/.agents/skills"
ln -s "$link_home/.agents/skills" "$link_home/.codex/skills"
link || fail "omarchy-agent-skills-link finishes with a folder that links to ~/.agents/skills"
for skill in "${skills[@]}"; do
  links_to_shipped "$link_home/.agents/skills/$skill" || fail "the shared links survive a folder that links to them ($skill)"
done
[[ -L $link_home/.codex/skills && $(readlink "$link_home/.codex/skills") == "$link_home/.agents/skills" ]] ||
  fail "the user's folder link is kept"
pass "a folder that links to ~/.agents/skills keeps the shared links and the link itself"
