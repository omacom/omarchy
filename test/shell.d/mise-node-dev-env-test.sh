#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mise_log="$test_tmp/mise"
mkdir -p "$mock_bin" "$test_home"

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

bash "$ROOT/bin/omarchy-install-dev-env" node >/dev/null
[[ $(<"$mise_log") == "install node" ]] || fail "Node setup installs the system-configured Node and leaves the user config alone"
pass "Node setup installs Omarchy's declared Node"

# mise skips Omarchy's declarations for a user who removed the preinstalls, so
# Node goes in their own config, leaving the opt-out in place.
miserc="$test_home/.config/mise/miserc.toml"
mkdir -p "$(dirname "$miserc")"
printf 'ignored_config_paths = ["%s"]\n' "$mise_config" >"$miserc"
: >"$mise_log"
bash "$ROOT/bin/omarchy-install-dev-env" node >/dev/null
[[ $(<"$mise_log") == "use --global node" ]] || fail "Node setup selects Node after Remove Preinstalls"
rm "$miserc"
pass "Node setup selects Node after Remove Preinstalls"

rm "$mise_config"
: >"$mise_log"
bash "$ROOT/bin/omarchy-install-dev-env" node >/dev/null
[[ $(<"$mise_log") == "use --global node" ]] || fail "Node setup selects Node when no system config declares it"
pass "Node setup selects Node without Omarchy's declarations"
