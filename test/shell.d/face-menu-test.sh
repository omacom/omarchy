#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

# The menu parser strips whole-line comments and trailing commas; mirror that
# so the face rows are checked as the shell would read them.
entries=$(grep -v '^[[:space:]]*//' "$menu" | sed -E ':a;N;$!ba;s/,([[:space:]]*[]}])/\1/g')
jq -e 'type == "object"' <<<"$entries" >/dev/null || fail "the menu parses as JSONC" "$entries"
pass "the menu parses as JSONC"

for id in setup.security.face remove.security.face; do
  entry=$(jq -ec --arg id "$id" '.[$id]' <<<"$entries") || fail "the menu defines $id"
  [[ $(jq -r .label <<<"$entry") == "Face" ]] || fail "$id is labelled Face"
  [[ -n $(jq -r .icon <<<"$entry") ]] || fail "$id has an icon"
  action=$(jq -r .action <<<"$entry")
  [[ $action == "omarchy-launch-floating-terminal-with-presentation omarchy-"* ]] ||
    fail "$id opens its wizard in a floating terminal" "$action"
  [[ -x $ROOT/bin/${action##* } ]] || fail "$id runs a command the checkout ships" "$action"
  pass "$id runs ${action##* } in a floating terminal"
done

[[ $(jq -r '."setup.security.face".when' <<<"$entries") == "omarchy-hw-dell-xps-ir-camera" ]] ||
  fail "the setup row is guarded by the hardware predicate"
# The setup installs the driver first and stops for a reboot, so the removal
# is offered from then on, before Howdy is there.
[[ $(jq -r '."remove.security.face".when' <<<"$entries") == "omarchy-pkg-present howdy || omarchy-pkg-present hm1092-ir-camera" ]] ||
  fail "the remove row is guarded by Howdy or the driver the setup installed"
pass "the rows show only where they apply"

jq -e '[."setup.security.face", ."remove.security.face"] | all(has("aliases") | not)' <<<"$entries" >/dev/null ||
  fail "the face rows declare no aliases"
pass "the face rows declare no aliases"
