#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

busy="$ROOT/bin/omarchy-agent-busy"
tmpdir=$(mktemp -d)
trap 'chmod -R u+rwx "$tmpdir" 2>/dev/null; rm -rf "$tmpdir"' EXIT

fresh_home() {
  home="$tmpdir/home-$1"
  mkdir -p "$home"
}

scan() {
  env -u CLAUDE_CONFIG_DIR -u CODEX_HOME -u GROK_HOME -u PI_CODING_AGENT_DIR -u XDG_DATA_HOME -u HERMES_HOME -u COPILOT_HOME \
    HOME="$home" "$@" "$busy" ${WITHIN:+--within "$WITHIN"}
}

write() {
  mkdir -p "$(dirname "$1")"
  touch -d "${2:-now}" "$1"
}

fresh_home empty
status=0
output=$(scan) || status=$?
[[ -z $output ]] && (( status == 1 )) || fail "a home with no agents is quiet" "status=$status output=$output"
pass "a home with no agents is quiet"

# Every store the scan knows, each written just now, names its agent.
fresh_home all
write "$home/.claude/projects/-home-me-work/session.jsonl"
write "$home/.codex/sessions/2026/10/10/rollout.jsonl"
write "$home/.grok/sessions/work/abc/usage.json"
write "$home/.pi/agent/sessions/work/session.jsonl"
write "$home/.omp/profiles/work/agent/sessions/session.jsonl"
write "$home/.local/share/opencode/opencode.db-wal"
write "$home/.hermes/state.db-wal"
write "$home/.openclaw/agents/main/sessions/session.jsonl"
write "$home/.copilot/session-state/abc/events.jsonl"
write "$home/.gemini/antigravity-cli/conversations/abc.pb"
mapfile -t names < <(scan)
expected=("Claude Code" "Codex" "Grok" "Pi" "Oh My Pi" "OpenCode" "Hermes" "OpenClaw" "GitHub Copilot" "Antigravity")
[[ ${names[*]} == "${expected[*]}" ]] || fail "each agent's session store names it" "got: ${names[*]}"
pass "each agent's session store names it"

fresh_home old
write "$home/.claude/projects/p/session.jsonl" "-20 minutes"
write "$home/.codex/sessions/2026/10/10/rollout.jsonl" "-16 minutes"
status=0
output=$(scan) || status=$?
[[ -z $output ]] && (( status == 1 )) || fail "writes older than the window are quiet" "status=$status output=$output"
WITHIN=30 scan >/dev/null || fail "a wider window sees them"
pass "only writes inside the window count"

# Configuration and auth writes are not work.
fresh_home config
write "$home/.claude/settings.json"
write "$home/.local/share/opencode/auth.json"
write "$home/.copilot/config.json"
status=0
scan >/dev/null || status=$?
(( status == 1 )) || fail "settings and auth writes are not agent activity" "status=$status"
pass "settings and auth writes are not agent activity"

fresh_home overrides
write "$tmpdir/claude-elsewhere/projects/p/session.jsonl"
write "$tmpdir/codex-elsewhere/sessions/rollout.jsonl"
mapfile -t names < <(scan CLAUDE_CONFIG_DIR="$tmpdir/claude-elsewhere" CODEX_HOME="$tmpdir/codex-elsewhere")
[[ ${names[*]} == "Claude Code Codex" ]] || fail "config home overrides are honored" "got: ${names[*]}"
pass "config home overrides are honored"

# An Omarchy account home links its projects to the primary's.
fresh_home account
write "$tmpdir/primary/projects/p/session.jsonl"
mkdir -p "$tmpdir/account"
ln -s "$tmpdir/primary/projects" "$tmpdir/account/projects"
[[ $(scan CLAUDE_CONFIG_DIR="$tmpdir/account") == "Claude Code" ]] || fail "a symlinked projects root is followed"
pass "a symlinked projects root is followed"

fresh_home unreadable
mkdir -p "$home/.claude/projects/p"
chmod 000 "$home/.claude/projects"
status=0
scan >/dev/null || status=$?
(( status == 3 )) || fail "a store that cannot be read is not reported quiet" "status=$status"
write "$home/.codex/sessions/rollout.jsonl"
status=0
scan >/dev/null || status=$?
(( status == 0 )) || fail "activity elsewhere still counts beside an unreadable store" "status=$status"
chmod 755 "$home/.claude/projects"
pass "a store that cannot be read is unknown, not quiet"

# Hidden behind a directory that cannot be searched is not the same as absent.
fresh_home ancestor
mkdir -p "$home/.claude/projects/p"
chmod 000 "$home/.claude"
status=0
scan >/dev/null || status=$?
chmod 755 "$home/.claude"
(( status == 3 )) || fail "a store behind an unsearchable directory is unknown, not quiet" "status=$status"
pass "a store behind an unsearchable directory is unknown, not quiet"

# Globbed stores disappear when their directory cannot be listed.
fresh_home unlistable
mkdir -p "$home/.openclaw/agents/main/sessions"
chmod 000 "$home/.openclaw/agents"
status=0
scan >/dev/null || status=$?
chmod 755 "$home/.openclaw/agents"
(( status == 3 )) || fail "an unlistable directory of globbed stores is unknown, not quiet" "status=$status"
pass "an unlistable directory of globbed stores is unknown, not quiet"

fresh_home link
mkdir -p "$tmpdir/locked-primary/projects" "$tmpdir/linked-account"
ln -s "$tmpdir/locked-primary/projects" "$tmpdir/linked-account/projects"
chmod 000 "$tmpdir/locked-primary"
status=0
scan CLAUDE_CONFIG_DIR="$tmpdir/linked-account" >/dev/null || status=$?
chmod 755 "$tmpdir/locked-primary"
(( status == 3 )) || fail "a projects link that cannot be followed is unknown, not quiet" "status=$status"
pass "a projects link that cannot be followed is unknown, not quiet"

fresh_home relative
status=0
(cd "$home" && timeout 5 env HOME="$home" CODEX_HOME=missing "$busy" >/dev/null) || status=$?
(( status == 1 )) || fail "a relative home that does not exist is quiet, not a hang" "status=$status"
pass "a relative home that does not exist is quiet, not a hang"

for bad in "--within 0" "--within x" "--bogus"; do
  # shellcheck disable=SC2086
  if HOME="$tmpdir" "$busy" $bad >/dev/null 2>&1; then fail "'$bad' is refused"; fi
done
pass "bad arguments are refused"
