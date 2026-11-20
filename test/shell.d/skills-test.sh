#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Missing optional software must be reported without installing anything.
status=0
PATH="$stub_bin:$ROOT/bin" "$ROOT/bin/omarchy-skills" search task >"$test_tmp/missing.log" 2>&1 || status=$?
[[ $status == 127 && $(<"$test_tmp/missing.log") == *"optional and is not installed"* ]] || fail "missing catalog is explicit" "$(cat "$test_tmp/missing.log")"
pass "missing catalog is explicit"

# The adapter must forward literal arguments and the real CLI's exit status.
cat >"$stub_bin/everything-skills" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$ARGS_LOG"
exit 47
SH
chmod +x "$stub_bin/everything-skills"
status=0
ARGS_LOG="$test_tmp/args" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-skills" search 'task with spaces' '--json' '$(not-a-command)' >/dev/null 2>&1 || status=$?
mapfile -d '' -t forwarded <"$test_tmp/args"
[[ $status == 47 && ${#forwarded[@]} == 4 && ${forwarded[1]} == "task with spaces" && ${forwarded[3]} == '$(not-a-command)' ]] || fail "arguments and exit status are preserved"
pass "arguments and exit status are preserved"

if (( EUID == 0 )); then
  skip "user skill linking requires a non-root user"
  exit 0
fi

test_home="$test_tmp/home"
mkdir -p "$test_home/.claude/skills/everything-skills" "$test_home/.hermes/profiles/work" "$test_home/custom"
echo "user content" >"$test_home/.claude/skills/everything-skills/keep"
ln -s "$test_home/custom" "$test_home/.pi"
mkdir -p "$test_home/custom/agent/skills"
echo "existing target" >"$test_home/custom/keep"
HOME=$test_home "$ROOT/bin/omarchy-setup-skills" >"$test_tmp/setup.log" 2>&1
skill="$ROOT/default/agents/skills/everything-skills"
[[ $test_home/.agents/skills/everything-skills -ef $skill && $test_home/.codex/skills/everything-skills -ef $skill ]] || fail "generic and Codex clients share the packaged guide"
[[ $test_home/.hermes/profiles/work/skills/everything-skills -ef $skill ]] || fail "existing Hermes profiles receive the guide"
[[ $(<"$test_home/.claude/skills/everything-skills/keep") == "user content" && $(<"$test_home/custom/keep") == "existing target" ]] || fail "user content survives setup"
HOME=$test_home "$ROOT/bin/omarchy-setup-skills" >"$test_tmp/setup-again.log" 2>&1
[[ $test_home/.agents/skills/everything-skills -ef $skill && $(<"$test_home/.claude/skills/everything-skills/keep") == "user content" ]] || fail "setup is idempotent"
pass "shared guide, profile linking, user content and repeated setup are preserved"
