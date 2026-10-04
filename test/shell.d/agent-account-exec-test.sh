#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command mise
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

account_test_home="$test_tmp/home"
real_bin="$test_tmp/real/bin"
mise_data="$test_tmp/data/mise"
registry_dir="$account_test_home/.local/state/omarchy/agents/accounts"
mkdir -p "$account_test_home" "$real_bin" "$registry_dir"

# Use real mise dispatch and real account resolution, with fake agent binaries.
# No shell functions, login startup files, credentials, or network are involved.
for provider in claude codex grok; do
  cat >"$real_bin/$provider" <<'SH'
#!/bin/bash
case "${0##*/}" in
  claude) printf '%s\n' "${CLAUDE_CONFIG_DIR:-default}" ;;
  codex) printf '%s\n' "${CODEX_HOME:-default}" ;;
  grok) printf '%s\n' "${GROK_HOME:-default}" ;;
esac
if (($#)); then
  printf '%s\n' "$@"
fi
if [[ ${OMARCHY_TEST_SWITCH_ACCOUNT:-} == "yes" ]]; then
  unset OMARCHY_TEST_SWITCH_ACCOUNT
  omarchy-agent-account-state use "${0##*/}" "${OMARCHY_TEST_SWITCH_TO:-side}" >/dev/null
  if [[ ${OMARCHY_TEST_NEW_SESSION:-} == "yes" ]]; then
    omarchy-agent --inline
  else
    "${0##*/}"
  fi
fi
if [[ -n ${OMARCHY_TEST_AGENT_CHILD:-} ]]; then
  child=$OMARCHY_TEST_AGENT_CHILD
  unset OMARCHY_TEST_AGENT_CHILD
  "$child"
fi
exit "${OMARCHY_TEST_AGENT_EXIT:-0}"
SH
  chmod +x "$real_bin/$provider"
done

run_isolated() {
  env -i HOME="$account_test_home" \
    XDG_CONFIG_HOME="$test_tmp/config" XDG_DATA_HOME="$test_tmp/data" XDG_CACHE_HOME="$test_tmp/cache" \
    MISE_DATA_DIR="$mise_data" MISE_SYSTEM_CONFIG_DIR="$ROOT/etc/mise" MISE_OFFLINE=1 \
    OMARCHY_PATH="$ROOT" PATH="$mise_data/command-wrappers/bin:$ROOT/bin:$real_bin:/usr/bin" \
    "$@"
}

select_account() {
  local provider=$1
  local selected=$2
  printf '{"active":"%s","accounts":[{"id":"main","primary":true},{"id":"side","home":"%s"}]}\n' \
    "$selected" "$test_tmp/accounts/$provider side" >"$registry_dir/$provider.json"
}

for helper in omarchy-agent-usage-update omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$real_bin/$helper"
  chmod +x "$real_bin/$helper"
done

cd "$test_tmp"
run_isolated mise reshim

for provider in claude codex grok; do
  select_account "$provider" side
  account_dir="$test_tmp/accounts/$provider side"
  output=$(run_isolated "$provider" 'a spaced prompt' '' '--flag=$literal')
  expected=$(printf '%s\n' "$account_dir" 'a spaced prompt' '' '--flag=$literal')
  [[ $output == "$expected" ]] || fail "$provider dispatch selects the active account and preserves arguments" "$output"
  pass "$provider dispatch selects the active account and preserves arguments"

  case "$provider" in
    claude) account_env=CLAUDE_CONFIG_DIR ;;
    codex) account_env=CODEX_HOME ;;
    grok) account_env=GROK_HOME ;;
  esac
  output=$(run_isolated env "$account_env=/explicit/account" "$provider")
  [[ $output == /explicit/account ]] || fail "$provider preserves an explicit account home" "$output"
  pass "$provider preserves an explicit account home"

  select_account "$provider" main
  output=$(run_isolated "$provider")
  [[ $output == default ]] || fail "$provider picks up switching back to Main without rebuilding shims" "$output"
  pass "$provider picks up switching back to Main without rebuilding shims"

  output=$(run_isolated env OMARCHY_TEST_SWITCH_ACCOUNT=yes "$provider")
  [[ $output == $'default\ndefault' ]] || fail "$provider Main sessions keep their account after a switch" "$output"
  pass "$provider Main sessions keep their account after a switch"

  mkdir -p "$account_test_home/.config/omarchy/defaults"
  printf '%s\n' "$provider" >"$account_test_home/.config/omarchy/defaults/agent"
  select_account "$provider" main
  output=$(run_isolated env OMARCHY_TEST_SWITCH_ACCOUNT=yes OMARCHY_TEST_NEW_SESSION=yes "$provider")
  [[ $(sed -n '2p' <<<"$output") == "$account_dir" ]] || fail "$provider new sessions follow a switch from Main" "$output"
  pass "$provider new sessions follow a switch from Main"

  output=$(run_isolated env OMARCHY_TEST_SWITCH_ACCOUNT=yes OMARCHY_TEST_SWITCH_TO=main OMARCHY_TEST_NEW_SESSION=yes "$provider")
  [[ $(sed -n '2p' <<<"$output") == default ]] || fail "$provider new sessions follow a switch to Main" "$output"
  pass "$provider new sessions follow a switch to Main"

  select_account "$provider" side
  output=$(run_isolated env OMARCHY_TEST_SWITCH_ACCOUNT=yes OMARCHY_TEST_SWITCH_TO=main "$provider")
  [[ $output == "$(printf '%s\n' "$account_dir" "$account_dir")" ]] || fail "$provider side sessions keep their account after a switch" "$output"
  pass "$provider side sessions keep their account after a switch"

  output=$(run_isolated env "OMARCHY_AGENT_${provider^^}_HOME=" "$account_env=/explicit/account" omarchy-agent --inline)
  [[ ${output%%$'\n'*} == /explicit/account ]] || fail "$provider new sessions preserve explicit account overrides" "$output"
  pass "$provider new sessions preserve explicit account overrides"

  select_account "$provider" side
  output=$(run_isolated omarchy-agent-account-add --reauth :primary "$provider" </dev/null)
  grep -Fxq default <<<"$output" || fail "$provider primary reauthentication bypasses the active side account" "$output"
  pass "$provider primary reauthentication bypasses the active side account"

  rm "$registry_dir/$provider.json"
  output=$(run_isolated "$provider")
  [[ $output == default ]] || fail "$provider works without an account registry" "$output"
  pass "$provider works without an account registry"
done

select_account claude side
output=$(run_isolated python3 -c 'import subprocess; print(subprocess.check_output(["claude", "-p", "review"], text=True), end="")')
[[ $output == "$(printf '%s\n' "$test_tmp/accounts/claude side" -p review)" ]] ||
  fail "a Python subprocess follows the selected Claude subscription" "$output"
pass "a Python subprocess follows the selected Claude subscription"

select_account codex side
output=$(run_isolated env OMARCHY_TEST_AGENT_CHILD=codex claude)
expected=$(printf '%s\n' "$test_tmp/accounts/claude side" "$test_tmp/accounts/codex side")
[[ $output == "$expected" ]] || fail "an agent's subprocess still dispatches the other provider's selected account" "$output"
pass "an agent's subprocess still dispatches the other provider's selected account"

# Give mise a real installed Claude tool directory, not just a system fallback.
ln -s "$real_bin/claude" "$test_tmp/real/claude"
run_isolated mise link claude@1.0.0 "$test_tmp/real" >/dev/null
mkdir -p "$test_tmp/config/mise"
printf '[tools]\nclaude = "1.0.0"\n' >"$test_tmp/config/mise/config.toml"
run_isolated mise trust "$test_tmp/config/mise/config.toml" >/dev/null 2>&1

# Existing tool shims used by SSH already dispatch wrappers, including with a
# relocated mise data directory. No additional stock-only PAM path is needed.
run_isolated mise reshim
output=$(run_isolated env PATH="$mise_data/shims:$ROOT/bin:/usr/bin" claude)
[[ $output == "$test_tmp/accounts/claude side" ]] || fail "SSH-style mise tool shims route through account dispatch in a custom data directory" "$output"
pass "SSH-style mise tool shims route through account dispatch in a custom data directory"

# Full PATH activation must also prefer the dispatcher over installed tools.
output=$(run_isolated bash -c 'eval "$(mise env -s bash)"; [[ $PATH == *"/installs/claude/"* ]] || exit 99; claude')
[[ $output == "$test_tmp/accounts/claude side" ]] || fail "mise PATH activation retains account dispatch" "$output"
pass "mise PATH activation retains account dispatch"

status=0
run_isolated env OMARCHY_TEST_AGENT_EXIT=42 claude >/dev/null || status=$?
(( status == 42 )) || fail "account dispatch preserves the agent exit status" "$status"
pass "account dispatch preserves the agent exit status"

# A dispatcher alone must not prevent the CLI from being installed on first use.
mv "$real_bin/grok" "$test_tmp/grok-fixture"
cat >"$real_bin/mise" <<'SH'
#!/bin/bash
case "$1" in
  use)
    [[ ${OMARCHY_TEST_INSTALL_FAIL:-} != "yes" ]] || exit 42
    [[ $* == "use -g --quiet grok" ]] || exit 99
    cp "$HOME/../grok-fixture" "$HOME/../real/bin/grok"
    ;;
  which)
    [[ ${MISE_MINIMUM_RELEASE_AGE:-} == "0" ]] || exit 99
    printf '%s\n' "$HOME/../real/bin/grok"
    ;;
  *) exit 99 ;;
esac
SH
chmod +x "$real_bin/mise"
select_account grok side
output=$(run_isolated grok)
[[ $output == "$test_tmp/accounts/grok side" ]] || fail "a dispatcher without a CLI installs it and uses the selected account" "$output"
pass "a dispatcher without a CLI installs it and uses the selected account"

rm "$real_bin/grok"
status=0
run_isolated env OMARCHY_TEST_INSTALL_FAIL=yes grok >/dev/null || status=$?
(( status == 42 )) || fail "a failed first-run install stops dispatch" "$status"
pass "a failed first-run install stops dispatch"
rm "$real_bin/mise"

# Migration only rebuilds native mise dispatch; account files stay untouched.
registry_before=$(sha256sum "$registry_dir"/*.json)
for attempt in 1 2; do
  run_isolated bash -euo pipefail "$ROOT/migrations/1791112479.sh" >/dev/null
  for provider in claude codex grok; do
    [[ -L $mise_data/command-wrappers/bin/$provider ]] || fail "migration builds every account dispatcher"
  done
done
[[ $(sha256sum "$registry_dir"/*.json) == "$registry_before" ]] || fail "migration preserves account state"
pass "migration rebuilds dispatchers idempotently without changing account state"
