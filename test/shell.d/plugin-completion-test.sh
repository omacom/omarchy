#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$ROOT/default/bash/completions"

test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT
export HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"
mkdir -p "$HOME/.config/omarchy/plugins/weather"
printf '%s\n' '{"id":"acme.weather"}' >"$HOME/.config/omarchy/plugins/weather/manifest.json"

# compopt requires an actual readline completion; record its option here.
compopt() {
  completion_options="$*"
}

for action in enable disable; do
  COMP_WORDS=(omarchy plugin "$action" "")
  COMP_CWORD=3
  completion_options=""
  _omarchy_complete
  [[ " ${COMPREPLY[*]} " == *" omarchy.clock "* ]] || fail "$action completes stock plugins"
  [[ " ${COMPREPLY[*]} " == *" acme.weather "* ]] || fail "$action completes user plugins"
  [[ $completion_options == "+o default" ]] || fail "$action disables filename fallback"

  COMP_WORDS[3]="acme.w"
  _omarchy_complete
  [[ ${COMPREPLY[*]} == "acme.weather" ]] || fail "$action filters plugin prefixes"

  COMP_WORDS[3]="nonexistent"
  _omarchy_complete
  (( ${#COMPREPLY[@]} == 0 )) || fail "$action has no matches for unknown plugins"
  pass "$action completes plugin IDs without filename fallback"
done

COMP_WORDS=(omarchy plugin "")
COMP_CWORD=2
completion_options=""
_omarchy_complete
[[ " ${COMPREPLY[*]} " == *" enable "* ]] || fail "plugin subcommands still complete"
[[ -z $completion_options ]] || fail "other completion keeps its default options"
pass "plugin subcommand completion is unchanged"
