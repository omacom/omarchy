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

# Full PATH activation must also prefer the dispatcher over installed tools.
output=$(run_isolated bash -c 'eval "$(mise env -s bash)"; [[ $PATH == *"/installs/claude/"* ]] || exit 99; claude')
[[ $output == "$test_tmp/accounts/claude side" ]] || fail "mise PATH activation retains account dispatch" "$output"
pass "mise PATH activation retains account dispatch"

status=0
run_isolated env OMARCHY_TEST_AGENT_EXIT=42 claude >/dev/null || status=$?
(( status == 42 )) || fail "account dispatch preserves the agent exit status" "$status"
pass "account dispatch preserves the agent exit status"

# Exercise the migration only against a copy of PAM config.
pam_config="$test_tmp/pam_env.conf"
migration="$test_tmp/migration.sh"
sed "s|/etc/security/pam_env.conf|$pam_config|g" "$ROOT/migrations/1791112479.sh" >"$migration"
cat >"$real_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$real_bin/sudo"
legacy_path='PATH DEFAULT=/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
wrapper_path='PATH DEFAULT=@{HOME}/.local/share/mise/command-wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:@{HOME}/.local/share/mise/shims:@{HOME}/.local/bin'
printf '# keep this comment\n%s\n' "$legacy_path" >"$pam_config"
run_isolated bash -euo pipefail "$migration" >/dev/null
grep -Fxq "$wrapper_path" "$pam_config" || fail "migration adds dispatch to Omarchy's SSH command path"
grep -Fxq '# keep this comment' "$pam_config" || fail "migration preserves other PAM configuration"
cp "$pam_config" "$test_tmp/once"
run_isolated bash -euo pipefail "$migration" >/dev/null
cmp -s "$pam_config" "$test_tmp/once" || fail "migration can run twice without changing configuration again"
pass "migration updates the stock SSH path idempotently and preserves other configuration"

printf 'PATH DEFAULT=/custom/bin:/usr/bin\n' >"$pam_config"
run_isolated bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$pam_config") == 'PATH DEFAULT=/custom/bin:/usr/bin' ]] || fail "migration leaves an administrator's SSH path alone"
pass "migration leaves an administrator's SSH path alone"
