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
    echo "printf '%s\\n' \"\$*\" >>\"$tmpdir/hyprctl.log\""
    echo 'case "$1" in'
    echo '  binds) cat <<'"'"'BINDS'"'"''
    cat
    echo 'BINDS'
    echo '  ;;'
    echo '  devices) echo "active keymap: English (US)" ;;'
    echo "  getoption) printf 'str: %s\\nset: true\\n' \"\$(cat \"$tmpdir/\${2#input:}\" 2>/dev/null)\" ;;"
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

# The keymap describe-key resolves keycodes through: kb_layout, kb_variant and
# kb_options as Hyprland reports them.
stub_keymap() {
  printf '%s' "$1" >"$tmpdir/kb_layout"
  printf '%s' "${2-}" >"$tmpdir/kb_variant"
  printf '%s' "${3-}" >"$tmpdir/kb_options"
}
stub_keymap us

describe() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print --describe "$@"
}

keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print
}

# Closing a window and toggling the scratchpad are two of the actions Omarchy
# binds twice on purpose. The last bind carries the longest description Omarchy
# ships, which is what puts a row closest to the width the menu allows.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "SUPER + F" "Full screen")
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle scratchpad")
$(exec_bind 73 "SUPER SHIFT ALT + 0" "Move window silently to workspace 10" "true")
BINDS

rendered=$(keybindings)
[[ -n $rendered ]] || fail "the keybindings menu renders with a stubbed Hyprland"

grep -q 'SUPER + F  *→ Full screen' <<<"$rendered" ||
  fail "a chord with no alternative renders on its own" "$rendered"
pass "the keybindings menu renders its entries"

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

# Describe key gets the XKB keycodes of a chord, modifiers included, in the order
# they were pressed: 133 is Super, 50 Shift, 36 Return.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + RETURN" "Terminal")
$(lua_bind 65 "SUPER SHIFT + RETURN" "Browser")
$(exec_bind 64 "SUPER + grave" "Toggle scratchpad" "true")
BINDS

[[ $(describe 133 36) == "SUPER + RETURN → Terminal" ]] ||
  fail "describe key names the chord and what it runs" "$(describe 133 36)"
[[ $(describe 50 133 36) == "SUPER SHIFT + RETURN → Browser" ]] ||
  fail "describe key reads modifiers pressed in any order" "$(describe 50 133 36)"
[[ $(describe 133 49) == "SUPER + ~ → Toggle scratchpad" ]] ||
  fail "describe key names the grave key the way the menu does" "$(describe 133 49)"
[[ $(describe 133 38) == "SUPER + A → Not bound" ]] ||
  fail "describe key says so when a chord is not bound" "$(describe 133 38)"
pass "describe key names the chord and what it runs"

# On a Swedish keyboard the key right of 0 (keycode 20) types plus, and the
# minus key sits by right Shift (keycode 61). A keycode bind has to match its
# key and a keysym bind the key that types it, without the menu's us names for
# keycodes ("code:20" reads as MINUS there) mixing the two up.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + code:20" "Expand window left")
$(lua_bind 64 "SUPER + MINUS" "Zoom out")
BINDS
stub_keymap se

[[ $(describe 133 20) == "SUPER + PLUS → Expand window left" ]] ||
  fail "a keycode bind matches its own key on any layout" "$(describe 133 20)"
[[ $(describe 133 61) == "SUPER + MINUS → Zoom out" ]] ||
  fail "a keysym bind matches the key that types it on the layout" "$(describe 133 61)"
pass "describe key matches keycode and keysym binds on a non-us layout"

# A remapped modifier is what it acts as: with ctrl:swapcaps, Caps Lock
# (keycode 66) is Ctrl and the key labeled Ctrl (37) is not.
stub_hyprctl <<BINDS
$(exec_bind 68 "SUPER CTRL + Q" "Calculator" "omacalc")
BINDS
stub_keymap us "" "ctrl:swapcaps"

[[ $(describe 133 66 24) == "SUPER CTRL + Q → Calculator" ]] ||
  fail "a remapped key counts as the modifier it acts as" "$(describe 133 66 24)"
[[ $(describe 133 37 24) == "SUPER + Q → Not bound" ]] ||
  fail "a key remapped away from a modifier no longer counts as one" "$(describe 133 37 24)"
pass "describe key follows remapped modifiers"

# In the menu, ? closes it and starts describe mode through the Lua function the
# Hyprland config defines, while Enter still runs the row. The stub menu answers
# the way omarchy-menu-select --expect does: the closing key, then the row.
cat >"$stub_bin/omarchy-menu-select" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >"$tmpdir/menu-args"
cat >/dev/null
cat "$tmpdir/menu-reply"
STUB
chmod +x "$stub_bin/omarchy-menu-select"

menu() {
  rm -f "$tmpdir/hyprctl.log"
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings"
}

stub_hyprctl <<BINDS
$(exec_bind 68 "SUPER CTRL + Q" "Calculator" "omacalc")
BINDS
stub_keymap us
row=$(keybindings | grep '→ Calculator$')

printf '?\n%s\n' "$row" >"$tmpdir/menu-reply"
menu
grep -q -- "--expect ?" "$tmpdir/menu-args" ||
  fail "the keybindings menu asks to hear about ?" "$(cat "$tmpdir/menu-args")"
grep -qx "eval o.describe_key()" "$tmpdir/hyprctl.log" ||
  fail "? in the keybindings menu starts describe mode" "$(cat "$tmpdir/hyprctl.log")"
! grep -q "omacalc" "$tmpdir/hyprctl.log" ||
  fail "? in the keybindings menu does not run the row under the cursor" "$(cat "$tmpdir/hyprctl.log")"
pass "? in the keybindings menu starts describe mode"

printf '\n%s\n' "$row" >"$tmpdir/menu-reply"
menu
grep -q "omacalc" "$tmpdir/hyprctl.log" ||
  fail "Enter in the keybindings menu still runs the row" "$(cat "$tmpdir/hyprctl.log")"
! grep -q "describe_key" "$tmpdir/hyprctl.log" ||
  fail "Enter in the keybindings menu does not start describe mode" "$(cat "$tmpdir/hyprctl.log")"
pass "Enter in the keybindings menu still runs the row"
