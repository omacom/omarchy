#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# No notification service, as in a provisioning chroot: the notice fails.
cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/omarchy-launch-config-editor" <<'SH'
#!/bin/bash
echo "edit $1" >>"$HOME/editor.log"
SH
chmod +x "$stub_bin"/*

new_home() {
  test_home="$test_tmp/home-$1"
  canonical="$test_home/.agents/AGENTS.md"
  mkdir -p "$test_home"
}

instructions() {
  HOME=$test_home PATH="$stub_bin:$ROOT/bin:$PATH" omarchy-agent-instructions "$@"
}

# A dotfiles link is the first rules found: it becomes the shared file and
# keeps pointing at the dotfiles copy, which every harness then reads.
new_home dotfiles
mkdir -p "$test_home/dotfiles" "$test_home/.claude" "$test_home/.codex"
echo "dotfiles rules" >"$test_home/dotfiles/CLAUDE.md"
ln -s "$test_home/dotfiles/CLAUDE.md" "$test_home/.claude/CLAUDE.md"
instructions >/dev/null
[[ $(readlink -f "$canonical") == "$test_home/dotfiles/CLAUDE.md" ]] ||
  fail "an existing instructions link becomes the shared file" "$(ls -l "$test_home/.agents")"
[[ $(<"$test_home/.claude/CLAUDE.md") == "dotfiles rules" && $(<"$test_home/.codex/AGENTS.md") == "dotfiles rules" ]] ||
  fail "every harness reads the rules behind an existing link"
pass "an existing instructions link becomes the shared file"

# Once there are shared rules, a link to different ones is moved aside like
# a file would be, still pointing at its rules, and a notice that can't be
# shown neither stops the run nor the editor from opening.
new_home differing
mkdir -p "$test_home/.agents" "$test_home/dotfiles" "$test_home/.codex"
echo "shared rules" >"$canonical"
echo "codex rules" >"$test_home/dotfiles/AGENTS.md"
ln -s "$test_home/dotfiles/AGENTS.md" "$test_home/.codex/AGENTS.md"
errors=$(instructions --edit 2>&1 >/dev/null) || fail "a failed notice doesn't stop the run" "$errors"
[[ $(readlink -f "$test_home/.codex/AGENTS.md.bak") == "$test_home/dotfiles/AGENTS.md" ]] ||
  fail "a differing instructions link is kept as .bak" "$(ls -la "$test_home/.codex")"
[[ $(<"$test_home/.codex/AGENTS.md") == "shared rules" ]] || fail "the harness reads the shared rules"
[[ $errors == *"$test_home/.codex/AGENTS.md.bak"* ]] || fail "the backup is printed when the notice fails" "$errors"
[[ $(<"$test_home/editor.log") == "edit $canonical" ]] || fail "the editor opens after a failed notice"
pass "a differing instructions link is kept as .bak, with a notice or without"

# A dangling link is someone's setup that hasn't arrived yet: leave it.
new_home dangling
mkdir -p "$test_home/.codex"
ln -s "$test_home/dotfiles/AGENTS.md" "$test_home/.codex/AGENTS.md"
instructions >/dev/null 2>&1
[[ $(readlink "$test_home/.codex/AGENTS.md") == "$test_home/dotfiles/AGENTS.md" ]] ||
  fail "a dangling instructions link is left alone"
pass "a dangling instructions link is left alone"

# An added Grok account's GROK_HOME doesn't move the link out of ~/.grok, and
# the account's own AGENTS.md links back to it.
new_home grok
account="$test_home/.local/state/omarchy/agents/accounts/grok/side"
mkdir -p "$test_home/.grok" "$account"
GROK_HOME=$account instructions grok >/dev/null
[[ $test_home/.grok/AGENTS.md -ef $canonical && ! -e $account/AGENTS.md ]] ||
  fail "Grok is linked in its primary home" "$(ls -la "$test_home/.grok" "$account")"
HOME=$test_home PATH="$ROOT/bin:$PATH" omarchy-agent-account-state link grok "$account" >/dev/null
[[ $account/AGENTS.md -ef $canonical ]] || fail "an added Grok account reads the shared rules" "$(ls -la "$account")"
pass "an added Grok account reads the shared rules"
