#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

if ! mise_bin=$(command -v mise); then
  skip "mise is unavailable; skipping real mise wrapper integration"
  exit 0
fi
require_command timeout
require_command git
ulimit -c 0

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
data_dir="$test_dir/data"
plugin_dir="$test_dir/plugin/bin"
tool_dir="$test_dir/local tool with spaces"
mkdir -p "$test_home" "$plugin_dir" "$tool_dir/bin" "$data_dir/shims" "$test_dir/bin"
ln -s "$mise_bin" "$test_dir/bin/mise"

# A local asdf plugin supplies a runtime variable without network or a compiler.
cat >"$plugin_dir/list-all" <<'SH'
#!/bin/bash
echo 1.0.0
SH
cat >"$plugin_dir/install" <<'SH'
#!/bin/bash
# The test links an already installed local tool; installation is a failure.
exit 90
SH
cat >"$plugin_dir/list-bin-paths" <<'SH'
#!/bin/bash
echo bin
SH
cat >"$plugin_dir/exec-env" <<'SH'
#!/bin/bash
export OMARCHY_FIXTURE_RUNTIME=from-real-mise
SH
cat >"$tool_dir/bin/omarchy-fixture" <<'SH'
#!/bin/bash
[[ ${OMARCHY_FIXTURE_RUNTIME:-} == from-real-mise ]] || exit 81
[[ $(command -v omarchy-fixture) == "$HOME/.local/bin/omarchy-fixture" ]] || exit 82
printf '%s\0' "$@"
SH
chmod +x "$plugin_dir/"* "$tool_dir/bin/omarchy-fixture"
git init -q "${plugin_dir%/bin}"
git -C "${plugin_dir%/bin}" add bin
git -C "${plugin_dir%/bin}" -c user.name=Fixture -c user.email=fixture@example.invalid \
  -c commit.gpgsign=false commit -qm "Local offline fixture"

# Remove inherited mise activation/configuration; all writes stay in the fixture.
run_isolated() {
  env -i HOME="$test_home" PATH="$test_home/.local/bin:$test_dir/bin:/usr/bin:/bin:$data_dir/shims" \
    XDG_CONFIG_HOME="$test_dir/config" XDG_CACHE_HOME="$test_dir/cache" \
    XDG_DATA_HOME="$test_dir/xdg-data" XDG_STATE_HOME="$test_dir/state" MISE_DATA_DIR="$data_dir" \
    MISE_CONFIG_DIR="$test_dir/config/mise" MISE_CACHE_DIR="$test_dir/cache/mise" \
    MISE_OFFLINE=true MISE_NOT_FOUND_AUTO_INSTALL=false MISE_AUTO_INSTALL=false \
    MISE_PARANOID=false \
    timeout 15 "$@"
}

cd "$test_home"
run_isolated mise plugins install --yes asdf:omarchy-fixture "file://${plugin_dir%/bin}" >/dev/null
run_isolated mise link omarchy-fixture@1.0.0 "$tool_dir" >/dev/null
run_isolated bash "$ROOT/bin/omarchy-mise-install" omarchy-fixture@1.0.0 omarchy-fixture
run_isolated "$test_home/.local/bin/omarchy-fixture" '' 'two words' '*' >"$test_dir/actual"
printf '%s\0' '' 'two words' '*' >"$test_dir/expected"
cmp -s "$test_dir/expected" "$test_dir/actual" || fail "real mise preserves wrapper arguments"
pass "real mise launches the generated wrapper with wrapper-first PATH and plugin runtime"
pass "real mise preserves empty, spaced, and literal glob arguments"

legacy_lookup=$(run_isolated mise x omarchy-fixture@1.0.0 -- which omarchy-fixture)
[[ $legacy_lookup == "$test_home/.local/bin/omarchy-fixture" ]] || fail "fixture reproduces legacy self-resolution"
pass "real mise bare-name lookup reproduces the original self-resolution"
