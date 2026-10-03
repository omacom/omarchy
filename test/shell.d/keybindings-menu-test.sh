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
    echo 'case "$1" in'
    echo '  binds) cat <<'"'"'BINDS'"'"''
    cat
    echo 'BINDS'
    echo '  ;;'
    echo '  devices) echo "active keymap: English (US)" ;;'
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

keybindings() {
  env -i ${LC_ALL:+LC_ALL="$LC_ALL"} PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
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

# A submap binding fires only inside its mode, so its row leads with the chord
# that enters the mode and sits right under that chord's own row.
mode_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: %s\n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: __lua\n\targ: \n' "$1" "$2" "$3" "$4"
}

stub_hyprctl <<BINDS
$(mode_bind 1 window "SHIFT + H" "Swap left")
$(lua_bind 64 "SUPER + F" "Full screen")
$(mode_bind 0 window "H" "Shrink width")
$(printf 'bind\n\tmodmask: 64\n\tsubmap: \n\tkey: P\n\tkeycode: 0\n\tcatchall: false\n\tdescription: Window mode\n\tdispatcher: submap\n\targ: window\n')
$(mode_bind 0 unbound "ESCAPE" "Leave unbound mode")
BINDS

rendered=$(keybindings)
grep -q '^SUPER + P > H  *→ Shrink width' <<<"$rendered" &&
  grep -q '^SUPER + P > SHIFT + H  *→ Swap left' <<<"$rendered" ||
  fail "a submap binding leads with the chord that enters its mode" "$rendered"
pass "a submap binding leads with the chord that enters its mode"

# The row after the chord that enters a mode, and the one after that, are the
# mode's own bindings, in every collation a desktop might sort them in.
mode_rows_follow_entry() {
  local entry="$1" count="$2" rendered="$3"

  [[ $(grep -A"$count" "^$entry  *→" <<<"$rendered" | tail -n +2 | grep -c "^$entry > ") == "$count" ]]
}

for locale in C en_US.UTF-8; do
  [[ $locale == "C" ]] || locale -a 2>/dev/null | grep -qix 'en_US.utf-\?8' || continue
  rendered=$(LC_ALL=$locale keybindings)
  mode_rows_follow_entry "SUPER + P" 2 "$rendered" ||
    fail "the bindings of a mode sort right under the chord that enters it ($locale)" "$rendered"
done
pass "the bindings of a mode sort right under the chord that enters it"

grep -q '^unbound > ESCAPE  *→ Leave unbound mode' <<<"$rendered" ||
  fail "a mode with no known entry chord is named instead" "$rendered"
pass "a mode with no known entry chord is named instead"

# A bind that enters a mode, optionally from inside another mode.
submap_bind() {
  printf 'bind\n\tmodmask: %s\n\tsubmap: %s\n\tkey: %s\n\tkeycode: 0\n\tcatchall: false\n\tdescription: %s\n\tdispatcher: submap\n\targ: %s\n' "$1" "${5:-}" "$2" "$3" "$4"
}

# The prefix names the entry chord exactly as that chord's own row does, so a
# second modifier or a renamed key still finds the row to sort under.
stub_hyprctl <<BINDS
$(mode_bind 0 window "H" "Shrink width")
$(submap_bind 65 "P" "Window mode" window)
$(mode_bind 0 resize "L" "Grow width")
$(submap_bind 64 "grave" "Resize mode" resize)
BINDS

rendered=$(keybindings)
mode_rows_follow_entry "SUPER SHIFT + P" 1 "$rendered" &&
  mode_rows_follow_entry "SUPER + ~" 1 "$rendered" ||
  fail "a mode is named the way the row of the chord entering it is" "$rendered"
pass "a mode is named the way the row of the chord entering it is"

# A mode entered from inside another names the whole sequence, and a keycode
# reads as its key in both the entry chord and the binding's own.
stub_hyprctl <<BINDS
$(submap_bind 64 "code:33" "Window mode" window)
$(mode_bind 0 window "code:43" "Shrink width")
$(submap_bind 0 "R" "Resize mode" resize window)
$(mode_bind 0 resize "L" "Grow width")
BINDS

rendered=$(keybindings)
mode_rows_follow_entry "SUPER + P" 3 "$rendered" &&
  grep -q '^SUPER + P > H  *→ Shrink width' <<<"$rendered" &&
  grep -q '^SUPER + P > R > L  *→ Grow width' <<<"$rendered" ||
  fail "a mode inside a mode is named by every chord that leads to it" "$rendered"
pass "a mode inside a mode is named by every chord that leads to it"

# A chord that comes back to a mode from another one does not name it, even
# when Hyprland reports it before the chord that enters from outside.
stub_hyprctl <<BINDS
$(submap_bind 0 "ESCAPE" "Back to window mode" window resize)
$(submap_bind 0 "ESCAPE" "Back to resize mode" resize detail)
$(submap_bind 0 "D" "Detail mode" detail resize)
$(submap_bind 64 "P" "Window mode" window)
$(submap_bind 0 "R" "Resize mode" resize window)
$(mode_bind 0 resize "L" "Grow width")
BINDS

rendered=$(keybindings)
mode_rows_follow_entry "SUPER + P" 5 "$rendered" &&
  grep -q '^SUPER + P > R > ESCAPE  *→ Back to window mode' <<<"$rendered" &&
  grep -q '^SUPER + P > R > D > ESCAPE  *→ Back to resize mode' <<<"$rendered" &&
  grep -q '^SUPER + P > R > L  *→ Grow width' <<<"$rendered" ||
  fail "a mode is named by the chord that enters it from outside every mode" "$rendered"
pass "a mode is named by the chord that enters it from outside every mode"

# An action Omarchy pairs up keeps a binding inside a mode on its own row, since
# its chord is not an alternative to the global one.
stub_hyprctl <<BINDS
$(exec_bind 64 "SUPER + W" "Close window" "true")
$(printf 'bind\n\tmodmask: 0\n\tsubmap: window\n\tkey: Q\n\tkeycode: 0\n\tcatchall: false\n\tdescription: Close window\n\tdispatcher: exec\n\targ: true\n')
$(submap_bind 64 "P" "Window mode" window)
BINDS

rendered=$(keybindings)
grep -q '^SUPER + W  *→ Close window' <<<"$rendered" &&
  mode_rows_follow_entry "SUPER + P" 1 "$rendered" ||
  fail "a binding inside a mode never shares a row with a global chord" "$rendered"
pass "a binding inside a mode never shares a row with a global chord"

# A binding whose description Omarchy ranks on its own still stays with its mode.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + F" "Full screen")
$(mode_bind 0 window "H" "Shrink width")
$(mode_bind 0 window "L" "Focus on right window")
$(submap_bind 64 "P" "Window mode" window)
BINDS

rendered=$(keybindings)
mode_rows_follow_entry "SUPER + P" 2 "$rendered" ||
  fail "every binding of a mode ranks with the chord that enters it" "$rendered"
pass "every binding of a mode ranks with the chord that enters it"

# A Lua config can move the chord that enters a mode. Only the chord Hyprland
# still reports names it, not one the config bound and later unbound.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")
require("default.hypr.helpers")
o.bind("SUPER + P", "Window mode", hl.dsp.submap("window"))
hl.unbind("SUPER + P")
o.bind("SUPER + M", "Window mode", hl.dsp.submap("window"))
LUA

stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + M" "Window mode")
$(mode_bind 0 window "H" "Shrink width")
BINDS

rm -rf "$tmpdir/cache"
rendered=$(keybindings)
mode_rows_follow_entry "SUPER + M" 1 "$rendered" &&
  ! grep -q '^SUPER + P > ' <<<"$rendered" ||
  fail "a mode entered by a Lua bind is named by the chord that enters it now" "$rendered"
pass "a mode entered by a Lua bind is named by the chord that enters it now"
