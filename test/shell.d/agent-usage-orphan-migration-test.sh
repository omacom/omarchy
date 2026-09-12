#!/bin/bash

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1788919234.sh"
[[ -f $migration ]] || fail "migration 1788919234 is present"

home=$(mktemp -d)
omarchy=$(mktemp -d)
trap 'rm -rf "$home" "$omarchy"' EXIT

mkdir -p "$omarchy/bin"
mkdir -p "$home/.config/omarchy/plugins"

cat >"$omarchy/bin/omarchy-agent-usage-claude" <<'EOF'
#!/bin/bash
echo '{"id":"claude"}'
EOF
chmod +x "$omarchy/bin/omarchy-agent-usage-claude"

mkdir -p "$home/.config/omarchy/plugins/grok/scripts"
cat >"$home/.config/omarchy/plugins/grok/scripts/omarchy-agent-usage-grok" <<'EOF'
#!/bin/bash
echo '{"id":"grok"}'
EOF

# A wrapper that runs the orchestrator is not a collector named "update".
mkdir -p "$home/.config/omarchy/plugins/wrap/scripts"
cat >"$home/.config/omarchy/plugins/wrap/scripts/omarchy-agent-usage-update" <<'EOF'
#!/bin/bash
exec omarchy-agent-usage-update "$@"
EOF

usage="$home/.local/state/omarchy/agents/usage"
mkdir -p "$usage"

# Record contents never matter to the migration, only names and ages do.
for name in copilot update; do
  echo '{}' >"$usage/$name.json"
  touch -d "30 days ago" "$usage/$name.json"
done
for name in claude grok; do
  echo '{}' >"$usage/$name.json"
  touch -d "30 days ago" "$usage/$name.json"
done
echo '{}' >"$usage/fresh.json"

message=$(env HOME="$home" XDG_STATE_HOME="" XDG_CONFIG_HOME="$home/.config" \
  OMARCHY_PATH="$omarchy" bash -euo pipefail "$migration" 2>&1) ||
  fail "orphan record migration runs clean" "$message"

[[ ! -e $usage/copilot.json ]] ||
  fail "orphan record migration drops the record of an agent that is gone"
pass "orphan record migration drops the record of an agent that is gone"

[[ ! -e $usage/update.json ]] ||
  fail "orphan record migration does not count a wrapper for the orchestrator"
pass "orphan record migration does not count a wrapper for the orchestrator"

[[ -e $usage/claude.json && -e $usage/grok.json ]] ||
  fail "orphan record migration keeps records of installed collectors"
pass "orphan record migration keeps records of installed collectors"

[[ -e $usage/fresh.json ]] ||
  fail "orphan record migration keeps a record written within the last week"
pass "orphan record migration keeps a record written within the last week"

[[ $message == *"copilot"* ]] ||
  fail "orphan record migration reports what it removes" "$message"
pass "orphan record migration reports what it removes"

first=$(find "$home" -type f | sort)
env HOME="$home" XDG_STATE_HOME="" XDG_CONFIG_HOME="$home/.config" \
  OMARCHY_PATH="$omarchy" bash -euo pipefail "$migration" >/dev/null 2>&1 ||
  fail "orphan record migration runs again with nothing left to do"
second=$(find "$home" -type f | sort)
[[ $first == "$second" ]] ||
  fail "orphan record migration is idempotent"
pass "orphan record migration is idempotent"
