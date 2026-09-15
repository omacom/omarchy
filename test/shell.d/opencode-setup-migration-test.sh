#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command jq

migration="$ROOT/migrations/1789444034.sh"
setup="$ROOT/bin/omarchy-setup-opencode"
[[ -f $migration ]] || fail "OpenCode setup migration exists"
[[ -f $setup ]] || fail "omarchy-setup-opencode exists"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
home="$test_dir/home"

run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null ||
    fail "migration exits clean"
}

run_setup() {
  HOME="$home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$setup" >/dev/null ||
    fail "setup exits clean"
}

# ------------------------------------------------------------------ no opencode yet → no-op

rm -rf "$home"
mkdir -p "$home"
run_migration
[[ ! -e $home/.config/opencode ]] || fail "migration no-ops when OpenCode is unused"
pass "migration no-ops when OpenCode is unused"

# ------------------------------------------------------------------ default agent selected → seeds config

rm -rf "$home"
mkdir -p "$home/.config/omarchy/defaults"
printf 'opencode\n' >"$home/.config/omarchy/defaults/agent"
run_migration
[[ -f $home/.config/opencode/AGENTS.md ]] || fail "migration copies AGENTS.md for default-agent users"
[[ -f $home/.config/opencode/opencode.json ]] || fail "migration copies opencode.json for default-agent users"
grep -Fq "$ROOT/default/agents/skills" "$home/.config/opencode/opencode.json" ||
  fail "migration adds OMARCHY_PATH skills path"
pass "migration seeds OpenCode config when default agent is opencode"

# ------------------------------------------------------------------ existing config dir → merge skills, preserve custom AGENTS.md

rm -rf "$home"
mkdir -p "$home/.config/opencode"
printf '# custom agents\n' >"$home/.config/opencode/AGENTS.md"
printf '%s\n' '{"$schema":"https://opencode.ai/config.json","autoupdate":false}' >"$home/.config/opencode/opencode.json"
run_migration
grep -qx '# custom agents' "$home/.config/opencode/AGENTS.md" || fail "migration preserves customized AGENTS.md"
grep -Fq "$ROOT/default/agents/skills" "$home/.config/opencode/opencode.json" ||
  fail "migration merges skills path into existing opencode.json"
run_migration
count=$(grep -cF "$ROOT/default/agents/skills" "$home/.config/opencode/opencode.json")
(( count == 1 )) || fail "migration is idempotent on skills path" "count=$count"
pass "migration merges skills and preserves customized AGENTS.md"

# ------------------------------------------------------------------ setup alone respects OMARCHY_PATH

rm -rf "$home"
mkdir -p "$home"
run_setup
grep -Fq "$ROOT/default/agents/skills" "$home/.config/opencode/opencode.json" ||
  fail "setup writes OMARCHY_PATH skills path for a fresh home"
pass "setup seeds a fresh OpenCode home with OMARCHY_PATH skills"

# ------------------------------------------------------------------ missing setup binary → no-op

rm -rf "$home"
mkdir -p "$home/.config/opencode" "$test_dir/empty-omarchy/bin"
printf '%s\n' '{}' >"$home/.config/opencode/opencode.json"
HOME="$home" OMARCHY_PATH="$test_dir/empty-omarchy" bash -euo pipefail "$migration" >/dev/null ||
  fail "migration exits clean when setup is missing"
grep -qx '{}' "$home/.config/opencode/opencode.json" || fail "migration leaves config alone when setup is missing"
pass "migration no-ops when omarchy-setup-opencode is missing"
