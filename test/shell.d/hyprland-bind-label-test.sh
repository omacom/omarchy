#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/hyprctl" <<'FAKE'
#!/bin/bash
cat <<'PLAIN'
bindd
	modmask: 72
	submap: 
	key: SPACE
	keycode: 0
	catchall: false
	description: Apps
	dispatcher: __lua
	arg: 1

bindd
	modmask: 64
	submap: 
	key: SUPER + K
	keycode: 0
	catchall: false
	description: Omarchy menu
	dispatcher: __lua
	arg: 2

bindd
	modmask: 69
	submap: 
	key: SUPER + CTRL + SHIFT + T
	keycode: 0
	catchall: false
	description: Theme menu
	dispatcher: __lua
	arg: 3

bindd
	modmask: 64
	submap: 
	key: 
	keycode: 20
	catchall: false
	description: Minus
	dispatcher: __lua
	arg: 4

bindld
	modmask: 0
	submap: 
	key: XF86AudioMute
	keycode: 0
	catchall: false
	description: Mute
	dispatcher: __lua
	arg: 5

bindmd
	modmask: 64
	submap: 
	key: mouse:272
	keycode: 0
	catchall: false
	description: Move window
	dispatcher: __lua
	arg: 6

bindd
	modmask: 0
	submap: resize
	key: H
	keycode: 0
	catchall: false
	description: Shrink
	dispatcher: __lua
	arg: 7
PLAIN
FAKE
chmod +x "$tmpdir/bin/hyprctl"

bind_label() {
  PATH="$tmpdir/bin:$PATH" "$ROOT/bin/omarchy-hyprland-bind-label" "$@"
}

[[ $(bind_label Apps) == "SUPER ALT + SPACE" ]] || fail "the label names the keys bound to Apps" "$(bind_label Apps)"
[[ $(bind_label "Omarchy menu") == "SUPER + K" ]] || fail "a key that already carries its modifiers is not prefixed twice" "$(bind_label "Omarchy menu")"
[[ $(bind_label "Theme menu") == "SUPER CTRL SHIFT + T" ]] || fail "modifiers are named in order" "$(bind_label "Theme menu")"
[[ $(bind_label Minus) == "SUPER + code:20" ]] || fail "a keycode binding is named by its code" "$(bind_label Minus)"
[[ $(bind_label Mute) == "XF86AudioMute" ]] || fail "a binding without modifiers is just its key"
pass "bind label reports the key combination Hyprland has bound"

if bind_label "Move window" >/dev/null; then fail "mouse bindings are not reported"; fi
if bind_label Shrink >/dev/null; then fail "bindings inside a submap are not reported"; fi
if bind_label "No such binding" >/dev/null; then fail "an unknown description exits 1"; fi
pass "bind label exits 1 when nothing matches"

if bind_label >/dev/null 2>&1; then fail "a missing description is an error"; fi
pass "bind label requires a description"
