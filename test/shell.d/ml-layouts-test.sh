#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_STATE_HOME="$test_tmp/state"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_STATE_HOME"

clients="$test_tmp/clients.json"
cat > "$clients" <<'EOF'
[
  {"class": "Alacritty", "workspace": {"id": 3}, "address": "0x1"},
  {"class": "firefox", "workspace": {"id": 3}, "address": "0x2"}
]
EOF
OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" layout save writing >/dev/null
listed=$(OMARCHY_ML_CLIENTS="$clients" "$ROOT/bin/omarchy-ml-workspace" layout list)
[[ $listed == $'writing\t3\tAlacritty,firefox' ]] || fail "a named layout remembers the windows" "$listed"

"$ROOT/bin/omarchy-ml-workspace" layout apps writing Alacritty code >/dev/null
restore=$("$ROOT/bin/omarchy-ml-workspace" layout restore writing --print)
grep -Fq "workspace 3" <<<"$restore" || fail "a saved layout opens its workspace" "$restore"
grep -Fq "omarchy-launch-or-focus code code" <<<"$restore" || fail "editing a layout changes its apps" "$restore"
if grep -Fq "firefox" <<<"$restore"; then
  fail "editing a layout drops the apps you removed" "$restore"
fi
grep -Fq '"trigger.ml.layout"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the menu can open a saved layout"
pass "workspace layouts can be named and edited"
