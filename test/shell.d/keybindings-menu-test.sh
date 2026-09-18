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

inspection_records() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="$tmpdir/cache-inspection" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print-inspection
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

# Priority ordering reads the row. XF86Calculator is outside physical
# inspection, so it no longer shares metadata with the ordinary Super chord;
# the ordinary calculator stays in the body and the media key stays in the
# tail.
stub_hyprctl <<BINDS
$(exec_bind 68 "SUPER CTRL + Q" "Calculator" "omacalc")
$(exec_bind 0 "XF86Calculator" "Calculator" "omacalc")
$(exec_bind 8 "ALT + TAB" "Reveal active window on top" "true")
BINDS

rendered=$(keybindings)
(( $(grep -n 'SUPER CTRL.*→ Calculator$' <<<"$rendered" | cut -d: -f1) <
   $(grep -n '→ Reveal active window on top$' <<<"$rendered" | cut -d: -f1) )) ||
  fail "an excluded alternative does not change where the safe entry ranks" "$rendered"
(( $(grep -c '→ Calculator$' <<<"$rendered") == 2 )) ||
  fail "safe and excluded alternatives keep separate metadata rows" "$rendered"
pass "safe and excluded alternatives keep separate rows"

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

# Physical lookup reads these fields, not the padded display label. Unsafe and
# unsupported rows stay present for ordinary text search.
cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
hl.bind("SUPER + W", hl.dsp.exec_cmd("true"), { description = "Close window" })
hl.bind("SUPER + I", hl.dsp.exec_cmd("true"), { description = "Ignore modifiers", ignore_mods = true })
hl.bind("SUPER + P", hl.dsp.exec_cmd("true"), { description = "Bypass inhibition", dont_inhibit = true })
hl.bind("SUPER + A", hl.dsp.exec_cmd("true"), { desc = "Allow input capture", allow_input_capture = true })
hl.bind("SUPER + M + N", hl.dsp.exec_cmd("true"), { description = "Multi key" })
hl.bind("SUPER + R", hl.dsp.exec_cmd("true"), { description = "Resize submap" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("true"), { description = "Mute" })
-- Empty kind+arg (Lua function) must not collapse TSV fields and demote this.
hl.bind("SUPER + C", function() end, { description = "Universal copy" })
LUA

stub_hyprctl <<'BINDS'
bindd
	modmask: 64
	submap:
	key: W
	keycode: 0
	catchall: false
	description: Close window
	dispatcher: exec
	arg: true

bindd
	modmask: 64
	submap:
	key: I
	keycode: 0
	catchall: false
	description: Ignore modifiers
	dispatcher: exec
	arg: true

bindd
	modmask: 64
	submap:
	key: P
	keycode: 0
	catchall: false
	description: Bypass inhibition
	dispatcher: exec
	arg: true

bindxd
	modmask: 64
	submap:
	key: A
	keycode: 0
	catchall: false
	description: Allow input capture
	dispatcher: exec
	arg: true

bindd
	modmask: 64
	submap:
	key: N
	keycode: 0
	catchall: false
	description: Multi key
	dispatcher: exec
	arg: true

bindd
	modmask: 64
	submap: resize
	key: R
	keycode: 0
	catchall: false
	description: Resize submap
	dispatcher: exec
	arg: true

bindd
	modmask: 0
	submap:
	key: XF86AudioMute
	keycode: 0
	catchall: false
	description: Mute
	dispatcher: exec
	arg: true

bind
	modmask: 64
	submap:
	key: C
	keycode: 0
	catchall: false
	description: Universal copy
	dispatcher: __lua
	arg: 
BINDS

metadata=$(inspection_records)
awk -F '\t' '$1 ~ /Close window$/ && $2 == "SUPER+W" && $3 == "1" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "an ordinary default-submap keyboard binding is inspectable" "$metadata"
awk -F '\t' '$1 ~ /Ignore modifiers$/ && $3 == "0" && $4 == "ignores modifiers" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "ignore-modifier bindings remain searchable but are not inspectable" "$metadata"
awk -F '\t' '$1 ~ /Bypass inhibition$/ && $3 == "0" && $5 == "1" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "inhibitor-bypassing bindings block physical capture for the request" "$metadata"
awk -F '\t' '$1 ~ /Allow input capture$/ && $3 == "0" && $4 == "allowed during input capture" && $5 == "0" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "input-capture bindings are excluded without being mistaken for shortcut-inhibitor bypasses" "$metadata"
awk -F '\t' '$1 ~ /Multi key$/ && $3 == "0" && $4 == "multi-key binding" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "multi-key Lua bindings retain unsupported context omitted by hyprctl" "$metadata"
awk -F '\t' '$1 ~ /Resize submap$/ && $3 == "0" && $4 == "non-default submap" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "non-default-submap bindings retain their context" "$metadata"
awk -F '\t' '$1 ~ /Mute$/ && $3 == "0" && $4 == "media or device key" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "media bindings remain text-searchable but outside physical inspection" "$metadata"
awk -F '\t' '$1 ~ /Universal copy$/ && $2 == "SUPER+C" && $3 == "1" && $4 == "" { found = 1 } END { exit !found }' <<<"$metadata" ||
  fail "Lua function binds stay inspectable when kind and arg are empty" "$metadata"
pass "structured inspection metadata preserves binding safety and context"

# A Lua workspace bind is declared as code:10; the guide resolves that to digit
# 1. Capture of Shift+1 arrives as Key_Exclam + scan 10 and must spell the same
# chord the inspection record carries.
stub_hyprctl <<BINDS
$(lua_bind 65 "SUPER SHIFT + code:10" "Move window to workspace 1")
BINDS

workspace_meta=$(inspection_records)
awk -F '\t' '$1 ~ /Move window to workspace 1$/ && $2 == "SUPER+SHIFT+1" { found = 1 } END { exit !found }' <<<"$workspace_meta" ||
  fail "SUPER+SHIFT+code:10 resolves to inspection chord SUPER+SHIFT+1" "$workspace_meta"

run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const SUPER = 0x10000000
const SHIFT = 0x02000000
const Key_Exclam = 0x21
assertEqual(menu.normalizeChordFromEvent(Key_Exclam, SUPER | SHIFT, 10), 'SUPER+SHIFT+1',
  'scan-code capture matches the SUPER+SHIFT+code:10 inspection chord')
JS
pass "SUPER+SHIFT+code:10 record chord matches scan-code normalize"

# Escape is a named chord key in the inspector model; without it in the
# keybindings allowlist SUPER+ESCAPE was demoted to unsupported and silent.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + ESCAPE" "System menu")
BINDS

escape_meta=$(inspection_records)
awk -F '\t' '$2 == "SUPER+ESCAPE" && $4 == "unsupported keyboard key" { bad = 1 } END { exit bad }' <<<"$escape_meta" ||
  fail "SUPER+ESCAPE was demoted as an unsupported keyboard key" "$escape_meta"
awk -F '\t' '$1 ~ /System menu$/ && $2 == "SUPER+ESCAPE" { found = 1 } END { exit !found }' <<<"$escape_meta" ||
  fail "SUPER+ESCAPE resolves to an inspection chord" "$escape_meta"
pass "SUPER+ESCAPE remains a supported inspection key"
