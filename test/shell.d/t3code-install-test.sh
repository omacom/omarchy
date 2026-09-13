#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Run the real theme refresh, renderer and publisher in a throwaway home.
# Only package installation, the T3 CLI and desktop launch are stubbed.
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $1 == "t3code-bin" ]]
SH

cat >"$mock_bin/t3" <<'SH'
#!/bin/bash
[[ $1 == "theme" && $2 == "set" && $3 == "omarchy" && $4 == "--base-dir" && $5 == "$T3CODE_HOME" ]] || exit 1
palette="$T3CODE_HOME/userdata/themes/omarchy.json"
if [[ ! -f $palette ]] || ! jq -e '.name == "Omarchy" and (.accent | test("^#[0-9a-fA-F]{6}$"))' "$palette" >/dev/null; then
  echo "No published Omarchy theme"
  exit 1
fi
if [[ ${OMARCHY_TEST_T3_FAIL:-0} == "1" ]]; then
  echo "T3 theme selection failed"
  exit 1
fi
echo "T3 selected Omarchy"
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

run_installer() {
  HOME="$test_home" T3CODE_HOME="$test_tmp/custom t3 home" \
    OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 XDG_RUNTIME_DIR="$test_tmp" \
    "$ROOT/bin/omarchy-install-ai-t3-code" >"$test_tmp/output" 2>&1
}

state="$test_home/.local/state/omarchy/current"
palette="$test_tmp/custom t3 home/userdata/themes/omarchy.json"
settings="$test_tmp/custom t3 home/userdata/settings.json"
mkdir -p "$state/theme"
echo 'tokyo-night' >"$state/theme.name"
cp "$ROOT/themes/tokyo-night/colors.toml" "$state/theme/colors.toml"

run_installer || fail "installing after an update succeeds" "$(cat "$test_tmp/output")"
[[ -f $state/theme/t3code.json && -f $palette ]] || fail "the missing palette is rendered and published"
cmp -s "$state/theme/t3code.json" "$palette" || fail "T3 receives the current theme's palette"
grep -q 'T3 selected Omarchy' "$test_tmp/output" || fail "the published palette is selected"
grep -q 'Opening T3 Code' "$test_tmp/output" || fail "the themed app opens"
[[ ! -e $test_home/.t3 ]] || fail "the custom T3 home is respected"
pass "an update with no staged T3 palette renders, publishes and selects it before launch"

# Preserve an already rendered palette, including a user-supplied color.
jq '.accent = "#abcdef"' "$state/theme/t3code.json" >"$test_tmp/palette.json"
cp "$test_tmp/palette.json" "$state/theme/t3code.json"
run_installer || fail "installing with an existing palette succeeds" "$(cat "$test_tmp/output")"
cmp -s "$test_tmp/palette.json" "$palette" || fail "an existing palette is published without re-staging"
pass "an existing palette is used without refreshing the current theme"

printf '{"defaultTheme":"dark","keep":"existing settings"}\n' >"$settings"
cp "$settings" "$test_tmp/settings-before.json"
if OMARCHY_TEST_T3_FAIL=1 run_installer; then
  fail "a failed T3 theme selection fails the installer"
fi
grep -q 'T3 theme selection failed' "$test_tmp/output" || fail "the CLI failure is visible"
if grep -Eq 'Opening T3 Code|T3 Code has been installed' "$test_tmp/output"; then
  fail "a failed selection does not report successful setup"
fi
cmp -s "$test_tmp/settings-before.json" "$settings" || fail "a failed selection does not rewrite settings"
pass "a CLI failure remains visible and leaves the existing settings intact"
