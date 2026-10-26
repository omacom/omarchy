#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A platform package names keys the way its keyboards print them. On a MacBook
# XF86MonBrightnessUp/Down are the F2/F1 keys, so without the names the menu
# shows rows like "SHIFT + XF86MonBrightnessUp". A cache written before the
# names were installed must not win over them.

mock_bin=$(mktemp -d)
cache_dir=$(mktemp -d)
platform=$(mktemp -d)
cleanup() {
  rm -rf "$mock_bin" "$cache_dir" "$platform"
}
trap cleanup EXIT

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "devices" ]]; then
  echo "Keyboards:"
  echo "	active keymap: Apple Keyboard (apple_vndr)"
  exit 0
fi
cat <<'BINDS'
bindl
	modmask: 1
	key: XF86MonBrightnessUp
	keycode: 0
	description: Keyboard brightness up
	dispatcher: exec
	arg: omarchy-brightness-keyboard up

bindl
	modmask: 1
	key: XF86MonBrightnessDown
	keycode: 0
	description: Keyboard brightness down
	dispatcher: exec
	arg: omarchy-brightness-keyboard down

bindi
	modmask: 8
	key: XF86MonBrightnessUp
	keycode: 0
	description: Brightness up precise
	dispatcher: exec
	arg: omarchy-brightness-display +1%

bind
	modmask: 64
	key: F5
	keycode: 0
	description: Press brightness up
	dispatcher: exec
	arg: wtype -k XF86MonBrightnessUp

bindm
	modmask: 64
	key: Q
	keycode: 0
	description: Close window
	dispatcher: killactive
	arg:
BINDS
SH
chmod +x "$mock_bin/hyprctl"

# Minimal valid keymap so keycode resolution has something to chew on.
cat >"$mock_bin/xkbcli" <<'SH'
#!/bin/bash
cat <<'KEYMAP'
xkb_keycodes {
    <AD01> = 24;
};
xkb_symbols {
    key <AD01> { [ q ] };
};
KEYMAP
SH
chmod +x "$mock_bin/xkbcli"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin/omarchy-cmd-present"

# The menu reads key names from the fixed platform root; copies of it read a
# fixture root with key names, and one without.
mkdir -p "$platform/root" "$platform/bin"
printf '%s\n' 'XF86MonBrightnessUp F2' 'XF86MonBrightnessDown F1' 'not a line' 'Bad-Sym F3' >"$platform/root/key-names"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$platform/bin/with-names" "$platform/root"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$platform/bin/without-names" "$platform/none"

# Pre-seed the exact cache file that v13, which knew no key names, would read
# for these mocked inputs. Cached records use the rendered row as field 1, followed by
# the dispatcher and argument fields.
mkdir -p "$cache_dir/omarchy"
v13_key=$({
  printf 'v13\n'
  "$mock_bin/hyprctl" devices 2>/dev/null | grep -F 'active keymap:'
  "$mock_bin/hyprctl" binds 2>/dev/null
} | sha256sum | awk '{ print $1 }')
cat >"$cache_dir/omarchy/keybindings-$v13_key.records" <<'EOF'
SHIFT + XF86MonBrightnessUp → Keyboard brightness up	exec	omarchy-brightness-keyboard up
SHIFT + XF86MonBrightnessDown → Keyboard brightness down	exec	omarchy-brightness-keyboard down
ALT + XF86MonBrightnessUp → Brightness up precise	exec	omarchy-brightness-display +1%
SUPER + Q → Close window	killactive
EOF

output=$(PATH="$mock_bin:$PATH" XDG_CACHE_HOME="$cache_dir" "$platform/bin/with-names" --print)

tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F2 → Keyboard brightness up' || \
  fail "SHIFT + XF86MonBrightnessUp renders as SHIFT + F2 with its description" "$output"

tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F1 → Keyboard brightness down' || \
  fail "SHIFT + XF86MonBrightnessDown renders as SHIFT + F1 with its description" "$output"

tr -s ' ' <<<"$output" | grep -qF 'ALT + F2 → Brightness up precise' || \
  fail "modifier combos keep the F-key name (ALT + F2)" "$output"

grep -qF 'XF86MonBrightness' <<<"$output" && \
  fail "raw XF86MonBrightness symbols no longer leak into the menu" "$output"

tr -s ' ' <<<"$output" | grep -qF 'SUPER + Q → Close window' || \
  fail "unrelated bindings render unchanged (SUPER + Q)" "$output"

# The menu runs a chosen row from its cached record, which carries what the
# binding runs.
records=$(cat "$cache_dir"/omarchy/keybindings-*.records)
grep -qF 'wtype -k XF86MonBrightnessUp' <<<"$records" && ! grep -qF 'wtype -k F2' <<<"$records" ||
  fail "a key name never changes what a binding runs" "$records"

pass "keybindings menu shows a platform's key names (F1/F2), stale caches ignored"

# A key-names file saved with CRLF line ends, or with blanks around a line,
# reads the same, as displays.conf does.
mkdir -p "$platform/crlf"
printf '%s\r\n' 'XF86MonBrightnessUp F2' '  XF86MonBrightnessDown	F1 ' >"$platform/crlf/key-names"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$platform/bin/crlf-names" "$platform/crlf"
output=$(PATH="$mock_bin:$PATH" XDG_CACHE_HOME="$cache_dir" "$platform/bin/crlf-names" --print)
tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F2 → Keyboard brightness up' && tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F1 → Keyboard brightness down' ||
  fail "key names saved with CRLF line ends and blanks around them still apply" "$output"
pass "keybindings menu reads key names saved with CRLF line ends"

# Without a platform package the keys keep their own names, and a cache made
# with the names is not reused.
output=$(PATH="$mock_bin:$PATH" XDG_CACHE_HOME="$cache_dir" "$platform/bin/without-names" --print)
tr -s ' ' <<<"$output" | grep -qF 'SHIFT + XF86MonBrightnessUp → Keyboard brightness up' ||
  fail "without key names the brightness key keeps its own name" "$output"
grep -qF 'SHIFT + F2' <<<"$output" && fail "without key names nothing is renamed F2" "$output"
pass "keybindings menu keeps keysym names without a platform package"
