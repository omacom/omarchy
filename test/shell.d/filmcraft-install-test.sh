#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
events="$test_tmp/events"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
echo "aur-add $*" >>"$OMARCHY_TEST_EVENTS"
[[ ${OMARCHY_TEST_AUR_FAIL:-0} != "1" ]]
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
echo "launch $*" >>"$OMARCHY_TEST_EVENTS"
SH
chmod +x "$mock_bin"/*

run_installer() {
  : >"$events"
  OMARCHY_TEST_EVENTS="$events" PATH="$mock_bin:/usr/bin:/bin" "$ROOT/bin/omarchy-install-filmcraft" >/dev/null 2>&1
}

# The launch is backgrounded, so it can land just after the installer exits
wait_for_launch() {
  for _ in {1..50}; do
    grep -q '^launch' "$events" && return 0
    sleep 0.1
  done
  return 1
}

run_installer || fail "installing FilmCraft succeeds"
wait_for_launch || fail "FilmCraft is opened after installing" "$(<"$events")"
[[ $(<"$events") == $'aur-add filmcraft-bin\nlaunch uwsm-app -- gtk-launch ai.storyteller.filmcraft' ]] ||
  fail "FilmCraft is installed from filmcraft-bin, then opened by its desktop id" "$(<"$events")"
pass "FilmCraft is installed from the AUR and opened"

OMARCHY_TEST_AUR_FAIL=1 run_installer && fail "a failed AUR install fails the installer"
grep -q '^launch' "$events" && fail "a failed AUR install opens nothing" "$(<"$events")"
pass "a failed AUR install opens nothing"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const row = items.find((item) => item.id === 'install.video.filmcraft')
const english = JSON.parse(fs.readFileSync(path.join(root, 'default/i18n/en/menu.json'), 'utf8'))

assertEqual(row && row.parent, 'install.video', 'FilmCraft sits under Install > Video')
assertEqual(row.action, 'omarchy-launch-floating-terminal-with-presentation omarchy-install-filmcraft', 'the row runs the installer')
assertEqual(english['install.video.filmcraft'].label, 'FilmCraft', 'the row has an English label')
JS
