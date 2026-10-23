#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home with spaces"
export PATH="$mock_bin:$HOME/.local/bin:$ROOT/bin:/usr/local/bin:/usr/bin"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$HOME/.local/bin"
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
SH
chmod +x "$mock_bin/mise"

source "$ROOT/install/user/mise.sh"
for agent in kimi cursor-agent muse; do
  [[ ! -e $HOME/.local/bin/$agent ]] || fail "provisioning must not create a handwritten $agent wrapper"
done
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "reshim --system reshim" ]] ||
  fail "provisioning builds the lazy shims without installing packages or writing the user's config"
pass "provisioning leaves lazy Kimi, Cursor, and Muse shims to mise"

# The settings package ships this, so the user's config stays theirs.
grep -Fx 'upgrade.auto_prune = false' "$ROOT/etc/mise/conf.d/omarchy.toml" >/dev/null ||
  fail "Omarchy's mise config keeps upgrades from pruning versions still in use"
pass "upgrade pruning is off in the package-owned mise config"
