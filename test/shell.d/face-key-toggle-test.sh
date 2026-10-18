#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

toggle="$ROOT/default/hypr/toggles/face-key.lua"
key="$ROOT/bin/omarchy-face-key"
setup="$ROOT/bin/omarchy-setup-security-face"
remove="$ROOT/bin/omarchy-remove-security-face"

# The Copilot key sends Super+Shift+F23. Root watches evdev's F23; Hyprland
# names the same key by its xkb code, evdev's plus 8.
evdev=$(sed -n 's/^KEY_F23 = \([0-9]*\)$/\1/p' "$key")
[[ $evdev == 193 ]] || fail "the key service watches F23" "$evdev"
grep -qxF 'o.rebind("SUPER + SHIFT + code:201", "Confirm with your face", { ipc = "polkit.faceKey" })' "$toggle" ||
  fail "the toggle rebinds the Copilot key to the polkit dialog's IPC call, the way upstream's bindings name the shell"
(( evdev + 8 == 201 )) || fail "Hyprland binds the key root watches"
utilities="$ROOT/default/hypr/bindings/utilities.lua"
if [[ -f $utilities ]]; then
  grep -q '"SUPER + SHIFT + code:201", "Omarchy menu"' "$utilities" || fail "upstream's Copilot binding is the one the toggle replaces"
fi
pass "the toggle takes the key root watches from the Omarchy menu and hands it to the polkit dialog"

grep -qx '  omarchy-hyprland-toggle face-key on' "$setup" || fail "the setup turns the toggle on"
grep -qx '    omarchy-hyprland-toggle face-key off' "$remove" || fail "the removal turns it off again"
pass "the face setup takes the key and the removal gives it back"

if command -v luac >/dev/null; then
  luac -p "$toggle" || fail "the toggle parses as Lua"
  pass "the toggle parses"
else
  skip "luac is not installed; Lua syntax not checked"
fi
