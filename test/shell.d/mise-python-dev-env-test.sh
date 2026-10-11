#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mise_log="$test_tmp/mise"
mkdir -p "$mock_bin" "$test_home/.local/bin" "$test_home/.cargo/bin"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
if [[ $* == 'settings get disable_tools' ]]; then
  printf '%s\n' "${OMARCHY_TEST_DISABLE_TOOLS:-[]}"
fi
SH
chmod +x "$mock_bin/mise"

export HOME="$test_home"
export OMARCHY_TEST_MISE_LOG="$mise_log"
export PATH="$mock_bin:$ROOT/bin:$PATH"

mise_config="$test_tmp/etc/mise/config.toml"
mkdir -p "$(dirname "$mise_config")"
cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
export OMARCHY_MISE_CONFIG_PATH="$mise_config"

bash "$ROOT/bin/omarchy-install-dev-env" python >/dev/null
grep -Fx 'use --global python@latest' "$mise_log" >/dev/null || fail "Python setup installs Python through mise"
grep -Fx 'install uv' "$mise_log" >/dev/null || fail "Python setup installs the system-configured uv"
grep -Fx 'use --global uv' "$mise_log" >/dev/null && fail "Python setup leaves the system-configured uv out of the user config"
pass "Python setup installs Python and uv through mise"

# A user who removed the preinstalls gets uv back without re-enabling the rest.
mkdir -p "$test_home/.local/state/omarchy"
printf 'gh\nuv\n' >"$test_home/.local/state/omarchy/mise-disabled-default-tools"
: >"$mise_log"
OMARCHY_TEST_DISABLE_TOOLS='["gh", "node", "uv"]' bash "$ROOT/bin/omarchy-install-dev-env" python >/dev/null
grep -Fx 'settings set disable_tools gh,node' "$mise_log" >/dev/null || fail "Python setup keeps the user's other disabled tools"
grep -Fx 'install uv' "$mise_log" >/dev/null || fail "Python setup installs uv after Remove Preinstalls"
[[ $(<"$test_home/.local/state/omarchy/mise-disabled-default-tools") == gh ]] ||
  fail "Python setup re-enables only uv after Remove Preinstalls"
pass "Python setup re-enables uv after Remove Preinstalls"

# Without Omarchy's declarations, nothing else declares uv.
rm "$mise_config"
: >"$mise_log"
bash "$ROOT/bin/omarchy-install-dev-env" python >/dev/null
grep -Fx 'use --global uv' "$mise_log" >/dev/null || fail "Python setup selects uv when no system config declares it"
pass "Python setup selects uv without Omarchy's declarations"

touch "$test_home/.local/bin/uv" "$test_home/.local/bin/uvx" "$test_home/.cargo/bin/uv"
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" python >/dev/null
grep -Fx 'uninstall python --all' "$mise_log" >/dev/null || fail "Python removal uninstalls mise Python"
grep -Fx 'rm -g python' "$mise_log" >/dev/null || fail "Python removal removes the global Python declaration"
grep -q 'uv' "$mise_log" && fail "Python removal does not remove the independent uv tool"
[[ -e $test_home/.local/bin/uv && -e $test_home/.local/bin/uvx && -e $test_home/.cargo/bin/uv ]] ||
  fail "Python removal preserves uv commands"
pass "Python removal preserves the default uv tool"
