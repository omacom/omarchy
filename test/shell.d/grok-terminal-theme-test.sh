#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
export HOME="$test_dir"
helper="$ROOT/bin/omarchy-setup-grok-theme"
bash "$helper"
python3 - <<'PY'
import os, pathlib, tomllib
data = tomllib.loads((pathlib.Path(os.environ['HOME']) / '.grok/config.toml').read_text())
assert data == {'ui': {'theme': 'terminal'}, 'features': {'terminal_theme': True}}
PY
cp "$HOME/.grok/config.toml" "$test_dir/first"
bash "$helper"
cmp "$test_dir/first" "$HOME/.grok/config.toml"
pass "fresh Grok defaults use the terminal palette idempotently"

cat >"$HOME/.grok/config.toml" <<'TOML'
# preserve comments and all other settings
[ui]
compact_mode = true
[features]
something_else = false
TOML
bash "$helper"
grep -q '# preserve comments' "$HOME/.grok/config.toml"
python3 - <<'PY'
import os, pathlib, tomllib
data = tomllib.loads((pathlib.Path(os.environ['HOME']) / '.grok/config.toml').read_text())
assert data['ui'] == {'compact_mode': True, 'theme': 'terminal'}
assert data['features'] == {'something_else': False, 'terminal_theme': True}
PY
[[ -f $HOME/.grok/config.toml.before-omarchy-terminal-theme ]]
pass "existing settings and comments survive with a backup"

for choice in groknight auto terminal; do
  printf '[ui]\ntheme = "%s"\n[features]\nterminal_theme = false\n' "$choice" >"$HOME/.grok/config.toml"
  cp "$HOME/.grok/config.toml" "$test_dir/before"
  bash "$helper"
  cmp "$test_dir/before" "$HOME/.grok/config.toml"
done
pass "explicit themes and rollout opt-outs remain unchanged"

printf 'ui.theme = "rosepine"\n' >"$HOME/.grok/config.toml"
cp "$HOME/.grok/config.toml" "$test_dir/before"
bash "$helper"
cmp "$test_dir/before" "$HOME/.grok/config.toml"
printf '[ui]\ntheme = [\n' >"$HOME/.grok/config.toml"
cp "$HOME/.grok/config.toml" "$test_dir/before"
if bash "$helper" >/dev/null 2>&1; then
  fail "invalid TOML must fail without replacement"
fi
cmp "$test_dir/before" "$HOME/.grok/config.toml"
pass "dotted explicit choices and invalid TOML are preserved"

rm "$HOME/.grok/config.toml"
printf '[ui]\ntheme = "custom"\n' >"$test_dir/dotfiles.toml"
cp "$test_dir/dotfiles.toml" "$test_dir/dotfiles.before"
ln -s "$test_dir/dotfiles.toml" "$HOME/.grok/config.toml"
bash "$helper"
[[ -L $HOME/.grok/config.toml ]]
cmp "$test_dir/dotfiles.before" "$test_dir/dotfiles.toml"
rm "$test_dir/dotfiles.toml"
bash "$helper"
[[ -L $HOME/.grok/config.toml && ! -e $HOME/.grok/config.toml ]]
pass "existing and dangling config symlinks skip successfully without changing user files"
