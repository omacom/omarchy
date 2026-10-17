#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"

setup_claude() {
  local home="$1"
  rm -rf "$home"
  mkdir -p "$home/.local/state/omarchy/current/theme" "$home/.claude"
  echo '{"dummy": "theme"}' >"$home/.local/state/omarchy/current/theme/claude.json"
}

setup_pi() {
  local home="$1"
  rm -rf "$home"
  mkdir -p "$home/.local/state/omarchy/current/theme" "$home/.pi/agent"
  echo '{"dummy": "theme"}' >"$home/.local/state/omarchy/current/theme/pi.json"
}

# A hand-edited settings.json: JSONC comments and trailing commas are common
# in these files, and jq rejects them.
write_invalid_settings() {
  printf '%s\n' '// user comment' '{ "theme": "dark", }' >"$1"
}

litter_count() {
  find "$(dirname "$1")" -maxdepth 1 -name "$(basename "$1").*" | wc -l
}

# 1. claude: a jq failure must not leave a settings.json.XXXXXX file behind,
# and the original settings.json must be untouched.
setup_claude "$test_home"
write_invalid_settings "$test_home/.claude/settings.json"
sha_before=$(sha256sum "$test_home/.claude/settings.json" | cut -d' ' -f1)

status=0
HOME="$test_home" CLAUDE_CONFIG_DIR="$test_home/.claude" bash "$ROOT/bin/omarchy-theme-set-claude" --activate 2>"$test_tmp/stderr" || status=$?

(( status != 0 )) || fail "claude refuses to activate on a settings.json jq cannot parse"
(( $(litter_count "$test_home/.claude/settings.json") == 0 )) || fail "claude leaves no settings.json.XXXXXX litter when jq fails"
[[ $(sha256sum "$test_home/.claude/settings.json" | cut -d' ' -f1) == "$sha_before" ]] || fail "claude leaves the unparseable settings.json untouched"
grep -q "could not update" "$test_tmp/stderr" || fail "claude explains which file it could not update"
pass "claude activate leaves no tmp litter and keeps settings.json on jq failure"

# 2. claude: the happy path still writes the theme.
setup_claude "$test_home"
echo '{"theme": "dark"}' >"$test_home/.claude/settings.json"

HOME="$test_home" CLAUDE_CONFIG_DIR="$test_home/.claude" bash "$ROOT/bin/omarchy-theme-set-claude" --activate || fail "claude activate succeeds on a valid settings.json"
[[ $(jq -r '.theme' "$test_home/.claude/settings.json") == "custom:omarchy" ]] || fail "claude writes custom:omarchy into settings.json"
(( $(litter_count "$test_home/.claude/settings.json") == 0 )) || fail "claude leaves no tmp litter on the happy path"
pass "claude activate writes the theme on a valid settings.json"

# 3. pi: same failure contract as claude.
setup_pi "$test_home"
write_invalid_settings "$test_home/.pi/agent/settings.json"
sha_before=$(sha256sum "$test_home/.pi/agent/settings.json" | cut -d' ' -f1)

status=0
HOME="$test_home" bash "$ROOT/bin/omarchy-theme-set-pi" --activate 2>"$test_tmp/stderr" || status=$?

(( status != 0 )) || fail "pi refuses to activate on a settings.json jq cannot parse"
(( $(litter_count "$test_home/.pi/agent/settings.json") == 0 )) || fail "pi leaves no settings.json.XXXXXX litter when jq fails"
[[ $(sha256sum "$test_home/.pi/agent/settings.json" | cut -d' ' -f1) == "$sha_before" ]] || fail "pi leaves the unparseable settings.json untouched"
grep -q "could not update" "$test_tmp/stderr" || fail "pi explains which file it could not update"
pass "pi activate leaves no tmp litter and keeps settings.json on jq failure"

# 4. pi: the happy path still writes the theme.
setup_pi "$test_home"
echo '{"theme": "dark"}' >"$test_home/.pi/agent/settings.json"

HOME="$test_home" bash "$ROOT/bin/omarchy-theme-set-pi" --activate || fail "pi activate succeeds on a valid settings.json"
[[ $(jq -r '.theme' "$test_home/.pi/agent/settings.json") == "omarchy-system" ]] || fail "pi writes omarchy-system into settings.json"
(( $(litter_count "$test_home/.pi/agent/settings.json") == 0 )) || fail "pi leaves no tmp litter on the happy path"
pass "pi activate writes the theme on a valid settings.json"
