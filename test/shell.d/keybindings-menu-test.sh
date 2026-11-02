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
    echo '  devices) echo "active keymap: English (US)" ;;'
    echo '  -j) [[ $2 == getoption ]] && cat "'"$stub_bin"'/option-${3#input:}" 2>/dev/null ;;'
    echo 'esac'
  } >"$stub_bin/hyprctl"
  chmod +x "$stub_bin/hyprctl"
}

# Renders the menu, by default the copy without a platform package, caching
# under $tmpdir/cache unless given another directory.
keybindings() {
  env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
    XDG_CACHE_HOME="${2:-$tmpdir/cache}" OMARCHY_PATH="$ROOT" \
    bash "${1:-$menu}" --print
}

# Closing a window is one of the actions Omarchy binds twice on purpose. The
# last bind carries the longest description Omarchy ships, which is what puts a
# row closest to the width the menu allows.
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + W" "Close window")
$(lua_bind 64 "SUPER + Q" "Close window")
$(lua_bind 64 "SUPER + F" "Full screen")
$(lua_bind 64 "SUPER + I" "Switch input language")
$(lua_bind 64 "SUPER + S" "Toggle scratchpad")
$(lua_bind 64 "SUPER + grave" "Toggle Quake console")
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
grep -q 'SUPER + ~  *→ Toggle Quake console' <<<"$rendered" ||
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
$(exec_bind 65 "SUPER SHIFT + Q" "Calculator" "omacalc")
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
	description: Toggle Quake console
	dispatcher: exec
	arg: true
BINDS

rendered=$(keybindings)
grep -q 'SUPER + ~  *→ Toggle Quake console' <<<"$rendered" ||
  fail "a keycode resolves to the symbol printed on the key too" "$rendered"
pass "a keycode resolves to the symbol printed on the key too"

# Resize sits on the two keys right of 0, named by the leading layout rather
# than by US: on JIS they print - and ^, and Shift + - is =, not +.
echo '{"str": "jp"}' >"$stub_bin/option-kb_layout"
stub_hyprctl <<BINDS
$(lua_bind 64 "SUPER + code:20" "Expand window left")
$(lua_bind 64 "SUPER + code:21" "Shrink window left")
BINDS

rendered=$(keybindings)
rm "$stub_bin/option-kb_layout"
grep -q 'SUPER + MINUS  *→ Expand window left' <<<"$rendered" &&
  grep -q 'SUPER + ^  *→ Shrink window left' <<<"$rendered" ||
  fail "a keycode is named by what the leading layout prints on it" "$rendered"
pass "a keycode is named by what the leading layout prints on it"

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

# A renamed description would leave an action the menu pairs up matching
# nothing, and the row it was meant to share would quietly split in two. Only
# real binds count: a commented-out example is not a second chord.
eval "$(sed -n '/^alternative_chord_actions()/,/^}/p' "$ROOT/bin/omarchy-menu-keybindings")"
[[ -n $(alternative_chord_actions) ]] || fail "the menu names the actions it pairs up"
while IFS= read -r action; do
  (( $(grep -rhE '^[[:space:]]*o\.bind\(' "$ROOT/default/hypr/bindings" |
       grep -cF ", \"$action\",") >= 2 )) ||
    fail "every action named as having an alternative is bound twice" "$action"
done < <(alternative_chord_actions)
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

# A plugin that walks the window list while it loads must not wedge the scan,
# and the binds after it must still be recovered from the Lua source.
{
  printf 'for _ in ipairs(hl.get_windows()) do\n  local window = nil\nend\n'
  cat "$home/.config/hypr/hyprland.lua"
} >"$tmpdir/hyprland.lua"
mv "$tmpdir/hyprland.lua" "$home/.config/hypr/hyprland.lua"

rm -rf "$tmpdir/cache"
# A wedged scan is stopped by the menu's own timeout before the Terminal bind,
# which the check below catches; the outer timeout only turns a hang into a fail.
timeout --kill-after=1s 60s env -i PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" \
  XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" \
  bash "$menu" --print >/dev/null 2>&1 ||
  fail "a plugin iterating windows at load time does not wedge the keybindings scan"
grep -qP '→ Terminal\texec\tomarchy-launch-terminal$' "$tmpdir"/cache/omarchy/keybindings-*.records ||
  fail "a plugin iterating windows at load time does not wedge the keybindings scan (it stopped before the Terminal bind)"
pass "a plugin iterating windows at load time does not wedge the keybindings scan"

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
  OMARCHY_PATH=$translate_root OMARCHY_LANGUAGE_FILE=$tmpdir/translate-language translate_binding_records)
expected=$(printf '%s\n' \
  $'SUPER + RETURN                      → Terminal (da)\texec\tomarchy-launch-terminal' \
  $'SUPER + 3                           → Skift til arbejdsområde 3\tworkspace\t3' \
  $'SUPER + X                           → My own thing\texec\tmy-thing')
[[ $translated == "$expected" ]] || fail "keybinding descriptions show in the Omarchy language" "$translated"
pass "keybinding descriptions show in the Omarchy language"

# A platform package names keys the way its keyboards print them. On a MacBook
# XF86MonBrightnessUp/Down are the F2/F1 keys, so without the names the menu
# shows rows like "SHIFT + XF86MonBrightnessUp". The menu reads them from the
# fixed platform root; copies of it read a fixture root with key names, one
# saved with CRLF line ends and blanks around a line, and (the copy above) none.
platform=$tmpdir/platform
mkdir -p "$platform/root" "$platform/crlf"
printf '%s\n' 'XF86MonBrightnessUp F2' 'XF86MonBrightnessDown F1' 'not a line' 'Bad-Sym F3' >"$platform/root/key-names"
printf '%s\r\n' 'XF86MonBrightnessUp F2' '  XF86MonBrightnessDown	F1 ' >"$platform/crlf/key-names"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$platform/with-names" "$platform/root"
platform_root_copy "$ROOT/bin/omarchy-menu-keybindings" "$platform/crlf-names" "$platform/crlf"

stub_hyprctl <<'BINDS'
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

# A run before the platform package arrived leaves a cache that differs from
# the one with key names only in them, so it is the stale cache a cache key
# blind to the names would serve.
names_cache=$tmpdir/cache-names
output=$(keybindings "$menu" "$names_cache")
tr -s ' ' <<<"$output" | grep -qF 'SHIFT + XF86MonBrightnessUp → Keyboard brightness up' ||
  fail "without key names the brightness key keeps its own name" "$output"

output=$(keybindings "$platform/with-names" "$names_cache")

tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F2 → Keyboard brightness up' ||
  fail "SHIFT + XF86MonBrightnessUp renders as SHIFT + F2 with its description" "$output"

tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F1 → Keyboard brightness down' ||
  fail "SHIFT + XF86MonBrightnessDown renders as SHIFT + F1 with its description" "$output"

tr -s ' ' <<<"$output" | grep -qF 'ALT + F2 → Brightness up precise' ||
  fail "modifier combos keep the F-key name (ALT + F2)" "$output"

grep -qF 'XF86MonBrightness' <<<"$output" &&
  fail "raw XF86MonBrightness symbols no longer leak into the menu" "$output"

tr -s ' ' <<<"$output" | grep -qF 'SUPER + Q → Close window' ||
  fail "unrelated bindings render unchanged (SUPER + Q)" "$output"

# The menu runs a chosen row from its cached record, which carries what the
# binding runs.
records=$(cat "$names_cache"/omarchy/keybindings-*.records)
grep -qF 'wtype -k XF86MonBrightnessUp' <<<"$records" && ! grep -qF 'wtype -k F2' <<<"$records" ||
  fail "a key name never changes what a binding runs" "$records"

pass "keybindings menu shows a platform's key names (F1/F2), stale caches ignored"

output=$(keybindings "$platform/crlf-names" "$names_cache")
tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F2 → Keyboard brightness up' && tr -s ' ' <<<"$output" | grep -qF 'SHIFT + F1 → Keyboard brightness down' ||
  fail "key names saved with CRLF line ends and blanks around them still apply" "$output"
pass "keybindings menu reads key names saved with CRLF line ends"

# Without a platform package the keys keep their own names, and a cache made
# with the names is not reused.
output=$(keybindings "$menu" "$names_cache")
tr -s ' ' <<<"$output" | grep -qF 'SHIFT + XF86MonBrightnessUp → Keyboard brightness up' ||
  fail "without key names the brightness key keeps its own name" "$output"
grep -qF 'SHIFT + F2' <<<"$output" && fail "without key names nothing is renamed F2" "$output"
pass "keybindings menu keeps keysym names without a platform package"

# The menu learns about Lua-only binds by running the user's hyprland.lua under
# a stub `hl`. That stub has to survive whatever a config does at load time, or
# the scan hangs (one user config spun a `lua` at 100% CPU for 27 hours after a
# single SUPER+K) or aborts halfway, silently dropping every bind declared after
# the failing line. The scan is run here on its own, lifted out of the menu.
scan=$(awk '/lua (-E - )?<<.LUA.$/ { capture = 1; next } /^LUA$/ { capture = 0 } capture' "$ROOT/bin/omarchy-menu-keybindings")
[[ -n $scan ]] || fail "keybindings menu embeds the Lua bind scan"

scan_home=$tmpdir/scan-home
mkdir -p "$scan_home/.config/hypr"
# No time budget, so a slow machine cannot fail it: a scan that never ended
# would be killed by the timeout, which fails the run on its exit status.
lua_scan() {
  HOME="$scan_home" DEBUG=1 timeout 60 lua -E - <<<"$scan" 2>&1
}

cat >"$scan_home/.config/hypr/hyprland.lua" <<'LUA'
-- Load-time reads a real config does against the compositor state.
for _, monitor in ipairs(hl.get_monitors()) do
  hl.monitor({ output = monitor.name, scale = monitor.scale })
end

local monitor = hl.get_active_monitor()
if not monitor or not monitor.scale or monitor.scale <= 0 then
  error("comparison should not raise")
end
local reserved = monitor.height - monitor.reserved.top * monitor.scale
local label = "monitor " .. monitor.name .. " " .. tostring(monitor.scale)
if #hl.get_workspaces() ~= 0 then
  error("stub collections should be empty")
end
if monitor.scale > 1 then
  error("stub comparisons should be false")
end

hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
hl.bind("SUPER + code:20", hl.dsp.workspace({ name = "special" }), { description = "Lua only bind" })
LUA

output=$(lua_scan) || fail "Lua bind scan exits cleanly on a config that iterates and compares compositor state (output: $output)"
pass "Lua bind scan survives load-time loops, comparisons, and arithmetic over stub state"

[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on stub comparisons ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports exec binds declared after load-time reads (got: $output)"
grep -qF $'64\tLua only bind\tcode:20\tlua\thl.dsp.workspace({ name = "special" })' <<<"$output" || fail "Lua bind scan reports Lua dispatcher binds (got: $output)"
pass "Lua bind scan reports binds declared after load-time compositor reads"

# A loop nothing in the stub can end is stopped inside the scan, well before
# the timeout, and the binds declared ahead of it are still reported.
cat >"$scan_home/.config/hypr/hyprland.lua" <<'LUA'
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
while true do end
LUA

output=$(lua_scan) || fail "Lua bind scan stops a runaway config instead of running until killed (output: $output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan keeps binds declared before a runaway loop (got: $output)"
pass "Lua bind scan stops a runaway config and keeps the binds declared before it"

# Indexing a collection still reads a stand-in: only `ipairs` sees it as empty,
# so a config that names its first or last monitor keeps the binds after it.
cat >"$scan_home/.config/hypr/hyprland.lua" <<'LUA'
local monitors = hl.get_monitors()
local first = monitors[1].name
local last = monitors[#monitors].name
hl.monitor({ output = first, scale = 1 })
hl.monitor({ output = last, scale = 1 })
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
LUA

output=$(lua_scan) || fail "Lua bind scan reads an indexed stub collection (output: $output)"
[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on an indexed stub collection ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports binds declared after indexing a stub collection (got: $output)"
pass "Lua bind scan reads an indexed stub collection and keeps the binds after it"

# A walk by index ends too, and the binds after it are still reported.
cat >"$scan_home/.config/hypr/hyprland.lua" <<'LUA'
local monitors = hl.get_monitors()
local i = 1
while monitors[i] do
  i = i + 1
end
hl.bind("SUPER + K", hl.dsp.exec_cmd("omarchy-menu keybindings"), { description = "Keybindings menu" })
LUA

output=$(lua_scan) || fail "Lua bind scan ends an indexed walk over a stub collection (output: $output)"
[[ $output != *"lua bind scan failed"* ]] || fail "Lua bind scan does not abort on an indexed walk over a stub collection ($output)"
grep -qF $'64\tKeybindings menu\tK\texec\tomarchy-menu keybindings' <<<"$output" || fail "Lua bind scan reports binds declared after an indexed walk (got: $output)"
pass "Lua bind scan ends an indexed walk over a stub collection and keeps the binds after it"
