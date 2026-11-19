#!/bin/bash

set -euo pipefail

# omarchy-theme-set-orca turns the generated Orca theme into a local plugin and
# asks a running Orca to load it. Run against a throwaway HOME with Orca's CLI
# stubbed, so a write on a machine without Orca, a palette with holes reaching
# Orca, or an install where an update belongs shows up on disk and in the calls.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

calls="$test_tmp/calls"
cli="$test_tmp/orca-ide"
cat >"$cli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_ORCA_CALLS"
case "$1 ${2:-}" in
  "status --json")
    printf '{"result":{"runtime":{"reachable":%s}}}\n' "${OMARCHY_TEST_ORCA_RUNNING:-true}"
    ;;
  "plugin list")
    if [[ -n ${OMARCHY_TEST_ORCA_INSTALLED_FROM:-} ]]; then
      printf '{"result":{"plugins":[{"pluginKey":"local.omarchy-theme","source":{"reference":"%s"}}]}}\n' "$OMARCHY_TEST_ORCA_INSTALLED_FROM"
    else
      printf '{"result":{"plugins":[]}}\n'
    fi
    ;;
esac
SH
chmod +x "$cli"

export HOME="$test_tmp/home"
theme="$HOME/.local/state/omarchy/current/theme"
plugin="$HOME/.local/state/omarchy/orca-theme"

reset_home() {
  rm -rf "$HOME" "$calls"
  mkdir -p "$theme"
  : >"$calls"
  printf '{"base":"%s","tokens":{"--background":"#1a1b26"}}\n' "${1:-dark}" >"$theme/orca-theme.json"
  printf '{"mode":"%s","terminal":{"background":"#1a1b26"}}\n' "${1:-dark}" >"$theme/orca-terminal.json"
}

run_hook() {
  OMARCHY_ORCA_CLI="${1:-$cli}" OMARCHY_TEST_ORCA_CALLS="$calls" "$ROOT/bin/omarchy-theme-set-orca"
}

reset_home
run_hook "$test_tmp/missing-orca-ide"
[[ ! -e $plugin ]] || fail "nothing is written when Orca is not installed"
pass "a machine without Orca is left alone"

reset_home
printf '{"base":"dark","tokens":{"--background":"{{ background }}"}}\n' >"$theme/orca-theme.json"
run_hook 2>/dev/null
[[ ! -e $plugin && ! -s $calls ]] || fail "a palette with unresolved colors never reaches Orca"
pass "unresolved colors keep the previous palette"

reset_home dark
OMARCHY_TEST_ORCA_RUNNING=false run_hook
jq -e '.contributes.themes | length == 2' "$plugin/orca-plugin.json" >/dev/null || fail "the manifest offers a dark and a light theme"
[[ $(jq -r .base "$plugin/themes/dark.json") == "dark" && $(jq -r .base "$plugin/themes/light.json") == "light" ]] ||
  fail "the inactive mode gets this palette relabelled"
[[ $(jq -r .mode "$plugin/terminal/light.json") == "light" ]] || fail "the terminal palette is relabelled too"
grep -q 'plugin' "$calls" && fail "a closed Orca is not asked to load the plugin"
pass "a closed Orca still gets the plugin written for later"

reset_home light
run_hook
grep -qx "plugin install $plugin" "$calls" || fail "a first run installs the plugin folder" "$(cat "$calls")"
[[ $(jq -r .base "$plugin/themes/light.json") == "light" ]] || fail "the light palette lands in the light slot"
pass "a running Orca installs the plugin on the first run"

: >"$calls"
OMARCHY_TEST_ORCA_INSTALLED_FROM="$plugin" run_hook
grep -qx 'plugin update local.omarchy-theme' "$calls" || fail "later runs update the installed plugin" "$(cat "$calls")"
grep -q 'plugin install' "$calls" && fail "an installed plugin is not installed again"
pass "a running Orca updates the plugin it already has"
