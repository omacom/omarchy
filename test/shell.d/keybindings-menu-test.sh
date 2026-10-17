#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command xkbcli

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to stub Hyprland in"
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home/.config" "$stub_bin"
cp -r "$ROOT/config/hypr" "$home/.config/hypr"

# No platform package: neither its key names nor its binds.
menu="$tmpdir/omarchy-menu-keybindings"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$menu" "$tmpdir/no-platform"

# The menu reads binds from Hyprland, which is not running here, so stand in for
# it. A Lua bind reports dispatcher __lua and no arg, and the menu recovers both
# from the Lua source; an exec bind carries its own command. Both shapes matter:
# what two chords dispatch is what decides whether they share a row.
lua_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: \n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: __lua\n\targ: \n' "$1" "$2" "$3"
}

exec_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: \n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: exec\n\targ: %s\n' "$1" "$2" "$3" "$4"
}

stub_hyprctl() {
  {
    echo '#!/bin/bash'
    echo 'case "$1" in'
    echo '  binds) cat <<'"'"'BINDS'"'"''
    cat
    echo 'BINDS'
    echo '  ;;'
    cat <<'DEVICES'
  devices) cat "$(dirname "$0")/keyboards" 2>/dev/null ||
    echo '{"keyboards":[{"name":"test","main":true,"layout":"us","active_layout_index":0}]}' ;;
DEVICES
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$menu" --print
}

# Closing a window and toggling the scratchpad are two of the actions Omarchy
# binds twice on purpose. The last bind carries the longest description Omarchy
# ships, which is what puts a row closest to the width the menu allows.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "SUPER + F" "Full screen")
$(lua_bind 64 "SUPER + I" "Switch input language")
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle scratchpad")
$(exec_bind 73 "SUPER SHIFT ALT + 0" "Move window silently to workspace 10" "true")
BINDS

rendered=$(keybindings)
[[ -n $rendered ]] || fail "the keybindings menu renders with a stubbed Hyprland"

grep -q 'SUPER + F  *→ Full screen' <<<"$rendered" ||
  fail "a chord with no alternative renders on its own" "$rendered"
pass "the keybindings menu renders its entries"
grep -q 'SUPER + I  *→ Switch input language' <<<"$rendered" ||
  fail "the input switch shortcut appears in the cheatsheet" "$rendered"
pass "the input switch shortcut appears in the cheatsheet"

# The menu's own scan of the config runs lua -E, so no LUA_INIT or LUA_PATH from
# the environment reaches it and nothing there can move the platform root.
printf "io.open('%s', 'w'):close()\n" "$tmpdir/init-ran" >"$tmpdir/init.lua"
LUA_INIT="@$tmpdir/init.lua" lua -e '' && [[ -e $tmpdir/init-ran ]] || fail "the LUA_INIT probe runs in a plain lua"
rm -f "$tmpdir/init-ran"
env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" XDG_CACHE_HOME="$tmpdir/cache-init" OMARCHY_PATH="$ROOT" \
  LUA_INIT="@$tmpdir/init.lua" LUA_INIT_5_5="@$tmpdir/init.lua" LUA_INIT_5_4="@$tmpdir/init.lua" LUA_PATH="$tmpdir/?.lua" \
  bash "$ROOT/bin/omarchy-menu-keybindings" --print >/dev/null
[[ ! -e $tmpdir/init-ran ]] || fail "the menu's config scan ignores LUA_INIT from the environment"
pass "the menu's config scan ignores LUA_INIT and LUA_PATH from the environment"

(( $(grep -c '→ Close window$' <<<"$rendered") == 1 )) ||
  fail "an alternative chord joins the row of the first one" "$rendered"
grep -q 'SUPER + W / SUPER + Q  *→ Close window' <<<"$rendered" ||
  fail "a shared row names both chords" "$rendered"
pass "an alternative chord joins the row of the first one"

# Which chord leads is the whole point of keeping Hyprland's order: SUPER + W is
# the documented default and SUPER + Q the alternative bound after it.
grep -q '^SUPER + W / SUPER + Q' <<<"$rendered" ||
  fail "the chord declared first leads a shared row" "$rendered"
pass "the chord declared first leads a shared row"

# Hyprland calls the key left of 1 "grave". Nobody reads their keyboard that way.
grep -q 'SUPER + S / SUPER + ~  *→ Toggle scratchpad' <<<"$rendered" ||
  fail "the grave key reads as the symbol printed on it" "$rendered"
! grep -q 'grave' <<<"$rendered" ||
  fail "no entry still says grave" "$rendered"
pass "the grave key reads as the symbol printed on it"

# Monospace menu: every arrow sits in one column, and nothing is allowed past
# it. A row that overruns pushes its own arrow out of line.
[[ $(awk -F '→' '{ print length($1) }' <<<"$rendered" | sort -u) == "36" ]] ||
  fail "every entry pads its chords to the same column" "$rendered"
pass "every entry pads its chords to the same column"

# The menu elides a row that outgrows its card: 754px of label, 78 monospace
# characters at the heading size. The longest entry Omarchy ships sits at 74, so
# a row has four characters of room and no more.
(( $(awk '{ print length($0) }' <<<"$rendered" | sort -rn | head -1) <= 78 )) ||
  fail "no entry outgrows the width the menu gives it" "$rendered"
pass "no entry outgrows the width the menu gives it"

# Priority ordering reads the row, and the chord sharing it must not reclassify
# the entry: XF86Calculator alone belongs in the tail the menu keeps for media
# keys, while the calculator itself sits in the body of the list.
stub_hyprctl <<BINDS
$(exec_bind 68 "SUPER CTRL + Q" "Calculator" "omacalc")
$(exec_bind 0 "XF86Calculator" "Calculator" "omacalc")
$(exec_bind 8 "ALT + TAB" "Reveal active window on top" "true")
BINDS

rendered=$(keybindings)
(( $(grep -n '→ Calculator$' <<<"$rendered" | cut -d: -f1) <
   $(grep -n '→ Reveal active window on top$' <<<"$rendered" | cut -d: -f1) )) ||
  fail "a shared chord does not change where its entry ranks" "$rendered"
pass "a shared chord does not change where its entry ranks"

# The same key written as a keycode arrives by the other road: Hyprland reports
# the code and the keymap resolves it, after the rename above has run.
stub_hyprctl <<'BINDS'
bind
	modmask: 64
	submap: 
	key: 
	keycode: 49
	catchall: false
	description: Toggle scratchpad
	dispatcher: exec
	arg: true
BINDS

rendered=$(keybindings)
grep -q 'SUPER + ~  *→ Toggle scratchpad' <<<"$rendered" ||
  fail "a keycode resolves to the symbol printed on the key too" "$rendered"
pass "a keycode resolves to the symbol printed on the key too"

# Resize sits on the two keys right of 0, named by the active layout rather
# than by US: on JIS they print - and ^, and Shift + - is =, not +.
echo '{"keyboards":[{"name":"test","main":true,"layout":"jp","active_layout_index":0}]}' >"$stub_bin/keyboards"
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + code:20" "Expand window left")
$(lua_bind 64 "SUPER + code:21" "Shrink window left")
BINDS

rendered=$(keybindings)
rm "$stub_bin/keyboards"
grep -q 'SUPER + MINUS  *→ Expand window left' <<<"$rendered" &&
  grep -q 'SUPER + ^  *→ Shrink window left' <<<"$rendered" ||
  fail "a keycode is named by what the active layout prints on it" "$rendered"
pass "a keycode is named by what the active layout prints on it"

# A keycode reads as the symbol the main keyboard's layout puts there, not US QWERTY's.
keycode_bind() {
  printf 'bind\n\tmodmask: 64\n\tsubmap: \n\tkey: \n\tkeycode: %s\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: exec\n\targ: true\n' "$1" "$2"
}

main_keyboard() {
  printf '{"keyboards":[{"name":"usb","main":false,"layout":"us","active_layout_index":0},{"name":"%s","main":true,"layout":"%s","variant":"%s","active_layout_index":%s}]}\n' "${4:-test}" "$1" "$2" "$3" >"$stub_bin/keyboards"
}

stub_hyprctl <<BINDS
$(keycode_bind 20 "Expand window left")
BINDS

main_keyboard be "" 0
rendered=$(keybindings)
grep -q 'SUPER + PARENRIGHT  *→ Expand window left' <<<"$rendered" ||
  fail "a keycode resolves through the main keyboard's layout" "$rendered"
pass "a keycode resolves through the main keyboard's layout"

echo '{"keyboards":[{"name":"test","main":false,"layout":"be","active_layout_index":0},{"name":"usb","main":false,"layout":"us","active_layout_index":0}]}' >"$stub_bin/keyboards"
rendered=$(keybindings)
grep -q 'SUPER + PARENRIGHT  *→ Expand window left' <<<"$rendered" ||
  fail "a keycode resolves through the first keyboard while none is main" "$rendered"
pass "a keycode resolves through the first keyboard while none is main"

main_keyboard us dvorak 0
rendered=$(keybindings)
grep -q 'SUPER + BRACKETLEFT  *→ Expand window left' <<<"$rendered" ||
  fail "a keycode resolves through the main keyboard's variant" "$rendered"
pass "a keycode resolves through the main keyboard's variant"

# Physical keys follow the active device layout; symbolic binds keep their names.
stub_hyprctl <<BINDS
$(keycode_bind 20 "Expand window left")
$(exec_bind 64 "SUPER + minus" "Symbolic minus" "true")
BINDS

main_keyboard us,de "" 1
rendered=$(keybindings)
grep -q 'SUPER + SSHARP  *→ Expand window left' <<<"$rendered" &&
  grep -q 'SUPER + MINUS  *→ Symbolic minus' <<<"$rendered" ||
  fail "physical minus follows German while symbolic minus keeps its name" "$rendered"
pass "physical minus follows German while symbolic minus keeps its name"

# Keep both devices and their rules unchanged, switching only which is main.
jq '.keyboards[0].main = true | .keyboards[1].main = false' "$stub_bin/keyboards" >"$tmpdir/next-keyboards"
mv "$tmpdir/next-keyboards" "$stub_bin/keyboards"
rendered=$(keybindings)
grep -q 'SUPER + MINUS  *→ Expand window left' <<<"$rendered" ||
  fail "switching the main keyboard refreshes cached physical key names" "$rendered"
pass "switching the main keyboard refreshes cached physical key names"

# With several layouts each key spans lines, one per group, and the active group counts.
stub_hyprctl <<BINDS
$(keycode_bind 34 "Make webcam overlay smaller")
BINDS

main_keyboard us,ru , 0
rendered=$(keybindings)
grep -q 'SUPER + BRACKETLEFT  *→ Make webcam overlay smaller' <<<"$rendered" ||
  fail "a keycode resolves through the first of several layouts while it is active" "$rendered"
pass "a keycode resolves through the first of several layouts while it is active"

main_keyboard us,ru , 1
rendered=$(keybindings)
grep -q 'SUPER + CYRILLIC_HA  *→ Make webcam overlay smaller' <<<"$rendered" ||
  fail "a keycode resolves through the second of several layouts once it is active" "$rendered"
pass "a keycode resolves through the second of several layouts once it is active"

# fcitx5 and wtype take main with a virtual keyboard that stays on the first layout.
echo '{"keyboards":[{"name":"test","main":false,"layout":"us,ru","variant":",","active_layout_index":1},{"name":"hl-virtual-keyboard-fcitx5","main":true,"layout":"us,ru","variant":",","active_layout_index":0}]}' >"$stub_bin/keyboards"
rendered=$(keybindings)
grep -q 'SUPER + CYRILLIC_HA  *→ Make webcam overlay smaller' <<<"$rendered" ||
  fail "a keycode resolves through the typed keyboard while a virtual one is main" "$rendered"
pass "a keycode resolves through the typed keyboard while a virtual one is main"

# Typing on another keyboard with the same settings makes it main without
# changing a label, so the cache it already built is the one read.
cache_file=$(echo "$tmpdir"/cache/omarchy/keybindings-*.records)
cache_inode=$(stat -c %i "$cache_file")
main_keyboard us,ru , 1 laptop
keybindings >/dev/null
[[ -f $cache_file && $(stat -c %i "$cache_file") == "$cache_inode" ]] ||
  fail "another main keyboard with the same settings reads the same cache" "$(ls "$tmpdir"/cache/omarchy)"
rm "$stub_bin/keyboards"
pass "another main keyboard with the same settings reads the same cache"

# A chord refused for width opens a row of its own, and the next chord tries
# that row rather than reaching back past it and printing out of order.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + A" "Calculator" "omacalc")
$(exec_bind 77 "SUPER SHIFT CTRL ALT + BACKSPACE" "Calculator" "omacalc")
$(exec_bind 64 "SUPER + B" "Calculator" "omacalc")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Calculator$' <<<"$rendered") == 3 )) ||
  fail "a refused chord does not let the next one jump the queue" "$rendered"
pass "a refused chord does not let the next one jump the queue"

# Sharing a row is something Omarchy names an action for, not something two
# chords earn by looking alike. Alt + Tab and Shift + Alt + Tab both read
# "Reveal active window on top" and cycle opposite ways.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + Y" "Zoom in" "omarchy-zoom in")
$(exec_bind 64 "SUPER + Z" "Zoom in" "omarchy-zoom in")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Zoom in$' <<<"$rendered") == 2 )) ||
  fail "an action Omarchy did not name keeps its chords on separate rows" "$rendered"
pass "an action Omarchy did not name keeps its chords on separate rows"

# Even a named action gives up the shared row rather than overrun the column:
# two rows in line beat one that juts out of it.
stub_hyprctl <<BINDS
$(exec_bind 73 "SUPER SHIFT ALT + BACKSPACE" "Calculator" "omacalc")
$(exec_bind 69 "SUPER SHIFT CTRL + BACKSPACE" "Calculator" "omacalc")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Calculator$' <<<"$rendered") == 2 )) ||
  fail "chords too wide to share a row stay on their own" "$rendered"
[[ $(awk -F '→' '{ print length($1) }' <<<"$rendered" | sort -u) == "36" ]] ||
  fail "chords too wide to share a row leave the column alone" "$rendered"
pass "chords too wide to share a row stay on their own"

# A shared label is not a shared action. Two chords that merely read alike have
# to stay apart, or the menu hides one of them behind the other.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(exec_bind 64 "SUPER + X" "Close window" "omarchy-hyprland-window-close-all")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Close window$' <<<"$rendered") == 2 )) ||
  fail "chords with the same label but different actions stay apart" "$rendered"
pass "chords with the same label but different actions stay apart"

# An unresolved Lua bind reports no dispatcher at all, so nothing says the two
# chords run the same thing, whatever their label promises.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + Y" "Close window")
$(lua_bind 64 "SUPER + Z" "Close window")
BINDS

rendered=$(keybindings)
(( $(grep -c '→ Close window$' <<<"$rendered") == 2 )) ||
  fail "chords whose dispatch is unknown stay apart" "$rendered"
pass "chords whose dispatch is unknown stay apart"

# What the menu is expected to pair up, written out here rather than read from
# the script, so dropping an action from the list fails instead of shrinking
# what gets checked.
expected_alternatives=(
  "Close window"
  "Calculator"
  "Toggle scratchpad"
  "Move window to scratchpad"
)

eval "$(sed -n '/^alternative_chord_actions()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"

[[ $(alternative_chord_actions) == "$(printf '%s\n' "${expected_alternatives[@]}")" ]] ||
  fail "the menu pairs up the actions Omarchy means it to" "$(alternative_chord_actions)"
pass "the menu pairs up the actions Omarchy means it to"

# A renamed description would leave an action named here matching nothing, and
# the row it was meant to share would quietly split in two. Only real binds
# count: a commented-out example is not a second chord.
for action in "${expected_alternatives[@]}"; do
  (( $(grep -rhE '^[[:space:]]*o\.bind\(' "$ROOT/default/hypr/bindings" |
       grep -cF ", \"$action\",") >= 2 )) ||
    fail "every action named as having an alternative is bound twice" "$action"
done
pass "every action named as having an alternative is bound twice"

# The terminal bind is a Lua function Hyprland reports only as __lua, so picking
# it from the menu has to run the command the function stands for.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + RETURN" "Terminal")
BINDS

rm -rf "$tmpdir/cache"
keybindings >/dev/null
grep -qP '→ Terminal\texec\tomarchy-launch-terminal$' "$tmpdir"/cache/omarchy/keybindings-*.records ||
  fail "picking the terminal bind from the menu launches a terminal" "$(cat "$tmpdir"/cache/omarchy/keybindings-*.records)"
pass "picking the terminal bind from the menu launches a terminal"

# Rows show their description in the Omarchy language: a numbered one
# matches its %1 pattern, an unknown one stays as written, and the chord
# column and what the row runs never change.
translate_root=$tmpdir/translate-root
mkdir -p "$translate_root/default/i18n/da"
cp "$ROOT/default/i18n/locales.json" "$translate_root/default/i18n/"
printf '{"Terminal": "Terminal (da)", "Switch to workspace %%1": "Skift til arbejdsområde %%1"}\n' >"$translate_root/default/i18n/da/keybindings.json"
echo da >"$tmpdir/translate-language"
eval "$(sed -n '/^translate_binding_records()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"
translated=$(printf '%s\n' \
  $'SUPER + RETURN                      → Terminal\texec\tomarchy-launch-terminal' \
  $'SUPER + 3                           → Switch to workspace 3\tworkspace\t3' \
  $'SUPER + X                           → My own thing\texec\tmy-thing' |
  PATH="$ROOT/bin:$PATH" OMARCHY_PATH=$translate_root OMARCHY_LANGUAGE_FILE=$tmpdir/translate-language translate_binding_records)
expected=$(printf '%s\n' \
  $'SUPER + RETURN                      → Terminal (da)\texec\tomarchy-launch-terminal' \
  $'SUPER + 3                           → Skift til arbejdsområde 3\tworkspace\t3' \
  $'SUPER + X                           → My own thing\texec\tmy-thing')
[[ $translated == "$expected" ]] || fail "keybinding descriptions show in the Omarchy language" "$translated"
pass "keybinding descriptions show in the Omarchy language"
