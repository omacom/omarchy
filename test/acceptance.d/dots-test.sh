#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
terminal_address=""
cleanup() {
  omarchy-menu close >/dev/null 2>&1 || true
  if [[ -n $terminal_address ]]; then
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$terminal_address\" })" >/dev/null 2>&1 || true
  fi
  rm -rf "$fixture"
}
trap cleanup EXIT

omarchy-menu summon system.dots
wait_until 'preferences menu shows sharing actions' 15 screen_contains 'Publish Settings'
screenshot success-preferences-menu
omarchy-menu close

for host in a b; do
  mkdir -p "$fixture/$host"
  printf 'color=blue\n' > "$fixture/$host/.bashrc"
done
git init --bare --quiet "$fixture/remote.git"
dots() {
  local home="$fixture/$1"
  shift
  HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" omarchy-dots "$@"
}
for host in a b; do dots "$host" setup --repo "$fixture/remote.git"; done
dots a push --yes
dots b pull --yes
printf 'color=red\n' > "$fixture/a/.bashrc"
printf 'color=green\n' > "$fixture/b/.bashrc"
dots a push --yes
dots b pull --yes

before=$(hyprctl -j clients | jq -r '.[].address')
printf -v command '%q ' env "HOME=$fixture/b" "XDG_CONFIG_HOME=$fixture/b/.config" \
  "XDG_DATA_HOME=$fixture/b/.local/share" "XDG_STATE_HOME=$fixture/b/.local/state" \
  omarchy-dots resolve
omarchy-launch-floating-terminal-with-presentation "$command" &
new_terminal() {
  terminal_address=$(hyprctl -j clients | jq -r --arg before "$before" '.[] | select(.address as $a | $before | split("\n") | index($a) | not) | .address' | head -1)
  [[ -n $terminal_address ]]
}
wait_until 'presentation terminal opens' 20 new_terminal
wait_until 'conflict picker is visible' 20 screen_contains 'Resolve which preference'
screenshot success-preferences-conflict-file
wtype -k Return
wait_until 'conflict versions are visible' 15 screen_contains 'Shared version'
screenshot success-preferences-conflict-choice
wtype -k Down -k Return
wait_until 'resolution is saved' 15 screen_contains 'Resolution saved'
screenshot success-preferences-conflict-resolved
dots b continue
[[ $(cat "$fixture/b/.bashrc") == 'color=red' ]] || fail 'choosing the shared version applies it'
pass 'preferences conflict picker resolves a real two-machine Git conflict'
