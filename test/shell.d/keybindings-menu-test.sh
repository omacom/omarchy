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
expected_alternative_ids=(
  "Close window"
  "Calculator"
  "Toggle scratchpad"
  "Move window to scratchpad"
)

eval "$(sed -n '/^alternative_chord_ids()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"

[[ $(alternative_chord_ids) == "$(printf '%s\n' "${expected_alternative_ids[@]}")" ]] ||
  fail "the menu pairs up the actions Omarchy means it to" "$(alternative_chord_ids)"
pass "the menu pairs up the actions Omarchy means it to"

# An id named here that matches no bind would quietly split the row it was meant
# to share. A bind answers to the id it declares, or to its description when it
# declares none, so either spelling counts. Only real binds count too: a
# commented-out example is not a second chord.
for id in "${expected_alternative_ids[@]}"; do
  (( $(grep -rhE '^[[:space:]]*o\.bind\(' "$ROOT/default/hypr/bindings" |
       grep -cF -e ", \"$id\"," -e "id = \"$id\"") >= 2 )) ||
    fail "every action named as having an alternative is bound twice" "$id"
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

# The id decides what pairs up and what sorts where, and then it comes off: a
# cached record is the three fields the menu has always read. Nothing here writes
# an arg with a tab in it, so every record is exactly three fields wide. The shape
# is the only thing an older cache still gets right, though, which is what the
# assertion below is about.
[[ $(awk -F '\t' '{ print NF }' "$tmpdir"/cache/omarchy/keybindings-*.records | sort -u) == "3" ]] ||
  fail "a cached record carries display text, dispatcher, and arg, and no id" \
    "$(cat "$tmpdir"/cache/omarchy/keybindings-*.records)"
pass "a cached record carries display text, dispatcher, and arg, and no id"

# Rows are paired and sorted before they are cached, and the key holds nothing
# that says how. So a cache an earlier version wrote reads back in that version's
# order on a machine whose keymap and binds have not moved, and the version in the
# key is the only thing that retires it. Plant a record under the key the version
# before this one would have written: it has to be ignored rather than served.
rm -f "$tmpdir"/cache/omarchy/keybindings-*.records
stale_key=$(
  {
    printf 'v14\n'
    PATH="$stub_bin:$PATH" hyprctl devices 2>/dev/null | grep -F 'active keymap:'
    PATH="$stub_bin:$PATH" hyprctl binds 2>/dev/null
  } | sha256sum | awk '{ print $1 }'
)
printf 'SUPER + RETURN  → a row an older version cached\tstale\t\n' \
  >"$tmpdir/cache/omarchy/keybindings-$stale_key.records"

! grep -q 'an older version cached' <<<"$(keybindings)" ||
  fail "a cache written before rows paired and sorted by id is not served"
pass "a cache written before rows paired and sorted by id is not served"

# An id and the description beside it only differ once something translates the
# description, so from here on the config declares both. It declares nothing
# else: the shipped config loads far more than these assertions are about, and
# the menu's scan gives up partway through it, so a bind appended to the end of
# it never reaches the scan at all.
cat >"$home/.config/hypr/hyprland.lua" <<LUA
dofile("$ROOT/default/hypr/bootstrap.lua")
require("default.hypr.helpers")

o.bind("SUPER + ALT + W", "關閉視窗", "true", { id = "Close window" })
o.bind("SUPER + ALT + Q", "關閉視窗", "true", { id = "Close window" })
o.bind("SUPER + ALT + RETURN", "終端機", "true", { id = "Terminal" })
LUA

# A description is not what a row is called. The id is, and both chords of a
# paired action carry the same one, so translating the label leaves the pair on
# one row.
stub_hyprctl <<BINDS
$(lua_bind 72 "SUPER ALT + W" "關閉視窗")
$(lua_bind 72 "SUPER ALT + Q" "關閉視窗")
BINDS

rendered=$(keybindings)
grep -q 'SUPER ALT + W / SUPER ALT + Q  *→ 關閉視窗' <<<"$rendered" ||
  fail "a pair whose label is translated still shares a row" "$rendered"
pass "a pair whose label is translated still shares a row"

# Where a row sorts reads the id as well. Translate the terminal and it stays at
# the head of the list. ALT sorts before SUPER, so the untranslated row would
# lead instead if the translated one had lost the place its id gives it.
stub_hyprctl <<BINDS
$(lua_bind 72 "SUPER ALT + RETURN" "終端機")
$(exec_bind 8 "ALT + V" "Zoom in" "omarchy-zoom in")
BINDS

rendered=$(keybindings)
(( $(grep -n '→ 終端機$' <<<"$rendered" | cut -d: -f1) <
   $(grep -n '→ Zoom in$' <<<"$rendered" | cut -d: -f1) )) ||
  fail "a translated label keeps the place its id sorts to" "$rendered"
pass "a translated label keeps the place its id sorts to"

# The tail the menu keeps for media keys is decided by the chord and not by the
# label: XF86AudioMute is a key, and translating "Mute" must not lift its row out
# of that tail. This is the one classification the id deliberately leaves alone.
# Revealing the active window sorts near the end of the list but ahead of the
# media keys, so a row that lost the tail lands above it rather than below.
stub_hyprctl <<BINDS
$(exec_bind 0 "XF86AudioMute" "靜音" "omarchy-audio-output-mute")
$(exec_bind 8 "ALT + TAB" "Reveal active window on top" "true")
BINDS

rendered=$(keybindings)
(( $(grep -n '→ 靜音$' <<<"$rendered" | cut -d: -f1) >
   $(grep -n '→ Reveal active window on top$' <<<"$rendered" | cut -d: -f1) )) ||
  fail "a media key whose label is translated stays in the tail" "$rendered"
pass "a media key whose label is translated stays in the tail"

# An id is written by hand, and the record the parser reads is comma separated
# with only its last field rebuilt out of the leftovers. A comma in an id would
# push the dispatcher into the field behind it, leaving a row that renders and
# then runs nothing.
cat >"$home/.config/hypr/hyprland.lua" <<LUA
dofile("$ROOT/default/hypr/bootstrap.lua")
require("default.hypr.helpers")

o.bind("SUPER + ALT + Z", "Zoom out", "omarchy-zoom out", { id = "Zoom, out" })
LUA

stub_hyprctl <<BINDS
$(lua_bind 72 "SUPER ALT + Z" "Zoom out")
BINDS

rm -rf "$tmpdir/cache"
keybindings >/dev/null
grep -qP '→ Zoom out\texec\tomarchy-zoom out$' "$tmpdir"/cache/omarchy/keybindings-*.records ||
  fail "an id holding a comma still dispatches what its bind declared" \
    "$(cat "$tmpdir"/cache/omarchy/keybindings-*.records)"
pass "an id holding a comma still dispatches what its bind declared"
