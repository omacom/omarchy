#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

leaf="$ROOT/install/user/keep-inputs-ready.sh"
conf="$ROOT/default/wireplumber/wireplumber.conf.d/keep-inputs-ready.conf"
script="$ROOT/default/wireplumber/scripts/omarchy/suspend-node.lua"

grep -q 'run_logged "$OMARCHY_INSTALL/user/keep-inputs-ready.sh"' "$ROOT/install/user/all.sh" ||
  fail "user setup installs the keep-inputs-ready hook"
grep -rq 'install/user/keep-inputs-ready.sh' "$ROOT/migrations" ||
  fail "a migration installs the keep-inputs-ready hook on existing installs"

grep -q 'name = omarchy/suspend-node.lua' "$conf" || fail "config loads the Omarchy suspend hook"
grep -q 'hooks.node.suspend = disabled' "$conf" || fail "config replaces the stock suspend hook"
grep -q 'hooks.node.suspend.omarchy = optional' "$conf" ||
  fail "a missing hook script cannot stop WirePlumber from starting"

if command -v luac >/dev/null; then
  luac -p "$script" || fail "suspend hook is valid Lua"
fi
grep -q '"session.keep-inputs-ready", "=", "true"' "$script" || fail "hook honors the client property"
grep -q '"device.api", "=", "alsa"' "$script" || fail "hook keeps only ALSA sources ready, not Bluetooth"

HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" bash -euo pipefail -c 'source "$1"; source "$1"' _ "$leaf"
[[ $(readlink "$test_tmp/home/.local/share/wireplumber/scripts/omarchy") == "$ROOT/default/wireplumber/scripts/omarchy" ]] ||
  fail "hook script directory is linked into WirePlumber's user script path"
cmp -s "$conf" "$test_tmp/home/.config/wireplumber/wireplumber.conf.d/keep-inputs-ready.conf" ||
  fail "hook config is installed for the user"

pass "keep-inputs-ready WirePlumber hook is installed and replaces the stock suspend hook"
