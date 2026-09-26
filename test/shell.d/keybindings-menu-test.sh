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

# The Lua bind scan runs the user's config under a fake environment. A config
# that hands it a cyclic table used to recurse the serializer without bound
# and take the session's memory with it (#12852). The scan must fail instead,
# leaving the menu to render the row from hyprctl alone.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
local cyclic = { name = "boom" }
cyclic.self = cyclic
hl.bind("SUPER + O", "Cyclic dispatch", hl.dsp.exec_cmd(cyclic))
LUA

stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + O" "Cyclic dispatch")
BINDS

# The fallback row also appears on an unpatched baseline (the pcall catches
# Lua's stack overflow), so the row alone cannot tell the cycle check from a
# crash being swallowed. The DEBUG diagnostic is what pins the check itself.
debug_err="$tmpdir/cyclic-debug.err"
rendered=$(env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
  XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" DEBUG=1 \
  bash "$ROOT/bin/omarchy-menu-keybindings" --print 2>"$debug_err")
grep -q '→ Cyclic dispatch$' <<<"$rendered" ||
  fail "a cyclic bind argument fails the scan instead of the session" "$rendered"
grep -q 'cyclic table in a bind argument' "$debug_err" ||
  fail "the scan reports why the cyclic bind argument failed" "$(cat "$debug_err")"
pass "a cyclic bind argument fails the scan instead of the session"

# Dispatcher expressions serialize their own arguments back into the
# expression, so a nest of them doubles in size every level. Forty levels
# used to be enough to reach the OOM killer; the size cap now fails the scan
# within its first few hundred bytes.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
local bomb = hl.dsp.exec_cmd("omarchy-notify boom")
for _ = 1, 40 do
  bomb = hl.dsp.exec_cmd(bomb)
end
hl.bind("SUPER + N", "Nested dispatch", bomb)
LUA

stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + N" "Nested dispatch")
BINDS

rendered=$(keybindings)
grep -q '→ Nested dispatch$' <<<"$rendered" ||
  fail "a nested dispatcher expression fails the scan instead of growing" "$rendered"
pass "a nested dispatcher expression fails the scan instead of growing"

# A config that never terminates fails the scan on its instruction budget,
# and the menu still opens on plain hyprctl binds.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
while true do end
LUA

stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + L" "Looping dispatch")
BINDS

rendered=$(keybindings)
grep -q '→ Looping dispatch$' <<<"$rendered" ||
  fail "a config that never terminates still cannot hang the menu" "$rendered"
pass "a config that never terminates still cannot hang the menu"
