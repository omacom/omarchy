#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_usage=$("$ROOT/bin/omarchy-install-dev-env" 2>&1) && fail "install-dev-env requires an environment" || true
[[ $install_usage == *firebase* ]] || fail "install-dev-env usage lists firebase" "$install_usage"
pass "install-dev-env usage lists firebase"

remove_usage=$("$ROOT/bin/omarchy-remove-dev-env" 2>&1) && fail "remove-dev-env requires an environment" || true
[[ $remove_usage == *firebase* ]] || fail "remove-dev-env usage lists firebase" "$remove_usage"
pass "remove-dev-env usage lists firebase"

stub_dir=$(mktemp -d)
log=$stub_dir/calls
trap 'rm -rf "$stub_dir"' EXIT

cat >"$stub_dir/mise" <<'STUB'
#!/bin/bash
printf 'mise %s\n' "$*" >>"$OMARCHY_DEV_ENV_LOG"
STUB
chmod +x "$stub_dir/mise"

: >"$log"
PATH="$stub_dir:$PATH" OMARCHY_DEV_ENV_LOG="$log" "$ROOT/bin/omarchy-install-dev-env" firebase >/dev/null
grep -Fxq 'mise use --global firebase@latest' "$log" || fail "firebase install uses mise" "$(cat "$log")"
pass "firebase install goes through mise"

: >"$log"
PATH="$stub_dir:$PATH" OMARCHY_DEV_ENV_LOG="$log" "$ROOT/bin/omarchy-remove-dev-env" firebase >/dev/null
grep -Fxq 'mise uninstall firebase --all' "$log" || fail "firebase removal uninstalls the tool" "$(cat "$log")"
grep -Fxq 'mise rm -g firebase' "$log" || fail "firebase removal clears the global version" "$(cat "$log")"
pass "firebase removal uninstalls the mise tool"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const parsed = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const byId = Object.fromEntries(parsed.map(item => [item.id, item]))

const install = byId['install.development.firebase']
assert(install, 'menu includes Install > Development > Firebase')
assertEqual(install.label, 'Firebase', 'Firebase install row is labeled Firebase')
assertEqual(install.icon, '', 'Firebase install row uses the Nerd Font Firebase glyph')
assertEqual(install.disabled, '[[ -d $HOME/.local/share/mise/installs/firebase ]]', 'Firebase install row dims once the CLI is installed')
assert(!install.when, 'Firebase install row stays in the catalog after install')
assert(install.action.includes("omarchy-install-dev-env firebase"), 'Firebase install row runs omarchy-install-dev-env firebase')

const remove = byId['remove.development.firebase']
assert(remove, 'menu includes Remove > Development > Firebase')
assertEqual(remove.when, '[[ -d $HOME/.local/share/mise/installs/firebase ]]', 'Firebase remove row is hidden until the CLI is installed')
assert(remove.action.includes("omarchy-remove-dev-env firebase"), 'Firebase remove row runs omarchy-remove-dev-env firebase')
JS
