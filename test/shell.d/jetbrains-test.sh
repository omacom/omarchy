#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/commands" "$test_tmp/packages"

export HOME="$test_tmp/home"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_JETBRAINS="$test_tmp"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ -e $OMARCHY_TEST_JETBRAINS/commands/$1 ]]
SH
cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
! omarchy-cmd-present "$@"
SH
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
for package in "$@"; do
  [[ -e $OMARCHY_TEST_JETBRAINS/packages/$package ]] || exit 1
done
SH
cat >"$mock_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
! omarchy-pkg-present "$@"
SH
cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_JETBRAINS/install"
[[ ${OMARCHY_TEST_INSTALL_FAIL:-false} == "false" ]] || exit 1
for package in "$@"; do
  touch "$OMARCHY_TEST_JETBRAINS/packages/$package"
done
if [[ ${OMARCHY_TEST_NO_LAUNCHER:-false} == "false" ]]; then
  source "$OMARCHY_PATH/default/jetbrains/products.sh"
  jetbrains_product "$OMARCHY_TEST_PRODUCT"
  mkdir -p "$(dirname "$OMARCHY_TEST_JETBRAINS/commands/$jetbrains_command")"
  touch "$OMARCHY_TEST_JETBRAINS/commands/$jetbrains_command"
fi
SH
cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_JETBRAINS/terminal"
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_JETBRAINS/notification"
SH
cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$*"
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_JETBRAINS/launch.next"
mv "$OMARCHY_TEST_JETBRAINS/launch.next" "$OMARCHY_TEST_JETBRAINS/launch"
SH
cat >"$mock_bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_JETBRAINS/launch"
SH
chmod +x "$mock_bin"/*

editor_file="$HOME/.local/state/omarchy/defaults/editor"
mkdir -p "$(dirname "$editor_file")"
source "$ROOT/default/jetbrains/products.sh"

wait_for_launch() {
  local attempt
  for (( attempt = 0; attempt < 100; attempt++ )); do
    [[ -s $test_tmp/launch ]] && return 0
    sleep 0.01
  done
  fail "installer launches the installed desktop entry"
}

editors=(air clion datagrip goland intellij-idea phpstorm pycharm rider rubymine rustrover webstorm)
for product in "${editors[@]}"; do
  export OMARCHY_TEST_PRODUCT=$product
  jetbrains_product "$product"
  rm -rf "$test_tmp/commands" "$test_tmp/packages"
  mkdir -p "$test_tmp/commands" "$test_tmp/packages"
  rm -f "$test_tmp/launch" "$test_tmp/install" "$test_tmp/notification"
  printf 'nvim\n' >"$editor_file"

  omarchy-default-editor "$product"
  [[ $(<"$test_tmp/terminal") == "$(printf '%s\n' omarchy-default-editor --install "$product")" ]] ||
    fail "$product opens the normal floating-terminal default installer"
  [[ $(<"$editor_file") == "nvim" && ! -e $test_tmp/install && ! -e $test_tmp/notification ]] ||
    fail "$product waits for installation before changing the default"

  OMARCHY_TEST_INSTALL_FAIL=true omarchy-default-editor --install "$product" >"$test_tmp/output" 2>&1 &&
    fail "$product reports a failed installation"
  [[ $(<"$editor_file") == "nvim" && ! -e $test_tmp/notification && ! -e $test_tmp/launch ]] ||
    fail "$product preserves the previous default on installation failure"

  OMARCHY_TEST_NO_LAUNCHER=true omarchy-default-editor --install "$product" >"$test_tmp/output" 2>&1 &&
    fail "$product rejects an installation without its launcher"
  [[ $(<"$editor_file") == "nvim" && ! -e $test_tmp/notification && ! -e $test_tmp/launch ]] ||
    fail "$product preserves the previous default when the launcher is missing"

  omarchy-default-editor --install "$product" >"$test_tmp/output"
  wait_for_launch
  [[ $(omarchy-default-editor) == "$jetbrains_command" ]] || fail "$product persists its package launcher"
  grep -Fq "$jetbrains_name" "$test_tmp/notification" || fail "$product confirms its display name"
  mapfile -d '' -t launch <"$test_tmp/launch"
  [[ ${launch[*]} == "uwsm-app -- gtk-launch $jetbrains_desktop" ]] || fail "$product opens its package desktop entry"

  rm -f "$test_tmp/install" "$test_tmp/launch" "$test_tmp/terminal"
  omarchy-default-editor "$product"
  [[ ! -e $test_tmp/install && ! -e $test_tmp/launch && ! -e $test_tmp/terminal ]] ||
    fail "$product selects an installed editor without installing or opening a window"

  # GUI --inline keeps the same launch behavior. Only path arguments change:
  # JetBrains does not accept the end-of-options delimiter used by other IDEs.
  for mode in normal inline; do
    args=()
    [[ $mode == "inline" ]] && args+=(--inline)
    omarchy-launch-editor "${args[@]}" "folder with spaces" --wait '/absolute/path with spaces' >"$test_tmp/output"
    mapfile -d '' -t launch <"$test_tmp/launch"
    [[ ${#launch[@]} == 6 && ${launch[0]} == "uwsm-app" && ${launch[1]} == "--" &&
      ${launch[2]} == "$jetbrains_command" && ${launch[3]} == "$PWD/folder with spaces" &&
      ${launch[4]} == "$PWD/--wait" && ${launch[5]} == "/absolute/path with spaces" ]] ||
      fail "$product preserves spaces and treats option-shaped filenames as paths ($mode)"
  done
done
pass "all eleven JetBrains defaults handle installation, failure, selection, and path launching"

# A partially installed package must not be considered a ready default.
export OMARCHY_TEST_PRODUCT=webstorm
rm -rf "$test_tmp/commands" "$test_tmp/packages"
mkdir -p "$test_tmp/commands" "$test_tmp/packages"
touch "$test_tmp/commands/webstorm" "$test_tmp/packages/webstorm"
rm -f "$test_tmp/launch"
printf 'nvim\n' >"$editor_file"
omarchy-default-editor webstorm
[[ $(<"$editor_file") == "nvim" ]] || fail "missing JBR opens the installer instead of selecting a broken IDE"
omarchy-default-editor --install webstorm >"$test_tmp/output"
wait_for_launch
[[ $(<"$test_tmp/install") == $'webstorm\nwebstorm-jre' ]] || fail "WebStorm installs its bundled JBR"
pass "an IDE missing its runtime is repaired before becoming the default"

# External launchers continue to work without requiring a duplicate AUR install.
rm -f "$test_tmp/packages/webstorm" "$test_tmp/packages/webstorm-jre" "$test_tmp/install"
omarchy-default-editor webstorm
[[ $(omarchy-default-editor) == "webstorm" && ! -e $test_tmp/install ]] || fail "an existing external IDE launcher can be selected"
pass "existing external editor launchers remain selectable"

# A Go `air` on PATH must not satisfy the JetBrains Air launcher check.
rm -rf "$test_tmp/commands"
mkdir -p "$test_tmp/commands"
touch "$test_tmp/commands/air"
printf 'nvim\n' >"$editor_file"
omarchy-default-editor air
[[ $(<"$editor_file") == "nvim" ]] || fail "Go Air is not mistaken for JetBrains Air"
pass "Air selection does not accept the unrelated Go executable"

# Install-only never writes the selected default, including non-editor tools.
for product in "${editors[@]}" toolbox gateway mps; do
  export OMARCHY_TEST_PRODUCT=$product
  printf 'nvim\n' >"$editor_file"
  rm -f "$test_tmp/launch"
  omarchy-install-jetbrains "$product" >"$test_tmp/output"
  wait_for_launch
  [[ $(<"$editor_file") == "nvim" ]] || fail "$product install-only leaves the default unchanged"
  jetbrains_product "$product"
  printf '%s\t%s\t%s\n' "$product" "$jetbrains_command" "${jetbrains_packages[*]}" >>"$test_tmp/catalog"
done
for product in toolbox gateway mps unknown --help; do
  omarchy-default-editor "$product" >"$test_tmp/output" 2>&1 && fail "$product is not a default editor"
  [[ $(<"$editor_file") == "nvim" ]] || fail "$product rejection preserves the current default"
done
for product in unknown --help; do
  rm -f "$test_tmp/install" "$test_tmp/launch"
  omarchy-install-jetbrains "$product" >"$test_tmp/output" 2>&1 && fail "$product is not an installable product"
  [[ ! -e $test_tmp/install && ! -e $test_tmp/launch ]] || fail "$product rejection has no side effects"
done
pass "all fourteen products install without changing defaults; tools and invalid IDs cannot become defaults"

OMARCHY_PATH="$test_tmp/missing" omarchy-default-editor >"$test_tmp/output"
[[ $(<"$test_tmp/output") == "nvim" ]] || fail "reading the default does not load the product catalog"
pass "default reads keep the existing fast path"

printf 'pycharm\n' >"$editor_file"
rm -f "$test_tmp/commands/pycharm"
omarchy-launch-editor "folder with spaces"
mapfile -d '' -t launch <"$test_tmp/launch"
[[ ${launch[*]} == "nvim -- folder with spaces" ]] || fail "removing the selected IDE preserves the Neovim fallback"
pass "uninstalled default editors still fall back to Neovim"

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = model.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const editors = ['air', 'clion', 'datagrip', 'goland', 'intellij-idea', 'phpstorm', 'pycharm', 'rider', 'rubymine', 'rustrover', 'webstorm']
const children = parent => items.filter(item => item.parent === parent)
const install = children('install.editor.jetbrains')
const defaults = children('setup.default.editor.jetbrains')
const catalog = Object.fromEntries(fs.readFileSync(path.join(process.env.OMARCHY_TEST_JETBRAINS, 'catalog'), 'utf8').trim().split('\n').map(line => {
  const [id, command, packages] = line.split('\t')
  return [id, { command, packages }]
}))
assertDeepEqual(install.map(item => item.id.split('.').pop()), editors, 'Install lists every eligible IDE in alphabetical order')
assertDeepEqual(defaults.map(item => item.label), install.map(item => item.label), 'Defaults lists the same IDEs in the same order')
for (let i = 0; i < editors.length; i++) {
  assertEqual(install[i].action, `omarchy-launch-floating-terminal-with-presentation omarchy-install-jetbrains ${editors[i]}`, `${editors[i]} uses a visible installer`)
  assertEqual(defaults[i].action, `omarchy-default-editor ${editors[i]}`, `${editors[i]} uses the standard defaults flow`)
  assert(!defaults[i].when && !defaults[i].disabled, `${editors[i]} remains selectable in Defaults when missing`)
  assert(install[i].disabled.startsWith('omarchy-pkg-present '), `${editors[i]} uses the cached package guard`)
  assert(!install[i].when, `${editors[i]} stays visible after installation`)
  assert(!defaults[i].aliases.length && !install[i].aliases.length, `${editors[i]} adds no new menu aliases`)
  assert(model.matchesQuery(install[i], `jetbrains ${install[i].label}`, true), `${editors[i]} is searchable by brand and product`)
  assert(model.matchesQuery(defaults[i], `default ${defaults[i].label}`, true), `${editors[i]} exposes the default action in search`)
  assertEqual(install[i].disabled, `omarchy-pkg-present ${catalog[editors[i]].packages}`, `${editors[i]} checks every package its installer needs`)
  assert(defaults[i].checked.includes(`== "${catalog[editors[i]].command}"`), `${editors[i]} checks the executable saved by Defaults`)
}
assertEqual(install[0].disabled, 'omarchy-pkg-present jetbrains-air jetbrains-air-jre', 'Air installed status includes JBR')
assertEqual(install[1].disabled, 'omarchy-pkg-present clion clion-jre clion-cmake clion-gdb clion-lldb', 'CLion installed status includes its runtime and bundled build/debug tools')
assertEqual(install[4].disabled, 'omarchy-pkg-present intellij-idea-ultimate-edition', 'IntelliJ uses the package that now includes JBR')
assert(defaults[8].checked.includes('jetbrains-rubymine'), 'RubyMine checks its actual AUR command name')
for (const tool of ['toolbox', 'gateway', 'mps'])
  assert(items.some(item => item.id === `install.development.jetbrains-${tool}`), `${tool} is a separate Development install`)
JS
