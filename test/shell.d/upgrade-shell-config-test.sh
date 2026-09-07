#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
upgrade="$ROOT/bin/omarchy-upgrade-to-quattro"

eval "$(awk '/^copy_missing_config_defaults\(\) \{/ { copying=1 } copying { print } copying && /^\}$/ { exit }' "$upgrade")"
is_retired_config_file() { return 1; }
apply_user_transition() { copy_missing_config_defaults "$test_tmp/defaults" "$target_home/.config"; }
apply_user_hardware_transition() { :; }
run_as_user_omarchy() {
  if [[ $1 == "omarchy-bar" ]]; then
    bar_reset=1
  fi
}
warn() { fail "$*"; }
transition=$(awk '/^preserve_shell_config=0$/ { copying=1 } /^cleanup_retired_services$/ { exit } copying { print }' "$upgrade")
[[ -n $transition ]] || fail "user transition is found"
always_copy=$(awk '/^always_copy_config_files=\(/ { copying=1 } copying { print } copying && /^\)$/ { exit }' "$upgrade")
[[ $always_copy != *omarchy/shell.json* ]] || fail "shell settings are not forcibly replaced"

mkdir -p "$test_tmp/defaults/omarchy"
printf '%s\n' '{"bar":{"layout":[]}}' > "$test_tmp/defaults/omarchy/shell.json"
for scenario in fresh custom invalid symlink dangling; do
  target_home="$test_tmp/$scenario"
  mkdir -p "$target_home/.config/omarchy"
  settings="$target_home/.config/omarchy/shell.json"
  case "$scenario" in
  custom) printf '%s\n' '{"plugins":["local.example"],"idle":{"lock":600},"bar":{"transparent":true}}' > "$settings" ;;
  invalid) printf '%s\n' 'unfinished user edit' > "$settings" ;;
  symlink)
    cp "$test_tmp/defaults/omarchy/shell.json" "$target_home/settings.json"
    ln -s "$target_home/settings.json" "$settings"
    ;;
  dangling) ln -s "$target_home/missing.json" "$settings" ;;
  esac
  before=$(readlink "$settings" || { [[ ! -f $settings ]] || sha256sum "$settings"; })
  bar_reset=0
  eval "$transition"
  if [[ $scenario == "fresh" ]]; then
    cmp "$settings" "$test_tmp/defaults/omarchy/shell.json"
    (( bar_reset == 1 )) || fail "fresh upgrades initialize the bar"
  else
    after=$(readlink "$settings" || sha256sum "$settings")
    [[ $before == "$after" ]] || fail "$scenario settings survive the upgrade"
    (( bar_reset == 0 )) || fail "$scenario settings avoid the bar reset"
  fi
  pass "$scenario shell configuration handled without overwriting user settings"
done
