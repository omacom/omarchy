#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1792072578.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

usage="$test_dir/state/omarchy/agents/usage"
mkdir -p "$usage"
for agent in litellm kiro freebuff claude kimi; do
  printf '{"id":"%s"}' "$agent" >"$usage/$agent.json"
done

run_migration() {
  HOME="$test_dir/home" XDG_STATE_HOME="$test_dir/state" bash -euo pipefail "$migration" >/dev/null
}

run_migration
[[ $(cd "$usage" && ls | tr '\n' ' ') == "claude.json kimi.json " ]] ||
  fail "the retired collectors' records go and every other record stays" "$(ls "$usage")"
pass "the retired collectors' records go and every other record stays"

run_migration
[[ $(cd "$usage" && ls | tr '\n' ' ') == "claude.json kimi.json " ]] ||
  fail "running the migration again changes nothing" "$(ls "$usage")"
pass "running the migration again changes nothing"

rm -rf "$test_dir/state"
run_migration || fail "a machine without usage records runs the migration cleanly"
pass "a machine without usage records runs the migration cleanly"
