#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

helper="$ROOT/install/helpers/codex-config.sh"
migration="$ROOT/migrations/1790543192.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
mkdir -p "$home"
export HOME="$home"
export OMARCHY_PATH="$ROOT"
# shellcheck disable=SC1090
source "$helper"

omarchy_ensure_codex_auto_review_config

config="$home/.codex/config.toml"
[[ -f $config ]] || fail "helper creates ~/.codex/config.toml"
grep -qE '^approvals_reviewer[[:space:]]*=[[:space:]]*"auto_review"$' "$config" ||
  fail "helper seeds approvals_reviewer=auto_review"
grep -qE '^approval_policy[[:space:]]*=[[:space:]]*"on-request"$' "$config" ||
  fail "helper seeds approval_policy=on-request"
grep -qE '^sandbox_mode[[:space:]]*=[[:space:]]*"workspace-write"$' "$config" ||
  fail "helper seeds sandbox_mode=workspace-write"
pass "helper seeds Approve-for-me defaults into an empty Codex config"

# Second run must be a no-op: do not duplicate keys or rewrite user values.
before=$(cat "$config")
omarchy_ensure_codex_auto_review_config
[[ $(cat "$config") == "$before" ]] || fail "helper is idempotent on a complete config"
pass "helper is idempotent on a complete config"

# Existing root keys win; only missing Approve-for-me keys are prepended.
custom_home="$test_dir/custom"
mkdir -p "$custom_home/.codex"
export HOME="$custom_home"
cat >"$custom_home/.codex/config.toml" <<'EOF'
model = "gpt-5"
approvals_reviewer = "user"
EOF
omarchy_ensure_codex_auto_review_config
grep -qE '^approvals_reviewer[[:space:]]*=[[:space:]]*"user"$' "$custom_home/.codex/config.toml" ||
  fail "helper preserves an existing approvals_reviewer"
grep -qE '^approvals_reviewer[[:space:]]*=[[:space:]]*"auto_review"$' "$custom_home/.codex/config.toml" &&
  fail "helper must not add auto_review when approvals_reviewer is already set"
grep -qE '^approval_policy[[:space:]]*=[[:space:]]*"on-request"$' "$custom_home/.codex/config.toml" ||
  fail "helper fills a missing approval_policy"
grep -qE '^sandbox_mode[[:space:]]*=[[:space:]]*"workspace-write"$' "$custom_home/.codex/config.toml" ||
  fail "helper fills a missing sandbox_mode"
grep -qE '^model[[:space:]]*=[[:space:]]*"gpt-5"$' "$custom_home/.codex/config.toml" ||
  fail "helper preserves unrelated Codex config"
pass "helper preserves existing keys and fills only the missing ones"

# Defaults must stay at the root even when the config ends in a project table.
require_command python3
for scenario in table overrides nested multiline-basic multiline-literal; do
  table_home="$test_dir/$scenario"
  mkdir -p "$table_home/.codex"
  export HOME="$table_home"
  table_config="$table_home/.codex/config.toml"
  if [[ $scenario == "overrides" ]]; then
    cat >"$table_config" <<'EOF'
approvals_reviewer = "user"
approval_policy = "never"
EOF
  elif [[ $scenario == "multiline-basic" ]]; then
    cat >"$table_config" <<'EOF'
developer_instructions = """
[Review instructions]
approval_policy = "never"
Escaped delimiter: \"""
"""
approvals_reviewer = "user"
sandbox_mode = "read-only"
EOF
  elif [[ $scenario == "multiline-literal" ]]; then
    cat >"$table_config" <<'EOF'
developer_instructions = '''
[Review instructions]
approval_policy = "never"
'''
approvals_reviewer = "user"
sandbox_mode = "read-only"
EOF
  else
    printf 'model = "gpt-5"\n' >"$table_config"
  fi
  cat >>"$table_config" <<'EOF'

[projects."/home/alice/Work"]
trust_level = "trusted"
EOF
  if [[ $scenario == "nested" ]]; then
    cat >>"$table_config" <<'EOF'
approvals_reviewer = "user"
approval_policy = "never"
sandbox_mode = "read-only"
EOF
  fi
  cp "$table_config" "$test_dir/original.toml"
  omarchy_ensure_codex_auto_review_config
  python3 - "$table_config" "$test_dir/original.toml" <<'PY' || fail "helper preserves TOML scope"
import sys
import tomllib
from pathlib import Path

config_path, original_path = map(Path, sys.argv[1:])
config = tomllib.loads(config_path.read_text())
original = tomllib.loads(original_path.read_text())
defaults = {
  "approvals_reviewer": "auto_review",
  "approval_policy": "on-request",
  "sandbox_mode": "workspace-write",
}
assert config == defaults | original, config
assert config_path.read_bytes().endswith(original_path.read_bytes())
PY
  cp "$table_config" "$test_dir/seeded.toml"
  omarchy_ensure_codex_auto_review_config
  cmp -s "$table_config" "$test_dir/seeded.toml" || fail "helper is idempotent with a project table"
  pass "helper preserves root values and project scope: $scenario"
done

# Migration sources the helper the same way update does for existing installs.
migration_home="$test_dir/migration"
mkdir -p "$migration_home"
HOME="$migration_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
grep -qE '^approvals_reviewer[[:space:]]*=[[:space:]]*"auto_review"$' "$migration_home/.codex/config.toml" ||
  fail "migration seeds approvals_reviewer via the shared helper"
pass "migration seeds Codex auto-review config for existing installs"

# Launchers must not pass --approve-for-me (CLI overrides force embedded mode).
grep -Fq "alias cy='codex'" "$ROOT/default/bash/aliases" ||
  fail "cy alias launches plain codex"
grep -qE "alias cy=.*approve-for-me" "$ROOT/default/bash/aliases" &&
  fail "cy alias must not pass --approve-for-me"
grep -qE 'command=\(codex --approve-for-me\)' "$ROOT/bin/omarchy-agent" &&
  fail "omarchy-agent must not pass --approve-for-me"
pass "launchers avoid --approve-for-me so Codex can use the shared server"
