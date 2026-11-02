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

# Fail only the selected publishing step; all other copies/moves stay real.
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/copy-or-move" <<'EOF'
#!/bin/bash
set -euo pipefail
command_name=${0##*/}
if [[ $command_name == "$FAIL_COMMAND" && ${2%.*} == "$FAIL_DESTINATION" && $command_name == "cp" ]] ||
  [[ $command_name == "$FAIL_COMMAND" && $2 == "$FAIL_DESTINATION" && $command_name == "mv" ]]; then
  if [[ $command_name == "cp" ]]; then
    printf 'partial copy\n' >"$2"
    printf '%s\n' "$2" >"$FAIL_STAGE"
  else
    [[ -s $1 ]]
    printf '%s\n' "$1" >"$FAIL_STAGE"
  fi
  exit 73
fi
if [[ $command_name == "cp" ]]; then
  exec "$REAL_CP" "$@"
else
  exec "$REAL_MV" "$@"
fi
EOF
chmod +x "$stub_bin/copy-or-move"
ln -s copy-or-move "$stub_bin/cp"
ln -s copy-or-move "$stub_bin/mv"

for app in claude pi; do
  for operation in theme-cp theme-mv settings-mv; do
    "setup_$app" "$test_home"
    if [[ $app == "claude" ]]; then
      config_dir="$test_home/.claude"
      theme_path="$config_dir/themes/omarchy.json"
    else
      config_dir="$test_home/.pi/agent"
      theme_path="$config_dir/themes/omarchy-system.json"
    fi
    settings_path="$config_dir/settings.json"
    mkdir -p "$config_dir/themes"
    printf '%s\n' '{"theme":"dark","keep":"user settings"}' >"$settings_path"
    printf '%s\n' '{"keep":"user theme"}' >"$theme_path"
    cp "$settings_path" "$test_tmp/settings-before"
    cp "$theme_path" "$test_tmp/theme-before"
    fail_destination="$theme_path"
    [[ $operation != "settings-mv" ]] || fail_destination="$settings_path"
    rm -f "$test_tmp/failed-stage"

    status=0
    HOME="$test_home" CLAUDE_CONFIG_DIR="$test_home/.claude" \
      REAL_CP="$(command -v cp)" REAL_MV="$(command -v mv)" \
      FAIL_COMMAND="${operation##*-}" FAIL_DESTINATION="$fail_destination" FAIL_STAGE="$test_tmp/failed-stage" \
      PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-$app" --activate 2>"$test_tmp/stderr" || status=$?

    (( status == 1 )) || fail "$app reports $operation failure"
    [[ -s $test_tmp/failed-stage ]] || fail "$app reaches the injected $operation failure"
    [[ ! -e $(<"$test_tmp/failed-stage") ]] || fail "$app removes the failed $operation stage"
    (( $(litter_count "$theme_path") == 0 && $(litter_count "$settings_path") == 0 )) || fail "$app leaves no staged files after $operation failure"
    cmp -s "$settings_path" "$test_tmp/settings-before" || fail "$app preserves settings bytes after $operation failure"
    if [[ $operation == "settings-mv" ]]; then
      cmp -s "$theme_path" "$test_home/.local/state/omarchy/current/theme/$app.json" || fail "$app publishes the theme before settings-mv failure"
    else
      cmp -s "$theme_path" "$test_tmp/theme-before" || fail "$app preserves theme bytes after $operation failure"
    fi
    pass "$app cleans up and preserves existing files on $operation failure"
  done
done
