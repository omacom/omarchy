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

# mise skips Omarchy's declarations for a user who removed the preinstalls, so
# uv goes in their own config, leaving the opt-out in place.
miserc="$test_home/.config/mise/miserc.toml"
mkdir -p "$(dirname "$miserc")"
printf 'ignored_config_paths = ["%s"]\n' "$mise_config" >"$miserc"
cp "$miserc" "$test_tmp/expected-miserc"
: >"$mise_log"
bash "$ROOT/bin/omarchy-install-dev-env" python >/dev/null
grep -Fx 'use --global uv' "$mise_log" >/dev/null || fail "Python setup selects uv after Remove Preinstalls"
grep -Fx 'install uv' "$mise_log" >/dev/null && fail "Python setup does not count on Omarchy's uv after Remove Preinstalls"
cmp -s "$miserc" "$test_tmp/expected-miserc" || fail "Python setup keeps the preinstall opt-out"
rm "$miserc"
pass "Python setup selects uv after Remove Preinstalls"

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
