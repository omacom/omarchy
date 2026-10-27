#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
log="$test_tmp/calls.log"
mkdir -p "$mock_bin"

# Stand in for mise, the rea shim it creates and npx, logging each call, with
# the release cooldown mise was given. OMARCHY_TEST_FAIL names the one call
# that fails, the way a failed download or a cancelled setup would.
for command in mise rea npx; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
call="${0##*/} $*"
echo "$call${MISE_MINIMUM_RELEASE_AGE:+ [age=$MISE_MINIMUM_RELEASE_AGE]}" >>"$OMARCHY_TEST_LOG"
[[ $call == "rea --version" ]] && echo "6.7.0"
if [[ $call == "mise ls --current --json node" ]]; then
  if [[ ${TEST_NODE_SELECTED:-0} == "1" ]]; then
    echo '[{"requested_version":"26.12.1","installed":false}]'
  else
    echo '[]'
  fi
fi
[[ $call != "${OMARCHY_TEST_FAIL:-}" ]]
SH
done

chmod +x "$mock_bin"/*

export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_LOG="$log"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_MISE_CONFIG_PATH="$test_tmp/omarchy-tools.toml"
mkdir -p "$HOME/.config/mise"
printf '[tools]\nnode = { version = "latest", lazy = true }\n' >"$OMARCHY_MISE_CONFIG_PATH"

run() {
  "$ROOT/bin/$1" </dev/null >"$test_tmp/output" 2>&1
}

calls() {
  paste -sd '|' "$log"
}

: >"$log"
run omarchy-install-ai-rea || fail "installing REA succeeds" "$(cat "$test_tmp/output")"
[[ $(calls) == "mise install node|mise use -g npm:rea-agents[allow_low_downloads=true] [age=0]|rea --version|npx -y rea-agents@6.7.0 setup" ]] ||
  fail "the install prepares Node, adds REA without a cooldown, then sets up agents through npx at the same version" "$(calls)"
grep -q 'REA has been installed.' "$test_tmp/output" || fail "a finished setup reports the install"
pass "the installer prepares the default Node runtime, adds REA, and registers the installed version through npx"

: >"$log"
if OMARCHY_TEST_FAIL="mise use -g npm:rea-agents[allow_low_downloads=true]" run omarchy-install-ai-rea; then
  fail "a failed download fails the install"
fi
[[ $(calls) == "mise install node|mise use -g npm:rea-agents[allow_low_downloads=true] [age=0]" ]] || fail "setup does not start after a failed download" "$(calls)"
pass "a failed download stops the install before setup"

: >"$log"
OMARCHY_TEST_FAIL="npx -y rea-agents@6.7.0 setup" run omarchy-install-ai-rea || fail "a cancelled setup still leaves REA installed" "$(cat "$test_tmp/output")"
grep -q "Run 'npx -y rea-agents@6.7.0 setup'" "$test_tmp/output" || fail "a cancelled setup says how to finish it"
pass "a cancelled setup keeps REA and says how to register it later"

# Opting out leaves no default Node selection for REA's npm backend or npx.
: >"$log"
printf 'ignored_config_paths = ["%s"]\n' "$OMARCHY_MISE_CONFIG_PATH" >"$HOME/.config/mise/miserc.toml"
run omarchy-install-ai-rea || fail "installing REA without default tools succeeds" "$(cat "$test_tmp/output")"
[[ $(calls) == "mise ls --current --json node|mise use -g node|mise use -g npm:rea-agents[allow_low_downloads=true] [age=0]|rea --version|npx -y rea-agents@6.7.0 setup" ]] ||
  fail "the install selects Node when the user opted out of defaults" "$(calls)"
pass "the installer selects Node when the user opted out of default tools"

: >"$log"
TEST_NODE_SELECTED=1 run omarchy-install-ai-rea || fail "installing REA with a selected Node succeeds" "$(cat "$test_tmp/output")"
[[ $(calls) == "mise ls --current --json node|mise install node|mise use -g npm:rea-agents[allow_low_downloads=true] [age=0]|rea --version|npx -y rea-agents@6.7.0 setup" ]] ||
  fail "the install preserves an existing Node selection after opt-out" "$(calls)"
pass "the installer keeps an existing Node selection after opting out of default tools"
