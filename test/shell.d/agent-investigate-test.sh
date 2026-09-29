#!/bin/bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/home"
AGENT_LOG="$TMPDIR/agent-log"

cat >"$TMPDIR/bin/omarchy-agent" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$AGENT_LOG"
SH
chmod +x "$TMPDIR/bin/omarchy-agent"

run_investigate() {
  AGENT_LOG="$AGENT_LOG" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-agent-investigate" "$@"
}

run_investigate

grep -Fxq -- "--prompt" "$AGENT_LOG" || \
  fail "problem investigation starts the default agent with a prompt"
grep -Fq -- "Use the diagnose-omarchy skill" "$AGENT_LOG" || \
  fail "problem investigation attaches the general diagnostic skill"
grep -Fq -- "Do not upload diagnostics" "$AGENT_LOG" || \
  fail "problem investigation keeps diagnostics local until reviewed"
pass "problem investigation starts a guarded diagnostic session"

: >"$AGENT_LOG"
run_investigate --inline
head -n 1 "$AGENT_LOG" | grep -Fxq -- "--inline" || \
  fail "problem investigation passes through the inline option"
pass "problem investigation supports inline agent sessions"

status=0
usage=$(AGENT_LOG="$AGENT_LOG" HOME="$TMPDIR/home" PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-agent-investigate" unexpected 2>&1) || status=$?
(( status == 1 )) || fail "unexpected arguments are rejected"
grep -Fq -- "Usage: omarchy agent investigate [--inline]" <<<"$usage" || \
  fail "unexpected arguments show the command usage"
pass "problem investigation rejects unexpected arguments"

[[ -f "$ROOT/default/agents/skills/diagnose-omarchy/SKILL.md" ]] || \
  fail "the general diagnostic skill is shipped with Omarchy"
pass "the general diagnostic skill is shipped"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = Object.fromEntries(items.map(item => [item.id, item]))
const skill = fs.readFileSync(path.join(root, 'default/agents/skills/diagnose-omarchy/SKILL.md'), 'utf8')

assertEqual(
  byId['trigger.investigate'].label,
  'Hunt Bugs',
  'menu exposes the problem investigation action'
)
assertEqual(
  byId['trigger.investigate'].description,
  'Investigate a bug or desktop problem with AI',
  'menu exposes searchable problem investigation text'
)
assertEqual(
  byId['trigger.investigate'].action,
  'omarchy-agent-investigate',
  'menu launches the problem investigation command'
)
assertEqual(
  skill.includes('name: diagnose-omarchy'),
  true,
  'the shipped skill has the expected name'
)
JS
