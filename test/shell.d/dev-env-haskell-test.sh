#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_usage=$("$ROOT/bin/omarchy-install-dev-env" 2>&1) && fail "install-dev-env requires an environment" || true
[[ $install_usage == *haskell* ]] || fail "install-dev-env usage lists haskell" "$install_usage"
pass "install-dev-env usage lists haskell"

remove_usage=$("$ROOT/bin/omarchy-remove-dev-env" 2>&1) && fail "remove-dev-env requires an environment" || true
[[ $remove_usage == *haskell* ]] || fail "remove-dev-env usage lists haskell" "$remove_usage"
pass "remove-dev-env usage lists haskell"

stub_dir=$(mktemp -d)
log=$stub_dir/calls
trap 'rm -rf "$stub_dir"' EXIT

cat >"$stub_dir/mise" <<'STUB'
#!/bin/bash
printf 'mise %s\n' "$*" >>"$OMARCHY_DEV_ENV_LOG"
if [[ -n ${OMARCHY_DEV_ENV_FAIL:-} && "$*" == *"$OMARCHY_DEV_ENV_FAIL"* ]]; then
  exit 1
fi
STUB
cat >"$stub_dir/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$OMARCHY_DEV_ENV_LOG"
STUB
chmod +x "$stub_dir/mise" "$stub_dir/omarchy-pkg-add"

: >"$log"
PATH="$stub_dir:$PATH" OMARCHY_DEV_ENV_LOG="$log" "$ROOT/bin/omarchy-install-dev-env" haskell >/dev/null
grep -Fxq 'pkg-add bc' "$log" || fail "haskell install adds bc for the GHCup plugin" "$(cat "$log")"
grep -Fxq 'mise plugins install hls https://github.com/mise-plugins/mise-ghcup.git' "$log" || fail "haskell install registers the HLS plugin" "$(cat "$log")"
grep -Fxq 'mise use --global ghc@latest' "$log" || fail "haskell install uses mise for ghc" "$(cat "$log")"
grep -Fxq 'mise use --global cabal@latest' "$log" || fail "haskell install uses mise for cabal" "$(cat "$log")"
grep -Fxq 'mise use --global hls@latest' "$log" || fail "haskell install uses mise for HLS" "$(cat "$log")"
pass "haskell install goes through mise"

: >"$log"
if PATH="$stub_dir:$PATH" OMARCHY_DEV_ENV_LOG="$log" OMARCHY_DEV_ENV_FAIL='cabal@latest' "$ROOT/bin/omarchy-install-dev-env" haskell >"$stub_dir/out" 2>&1; then
  fail "haskell install fails when Cabal does not install" "$(cat "$stub_dir/out")"
fi
output=$(cat "$stub_dir/out")
[[ $output == *"Failed to install Cabal."* ]] || fail "haskell install reports the Cabal failure" "$output"
[[ $output != *"You can now run"* ]] || fail "haskell install does not say it is ready after Cabal fails" "$output"
grep -Fxq 'mise use --global ghc@latest' "$log" || fail "haskell install reached GHC before Cabal failed" "$(cat "$log")"
if grep -Fxq 'mise use --global hls@latest' "$log"; then
  fail "haskell install stops after Cabal fails" "$(cat "$log")"
fi
pass "haskell install stops when a tool fails"

: >"$log"
PATH="$stub_dir:$PATH" OMARCHY_DEV_ENV_LOG="$log" "$ROOT/bin/omarchy-remove-dev-env" haskell >/dev/null
for call in \
  'mise uninstall ghc --all' \
  'mise uninstall cabal --all' \
  'mise uninstall hls --all' \
  'mise rm -g ghc' \
  'mise rm -g cabal' \
  'mise rm -g hls'
do
  grep -Fxq "$call" "$log" || fail "haskell removal runs $call" "$(cat "$log")"
done
pass "haskell removal uninstalls the mise tools"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const parsed = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = Object.fromEntries(parsed.map(item => [item.id, item]))

const install = byId['install.development.haskell']
assert(install, 'menu includes Install > Development > Haskell')
assertEqual(install.label, 'Haskell', 'Haskell install row is labeled Haskell')
assertEqual(install.icon, '', 'Haskell install row uses the Nerd Font Haskell glyph')
const installed = '[[ -d $HOME/.local/share/mise/installs/ghc && -d $HOME/.local/share/mise/installs/cabal && -d $HOME/.local/share/mise/installs/hls ]]'
assertEqual(install.disabled, installed, 'Haskell install row dims once GHC, Cabal, and HLS are installed')
assert(!install.when, 'Haskell install row stays in the catalog after install')
assert(install.action.includes("omarchy-install-dev-env haskell"), 'Haskell install row runs omarchy-install-dev-env haskell')

const remove = byId['remove.development.haskell']
assert(remove, 'menu includes Remove > Development > Haskell')
const partial = '[[ -d $HOME/.local/share/mise/installs/ghc || -d $HOME/.local/share/mise/installs/cabal || -d $HOME/.local/share/mise/installs/hls ]]'
assertEqual(remove.when, partial, 'Haskell remove row appears when any of GHC, Cabal, or HLS is installed')
assert(remove.action.includes("omarchy-remove-dev-env haskell"), 'Haskell remove row runs omarchy-remove-dev-env haskell')
JS
